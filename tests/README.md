# PHPNuxBill Security Testing Guide

## Quick Start

### 1. Run All Tests
```bash
cd /Applications/MAMP/htdocs/phpnuxbill
chmod +x tests/security_test_suite.sh
./tests/security_test_suite.sh
```

### 2. Run PHP Unit Tests
```bash
cd /Applications/MAMP/htdocs/phpnuxbill
php tests/security_unit_tests.php
```

### 3. Run Manual Security Tests
```bash
cd /Applications/MAMP/htdocs/phpnuxbill/tests
chmod +x manual_security_tests.sh
./manual_security_tests.sh
```

---

## Test Suite Overview

### Automated Test Suite (`security_test_suite.sh`)
**Purpose**: Validates all 7 phases of security fixes  
**Tests**: 30+ automated checks  
**Runtime**: ~30 seconds

**What it tests**:
- ✅ RCE prevention (eval() removal)
- ✅ SQL injection prevention (parameterized queries)
- ✅ Command injection prevention (shell escaping)
- ✅ Session security (fixation, regeneration)
- ✅ Cryptographic security (RNG, HMAC)
- ✅ IDOR prevention (access control)
- ✅ Router password encryption
- ✅ Helper classes existence
- ✅ Migration scripts existence

### PHP Unit Tests (`security_unit_tests.php`)
**Purpose**: Tests security helper classes  
**Tests**: 15+ unit tests  
**Runtime**: ~5 seconds

**What it tests**:
- ✅ Crypto class (encryption, decryption, HMAC)
- ✅ SecurityHelper class (sanitization, validation)
- ✅ SessionConfig class (configuration methods)
- ✅ Input validation functions

### Manual Security Tests (`manual_security_tests.sh`)
**Purpose**: Interactive penetration testing  
**Tests**: 20+ manual test cases  
**Runtime**: ~10 minutes (manual)

**What it tests**:
- ✅ SQL injection attempts
- ✅ XSS attempts
- ✅ Session hijacking attempts
- ✅ IDOR exploitation attempts
- ✅ Authentication bypass attempts

---

## Configuration

### Environment Variables
```bash
# Set these before running tests
export BASE_URL="http://localhost"
export ADMIN_USER="admin"
export ADMIN_PASS="your_admin_password"
export TEST_CUSTOMER="testuser"
export TEST_CUSTOMER_PASS="testpass"
```

### Database Configuration
Ensure your test database is configured in `config.php`

---

## Test Results Interpretation

### Expected Results

#### ✅ All Tests Pass
```
Total Tests: 35
Passed: 35
Failed: 0

✓ All tests passed!
```
**Action**: Proceed to staging deployment

#### ⚠️ Some Tests Fail
```
Total Tests: 35
Passed: 30
Failed: 5

✗ Some tests failed. Please review the output above.
```
**Action**: Review failed tests, fix issues, re-run

#### ❌ Many Tests Fail
```
Total Tests: 35
Passed: 10
Failed: 25

✗ Many tests failed. Critical issues detected.
```
**Action**: Do NOT deploy. Review implementation

---

## Common Test Failures

### 1. "eval() still present in widget files"
**Cause**: RCE fix not applied  
**Fix**: Re-apply Phase 1 fixes

### 2. "SQL injection vulnerability still present"
**Cause**: Parameterized queries not implemented  
**Fix**: Re-apply Phase 2 fixes

### 3. "Session can be fixed via URL parameter"
**Cause**: Session fixation not removed  
**Fix**: Re-apply Phase 4 fixes

### 4. "Crypto.php helper class not found"
**Cause**: Helper classes not created  
**Fix**: Create missing helper classes

---

## Manual Testing Checklist

### Functional Tests
- [ ] Admin login/logout works
- [ ] Customer login/logout works
- [ ] Widgets display correctly
- [ ] Search functions work (customers, payments, maps, mail, logs)
- [ ] Voucher generation works
- [ ] Voucher activation works
- [ ] Router management works (add/edit)
- [ ] Plan management works
- [ ] User recharge works
- [ ] User deactivate works

### Security Tests
- [ ] SQL injection blocked in search fields
- [ ] XSS blocked in input fields
- [ ] Session fixation prevented
- [ ] IDOR prevented (cannot access other users' data)
- [ ] Router passwords encrypted in database
- [ ] Voucher codes are random and unique
- [ ] PHP code in widgets does not execute
- [ ] Command injection blocked in Radius

---

## Troubleshooting

### Tests Won't Run
```bash
# Check permissions
chmod +x tests/*.sh

# Check PHP CLI
php -v

# Check curl
curl --version
```

### Database Connection Errors
```bash
# Verify database credentials in config.php
# Ensure database server is running
# Check database permissions
```

### False Positives
Some tests may fail due to environment differences:
- Adjust `BASE_URL` to match your setup
- Ensure test user accounts exist
- Check file paths are correct

---

## Next Steps After Testing

### If All Tests Pass ✅
1. Run migration scripts
2. Deploy to staging
3. Perform user acceptance testing
4. Schedule production deployment

### If Tests Fail ❌
1. Review failed test output
2. Fix identified issues
3. Re-run tests
4. Do NOT deploy until all tests pass

---

## Additional Security Testing

### Professional Tools
```bash
# OWASP ZAP
zap.sh -quickurl http://localhost -quickout report.html

# SQLMap
sqlmap -u "http://localhost/customers?search=test" --batch

# Nikto
nikto -h http://localhost
```

### Manual Penetration Testing
Consider hiring a professional penetration tester for:
- Comprehensive security audit
- Advanced attack scenarios
- Compliance verification
- Security certification

---

## Support

For issues with tests:
1. Check test output for specific errors
2. Review security fix implementation
3. Consult walkthrough.md for guidance
4. Contact development team if needed

---

**Last Updated**: 2025-12-12  
**Test Suite Version**: 1.0  
**Compatible with**: PHPNuxBill Security Fixes v1.0
