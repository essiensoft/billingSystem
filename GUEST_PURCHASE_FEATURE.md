# Guest Purchase Feature - Documentation

## Overview
The Guest Purchase feature allows customers to buy internet packages directly through payment gateways **without creating an account**. After successful payment, customers receive a voucher code via email which they can use to activate internet access.

## How It Works

### Customer Journey
1. **Browse Packages**: Guest visits the login page and sees available internet packages
2. **Select Package**: Click "Buy Now" on desired package
3. **Enter Email**: Provide email address for voucher delivery
4. **Select Payment Gateway**: Choose payment method (Paystack, etc.)
5. **Complete Payment**: Redirected to payment gateway to complete transaction
6. **Receive Voucher**: Upon successful payment:
   - Voucher code is auto-generated
   - Sent to email
   - Displayed on success page
7. **Activate Internet**: Use voucher code to activate internet access

### Technical Flow
```
Guest → Browse Plans → Select Plan → Enter Email → Pay → Auto-Generate Voucher → Email Voucher → Activate
```

## Key Features

### 1. **No Registration Required**
- Guests can purchase without creating an account
- Only email address is required
- Immediate access to internet packages

### 2. **Auto-Voucher Generation**
- Automatic voucher creation upon successful payment
- Unique voucher codes (format: PREFIX-XXXXXXXXXXXX)
- Linked to purchased plan and router

### 3. **Email Delivery**
- Professional HTML email with voucher code
- QR code for easy scanning
- Instructions for activation
- Package details and receipt

### 4. **Real-time Payment Verification**
- Webhook support for instant confirmation
- Manual payment check option
- Transaction status tracking

### 5. **Multiple Payment Gateways**
- Currently supports: Paystack
- Modular design for easy addition of new gateways
- Secure payment processing

## Files Created/Modified

### New Files
1. **`/system/controllers/guest.php`**
   - Main controller for guest purchases
   - Handles package listing, gateway selection, transaction creation
   - Routes: `guest/order/package`, `guest/order/gateway`, `guest/order/buy`, `guest/order/view`

2. **`/system/autoload/GuestPurchase.php`**
   - Helper class for guest purchase operations
   - Auto-generates vouchers
   - Sends email notifications
   - Handles guest transaction logic

3. **`/ui/ui/customer/guest-gateway.tpl`**
   - Payment gateway selection page
   - Email collection form
   - Order summary display

4. **`/ui/ui/customer/guest-transaction-view.tpl`**
   - Transaction status page
   - Voucher display (if paid)
   - Payment pending/failed states

### Modified Files
1. **`/ui/ui/customer/login-noreg.tpl`**
   - Added package listing section
   - "Buy Now" buttons for each package
   - Guest purchase call-to-action

2. **`/system/controllers/login.php`**
   - Fetches guest plans
   - Passes plans to template

3. **`/system/paymentgateway/paystack.php`**
   - Modified webhook to detect guest transactions
   - Auto-generates vouchers for guest purchases
   - Updates `paystack_payment_notification()` function
   - Updates `paystack_get_status()` function

4. **`/system/lan/english.json`**
   - Added 50+ translations for guest purchase feature

## Database Schema

### Guest Transactions in `tbl_payment_gateway`
```sql
- username: 'GUEST-{timestamp}{random}' (e.g., GUEST-170000001234)
- user_id: 0 (indicates guest)
- pg_request: JSON with 'guest_purchase: true' and 'email' fields
- pg_paid_response: Contains 'voucher_code' after successful payment
```

### Auto-Generated Vouchers in `tbl_voucher`
```sql
- code: '{PREFIX}-{UNIQUE_CODE}' (e.g., GT-ABC123XYZ789)
- user: '0' (guest voucher)
- status: '0' (unused)
- generated_by: 0 (system generated)
- created_at: timestamp
```

## Configuration

### Payment Gateway Setup
1. Navigate to: **Payment Gateway → Paystack**
2. Enter Paystack Secret Key
3. Save configuration

### Voucher Prefix (Optional)
Default prefix for guest vouchers: `GT-`

To change:
1. Navigate to: **Vouchers → Add Voucher**
2. Set custom prefix
3. System will use it for future guest purchases

### Email Configuration
Ensure email settings are configured in:
- **Settings → Localisation → Email Settings**

Email template is automatically generated with:
- Company name
- Voucher code with QR code
- Package details
- Activation instructions

## API Integration

### Webhook URL
```
{YOUR_DOMAIN}/callback/paystack
```

Configure this URL in your Paystack dashboard for automatic payment confirmation.

### Guest Transaction Detection
The system detects guest transactions using:
```php
GuestPurchase::isGuestTransaction($transaction)
```

Checks:
1. Username starts with "GUEST-"
2. `pg_request` contains `guest_purchase: true`
3. `user_id` equals 0

### Voucher Generation
```php
GuestPurchase::generateVoucher($transaction, $email)
```

Returns: Voucher code or false on failure

## User Interface

### Login Page (login-noreg.tpl)
```
┌─────────────────────────────────────┐
│  Announcement Panel                 │
│                                     │
│  ┌────────────────────────────┐   │
│  │ Buy Internet Package       │   │
│  │                            │   │
│  │  [Package 1] [Price]       │   │
│  │  [Buy Now Button]          │   │
│  │                            │   │
│  │  [Package 2] [Price]       │   │
│  │  [Buy Now Button]          │   │
│  └────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Payment Gateway Selection
```
┌─────────────────────────────────────┐
│  Order Summary                      │
│  - Package Name                     │
│  - Bandwidth                        │
│  - Validity                         │
│  - Price                            │
│  - Tax (if applicable)              │
│  - Total Amount                     │
│                                     │
│  [Email Input Field]                │
│  [Payment Gateway Selection]        │
│  [Pay Now Button]                   │
└─────────────────────────────────────┘
```

### Success Page
```
┌─────────────────────────────────────┐
│  ✓ Payment Successful!              │
│                                     │
│  Your Voucher Code:                 │
│  ┌──────────────────────────┐      │
│  │  GT-ABC123XYZ789         │      │
│  └──────────────────────────┘      │
│  [QR Code]                          │
│                                     │
│  How to use:                        │
│  1. Connect to WiFi                 │
│  2. Open browser                    │
│  3. Enter voucher code              │
│  4. Activate and enjoy!             │
│                                     │
│  [Activate Voucher Now Button]      │
└─────────────────────────────────────┘
```

## Security Features

### 1. CSRF Protection
All forms include CSRF tokens to prevent cross-site request forgery.

### 2. Email Validation
```php
filter_var($email, FILTER_VALIDATE_EMAIL)
```

### 3. Webhook Signature Verification
Paystack webhooks are verified using HMAC SHA512 signature.

### 4. Transaction Expiry
Guest transactions expire after 6 hours if unpaid.

### 5. Unique Voucher Codes
- Generated using cryptographically secure random
- Duplicate checking with retry mechanism
- Maximum 5 retry attempts

## Testing Checklist

### Pre-requisites
- [ ] Paystack account configured
- [ ] At least one enabled Hotspot plan
- [ ] At least one enabled router
- [ ] Email settings configured

### Test Cases

#### 1. Package Display
- [ ] Packages display on login page
- [ ] Prices show correctly
- [ ] "Buy Now" buttons work

#### 2. Payment Flow
- [ ] Email validation works
- [ ] Gateway selection works
- [ ] Redirect to Paystack works
- [ ] Callback URL receives webhook

#### 3. Voucher Generation
- [ ] Voucher auto-generates on payment
- [ ] Voucher code is unique
- [ ] Voucher linked to correct plan

#### 4. Email Delivery
- [ ] Email sent to guest
- [ ] Email contains voucher code
- [ ] QR code displays correctly
- [ ] Instructions are clear

#### 5. Voucher Activation
- [ ] Voucher code can be used on login page
- [ ] Internet access activates successfully
- [ ] Plan expiry calculated correctly

#### 6. Error Handling
- [ ] Invalid email rejected
- [ ] Payment failure handled gracefully
- [ ] Webhook failures logged
- [ ] Duplicate voucher codes prevented

## Troubleshooting

### Issue: Packages Not Showing
**Solution:**
1. Check if plans are enabled: `Plans → List Plans`
2. Ensure plan type is "Hotspot"
3. Verify router is enabled

### Issue: Payment Not Confirming
**Solution:**
1. Check webhook URL in Paystack dashboard
2. Verify webhook logs: `pages/paystack-webhook.html`
3. Check transaction status: `Payment Gateway → Audit`

### Issue: Voucher Not Generated
**Solution:**
1. Check logs in database: `tbl_logs`
2. Verify GuestPurchase.php is loaded
3. Check voucher table for duplicates
4. Review Telegram notifications (if configured)

### Issue: Email Not Received
**Solution:**
1. Check email configuration: `Settings → Email`
2. Verify SMTP settings
3. Check spam/junk folder
4. Review email logs

## Monitoring & Logs

### Transaction Logs
- Location: `tbl_payment_gateway`
- Status codes:
  - 1 = Unpaid
  - 2 = Paid
  - 3 = Failed
  - 4 = Cancelled

### System Logs
```sql
SELECT * FROM tbl_logs
WHERE description LIKE '%GuestPurchase%'
ORDER BY id DESC;
```

### Voucher Logs
```sql
SELECT * FROM tbl_voucher
WHERE generated_by = 0
AND user = '0'
ORDER BY id DESC;
```

### Webhook Logs
- File: `pages/paystack-webhook.html`
- Contains raw webhook payloads

## Customization

### Change Voucher Prefix
Edit `/system/autoload/GuestPurchase.php`:
```php
$prefix = $config['voucher_prefix'] ?? 'YOUR-PREFIX-';
```

### Modify Email Template
Edit `/system/autoload/GuestPurchase.php` → `sendVoucherEmail()` function

### Change Package Filter
Edit `/system/controllers/login.php`:
```php
// Show all plan types
->where('tbl_plans.type', 'Hotspot') // Change this
```

### Customize Success Page
Edit `/ui/ui/customer/guest-transaction-view.tpl`

## Support & Maintenance

### Regular Maintenance
1. **Clean expired transactions** (monthly)
   ```sql
   DELETE FROM tbl_payment_gateway
   WHERE status = 1
   AND expired_date < NOW() - INTERVAL 30 DAY;
   ```

2. **Archive old guest vouchers** (quarterly)
   ```sql
   SELECT * FROM tbl_voucher
   WHERE generated_by = 0
   AND status = 1
   AND used_date < NOW() - INTERVAL 90 DAY;
   ```

3. **Monitor webhook failures**
   - Review `pages/paystack-webhook.html` weekly
   - Check for signature verification failures

### Performance Optimization
1. Add database index on guest transactions:
   ```sql
   ALTER TABLE tbl_payment_gateway
   ADD INDEX idx_guest_username (username(10));
   ```

2. Add index on voucher codes:
   ```sql
   ALTER TABLE tbl_voucher
   ADD INDEX idx_voucher_code (code);
   ```

## Future Enhancements

### Planned Features
- [ ] Multiple payment gateway support (Stripe, PayPal, etc.)
- [ ] SMS voucher delivery option
- [ ] WhatsApp voucher delivery
- [ ] Custom voucher design templates
- [ ] Guest purchase analytics dashboard
- [ ] Promotional codes for guest purchases
- [ ] Multi-currency support
- [ ] Voucher batch generation for bulk sales

## License & Credits
- Part of PHPNuxBill Hotspot Billing System
- Guest Purchase Feature developed for seamless customer experience
- Compatible with PHPNuxBill v2025+

## Contact & Support
For issues or feature requests:
- GitHub: https://github.com/hotspotbilling/phpnuxbill/
- Telegram: https://t.me/phpnuxbill

---

**Last Updated:** 2025-01-15
**Version:** 1.0.0
**Status:** Production Ready
