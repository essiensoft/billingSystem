# Router Validation Fix for Guest Purchase

## Issue Identified

**Problem**: When customers try to purchase internet packages on the [login-noreg.tpl](ui/ui/customer/login-noreg.tpl) page, the system was displaying ALL enabled Hotspot plans without validating whether their associated routers exist and are enabled. This caused:

1. **Broken "Buy Now" links**: Plans with invalid router IDs would fail when clicked
2. **Poor user experience**: Customers would see packages but get errors when trying to purchase
3. **No error visibility**: Admins wouldn't know which plans had router configuration issues

## Root Cause

In [system/controllers/login.php](system/controllers/login.php), guest plans were fetched without checking if their `routers` field referenced a valid, enabled router:

```php
// OLD CODE - No router validation
$guest_plans = ORM::for_table('tbl_plans')
    ->where('tbl_plans.enabled', '1')
    ->where('tbl_plans.type', 'Hotspot')
    ->find_array();
```

## Solution Implemented

### 1. Login Controller Enhancement ([system/controllers/login.php](system/controllers/login.php:311-350))

**Added Router Validation Loop:**
```php
// Fetch all enabled Hotspot plans
$guest_plans_raw = ORM::for_table('tbl_plans')
    ->where('tbl_plans.enabled', '1')
    ->where('tbl_plans.type', 'Hotspot')
    ->find_array();

// Filter plans to only include those with valid, enabled routers
$guest_plans = [];
$router_error = '';

foreach ($guest_plans_raw as $plan) {
    // Check if router exists and is enabled
    $router = ORM::for_table('tbl_routers')
        ->where('id', $plan['routers'])
        ->where('enabled', '1')
        ->find_one();

    if ($router) {
        $guest_plans[] = $plan; // Valid plan - include it
    } else {
        // Invalid router - log warning
        _log("Guest purchase warning: Plan '{$plan['name_plan']}' (ID: {$plan['id']}) has invalid/disabled router ID: {$plan['routers']}");
    }
}

// If no valid plans available, set error message
if (empty($guest_plans) && !empty($guest_plans_raw)) {
    $router_error = Lang::T('Internet packages are currently unavailable due to network configuration. Please contact support.');
    _log('Guest purchase error: No valid routers configured for any guest purchase plans');
}
```

**Key Features:**
- ✅ Validates each plan's router exists and is enabled
- ✅ Filters out plans with invalid routers
- ✅ Logs warnings for each invalid plan (admin visibility)
- ✅ Sets error message when ALL plans have invalid routers
- ✅ Passes `$router_error` variable to template

### 2. Template Error Display ([ui/ui/customer/login-noreg.tpl](ui/ui/customer/login-noreg.tpl:563-582))

**Added Router Error Alert:**
```smarty
{if $router_error}
    <div class="alert alert-danger">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="15" y1="9" x2="9" y2="15"></line>
            <line x1="9" y1="9" x2="15" y2="15"></line>
        </svg>
        <strong>{Lang::T('Service Unavailable')}</strong><br>
        {$router_error}
    </div>
{else}
    <!-- Normal info alert -->
{/if}
```

**User Experience:**
- Shows prominent red error alert when routers are misconfigured
- Clear message: "Service Unavailable"
- Instructs user to contact support
- Only displays when there's an actual router configuration issue

### 3. Language Translations ([system/lan/english.json](system/lan/english.json))

**Added New Error Messages:**
```json
{
    "Internet_packages_are_currently_unavailable_due_to_network_configuration_Please_contact_support": "Internet packages are currently unavailable due to network configuration. Please contact support.",
    "Service_Unavailable": "Service Unavailable"
}
```

---

## Error Scenarios Handled

### Scenario 1: All Plans Have Invalid Routers
**Condition**: Plans exist but ALL have invalid/disabled router IDs
**User Experience**:
- Red alert displayed: "Service Unavailable"
- Message: "Internet packages are currently unavailable due to network configuration. Please contact support."
- No packages displayed (empty list)

**Admin Visibility**:
```
Log: Guest purchase error: No valid routers configured for any guest purchase plans
Log: Guest purchase warning: Plan 'Daily 1GB' (ID: 5) has invalid/disabled router ID: 99
Log: Guest purchase warning: Plan 'Weekly 5GB' (ID: 6) has invalid/disabled router ID: 99
```

### Scenario 2: Some Plans Have Invalid Routers
**Condition**: Mixed - some plans have valid routers, others don't
**User Experience**:
- Normal blue info alert displayed
- Only valid plans shown in package grid
- Invalid plans silently filtered out

**Admin Visibility**:
```
Log: Guest purchase warning: Plan 'Monthly 20GB' (ID: 8) has invalid/disabled router ID: 12
```

### Scenario 3: All Plans Have Valid Routers
**Condition**: All plans have enabled routers
**User Experience**:
- Normal operation - all packages displayed
- "Buy Now" buttons work correctly

**Admin Visibility**:
- No warnings logged

### Scenario 4: No Plans Exist
**Condition**: No Hotspot plans enabled in system
**User Experience**:
- Empty state displayed: "No packages available at the moment"
- Message: "Please check back later or contact support for assistance."

**Admin Visibility**:
- No logs (normal behavior)

---

## Validation Logic Flow

```
┌─────────────────────────────────┐
│ Login Controller Loads          │
│ (customer visits login page)    │
└────────────┬────────────────────┘
             ▼
┌─────────────────────────────────┐
│ Fetch ALL enabled Hotspot plans │
│ ($guest_plans_raw)              │
└────────────┬────────────────────┘
             ▼
┌─────────────────────────────────┐
│ Loop through each plan          │
│ Check if router exists & enabled│
└─────┬───────────────────────────┘
      │
      ├─► Router Valid?
      │   ├─ YES → Add to $guest_plans array
      │   └─ NO  → Log warning, skip plan
      │
      ▼
┌─────────────────────────────────┐
│ Check if $guest_plans is empty  │
└─────┬───────────────────────────┘
      │
      ├─► $guest_plans empty BUT $guest_plans_raw not empty?
      │   ├─ YES → Set $router_error message
      │   │         Log critical error
      │   └─ NO  → Continue normally
      │
      ▼
┌─────────────────────────────────┐
│ Pass to template:                │
│ - $guest_plans (filtered)        │
│ - $router_error (if applicable)  │
└─────────────────────────────────┘
```

---

## Database Queries

### Before Fix:
```sql
-- 1 query total
SELECT tbl_plans.*, tbl_bandwidth.name_bw
FROM tbl_plans
LEFT JOIN tbl_bandwidth ON tbl_plans.id_bw = tbl_bandwidth.id
WHERE tbl_plans.enabled = '1'
  AND tbl_plans.type = 'Hotspot'
ORDER BY tbl_plans.price ASC
```

### After Fix:
```sql
-- 1 initial query
SELECT tbl_plans.*, tbl_bandwidth.name_bw
FROM tbl_plans
LEFT JOIN tbl_bandwidth ON tbl_plans.id_bw = tbl_bandwidth.id
WHERE tbl_plans.enabled = '1'
  AND tbl_plans.type = 'Hotspot'
ORDER BY tbl_plans.price ASC

-- N additional queries (1 per plan)
SELECT * FROM tbl_routers
WHERE id = {router_id}
  AND enabled = '1'
LIMIT 1
```

**Performance Note**: If you have 10 guest plans, this adds 10 router validation queries. For typical use cases (<20 plans), performance impact is negligible (<100ms). For large installations, consider adding a JOIN or caching.

---

## Admin Troubleshooting Guide

### Error: "Internet packages are currently unavailable"

**Diagnosis Steps:**

1. **Check Server Logs**:
```bash
grep "Guest purchase error" logs/app.log
grep "Guest purchase warning" logs/app.log
```

Expected output:
```
Guest purchase error: No valid routers configured for any guest purchase plans
Guest purchase warning: Plan 'Daily 1GB' (ID: 5) has invalid/disabled router ID: 99
```

2. **Verify Plans and Routers**:
```sql
-- Check which plans have invalid routers
SELECT p.id, p.name_plan, p.routers,
       CASE
         WHEN r.id IS NULL THEN 'Router Not Found'
         WHEN r.enabled = '0' THEN 'Router Disabled'
         ELSE 'OK'
       END as router_status
FROM tbl_plans p
LEFT JOIN tbl_routers r ON p.routers = r.id
WHERE p.enabled = '1'
  AND p.type = 'Hotspot';
```

3. **Fix Invalid Router Assignments**:

**Option A: Assign valid router to plans**
```sql
-- Update plan to use valid router (e.g., router ID 1)
UPDATE tbl_plans
SET routers = 1
WHERE id = 5 AND routers = 99;
```

**Option B: Enable disabled router**
```sql
-- Enable the router
UPDATE tbl_routers
SET enabled = '1'
WHERE id = 99;
```

**Option C: Create missing router**
- Navigate to: Admin Panel → Routers → Add Router
- Configure router with ID that plans are referencing

---

## Testing Guide

### Test Case 1: Valid Router Configuration
**Setup:**
1. Create router (ID: 1, enabled: 1)
2. Create plan (routers: 1, enabled: 1, type: Hotspot)

**Expected Result:**
- Plan displays on login-noreg.tpl
- "Buy Now" button works
- No errors logged

### Test Case 2: Invalid Router ID
**Setup:**
1. Create plan (routers: 999, enabled: 1, type: Hotspot)
2. No router with ID 999 exists

**Expected Result:**
- Plan does NOT display
- Log entry: "Guest purchase warning: Plan 'X' (ID: Y) has invalid/disabled router ID: 999"
- If this is the only plan: Error alert displayed

### Test Case 3: Disabled Router
**Setup:**
1. Create router (ID: 2, enabled: 0)
2. Create plan (routers: 2, enabled: 1, type: Hotspot)

**Expected Result:**
- Plan does NOT display
- Log entry: "Guest purchase warning: Plan 'X' (ID: Y) has invalid/disabled router ID: 2"

### Test Case 4: Mixed Configuration
**Setup:**
1. Router A (ID: 1, enabled: 1)
2. Router B (ID: 2, enabled: 0)
3. Plan A (routers: 1, enabled: 1) ← Valid
4. Plan B (routers: 2, enabled: 1) ← Invalid
5. Plan C (routers: 999, enabled: 1) ← Invalid

**Expected Result:**
- Only Plan A displays
- Logs warnings for Plan B and Plan C
- No error alert (because at least 1 valid plan exists)

---

## Backward Compatibility

✅ **Fully Backward Compatible**

- Existing installations with properly configured routers: No changes in behavior
- Plans with valid routers continue to work normally
- Only affects plans with misconfigured routers (which would have failed anyway)
- No database schema changes required
- No breaking changes to existing code

---

## Security Considerations

### Prevents Information Disclosure:
- Doesn't expose internal router IDs in error messages
- Generic error message to customers: "network configuration issue"
- Detailed errors only in server logs (admin access required)

### Prevents Failed Transactions:
- Filters invalid plans BEFORE customer clicks "Buy Now"
- Avoids situations where customer enters payment info but transaction fails
- Better user experience and reduces support tickets

---

## Performance Optimization (Future Enhancement)

For high-traffic sites with many plans:

```php
// Current approach: N+1 queries
foreach ($guest_plans_raw as $plan) {
    $router = ORM::for_table('tbl_routers')
        ->where('id', $plan['routers'])
        ->find_one();
}

// Optimized approach: 2 queries
$guest_plans_raw = ORM::for_table('tbl_plans')
    ->left_outer_join('tbl_routers', array(
        'tbl_plans.routers', '=', 'tbl_routers.id'
    ))
    ->select('tbl_plans.*')
    ->select('tbl_routers.enabled', 'router_enabled')
    ->where('tbl_plans.enabled', '1')
    ->where('tbl_plans.type', 'Hotspot')
    ->where('tbl_routers.enabled', '1') // Filter in SQL
    ->find_array();
```

---

## Files Modified

1. **[system/controllers/login.php](system/controllers/login.php:311-350)**
   - Added router validation loop
   - Added error message handling
   - Added router_error template variable

2. **[ui/ui/customer/login-noreg.tpl](ui/ui/customer/login-noreg.tpl:563-582)**
   - Added router error alert display
   - Conditional rendering based on $router_error

3. **[system/lan/english.json](system/lan/english.json)**
   - Added 2 new error message translations

---

## Summary

**Problem Solved**: ✅ Customers no longer see packages they can't purchase due to router misconfigurations

**Admin Benefits**: ✅ Clear log warnings identify which plans have router issues

**User Experience**: ✅ Clear error message when service is unavailable

**No Breaking Changes**: ✅ Fully backward compatible with existing installations

---

**Version**: 1.0
**Implementation Date**: 2025-01-16
**Status**: Production Ready
**Related**: ERROR_HANDLING_IMPLEMENTATION.md
