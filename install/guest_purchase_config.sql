-- Guest Purchase Improvements - Configuration Setup
-- Run this SQL to add all new configuration settings to your PHPNuxBill database

-- Add guest purchase configuration settings
INSERT INTO tbl_app_config (setting, value) VALUES
('guest_auto_activate', 'yes'),
('guest_allowed_plan_types', 'Hotspot'),
('guest_transaction_expiry_hours', '6'),
('guest_transaction_cleanup_days', '30')
ON DUPLICATE KEY UPDATE value=VALUES(value);

-- Verify settings were added
SELECT * FROM tbl_app_config 
WHERE setting IN (
    'guest_auto_activate',
    'guest_allowed_plan_types',
    'guest_transaction_expiry_hours',
    'guest_transaction_cleanup_days'
);

-- Optional: Enable auto-activation (uncomment to enable)
-- UPDATE tbl_app_config SET value = 'yes' WHERE setting = 'guest_auto_activate';

-- Optional: Allow multiple plan types (uncomment and modify as needed)
-- UPDATE tbl_app_config SET value = 'Hotspot,PPPOE,VPN' WHERE setting = 'guest_allowed_plan_types';

-- Optional: Change transaction expiry to 24 hours (uncomment to enable)
-- UPDATE tbl_app_config SET value = '24' WHERE setting = 'guest_transaction_expiry_hours';

-- Optional: Change cleanup retention to 7 days (uncomment to enable)
-- UPDATE tbl_app_config SET value = '7' WHERE setting = 'guest_transaction_cleanup_days';
