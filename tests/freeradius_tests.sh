#!/bin/bash
# FreeRADIUS Configuration Tests
# Run these tests to validate FreeRADIUS configuration before deployment

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Test result functions
pass() {
    echo "✓ PASS: $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    echo "✗ FAIL: $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

warn() {
    echo "⚠ WARN: $1"
    WARN_COUNT=$((WARN_COUNT + 1))
}

# ============================================================================
# UNIT TESTS - Configuration File Validation
# ============================================================================

echo ""
echo "=========================================="
echo " UNIT TESTS - FreeRADIUS Configuration"
echo "=========================================="
echo ""

# Test 1: Check that freeradius directory exists
echo "--- Test: FreeRADIUS directory structure ---"
if [ -d "freeradius" ]; then
    pass "freeradius/ directory exists"
else
    fail "freeradius/ directory missing"
fi

# Test 2: Check required configuration files exist
REQUIRED_FILES=(
    "freeradius/mods-available/sql"
    "freeradius/mods-available/sqlcounter"
    "freeradius/sites-available/default"
    "freeradius/clients.conf"
    "freeradius/mods-config/sql/counter/mysql/accessperiod.conf"
    "freeradius/mods-config/sql/counter/mysql/quotalimit.conf"
)

echo "--- Test: Required configuration files ---"
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "File exists: $file"
    else
        fail "File missing: $file"
    fi
done

# Test 3: Validate SQL module configuration
echo ""
echo "--- Test: SQL module configuration ---"
if grep -q "driver = \"rlm_sql_mysql\"" freeradius/mods-available/sql; then
    pass "SQL driver configured for MySQL"
else
    fail "SQL driver not set to MySQL"
fi

if grep -q "server = \"mysql\"" freeradius/mods-available/sql; then
    pass "SQL server set to 'mysql' (Docker service name)"
else
    fail "SQL server not set to Docker service name"
fi

if grep -q "radius_db = \"phpnuxbill\"" freeradius/mods-available/sql; then
    pass "Database name set to phpnuxbill"
else
    fail "Database name not set correctly"
fi

if grep -q "read_clients = yes" freeradius/mods-available/sql; then
    pass "Dynamic NAS client reading enabled"
else
    fail "Dynamic NAS client reading not enabled"
fi

if grep -q "client_table = \"nas\"" freeradius/mods-available/sql; then
    pass "NAS client table configured"
else
    fail "NAS client table not configured"
fi

# Test 4: Validate sites-available/default
echo ""
echo "--- Test: Site default configuration ---"
if grep -q "type = auth" freeradius/sites-available/default; then
    pass "Auth listener configured"
else
    fail "Auth listener not configured"
fi

if grep -q "type = acct" freeradius/sites-available/default; then
    pass "Accounting listener configured"
else
    fail "Accounting listener not configured"
fi

if grep -q "sql" freeradius/sites-available/default; then
    pass "SQL module referenced in site config"
else
    fail "SQL module not referenced in site config"
fi

# Test 5: Validate clients.conf
echo ""
echo "--- Test: Clients configuration ---"
if grep -q "client localhost" freeradius/clients.conf; then
    pass "Localhost client configured"
else
    fail "Localhost client not configured"
fi

if grep -q "secret = testing123" freeradius/clients.conf; then
    pass "Test secret configured for localhost"
else
    warn "Default test secret not found (may be customized)"
fi

if grep -q "client dockernet" freeradius/clients.conf; then
    pass "Docker network client configured"
else
    fail "Docker network client not configured"
fi

# Test 6: Validate sqlcounter module
echo ""
echo "--- Test: SQL Counter configuration ---"
if grep -q "sqlcounter accessperiod" freeradius/mods-available/sqlcounter; then
    pass "Access period counter configured"
else
    fail "Access period counter not configured"
fi

if grep -q "sqlcounter quotalimit" freeradius/mods-available/sqlcounter; then
    pass "Quota limit counter configured"
else
    fail "Quota limit counter not configured"
fi

if grep -q "sqlcounter uptimelimit" freeradius/mods-available/sqlcounter; then
    pass "Uptime limit counter configured"
else
    fail "Uptime limit counter not configured"
fi

# Test 7: Validate counter query files
echo ""
echo "--- Test: Counter query files ---"
if grep -q "AcctStartTime" freeradius/mods-config/sql/counter/mysql/accessperiod.conf; then
    pass "Access period query valid"
else
    fail "Access period query invalid"
fi

if grep -q "acctinputoctets" freeradius/mods-config/sql/counter/mysql/quotalimit.conf; then
    pass "Quota limit query valid"
else
    fail "Quota limit query invalid"
fi

# ============================================================================
# INTEGRATION TESTS - Docker Compose Validation
# ============================================================================

echo ""
echo "=========================================="
echo " INTEGRATION TESTS - Docker Compose"
echo "=========================================="
echo ""

# Test 8: Validate docker-compose.production.yml has FreeRADIUS service  
echo "--- Test: Docker Compose FreeRADIUS service ---"
if grep -q "freeradius:" docker-compose.production.yml; then
    pass "FreeRADIUS service defined in docker-compose"
else
    fail "FreeRADIUS service not found in docker-compose"
fi

if grep -q "freeradius/freeradius-server" docker-compose.production.yml; then
    pass "FreeRADIUS image specified"
else
    fail "FreeRADIUS image not specified"
fi

if grep -q "1812:1812/udp" docker-compose.production.yml; then
    pass "Auth port 1812/udp exposed"
else
    fail "Auth port 1812/udp not exposed"
fi

if grep -q "1813:1813/udp" docker-compose.production.yml; then
    pass "Accounting port 1813/udp exposed"
else
    fail "Accounting port 1813/udp not exposed"
fi

if grep -q "3799:3799/udp" docker-compose.production.yml; then
    pass "CoA port 3799/udp exposed"
else
    fail "CoA port 3799/udp not exposed"
fi

# Test 9: Validate Dockerfile has freeradius-utils
echo ""  
echo "--- Test: Dockerfile freeradius-utils ---"
if grep -q "freeradius-utils" Dockerfile; then
    pass "freeradius-utils package in Dockerfile"
else
    fail "freeradius-utils package missing from Dockerfile"
fi

# Test 10: Validate environment file has RADIUS section
echo ""
echo "--- Test: Environment configuration ---"
if grep -q "FREERADIUS CONFIGURATION" .env.production.example; then
    pass "FreeRADIUS section in .env.production.example"
else
    fail "FreeRADIUS section missing from .env.production.example"
fi

if grep -q "RADIUS_SECRET" .env.production.example; then
    pass "RADIUS_SECRET variable documented"
else
    fail "RADIUS_SECRET variable not documented"
fi

# Test 11: Validate documentation exists
echo ""
echo "--- Test: Documentation ---"
if [ -f "FREERADIUS_SETUP.md" ]; then
    pass "FREERADIUS_SETUP.md exists"
    
    if grep -q "MikroTik" FREERADIUS_SETUP.md; then
        pass "MikroTik configuration documented"
    else
        warn "MikroTik configuration not documented"
    fi
    
    if grep -q "radtest" FREERADIUS_SETUP.md; then
        pass "Testing instructions documented"
    else
        warn "Testing instructions not documented"
    fi
else
    fail "FREERADIUS_SETUP.md missing"
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "=========================================="
echo " TEST SUMMARY"
echo "=========================================="
echo ""
echo "  Passed: $PASS_COUNT"
echo "  Failed: $FAIL_COUNT"
echo "  Warnings: $WARN_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed. Please review the output above."
    exit 1
fi
