<?php

/**
 *  PHP Mikrotik Billing (https://github.com/hotspotbilling/phpnuxbill/)
 *  Guest Purchase Helper - Auto-generate vouchers for guest purchases
 **/

class GuestPurchase
{
    /**
     * Auto-generate a voucher for guest purchase after successful payment
     *
     * @param object $transaction - Payment gateway transaction record
     * @param string $email - Guest email address
     * @param string $phonenumber - Guest phone number (optional)
     * @return string|false - Voucher code or false on failure
     */
    public static function generateVoucher($transaction, $email = '', $phonenumber = '')
    {
        global $config;

        try {
            // Validate transaction
            if (!$transaction || !isset($transaction['id'])) {
                _log("GuestPurchase Error: Invalid transaction object provided");
                Message::sendTelegram("Guest Purchase Failed: Invalid transaction object");
                return false;
            }

            // Get plan details
            $plan = ORM::for_table('tbl_plans')
                ->where('id', $transaction['plan_id'])
                ->find_one();

            if (!$plan) {
                _log("GuestPurchase Error: Plan ID {$transaction['plan_id']} not found for transaction {$transaction['id']}");
                Message::sendTelegram("Guest Purchase Failed: Plan not found for transaction {$transaction['id']}");
                return false;
            }

            // Generate unique voucher code
            $code_length = 12; // Default voucher code length
            $prefix = $config['voucher_prefix'] ?? 'GT-'; // Guest voucher prefix

            // Generate unique code
            $code = self::generateUniqueCode($code_length);
            $voucher_code = $prefix . $code;

            // Check if voucher with this code already exists
            $existing = ORM::for_table('tbl_voucher')
                ->where('code', $voucher_code)
                ->find_one();

            // If exists, regenerate
            $max_attempts = 5;
            $attempts = 0;
            while ($existing && $attempts < $max_attempts) {
                $code = self::generateUniqueCode($code_length);
                $voucher_code = $prefix . $code;
                $existing = ORM::for_table('tbl_voucher')
                    ->where('code', $voucher_code)
                    ->find_one();
                $attempts++;
            }

            if ($existing) {
                _log("GuestPurchase Error: Failed to generate unique voucher code after {$max_attempts} attempts for transaction {$transaction['id']}");
                Message::sendTelegram("Guest Purchase Failed: Could not generate unique voucher code after {$max_attempts} attempts");
                return false;
            }

            // Create voucher record
            try {
                $voucher = ORM::for_table('tbl_voucher')->create();
                $voucher->type = $plan['type'];
                $voucher->routers = $transaction['routers'];
                $voucher->id_plan = $plan['id'];
                $voucher->code = $voucher_code;
                $voucher->user = '0'; // Guest voucher (no user assigned)
                $voucher->status = '0'; // Unused
                $voucher->generated_by = 0; // System generated
                $voucher->created_at = date('Y-m-d H:i:s');
                $voucher->validity = $plan['validity'];
                $voucher->validity_unit = $plan['validity_unit'];
                $voucher->price = $transaction['price'];
                $voucher->save();

                _log("GuestPurchase Success: Voucher {$voucher_code} generated for transaction {$transaction['id']}");

            } catch (Exception $e) {
                _log("GuestPurchase Error: Failed to save voucher to database - " . $e->getMessage());
                Message::sendTelegram("Guest Purchase Failed: Database error creating voucher for transaction {$transaction['id']}: " . $e->getMessage());
                return false;
            }

            // Send voucher via email if email is provided
            if (!empty($email) && filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $emailSent = self::sendVoucherEmail($voucher, $plan, $email, $transaction);
                if (!$emailSent) {
                    _log("GuestPurchase Warning: Voucher {$voucher_code} created but email delivery failed to {$email}");
                }
            } else {
                _log("GuestPurchase Warning: No valid email provided for voucher {$voucher_code}, email notification skipped");
            }

            // Send voucher via SMS if phone number is provided
            if (!empty($phonenumber)) {
                $smsSent = self::sendVoucherSMS($voucher, $plan, $phonenumber, $transaction);
                if (!$smsSent) {
                    _log("GuestPurchase Warning: Voucher {$voucher_code} created but SMS delivery failed to {$phonenumber}");
                }
            } else {
                _log("GuestPurchase Warning: No phone number provided for voucher {$voucher_code}, SMS notification skipped");
            }

            return $voucher_code;

        } catch (Exception $e) {
            _log("GuestPurchase Critical Error: Unexpected error generating voucher - " . $e->getMessage());
            Message::sendTelegram("Guest Purchase Critical Error: " . $e->getMessage() . " for transaction " . ($transaction['id'] ?? 'unknown'));
            return false;
        }
    }

    /**
     * Generate a unique alphanumeric code
     * SECURITY: Uses cryptographically secure random number generation
     *
     * @param int $length - Length of the code
     * @return string - Generated code
     */
    private static function generateUniqueCode($length = 12)
    {
        $characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $code = '';
        $max = strlen($characters) - 1;

        // SECURITY FIX: Use random_int() instead of rand() for cryptographically secure randomness
        try {
            for ($i = 0; $i < $length; $i++) {
                $code .= $characters[random_int(0, $max)];
            }
        } catch (Exception $e) {
            _log("GuestPurchase Security Error: Failed to generate cryptographically secure random code - " . $e->getMessage());
            // Fallback to less secure method if random_int fails (should never happen in PHP 7+)
            for ($i = 0; $i < $length; $i++) {
                $code .= $characters[mt_rand(0, $max)];
            }
        }

        return $code;
    }

    /**
     * Send voucher code to guest email
     *
     * @param object $voucher - Voucher record
     * @param object $plan - Plan record
     * @param string $email - Guest email address
     * @param object $transaction - Transaction record
     * @return bool - Success status
     */
    private static function sendVoucherEmail($voucher, $plan, $email, $transaction)
    {
        global $config;

        try {
            $subject = Lang::T('Your Internet Voucher Code') . ' - ' . $config['CompanyName'];

            $message = "
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #5cb85c; color: white; padding: 20px; text-align: center; }
        .content { background: #f9f9f9; padding: 20px; margin: 20px 0; }
        .voucher-code {
            background: #fff;
            border: 2px dashed #5cb85c;
            padding: 20px;
            text-align: center;
            font-size: 24px;
            font-weight: bold;
            letter-spacing: 3px;
            margin: 20px 0;
            font-family: monospace;
        }
        .details { background: #fff; padding: 15px; margin: 10px 0; }
        .footer { text-align: center; padding: 20px; font-size: 12px; color: #777; }
        .instructions { background: #e7f4e7; border-left: 4px solid #5cb85c; padding: 15px; margin: 15px 0; }
        .instructions ol { margin: 10px 0; padding-left: 20px; }
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>{$config['CompanyName']}</h1>
            <p>Thank you for your purchase!</p>
        </div>

        <div class='content'>
            <h2>Your Internet Access Voucher</h2>
            <p>Dear Customer,</p>
            <p>Your payment has been confirmed. Below is your voucher code to access the internet.</p>

            <div class='voucher-code'>
                {$voucher['code']}
            </div>

            <div class='details'>
                <h3>Package Details:</h3>
                <table style='width: 100%;'>
                    <tr>
                        <td><strong>Package Name:</strong></td>
                        <td>{$plan['name_plan']}</td>
                    </tr>
                    <tr>
                        <td><strong>Validity:</strong></td>
                        <td>{$voucher['validity']} {$voucher['validity_unit']}</td>
                    </tr>
                    <tr>
                        <td><strong>Amount Paid:</strong></td>
                        <td>" . Lang::moneyFormat($transaction['price']) . "</td>
                    </tr>
                    <tr>
                        <td><strong>Transaction Date:</strong></td>
                        <td>{$transaction['created_date']}</td>
                    </tr>
                </table>
            </div>

            <div class='instructions'>
                <h3>How to Activate Your Voucher:</h3>
                <ol>
                    <li>Connect to the WiFi network</li>
                    <li>Open your web browser - you will be redirected to the login page</li>
                    <li>Enter the voucher code shown above</li>
                    <li>Click 'Activate' and enjoy your internet access!</li>
                </ol>
            </div>

            <p><strong>Note:</strong> This voucher is valid for one-time use only. Please keep this email for your records.</p>
        </div>

        <div class='footer'>
            <p>&copy; " . date('Y') . " {$config['CompanyName']}. All rights reserved.</p>
            <p>This is an automated email. Please do not reply to this message.</p>
        </div>
    </div>
</body>
</html>
            ";

            // Validate email before sending
            if (empty($email)) {
                _log("GuestPurchase Error: Cannot send email - email address is empty");
                return false;
            }

            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                _log("GuestPurchase Error: Invalid email format - {$email}");
                return false;
            }

            // Send email using Message class
            try {
                $result = Message::sendEmail($email, $subject, $message);

                if ($result) {
                    _log("GuestPurchase Success: Voucher email sent to {$email} for voucher {$voucher['code']}");
                    return true;
                } else {
                    _log("GuestPurchase Error: Email gateway returned false for {$email}");
                    Message::sendTelegram("Guest Purchase Warning: Failed to send email to {$email} for voucher {$voucher['code']}");
                    return false;
                }

            } catch (Exception $e) {
                _log("GuestPurchase Error: Email delivery exception - " . $e->getMessage());
                Message::sendTelegram("Guest Purchase Email Error: " . $e->getMessage() . " for email {$email}");
                return false;
            }

        } catch (Exception $e) {
            _log("GuestPurchase Error: Unexpected error sending voucher email - " . $e->getMessage());
            Message::sendTelegram("Guest Purchase Email Critical Error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Check if a transaction is a guest purchase
     *
     * @param object $transaction - Transaction record
     * @return bool - True if guest purchase
     */
    public static function isGuestTransaction($transaction)
    {
        // Check if username starts with GUEST-
        if (strpos($transaction['username'], 'GUEST-') === 0) {
            return true;
        }

        // Check pg_request for guest_purchase flag
        $pg_request = json_decode($transaction['pg_request'], true);
        if (isset($pg_request['guest_purchase']) && $pg_request['guest_purchase'] === true) {
            return true;
        }

        // Check if user_id is 0
        if (isset($transaction['user_id']) && $transaction['user_id'] == 0) {
            return true;
        }

        return false;
    }

    /**
     * Send voucher code to guest via SMS
     *
     * @param object $voucher - Voucher record
     * @param object $plan - Plan record
     * @param string $phonenumber - Guest phone number
     * @param object $transaction - Transaction record
     * @return bool - Success status
     */
    private static function sendVoucherSMS($voucher, $plan, $phonenumber, $transaction)
    {
        global $config;

        try {
            // Validate phone number
            if (empty($phonenumber)) {
                _log("GuestPurchase Error: Cannot send SMS - phone number is empty");
                return false;
            }

            // Check if SMS is configured
            if (empty($config['sms_url'])) {
                _log("GuestPurchase Error: SMS gateway not configured, cannot send voucher SMS to {$phonenumber}");
                Message::sendTelegram("Guest Purchase Warning: SMS not sent - gateway not configured");
                return false;
            }

            $message = $config['CompanyName'] . "\n";
            $message .= Lang::T('Your Internet Voucher Code') . ":\n\n";
            $message .= $voucher['code'] . "\n\n";
            $message .= Lang::T('Package') . ": " . $plan['name_plan'] . "\n";
            $message .= Lang::T('Validity') . ": " . $voucher['validity'] . " " . $voucher['validity_unit'] . "\n";
            $message .= Lang::T('Amount Paid') . ": " . Lang::moneyFormat($transaction['price']) . "\n\n";
            $message .= Lang::T('To activate, connect to WiFi and enter this code on the login page') . ".";

            // Send SMS using Message class
            try {
                $result = Message::sendSMS($phonenumber, $message);

                if ($result) {
                    _log("GuestPurchase Success: Voucher SMS sent to {$phonenumber} for voucher {$voucher['code']}");
                    return true;
                } else {
                    _log("GuestPurchase Error: SMS gateway returned false for {$phonenumber}");
                    Message::sendTelegram("Guest Purchase Warning: Failed to send SMS to {$phonenumber} for voucher {$voucher['code']}");
                    return false;
                }

            } catch (Exception $e) {
                _log("GuestPurchase Error: SMS delivery exception - " . $e->getMessage());
                Message::sendTelegram("Guest Purchase SMS Error: " . $e->getMessage() . " for phone {$phonenumber}");
                return false;
            }

        } catch (Exception $e) {
            _log("GuestPurchase Error: Unexpected error sending voucher SMS - " . $e->getMessage());
            Message::sendTelegram("Guest Purchase SMS Critical Error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Get guest email from transaction
     *
     * @param object $transaction - Transaction record
     * @return string|null - Email address or null
     */
    public static function getGuestEmail($transaction)
    {
        $pg_request = json_decode($transaction['pg_request'], true);
        if (isset($pg_request['email'])) {
            return $pg_request['email'];
        }

        return null;
    }

    /**
     * Get guest phone number from transaction
     *
     * @param object $transaction - Transaction record
     * @return string|null - Phone number or null
     */
    public static function getGuestPhoneNumber($transaction)
    {
        $pg_request = json_decode($transaction['pg_request'], true);
        if (isset($pg_request['phonenumber'])) {
            return $pg_request['phonenumber'];
        }

        return null;
    }
}
