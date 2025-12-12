#!/bin/bash

###############################################################################
# PHPNuxBill - Manual Security Testing Script
# Interactive penetration testing for security fixes
###############################################################################

BASE_URL="${BASE_URL:-http://localhost}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

print_result() {
    echo -e "${GREEN}[RESULT]${NC} $1"
}

print_warning() {
    echo -e "${RED}[WARNING]${NC} $1"
}

# SQL Injection Tests
test_sql_injection() {
    print_header "SQL Injection Tests"
    
    print_test "Testing customer search with SQL injection payload"
    echo "Payload: ' OR '1'='1"
    curl -s "${BASE_URL}/customers?search=%27%20OR%20%271%27=%271" > /tmp/sql_test1.html
    if grep -qi "SQL\|syntax\|error" /tmp/sql_test1.html; then
        print_warning "Possible SQL injection vulnerability detected!"
    else
        print_result "No SQL error messages found (good)"
    fi
    
    print_test "Testing payment gateway with UNION injection"
    echo "Payload: ' UNION SELECT NULL--"
    curl -s "${BASE_URL}/paymentgateway/audit/test?q=%27%20UNION%20SELECT%20NULL--" > /tmp/sql_test2.html
    if grep -qi "SQL\|syntax\|error" /tmp/sql_test2.html; then
        print_warning "Possible SQL injection vulnerability detected!"
    else
        print_result "No SQL error messages found (good)"
    fi
    
    print_test "Testing maps search with DROP TABLE"
    echo "Payload: '; DROP TABLE tbl_customers--"
    curl -s "${BASE_URL}/maps/customer?search=%27%3B%20DROP%20TABLE%20tbl_customers--" > /tmp/sql_test3.html
    if grep -qi "SQL\|syntax\|error" /tmp/sql_test3.html; then
        print_warning "Possible SQL injection vulnerability detected!"
    else
        print_result "No SQL error messages found (good)"
    fi
    
    echo -e "\n${BLUE}Manual Verification:${NC}"
    echo "1. Check database to ensure tbl_customers still exists"
    echo "2. Review /tmp/sql_test*.html for any suspicious output"
    echo "3. Check application logs for SQL errors"
}

# Session Security Tests
test_session_security() {
    print_header "Session Security Tests"
    
    print_test "Testing session fixation via URL parameter"
    echo "Attempting to set session ID via ?uid=malicious_id"
    curl -s -c /tmp/cookies_test.txt "${BASE_URL}/?uid=malicious_session_id" > /dev/null
    if grep -q "malicious_session_id" /tmp/cookies_test.txt 2>/dev/null; then
        print_warning "Session fixation vulnerability detected!"
    else
        print_result "Session cannot be fixed via URL (good)"
    fi
    rm -f /tmp/cookies_test.txt
    
    print_test "Testing session cookie attributes"
    curl -s -D /tmp/headers.txt "${BASE_URL}/" > /dev/null
    if grep -qi "HttpOnly" /tmp/headers.txt; then
        print_result "HttpOnly flag is set (good)"
    else
        print_warning "HttpOnly flag not found"
    fi
    
    if grep -qi "SameSite" /tmp/headers.txt; then
        print_result "SameSite attribute is set (good)"
    else
        print_warning "SameSite attribute not found"
    fi
    rm -f /tmp/headers.txt
    
    echo -e "\n${BLUE}Manual Verification:${NC}"
    echo "1. Login to the application"
    echo "2. Note your session ID from browser cookies"
    echo "3. Try to use that session ID in another browser"
    echo "4. Verify session regenerates after login"
}

# XSS Tests
test_xss() {
    print_header "XSS (Cross-Site Scripting) Tests"
    
    print_test "Testing reflected XSS in search"
    echo "Payload: <script>alert('XSS')</script>"
    curl -s "${BASE_URL}/customers?search=%3Cscript%3Ealert%28%27XSS%27%29%3C%2Fscript%3E" > /tmp/xss_test1.html
    if grep -q "<script>alert" /tmp/xss_test1.html; then
        print_warning "Possible XSS vulnerability detected!"
    else
        print_result "XSS payload appears to be filtered (good)"
    fi
    
    print_test "Testing stored XSS in widget content"
    echo "Note: This requires admin access to create a widget"
    echo "Payload: <?php echo 'RCE'; ?>"
    print_result "Manual test required - create widget with PHP code"
    
    echo -e "\n${BLUE}Manual Verification:${NC}"
    echo "1. Try to create a widget with: <?php system('whoami'); ?>"
    echo "2. Verify the code is displayed as text, not executed"
    echo "3. Check security logs for PHP code detection"
}

# IDOR Tests
test_idor() {
    print_header "IDOR (Insecure Direct Object Reference) Tests"
    
    print_test "Testing unauthorized recharge access"
    echo "Note: This requires two user accounts"
    echo "1. Login as User A and note a recharge ID"
    echo "2. Login as User B"
    echo "3. Try to access User A's recharge: /home?recharge=<ID>"
    print_result "Manual test required"
    
    print_test "Testing unauthorized plan deactivation"
    echo "1. Login as User A and note a plan ID"
    echo "2. Login as User B"
    echo "3. Try to deactivate User A's plan: /home?deactivate=<ID>"
    print_result "Manual test required"
    
    echo -e "\n${BLUE}Manual Verification:${NC}"
    echo "1. Attempt should be blocked"
    echo "2. Check security logs for unauthorized access attempts"
    echo "3. Verify error message is shown to User B"
}

# Authentication Tests
test_authentication() {
    print_header "Authentication Tests"
    
    print_test "Testing brute force protection"
    echo "Attempting multiple failed logins..."
    for i in {1..5}; do
        curl -s -X POST "${BASE_URL}/admin/post" \
            -d "username=admin&password=wrong_password_$i" > /dev/null
        echo "Attempt $i/5"
    done
    print_result "Check if account is locked or rate limited"
    
    print_test "Testing password complexity"
    echo "Note: Try to create user with weak password"
    print_result "Manual test required"
    
    echo -e "\n${BLUE}Manual Verification:${NC}"
    echo "1. Check if rate limiting is active"
    echo "2. Verify account lockout after failed attempts"
    echo "3. Test password complexity requirements"
}

# File Upload Tests
test_file_upload() {
    print_header "File Upload Tests"
    
    print_test "Testing malicious file upload"
    echo "Note: Try to upload PHP file as image"
    echo "Create file: test.php.jpg with PHP code"
    print_result "Manual test required"
    
    echo -e "\n${BLUE}Manual Verification:${NC}"
    echo "1. Try to upload: test.php.jpg containing <?php phpinfo(); ?>"
    echo "2. Verify file type validation"
    echo "3. Check if uploaded file can be executed"
}

# Command Injection Tests
test_command_injection() {
    print_header "Command Injection Tests"
    
    print_test "Testing Radius disconnect command injection"
    echo "Note: This requires Radius configuration"
    echo "Payload: username; whoami"
    print_result "Manual test required - check Radius logs"
    
    echo -e "\n${BLUE}Manual Verification:${NC}"
    echo "1. Create user with username: test; whoami"
    echo "2. Attempt Radius disconnect"
    echo "3. Check if command was executed"
    echo "4. Verify proper shell escaping in logs"
}

# Cryptography Tests
test_cryptography() {
    print_header "Cryptography Tests"
    
    print_test "Testing voucher code randomness"
    echo "Generating 10 vouchers to check for patterns..."
    print_result "Manual test required - generate vouchers and check for patterns"
    
    print_test "Testing router password encryption"
    echo "1. Add a router with password 'test123'"
    echo "2. Check database: SELECT password FROM tbl_routers"
    echo "3. Verify password is encrypted (not 'test123')"
    print_result "Manual test required"
    
    echo -e "\n${BLUE}Manual Verification:${NC}"
    echo "1. Generate multiple vouchers"
    echo "2. Verify codes are random and unique"
    echo "3. Check router passwords in database are encrypted"
}

# Print summary
print_summary() {
    print_header "Manual Testing Summary"
    echo "All automated tests completed."
    echo ""
    echo "Please review the output above and perform manual verification steps."
    echo ""
    echo "Key files to check:"
    echo "  - /tmp/sql_test*.html - SQL injection test results"
    echo "  - /tmp/xss_test*.html - XSS test results"
    echo "  - Application error logs"
    echo "  - Security event logs (tbl_logs)"
    echo ""
    echo "Next steps:"
    echo "  1. Review all test results"
    echo "  2. Perform manual verification steps"
    echo "  3. Document any findings"
    echo "  4. Fix any identified issues"
    echo "  5. Re-run tests"
}

# Main execution
main() {
    print_header "PHPNuxBill Manual Security Testing"
    echo "Base URL: $BASE_URL"
    echo ""
    echo "This script will perform various security tests."
    echo "Some tests require manual verification."
    echo ""
    read -p "Press Enter to continue..."
    
    test_sql_injection
    test_session_security
    test_xss
    test_idor
    test_authentication
    test_file_upload
    test_command_injection
    test_cryptography
    
    print_summary
}

# Run tests
main
