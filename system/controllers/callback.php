<?php

/**
 *  PHP Mikrotik Billing (https://github.com/hotspotbilling/phpnuxbill/)
 *  by https://t.me/ibnux
 **/


$action = $routes['1'];


if (file_exists($PAYMENTGATEWAY_PATH . DIRECTORY_SEPARATOR . $action . '.php')) {
    include $PAYMENTGATEWAY_PATH . DIRECTORY_SEPARATOR . $action . '.php';
    if (function_exists($action . '_payment_notification')) {
        run_hook('callback_payment_notification'); #HOOK
        call_user_func($action . '_payment_notification');
        
        // Auto-generate voucher for guest purchases after payment confirmation
        // This runs after the payment gateway has updated the transaction status
        run_hook('after_payment_notification'); #HOOK
        
        // Check if there are any newly paid guest transactions that need vouchers
        $recentPaidTransactions = ORM::for_table('tbl_payment_gateway')
            ->where('status', 2) // Paid status
            ->where_raw("(pg_paid_response IS NULL OR pg_paid_response = '' OR pg_paid_response NOT LIKE '%voucher_code%')")
            ->where_raw("created_date >= DATE_SUB(NOW(), INTERVAL 1 HOUR)") // Only check recent transactions
            ->find_many();
        
        foreach ($recentPaidTransactions as $trx) {
            // Check if this is a guest purchase
            if (GuestPurchase::isGuestTransaction($trx)) {
                // Get guest email and phone from transaction
                $guestEmail = GuestPurchase::getGuestEmail($trx);
                $guestPhone = GuestPurchase::getGuestPhoneNumber($trx);
                
                // Generate voucher
                _log("Callback: Generating voucher for guest transaction {$trx['id']}");
                $voucherCode = GuestPurchase::generateVoucher($trx, $guestEmail, $guestPhone);
                
                if ($voucherCode) {
                    // Update transaction with voucher info
                    $pg_response = json_decode($trx['pg_paid_response'], true) ?: [];
                    $pg_response['voucher_code'] = $voucherCode;
                    $pg_response['voucher_generated_at'] = date('Y-m-d H:i:s');
                    
                    $trx->pg_paid_response = json_encode($pg_response);
                    $trx->save();
                    
                    _log("Callback: Voucher {$voucherCode} generated and saved for transaction {$trx['id']}");
                } else {
                    _log("Callback Error: Failed to generate voucher for guest transaction {$trx['id']}");
                }
            }
        }
        
        die();
    }
}

header('HTTP/1.1 404 Not Found');
echo 'Not Found';
