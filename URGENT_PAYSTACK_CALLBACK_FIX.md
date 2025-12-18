# URGENT: Paystack Payment Gateway - Guest Purchase Return URL Fix

## Current Issue

After successful payment, guests are redirected to `?_route=login` instead of `guest/order/view/{transaction_id}`.

**This breaks the entire flow:**
- ❌ No voucher displayed
- ❌ No auto-login
- ❌ No auto-activation
- ❌ Guest sees login page instead

---

## Root Cause

The `system/paymentgateway/paystack.php` file is using the default callback URL for ALL transactions, including guest purchases.

**Default callback:** `{site_url}/login`  
**Should be:** `{site_url}/guest/order/view/{transaction_id}` for guest purchases

---

## Required Fix in `system/paymentgateway/paystack.php`

### In `paystack_create_transaction()` Function

**Current code (approximate):**
```php
function paystack_create_transaction($trx, $user) {
    global $config;
    
    // ... existing code ...
    
    $paystack_data = [
        'email' => $user['email'],
        'amount' => $trx['price'] * 100,
        'reference' => 'TRX-' . $trx->id(),
        'callback_url' => U . 'login'  // ❌ WRONG for guest purchases
    ];
    
    // Send to Paystack API
    // ... redirect user ...
}
```

**Fixed code:**
```php
function paystack_create_transaction($trx, $user) {
    global $config;
    
    // ... existing code ...
    
    // Check if this is a guest purchase
    $pg_request = json_decode($trx['pg_request'], true);
    $is_guest = isset($pg_request['guest_purchase']) && $pg_request['guest_purchase'] === true;
    
    // Use guest callback URL if guest purchase
    if ($is_guest && isset($pg_request['callback_url'])) {
        $callback_url = $pg_request['callback_url'];
    } else {
        $callback_url = U . 'login';  // Default for regular customers
    }
    
    $paystack_data = [
        'email' => $user['email'] ?: $pg_request['email'],
        'amount' => $trx['price'] * 100,
        'reference' => 'TRX-' . $trx->id() . '-' . time(),
        'callback_url' => $callback_url,  // ✅ CORRECT - uses guest URL
        'metadata' => [
            'transaction_id' => $trx->id(),
            'guest_purchase' => $is_guest,
            'plan_name' => $trx['plan_name']
        ]
    ];
    
    // Send to Paystack API
    // ... redirect user ...
}
```

---

## What We've Already Done

### 1. Added callback_url to Transaction
**File:** `system/controllers/guest.php`

```php
$pg_request_data = [
    'email' => $email,
    'phonenumber' => $phonenumber,
    'guest_purchase' => true,
    'transaction_id' => $trx->id(),
    'callback_url' => U . 'guest/order/view/' . $trx->id()  // ✅ Set
];
```

### 2. Added Auto-Login Logic
**File:** `system/controllers/guest.php` (view case)

When guest returns after payment:
- Checks if auto-activated
- Logs guest in automatically
- Redirects to dashboard

### 3. Added Voucher Generation
**File:** `callback.php` and `guest.php`

Automatically generates vouchers after payment confirmation.

---

## Testing After Fix

### 1. Test Guest Purchase Flow
```
1. Go to login page (guest view)
2. Click "Buy Package"
3. Fill email/phone, select Paystack
4. Click "Pay Now"
5. Complete payment at Paystack
6. ✅ Should redirect to: guest/order/view/{transaction_id}
7. ✅ Should see voucher code OR auto-login to dashboard
```

### 2. Check Logs
```
Guest purchase: Transaction {id} created
Guest purchase: Initiating payment with paystack
Paystack: Redirecting to payment page with callback: guest/order/view/{id}
[After payment]
Guest purchase: Payment confirmed
GuestPurchase: Voucher generated
Guest purchase: Auto-logged in customer {username}
```

### 3. Verify Database
```sql
-- Check transaction has callback URL
SELECT id, pg_request 
FROM tbl_payment_gateway 
WHERE username LIKE 'GUEST-%' 
ORDER BY id DESC LIMIT 1;

-- Should show:
{
  "email": "test@example.com",
  "phonenumber": "+1234567890",
  "guest_purchase": true,
  "transaction_id": 123,
  "callback_url": "http://yoursite.com/guest/order/view/123"
}
```

---

## Alternative Quick Fix (If Can't Modify Payment Gateway)

### Option 1: Override in Hook
Create a plugin/hook that modifies the callback URL before payment:

```php
// In a custom plugin file
add_action('guest_create_transaction', function() use ($trx) {
    // Force callback URL in session or global
    $_SESSION['paystack_callback'] = U . 'guest/order/view/' . $trx->id();
});
```

### Option 2: Paystack Dashboard Setting
1. Go to Paystack Dashboard
2. Settings → API Keys & Webhooks
3. Set default callback URL to handle both guest and customer
4. Use URL parameter to differentiate: `callback?type=guest&trx={id}`

---

## Impact of Not Fixing

**Without this fix:**
- ✅ Payment works
- ✅ Webhook receives notification
- ✅ Voucher generated
- ✅ Email/SMS sent
- ❌ Guest redirected to login page (confusing!)
- ❌ No auto-login (even if enabled)
- ❌ Guest must manually find voucher in email

**With this fix:**
- ✅ Payment works
- ✅ Webhook receives notification
- ✅ Voucher generated
- ✅ Email/SMS sent
- ✅ Guest redirected to transaction page
- ✅ Auto-login works (if enabled)
- ✅ Seamless user experience

---

## Priority: HIGH

This is a critical UX issue that affects every guest purchase. Without it, the auto-activation and auto-login features cannot work properly.

**Estimated fix time:** 5-10 minutes  
**Files to modify:** 1 (`system/paymentgateway/paystack.php`)  
**Lines to change:** ~5 lines

---

## Summary

1. ✅ Transaction now stores callback URL
2. ✅ Auto-login logic implemented
3. ✅ Voucher generation working
4. ❌ **Payment gateway not using callback URL** ← FIX THIS
5. ❌ Guests redirected to wrong page

**Next step:** Update `paystack_create_transaction()` to use `$pg_request['callback_url']` for guest purchases.
