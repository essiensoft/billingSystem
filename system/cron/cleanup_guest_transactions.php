<?php
/**
 * Guest Purchase Cleanup Cron Job
 * Automatically removes expired guest transactions
 * 
 * Usage: Run daily via cron
 * Example crontab: 0 2 * * * php /path/to/cleanup_guest_transactions.php
 */

// Load PHPNuxBill system
$base_path = dirname(dirname(__FILE__));
require_once $base_path . '/system/autoload.php';

try {
    // Get configuration
    $daysToKeep = $config['guest_transaction_cleanup_days'] ?? 30;
    $dryRun = false; // Set to true for testing without deleting
    
    _log("Guest Transaction Cleanup: Starting cleanup process (keeping last {$daysToKeep} days)");
    
    // Find expired guest transactions older than configured days
    $expiredTransactions = ORM::for_table('tbl_payment_gateway')
        ->where('status', 1) // Unpaid only
        ->where_raw("username LIKE 'GUEST-%'")
        ->where_raw("expired_date < DATE_SUB(NOW(), INTERVAL ? DAY)", [$daysToKeep])
        ->find_many();
    
    $count = count($expiredTransactions);
    
    if ($count === 0) {
        _log("Guest Transaction Cleanup: No expired transactions found");
        echo "No expired guest transactions to clean up.\n";
        exit(0);
    }
    
    _log("Guest Transaction Cleanup: Found {$count} expired transactions to remove");
    
    if ($dryRun) {
        echo "DRY RUN: Would delete {$count} expired guest transactions\n";
        foreach ($expiredTransactions as $trx) {
            echo "  - Transaction ID: {$trx['id']}, Created: {$trx['created_date']}, Expired: {$trx['expired_date']}\n";
        }
        exit(0);
    }
    
    // Delete expired transactions
    $deleted = 0;
    foreach ($expiredTransactions as $trx) {
        try {
            $trx->delete();
            $deleted++;
        } catch (Exception $e) {
            _log("Guest Transaction Cleanup Error: Failed to delete transaction {$trx['id']} - " . $e->getMessage());
        }
    }
    
    _log("Guest Transaction Cleanup: Successfully deleted {$deleted} of {$count} expired transactions");
    
    // Send Telegram notification
    if ($deleted > 0) {
        Message::sendTelegram("Guest Transaction Cleanup: Removed {$deleted} expired transactions (older than {$daysToKeep} days)");
    }
    
    echo "Cleanup complete: Deleted {$deleted} expired guest transactions.\n";
    exit(0);
    
} catch (Exception $e) {
    _log("Guest Transaction Cleanup Critical Error: " . $e->getMessage());
    Message::sendTelegram("Guest Transaction Cleanup FAILED: " . $e->getMessage());
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
