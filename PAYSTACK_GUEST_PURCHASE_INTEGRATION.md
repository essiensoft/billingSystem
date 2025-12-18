# Paystack Payment Gateway - Guest Purchase Integration

## Current Issue

Paystack webhooks are failing with error:
```
Transaction with reference trx69444a526105e not found
```

**Root Cause:** The payment gateway is looking for transactions by `gateway_trx_id` (Paystack's reference), but guest purchase transactions don't have this field populated when created.

---

## Required Changes to `system/paymentgateway/paystack.php`

### 1. In `paystack_create_transaction()` Function

**Current behavior:** Creates Paystack transaction and redirects user

**Required changes:**
```php
function paystack_create_transaction($trx, $user) {
    // ... existing code ...
    
    // After creating Paystack transaction, store the reference
    $paystack_reference = $response['data']['reference']; // e.g., trx69444a526105e
    
    // Update transaction with Paystack reference
    $trx->gateway_trx_id = $paystack_reference;
    $trx->save();
    
    // ... redirect to Paystack ...
}
```

### 2. In `paystack_payment_notification()` Function (Webhook Handler)

**Current behavior:** Looks up transaction by `gateway_trx_id`

**Required changes:**
```php
function paystack_payment_notification() {
    // Get Paystack reference from webhook
    $reference = $_POST['data']['reference'] ?? '';
    
    // Try to find transaction by gateway_trx_id
    $trx = ORM::for_table('tbl_payment_gateway')
        ->where('gateway_trx_id', $reference)
        ->find_one();
    
    // FALLBACK: If not found, try finding by metadata (for guest purchases)
    if (!$trx) {
        // Get transaction ID from Paystack metadata if available
        $metadata = $_POST['data']['metadata'] ?? [];
        $transaction_id = $metadata['transaction_id'] ?? null;
        
        if ($transaction_id) {
            $trx = ORM::for_table('tbl_payment_gateway')
                ->find_one($transaction_id);
        }
    }
    
    if (!$trx) {
        _log("Paystack webhook: Transaction with reference {$reference} not found");
        http_response_code(404);
        echo json_encode(['error' => 'Transaction not found']);
        return;
    }
    
    // Verify payment with Paystack API
    // ... existing verification code ...
    
    // If payment successful
    if ($payment_verified) {
        $trx->status = 2; // Paid
        $trx->paid_date = date('Y-m-d H:i:s');
        $trx->gateway_trx_id = $reference; // Store reference if not already set
        $trx->save();
        
        _log("Paystack webhook: Payment confirmed for transaction {$trx->id()}");
    }
}
```

### 3. Pass Transaction ID in Paystack Metadata

**In `paystack_create_transaction()`:**
```php
// When creating Paystack transaction, include metadata
$pg_request = json_decode($trx['pg_request'], true);

$paystack_data = [
    'email' => $user['email'] ?: $pg_request['email'],
    'amount' => $trx['price'] * 100, // Convert to kobo
    'reference' => 'TRX-' . $trx->id() . '-' . time(),
    'metadata' => [
        'transaction_id' => $trx->id(),  // ← ADD THIS
        'plan_name' => $trx['plan_name'],
        'customer_name' => $user['fullname'],
        'guest_purchase' => $pg_request['guest_purchase'] ?? false
    ]
];

// Send to Paystack API
$response = // ... API call ...
```

---

## Alternative Solution (If Can't Modify Payment Gateway)

### Use Custom Reference Format

Modify guest.php to set a predictable `gateway_trx_id` before calling payment gateway:

```php
// In guest.php, before calling payment gateway
$custom_reference = 'GT-' . $trx->id() . '-' . time();
$trx->gateway_trx_id = $custom_reference;
$trx->save();

// Payment gateway should use this reference when creating Paystack transaction
```

Then payment gateway can find transaction by this reference.

---

## Testing

After implementing changes:

1. **Create test transaction**
   - Guest buys package
   - Check `gateway_trx_id` is set in database

2. **Simulate webhook**
   ```bash
   curl -X POST http://yoursite.com/callback/paystack \
     -H "Content-Type: application/json" \
     -d '{
       "event": "charge.success",
       "data": {
         "reference": "trx69444a526105e",
         "status": "success",
         "metadata": {
           "transaction_id": 123
         }
       }
     }'
   ```

3. **Verify**
   - Transaction status updated to "Paid"
   - Voucher generated
   - Email/SMS sent

---

## Current Workaround

Users can manually check payment status:
1. Go to transaction view page
2. Click "Check Payment Status"
3. System calls Paystack API directly
4. Updates transaction and generates voucher

This works but requires manual action instead of automatic webhook processing.
