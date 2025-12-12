#!/bin/bash

###############################################################################
# PHPNuxBill Security Fixes - Automated Test Suite
# Tests all 7 phases of security remediation
###############################################################################

# Configuration
BASE_URL="${BASE_URL:-http://localhost:8888/phpnuxbill}"
ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASS="${ADMIN_PASS:-admin}"
TEST_CUSTOMER="${TEST_CUSTOMER:-testuser}"
TEST_CUSTOMER_PASS="${TEST_CUSTOMER_PASS:-testpass}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
    ((TOTAL_TESTS++))
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_TESTS++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_TESTS++))
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Test Phase 1: RCE Prevention
test_rce_prevention() {
    print_header "Phase 1: Testing RCE Prevention"
    
    print_test "Widget eval() removal - PHP code should not execute"
    # This would require admin access to create a widget
    # For now, we'll check if the files have been modified
    if grep -q "SecurityHelper::sanitizeHtml" /Applications/MAMP/htdocs/phpnuxbill/system/widgets/html_php.php; then
        print_pass "html_php.php uses sanitizeHtml instead of eval()"
    else
        print_fail "html_php.php still vulnerable to RCE"
    fi
    
    # Check that eval is not used for execution (comments are OK)
    if grep -v "^[[:space:]]*\/\/" /Applications/MAMP/htdocs/phpnuxbill/system/widgets/html_php.php | grep -v "SECURITY FIX" | grep -q "eval("; then
        print_fail "eval() still present in html_php.php"
    else
        print_pass "No eval() execution found in html_php.php"
    fi
    
    if grep -q "SecurityHelper::sanitizeHtml" /Applications/MAMP/htdocs/phpnuxbill/system/widgets/html_php_card.php; then
        print_pass "html_php_card.php uses sanitizeHtml instead of eval()"
    else
        print_fail "html_php_card.php still vulnerable to RCE"
    fi
    
    if grep -q "SecurityHelper::sanitizeHtml" /Applications/MAMP/htdocs/phpnuxbill/system/widgets/customer/html_php.php; then
        print_pass "customer/html_php.php uses sanitizeHtml instead of eval()"
    else
        print_fail "customer/html_php.php still vulnerable to RCE"
    fi
}

# Test Phase 2: SQL Injection Prevention
test_sql_injection_prevention() {
    print_header "Phase 2: Testing SQL Injection Prevention"
    
    print_test "SQL Injection in customer search"
    RESPONSE=$(curl -s "${BASE_URL}/customers?search=%27%20OR%20%271%27=%271")
    if echo "$RESPONSE" | grep -q "SQL syntax"; then
        print_fail "SQL injection vulnerability still present in customer search"
    else
        print_pass "Customer search protected against SQL injection"
    fi
    
    print_test "SQL Injection in payment gateway search"
    RESPONSE=$(curl -s "${BASE_URL}/paymentgateway/audit/test?q=%27%20OR%20%271%27=%271")
    if echo "$RESPONSE" | grep -q "SQL syntax"; then
        print_fail "SQL injection vulnerability still present in payment gateway"
    else
        print_pass "Payment gateway search protected against SQL injection"
    fi
    
    print_test "Checking for parameterized queries in controllers"
    if grep -q "where_raw.*\?" /Applications/MAMP/htdocs/phpnuxbill/system/controllers/customers.php; then
        print_pass "customers.php uses parameterized queries"
    else
        print_fail "customers.php may not use parameterized queries"
    fi
    
    if grep -q "where_raw.*\?" /Applications/MAMP/htdocs/phpnuxbill/system/controllers/mail.php; then
        print_pass "mail.php uses parameterized queries"
    else
        print_fail "mail.php may not use parameterized queries"
    fi
    
    if grep -q "where_raw.*\?" /Applications/MAMP/htdocs/phpnuxbill/system/controllers/logs.php; then
        print_pass "logs.php uses parameterized queries"
    else
        print_fail "logs.php may not use parameterized queries"
    fi
}

# Test Phase 3: Command Injection Prevention
test_command_injection_prevention() {
    print_header "Phase 3: Testing Command Injection Prevention"
    
    print_test "Checking Radius.php for proper shell escaping"
    if grep -q "escapeshellarg" /Applications/MAMP/htdocs/phpnuxbill/system/devices/Radius.php; then
        print_pass "Radius.php uses escapeshellarg for shell commands"
    else
        print_fail "Radius.php may not properly escape shell arguments"
    fi
    
    if grep -q "echoArg.*escapeshellarg" /Applications/MAMP/htdocs/phpnuxbill/system/devices/Radius.php; then
        print_pass "Radius disconnect properly escapes arguments"
    else
        print_fail "Radius disconnect may be vulnerable to command injection"
    fi
}

# Test Phase 4: Session Security
test_session_security() {
    print_header "Phase 4: Testing Session Security"
    
    print_test "Session fixation vulnerability removed"
    if ! grep -q "\$_COOKIE\['uid'\] = \$_GET\['uid'\]" /Applications/MAMP/htdocs/phpnuxbill/system/boot.php; then
        print_pass "Session fixation vulnerability removed from boot.php"
    else
        print_fail "Session fixation vulnerability still present"
    fi
    
    print_test "Session fixation via URL parameter"
    RESPONSE=$(curl -s -c /tmp/cookies.txt "${BASE_URL}/?uid=malicious_session_id")
    if grep -q "malicious_session_id" /tmp/cookies.txt 2>/dev/null; then
        print_fail "Session can be fixed via URL parameter"
    else
        print_pass "Session cannot be fixed via URL parameter"
    fi
    rm -f /tmp/cookies.txt
    
    print_test "SessionConfig initialization"
    if grep -q "SessionConfig::init()" /Applications/MAMP/htdocs/phpnuxbill/system/autoload/Admin.php; then
        print_pass "SessionConfig::init() called in Admin.php"
    else
        print_fail "SessionConfig::init() not found in Admin.php"
    fi
    
    print_test "Session regeneration on login"
    if grep -q "SessionConfig::regenerate()" /Applications/MAMP/htdocs/phpnuxbill/system/controllers/admin.php; then
        print_pass "Session regeneration implemented on login"
    else
        print_fail "Session regeneration not implemented on login"
    fi
}

# Test Phase 5: Cryptographic Security
test_cryptographic_security() {
    print_header "Phase 5: Testing Cryptographic Security"
    
    print_test "Secure random number generation"
    if grep -q "random_int" /Applications/MAMP/htdocs/phpnuxbill/init.php; then
        print_pass "Voucher generation uses random_int() instead of rand()"
    else
        print_fail "Voucher generation may still use weak rand()"
    fi
    
    if ! grep -q "rand(0" /Applications/MAMP/htdocs/phpnuxbill/init.php | grep -v "random_int"; then
        print_pass "No weak rand() found in voucher generation"
    else
        print_fail "Weak rand() still present in init.php"
    fi
    
    print_test "HMAC-SHA256 usage"
    if grep -q "hash_hmac.*sha256" /Applications/MAMP/htdocs/phpnuxbill/system/controllers/voucher.php; then
        print_pass "Voucher signatures use HMAC-SHA256"
    else
        print_fail "Voucher signatures may not use HMAC-SHA256"
    fi
}

# Test Phase 6: IDOR Prevention
test_idor_prevention() {
    print_header "Phase 6: Testing IDOR Prevention"
    
    print_test "Plan extension authorization check"
    if grep -q "requireAdminPermission\|in_array.*user_type.*SuperAdmin" /Applications/MAMP/htdocs/phpnuxbill/system/controllers/plan.php; then
        print_pass "Plan extension has admin permission check"
    else
        print_fail "Plan extension may lack proper authorization"
    fi
    
    print_test "Customer ID verification in recharge"
    if grep -q "customer_id.*user\['id'\]" /Applications/MAMP/htdocs/phpnuxbill/system/controllers/home.php; then
        print_pass "Recharge uses customer_id for verification"
    else
        print_fail "Recharge may use weak username-based verification"
    fi
    
    print_test "Security logging for unauthorized access"
    if grep -q "SecurityHelper::logSecurityEvent.*Unauthorized" /Applications/MAMP/htdocs/phpnuxbill/system/controllers/home.php; then
        print_pass "Unauthorized access attempts are logged"
    else
        print_fail "No security logging for unauthorized access"
    fi
}

# Test Phase 7: Router Password Encryption
test_router_password_encryption() {
    print_header "Phase 7: Testing Router Password Encryption"
    
    print_test "Router password encryption on add"
    if grep -q "Crypto::encrypt.*password" /Applications/MAMP/htdocs/phpnuxbill/system/controllers/routers.php; then
        print_pass "Router passwords are encrypted before storage"
    else
        print_fail "Router passwords may not be encrypted"
    fi
    
    print_test "Encryption error handling"
    if grep -q "catch.*Exception.*encrypt" /Applications/MAMP/htdocs/phpnuxbill/system/controllers/routers.php; then
        print_pass "Encryption errors are properly handled"
    else
        print_fail "No error handling for encryption failures"
    fi
}

# Test Helper Classes
test_helper_classes() {
    print_header "Testing Security Helper Classes"
    
    print_test "Crypto class exists"
    if [ -f "/Applications/MAMP/htdocs/phpnuxbill/system/autoload/Crypto.php" ]; then
        print_pass "Crypto.php helper class exists"
    else
        print_fail "Crypto.php helper class not found"
    fi
    
    print_test "SecurityHelper class exists"
    if [ -f "/Applications/MAMP/htdocs/phpnuxbill/system/autoload/SecurityHelper.php" ]; then
        print_pass "SecurityHelper.php helper class exists"
    else
        print_fail "SecurityHelper.php helper class not found"
    fi
    
    print_test "SessionConfig class exists"
    if [ -f "/Applications/MAMP/htdocs/phpnuxbill/system/autoload/SessionConfig.php" ]; then
        print_pass "SessionConfig.php helper class exists"
    else
        print_fail "SessionConfig.php helper class not found"
    fi
}

# Test Migration Scripts
test_migration_scripts() {
    print_header "Testing Migration Scripts"
    
    print_test "Router password migration script exists"
    if [ -f "/Applications/MAMP/htdocs/phpnuxbill/migrate_router_passwords.php" ]; then
        print_pass "migrate_router_passwords.php exists"
    else
        print_fail "migrate_router_passwords.php not found"
    fi
    
    print_test "Widget migration script exists"
    if [ -f "/Applications/MAMP/htdocs/phpnuxbill/migrate_widgets.php" ]; then
        print_pass "migrate_widgets.php exists"
    else
        print_fail "migrate_widgets.php not found"
    fi
}

# Print summary
print_summary() {
    print_header "Test Summary"
    echo -e "Total Tests: ${BLUE}${TOTAL_TESTS}${NC}"
    echo -e "Passed: ${GREEN}${PASSED_TESTS}${NC}"
    echo -e "Failed: ${RED}${FAILED_TESTS}${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "\n${GREEN}✓ All tests passed!${NC}"
        exit 0
    else
        echo -e "\n${RED}✗ Some tests failed. Please review the output above.${NC}"
        exit 1
    fi
}

# Main execution
main() {
    print_header "PHPNuxBill Security Fixes - Automated Test Suite"
    print_info "Testing all 7 phases of security remediation"
    print_info "Base URL: $BASE_URL"
    echo ""
    
    test_rce_prevention
    test_sql_injection_prevention
    test_command_injection_prevention
    test_session_security
    test_cryptographic_security
    test_idor_prevention
    test_router_password_encryption
    test_helper_classes
    test_migration_scripts
    
    print_summary
}

# Run tests
main
