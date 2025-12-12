<?php

/**
 *  PHP Mikrotik Billing (https://github.com/hotspotbilling/phpnuxbill/)
 *  Guest Purchase Controller - Allows guests to buy packages without registration
 **/

// Guest users can access this controller
// No login required

$action = $routes['1'] ?? 'order';
$sub_action = $routes['2'] ?? 'package';

switch ($action) {
    case 'order':
        switch ($sub_action) {
            case 'package':
                // Display available packages for guest purchase
                run_hook('guest_view_packages'); #HOOK

                // Fetch enabled plans (Hotspot only for guest purchase)
                $plans = ORM::for_table('tbl_plans')
                    ->left_outer_join('tbl_bandwidth', array('tbl_plans.id_bw', '=', 'tbl_bandwidth.id'))
                    ->select('tbl_plans.*')
                    ->select('tbl_bandwidth.name_bw', 'name_bw')
                    ->where('tbl_plans.enabled', '1')
                    ->where('tbl_plans.type', 'Hotspot')
                    ->order_by_asc('tbl_plans.price')
                    ->find_many();

                $ui->assign('_title', Lang::T('Buy Internet Package'));
                $ui->assign('plans', $plans);
                $ui->assign('csrf_token', Csrf::generateAndStoreToken());
                $ui->display('customer/guest-packages.tpl');
                break;

            case 'gateway':
                // Select payment gateway and collect email
                $router_id = $routes['3'] ?? '';
                $plan_id = $routes['4'] ?? '';

                try {
                    if (empty($plan_id) || !is_numeric($plan_id)) {
                        _log('Guest purchase error: Invalid plan ID provided');
                        r2(getUrl('login'), 'e', Lang::T('Invalid plan selected. Please try again.'));
                    }

                    $plan = ORM::for_table('tbl_plans')
                        ->left_outer_join('tbl_bandwidth', array('tbl_plans.id_bw', '=', 'tbl_bandwidth.id'))
                        ->select('tbl_plans.*')
                        ->select('tbl_bandwidth.name_bw', 'name_bw')
                        ->where('tbl_plans.id', $plan_id)
                        ->where('tbl_plans.enabled', '1')
                        ->find_one();

                    if (!$plan) {
                        _log("Guest purchase error: Plan ID {$plan_id} not found or disabled");
                        r2(getUrl('login'), 'e', Lang::T('The selected plan is not available. Please choose another plan.'));
                    }

                    if (empty($router_id) || !is_numeric($router_id)) {
                        _log('Guest purchase error: Invalid router ID provided');
                        r2(getUrl('login'), 'e', Lang::T('Invalid router selected. Please try again.'));
                    }

                    $router = ORM::for_table('tbl_routers')
                        ->where('id', $router_id)
                        ->where('enabled', '1')
                        ->find_one();

                    if (!$router) {
                        _log("Guest purchase error: Router ID {$router_id} not found or disabled");
                        r2(getUrl('login'), 'e', Lang::T('The selected router is not available. Please contact support.'));
                    }

                    // Check for existing unpaid transaction from this session/email
                    $email = _req('email');

                    // Calculate total price
                    $plan_price = $plan['price'];
                    $tax_rate = $config['tax_rate'] ?? 0;
                    $tax_amount = 0;

                    if ($config['enable_tax'] == 'yes' && $tax_rate > 0) {
                        $tax_amount = Package::tax($plan_price, $tax_rate);
                    }

                    $total_price = $plan_price + $tax_amount;

                    // Get enabled payment gateways
                    $payment_gateways = explode(',', $config['payment_gateway'] ?? '');
                    $enabled_gateways = [];

                    foreach ($payment_gateways as $gateway) {
                        $gateway = trim($gateway);
                        if (!empty($gateway) && file_exists('system/paymentgateway/' . $gateway . '.php')) {
                            $enabled_gateways[] = $gateway;
                        }
                    }

                    if (empty($enabled_gateways)) {
                        _log('Guest purchase error: No payment gateways configured');
                        r2(getUrl('login'), 'e', Lang::T('Payment system is currently unavailable. Please contact support.'));
                    }

                    $ui->assign('_title', Lang::T('Select Payment Method'));
                    $ui->assign('plan', $plan);
                    $ui->assign('router', $router);
                    $ui->assign('plan_price', $plan_price);
                    $ui->assign('tax_amount', $tax_amount);
                    $ui->assign('total_price', $total_price);
                    $ui->assign('gateways', $enabled_gateways);
                    $ui->assign('csrf_token', Csrf::generateAndStoreToken());
                    $ui->display('customer/guest-gateway.tpl');

                } catch (Exception $e) {
                    _log('Guest purchase gateway error: ' . $e->getMessage());
                    r2(getUrl('login'), 'e', Lang::T('An error occurred while loading the payment page. Please try again.'));
                }
                break;

            case 'buy':
                // Create transaction and redirect to payment gateway
                $router_id = $routes['3'] ?? '';
                $plan_id = $routes['4'] ?? '';

                try {
                    $csrf_token = _post('csrf_token');
                    if (!Csrf::check($csrf_token)) {
                        _log('Guest purchase error: Invalid CSRF token');
                        r2(getUrl('login'), 'e', Lang::T('Security token expired. Please refresh and try again.'));
                    }

                    $email = _post('email');
                    $phonenumber = _post('phonenumber');
                    $gateway = _post('gateway');

                    // Validate email
                    if (empty($email)) {
                        _log('Guest purchase error: Email is required but not provided');
                        r2(getUrl('guest/order/gateway/' . $router_id . '/' . $plan_id), 'e', Lang::T('Email address is required. Please enter your email.'));
                    }

                    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                        _log("Guest purchase error: Invalid email format - {$email}");
                        r2(getUrl('guest/order/gateway/' . $router_id . '/' . $plan_id), 'e', Lang::T('Invalid email format. Please enter a valid email address (e.g., name@example.com).'));
                    }

                    // Validate phone number
                    if (empty($phonenumber)) {
                        _log('Guest purchase error: Phone number is required but not provided');
                        r2(getUrl('guest/order/gateway/' . $router_id . '/' . $plan_id), 'e', Lang::T('Phone number is required for SMS delivery. Please enter your phone number.'));
                    }

                    if (empty($gateway)) {
                        _log('Guest purchase error: Payment method not selected');
                        r2(getUrl('guest/order/gateway/' . $router_id . '/' . $plan_id), 'e', Lang::T('Please select a payment method to continue.'));
                    }

                    // Validate gateway exists
                    $gateway_file = 'system/paymentgateway/' . $gateway . '.php';
                    if (!file_exists($gateway_file)) {
                        _log("Guest purchase error: Payment gateway file not found - {$gateway}");
                        r2(getUrl('guest/order/gateway/' . $router_id . '/' . $plan_id), 'e', Lang::T('The selected payment method is not available. Please choose another method.'));
                    }

                    $plan = ORM::for_table('tbl_plans')
                        ->where('id', $plan_id)
                        ->where('enabled', '1')
                        ->find_one();

                    if (!$plan) {
                        _log("Guest purchase error: Plan ID {$plan_id} not found or disabled during transaction creation");
                        r2(getUrl('login'), 'e', Lang::T('The selected plan is no longer available. Please choose another plan.'));
                    }

                    $router = ORM::for_table('tbl_routers')
                        ->where('id', $router_id)
                        ->where('enabled', '1')
                        ->find_one();

                    if (!$router) {
                        _log("Guest purchase error: Router ID {$router_id} not found or disabled during transaction creation");
                        r2(getUrl('login'), 'e', Lang::T('Network router is unavailable. Please contact support.'));
                    }

                    // Calculate total price
                    $plan_price = $plan['price'];
                    $tax_rate = $config['tax_rate'] ?? 0;
                    $tax_amount = 0;

                    if ($config['enable_tax'] == 'yes' && $tax_rate > 0) {
                        $tax_amount = Package::tax($plan_price, $tax_rate);
                    }

                    $total_price = $plan_price + $tax_amount;

                    // Create payment gateway transaction
                    $trx = ORM::for_table('tbl_payment_gateway')->create();
                    $trx->username = 'GUEST-' . time() . rand(1000, 9999); // Temporary guest identifier
                    $trx->gateway = $gateway;
                    $trx->plan_id = $plan['id'];
                    $trx->plan_name = $plan['name_plan'];
                    $trx->routers_id = $router['id'];
                    $trx->routers = $router['name'];
                    $trx->price = $total_price;
                    $trx->tax_rate = $tax_rate;
                    $trx->tax_amount = $tax_amount;
                    $trx->pg_url_payment = '-';
                    $trx->gateway_trx_id = '';
                    $trx->payment_method = '';
                    $trx->payment_channel = '';
                    $trx->created_date = date('Y-m-d H:i:s');
                    $trx->expired_date = date('Y-m-d H:i:s', strtotime('+6 hours'));
                    $trx->pg_request = json_encode(['email' => $email, 'phonenumber' => $phonenumber, 'guest_purchase' => true]);
                    $trx->status = 1; // Unpaid
                    $trx->save();

                    _log("Guest purchase: Transaction {$trx->id()} created for email {$email}, phone {$phonenumber}, plan {$plan['name_plan']}");

                    run_hook('guest_create_transaction'); #HOOK

                    // Load payment gateway and create transaction
                    require_once $gateway_file;

                    // Create pseudo user for gateway
                    $guest_user = [
                        'id' => 0,
                        'username' => $trx['username'],
                        'fullname' => 'Guest Customer',
                        'email' => $email,
                        'phonenumber' => $phonenumber
                    ];

                    $create_function = $gateway . '_create_transaction';
                    if (function_exists($create_function)) {
                        _log("Guest purchase: Initiating payment with {$gateway} for transaction {$trx->id()}");
                        $create_function($trx, $guest_user);
                    } else {
                        _log("Guest purchase error: Payment gateway function {$create_function} not found");
                        r2(getUrl('guest/order/view/' . $trx->id()), 'e', Lang::T('Payment gateway is not configured properly. Please contact support.'));
                    }

                } catch (Exception $e) {
                    _log('Guest purchase buy error: ' . $e->getMessage());
                    r2(getUrl('login'), 'e', Lang::T('An error occurred while processing your order. Please try again or contact support.'));
                }
                break;

            case 'view':
                // View transaction status
                $trx_id = $routes['3'] ?? '';
                $check = $routes['4'] ?? '';

                try {
                    if (empty($trx_id) || !is_numeric($trx_id)) {
                        _log('Guest purchase error: Invalid transaction ID provided');
                        r2(getUrl('login'), 'e', Lang::T('Invalid transaction reference. Please check your link.'));
                    }

                    $trx = ORM::for_table('tbl_payment_gateway')->find_one($trx_id);

                    if (!$trx) {
                        _log("Guest purchase error: Transaction ID {$trx_id} not found");
                        r2(getUrl('login'), 'e', Lang::T('Transaction not found. Please verify your transaction reference.'));
                    }

                    // Manual payment check
                    if ($check == 'check') {
                        $gateway = $trx['gateway'];
                        $gateway_file = 'system/paymentgateway/' . $gateway . '.php';

                        if (file_exists($gateway_file)) {
                            require_once $gateway_file;
                            $status_function = $gateway . '_get_status';

                            if (function_exists($status_function)) {
                                _log("Guest purchase: Checking payment status for transaction {$trx_id} via {$gateway}");
                                try {
                                    $status_function($trx, null);
                                } catch (Exception $e) {
                                    _log("Guest purchase error: Payment status check failed - " . $e->getMessage());
                                    r2(getUrl('guest/order/view/' . $trx_id), 'w', Lang::T('Unable to verify payment status. Please try again later.'));
                                }
                            } else {
                                _log("Guest purchase error: Payment gateway status function {$status_function} not found");
                                r2(getUrl('guest/order/view/' . $trx_id), 'w', Lang::T('Payment verification is temporarily unavailable.'));
                            }
                        } else {
                            _log("Guest purchase error: Payment gateway file not found - {$gateway}");
                            r2(getUrl('guest/order/view/' . $trx_id), 'w', Lang::T('Payment gateway configuration issue. Please contact support.'));
                        }

                        // Reload transaction
                        $trx = ORM::for_table('tbl_payment_gateway')->find_one($trx_id);
                    }

                    // Get voucher if payment is successful
                    $voucher = null;
                    if ($trx['status'] == 2) {
                        // Payment successful, find voucher
                        $pg_response = json_decode($trx['pg_paid_response'], true);
                        if (isset($pg_response['voucher_code'])) {
                            $voucher = ORM::for_table('tbl_voucher')
                                ->where('code', $pg_response['voucher_code'])
                                ->find_one();

                            if (!$voucher) {
                                _log("Guest purchase warning: Voucher code {$pg_response['voucher_code']} not found for paid transaction {$trx_id}");
                            }
                        } else {
                            _log("Guest purchase warning: No voucher code in response for paid transaction {$trx_id}");
                        }
                    }

                    $ui->assign('_title', Lang::T('Transaction Status'));
                    $ui->assign('trx', $trx);
                    $ui->assign('voucher', $voucher);
                    $ui->assign('csrf_token', Csrf::generateAndStoreToken());
                    $ui->display('customer/guest-transaction-view.tpl');

                } catch (Exception $e) {
                    _log('Guest purchase view error: ' . $e->getMessage());
                    r2(getUrl('login'), 'e', Lang::T('An error occurred while loading transaction details. Please try again.'));
                }
                break;

            default:
                r2(getUrl('login'));
                break;
        }
        break;

    default:
        r2(getUrl('login'));
        break;
}
