<?php
/**
 * MikroTik Sync Diagnostic Script
 * Run this to test if your MikroTik router connection is working
 */

// Load PHPNuxBill
require_once __DIR__ . '/system/autoload.php';
require_once __DIR__ . '/system/autoload/PEAR2/Autoload.php';

use PEAR2\Net\RouterOS;

echo "=== MikroTik Sync Diagnostic ===\n\n";

// Get all routers
$routers = ORM::for_table('tbl_routers')->find_many();

if (count($routers) == 0) {
    echo "❌ ERROR: No routers found in database!\n";
    echo "Please add a router in PHPNuxBill admin panel first.\n";
    exit(1);
}

echo "Found " . count($routers) . " router(s) in database:\n\n";

foreach ($routers as $router) {
    echo "Router: {$router['name']}\n";
    echo "IP: {$router['ip_address']}\n";
    echo "Username: {$router['username']}\n";
    echo "Enabled: " . ($router['enabled'] ? 'Yes' : 'No') . "\n";
    
    // Test connection
    echo "Testing connection... ";
    
    try {
        $iport = explode(":", $router['ip_address']);
        $client = new RouterOS\Client(
            $iport[0], 
            $router['username'], 
            $router['password'], 
            ($iport[1]) ? $iport[1] : null
        );
        
        // Try to get system identity
        $printRequest = new RouterOS\Request('/system/identity/print');
        $identity = $client->sendSync($printRequest)->getProperty('name');
        
        echo "✅ SUCCESS!\n";
        echo "Router Identity: $identity\n";
        
        // Test hotspot user list
        echo "Testing hotspot user access... ";
        $printRequest = new RouterOS\Request('/ip/hotspot/user/print');
        $printRequest->setArgument('.proplist', 'name');
        $users = $client->sendSync($printRequest);
        echo "✅ Can access hotspot users\n";
        
        // Test hotspot profile list
        echo "Testing hotspot profile access... ";
        $printRequest = new RouterOS\Request('/ip/hotspot/user/profile/print');
        $printRequest->setArgument('.proplist', 'name');
        $profiles = $client->sendSync($printRequest);
        echo "✅ Can access hotspot profiles\n";
        
    } catch (Exception $e) {
        echo "❌ FAILED!\n";
        echo "Error: " . $e->getMessage() . "\n";
        echo "This router will NOT sync properly.\n";
    }
    
    echo "\n" . str_repeat("-", 50) . "\n\n";
}

// Check for active plans
echo "=== Checking Plans ===\n\n";
$plans = ORM::for_table('tbl_plans')
    ->where('enabled', 1)
    ->find_many();

if (count($plans) == 0) {
    echo "❌ WARNING: No enabled plans found!\n\n";
} else {
    echo "Found " . count($plans) . " enabled plan(s):\n\n";
    foreach ($plans as $plan) {
        echo "Plan: {$plan['name_plan']}\n";
        echo "Type: {$plan['type']}\n";
        echo "Router: {$plan['routers']}\n";
        echo "Device: {$plan['device']}\n";
        
        // Check if device file exists
        $device_path = "system/devices/{$plan['device']}.php";
        if (file_exists($device_path)) {
            echo "Device File: ✅ Found\n";
        } else {
            echo "Device File: ❌ NOT FOUND at $device_path\n";
        }
        
        echo "\n";
    }
}

// Check for active user recharges
echo "=== Checking Active User Recharges ===\n\n";
$recharges = ORM::for_table('tbl_user_recharges')
    ->where('status', 'on')
    ->limit(5)
    ->find_many();

if (count($recharges) == 0) {
    echo "No active user recharges found.\n\n";
} else {
    echo "Found " . count($recharges) . " active recharge(s) (showing first 5):\n\n";
    foreach ($recharges as $r) {
        echo "Username: {$r['username']}\n";
        echo "Plan: {$r['namebp']}\n";
        echo "Router: {$r['routers']}\n";
        echo "Expires: {$r['expiration']} {$r['time']}\n";
        echo "\n";
    }
}

echo "=== Diagnostic Complete ===\n";
echo "\nIf you see any ❌ errors above, those need to be fixed for sync to work.\n";
