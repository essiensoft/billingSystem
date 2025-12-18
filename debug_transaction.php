<?php
// Debug script to check transaction data
require_once 'system/init.php';

$trx_id = $_GET['id'] ?? 16;
$trx = ORM::for_table('tbl_payment_gateway')->find_one($trx_id);

if (!$trx) {
    die("Transaction $trx_id not found");
}

echo "<h2>Transaction $trx_id Debug</h2>";
echo "<pre>";
echo "Username: " . $trx['username'] . "\n";
echo "Status: " . $trx['status'] . "\n";
echo "Gateway: " . $trx['gateway'] . "\n";
echo "Plan ID: " . $trx['plan_id'] . "\n\n";

echo "=== pg_request (raw) ===\n";
echo $trx['pg_request'] . "\n\n";

echo "=== pg_request (parsed) ===\n";
$pg_request = json_decode($trx['pg_request'], true);
print_r($pg_request);
echo "\n\n";

echo "=== Email/Phone Extraction ===\n";
$email = GuestPurchase::getGuestEmail($trx);
$phone = GuestPurchase::getGuestPhoneNumber($trx);
echo "Email: " . ($email ?: 'NULL/EMPTY') . "\n";
echo "Phone: " . ($phone ?: 'NULL/EMPTY') . "\n\n";

echo "=== Is Guest Transaction? ===\n";
echo GuestPurchase::isGuestTransaction($trx) ? 'YES' : 'NO';
echo "\n\n";

echo "=== pg_paid_response ===\n";
echo $trx['pg_paid_response'] . "\n";
echo "</pre>";
