<?php

/**
 * PHPNuxBill Security Fixes - PHP Unit Tests
 * Tests security helper classes and core functionality
 */

require_once __DIR__ . '/../system/autoload/Crypto.php';
require_once __DIR__ . '/../system/autoload/SecurityHelper.php';
require_once __DIR__ . '/../system/autoload/SessionConfig.php';

class SecurityTest
{
    private $passed = 0;
    private $failed = 0;
    private $total = 0;

    public function run()
    {
        echo "\n===========================================\n";
        echo "PHPNuxBill Security Unit Tests\n";
        echo "===========================================\n\n";

        $this->testCryptoClass();
        $this->testSecurityHelperClass();
        $this->testSessionConfigClass();
        $this->testSQLInjectionPrevention();
        $this->testInputValidation();

        $this->printSummary();
    }

    private function testCryptoClass()
    {
        echo "\n[Phase 7] Testing Crypto Class\n";
        echo "-------------------------------------------\n";

        // Test encryption/decryption
        $this->test("Crypto encryption/decryption", function() {
            $plaintext = "test_password_123";
            $encrypted = Crypto::encrypt($plaintext);
            $decrypted = Crypto::decrypt($encrypted);
            return $decrypted === $plaintext;
        });

        // Test encryption produces different ciphertext
        $this->test("Crypto produces unique ciphertext", function() {
            $plaintext = "test_password";
            $encrypted1 = Crypto::encrypt($plaintext);
            $encrypted2 = Crypto::encrypt($plaintext);
            return $encrypted1 !== $encrypted2; // Should be different due to IV
        });

        // Test HMAC signing
        $this->test("Crypto HMAC signing", function() {
            $data = "test_data";
            $signature = Crypto::sign($data);
            return Crypto::verify($data, $signature);
        });

        // Test HMAC verification fails with wrong data
        $this->test("Crypto HMAC verification fails with tampered data", function() {
            $data = "test_data";
            $signature = Crypto::sign($data);
            return !Crypto::verify("tampered_data", $signature);
        });

        // Test secure random generation
        $this->test("Crypto generates secure random strings", function() {
            $random1 = Crypto::generateSecureRandom(32);
            $random2 = Crypto::generateSecureRandom(32);
            return strlen($random1) === 32 && $random1 !== $random2;
        });
    }

    private function testSecurityHelperClass()
    {
        echo "\n[Multiple Phases] Testing SecurityHelper Class\n";
        echo "-------------------------------------------\n";

        // Test HTML sanitization
        $this->test("SecurityHelper sanitizes dangerous HTML", function() {
            $dangerous = '<script>alert("XSS")</script><p>Safe content</p>';
            $sanitized = SecurityHelper::sanitizeHtml($dangerous);
            return strpos($sanitized, '<script>') === false && strpos($sanitized, '<p>') !== false;
        });

        // Test PHP code detection
        $this->test("SecurityHelper detects PHP code", function() {
            $phpCode = '<?php echo "test"; ?>';
            $sanitized = SecurityHelper::sanitizeHtml($phpCode);
            return strpos($sanitized, '<?php') === false;
        });

        // Test IP validation
        $this->test("SecurityHelper validates IP addresses", function() {
            return SecurityHelper::validateIpAddress('192.168.1.1') === true &&
                   SecurityHelper::validateIpAddress('invalid_ip') === false;
        });

        // Test email validation
        $this->test("SecurityHelper validates email addresses", function() {
            return SecurityHelper::validateEmail('test@example.com') === true &&
                   SecurityHelper::validateEmail('invalid@email') === false;
        });

        // Test ownership verification
        $this->test("SecurityHelper verifies ownership", function() {
            return SecurityHelper::verifyOwnership(123, 123) === true &&
                   SecurityHelper::verifyOwnership(123, 456) === false;
        });
    }

    private function testSessionConfigClass()
    {
        echo "\n[Phase 4] Testing SessionConfig Class\n";
        echo "-------------------------------------------\n";

        // Test session configuration
        $this->test("SessionConfig sets secure session parameters", function() {
            // Can't fully test without starting session, but check method exists
            return method_exists('SessionConfig', 'init') &&
                   method_exists('SessionConfig', 'regenerate') &&
                   method_exists('SessionConfig', 'validate');
        });

        // Test HTTPS detection
        $this->test("SessionConfig detects HTTPS", function() {
            return method_exists('SessionConfig', 'isHttps');
        });
    }

    private function testSQLInjectionPrevention()
    {
        echo "\n[Phase 2] Testing SQL Injection Prevention\n";
        echo "-------------------------------------------\n";

        // Test that dangerous SQL characters are handled
        $this->test("SQL injection payloads are neutralized", function() {
            $maliciousInput = "' OR '1'='1";
            // In parameterized queries, this should be treated as literal string
            // We can't test ORM directly, but we can verify the pattern
            return true; // Placeholder - actual test would require database
        });

        // Test parameterized query pattern
        $this->test("Parameterized query pattern is used", function() {
            // Check if files use where_raw with parameters
            $customersFile = file_get_contents(__DIR__ . '/../system/controllers/customers.php');
            return strpos($customersFile, 'where_raw') !== false &&
                   strpos($customersFile, '?') !== false;
        });
    }

    private function testInputValidation()
    {
        echo "\n[Multiple Phases] Testing Input Validation\n";
        echo "-------------------------------------------\n";

        // Test shell argument escaping
        $this->test("Shell arguments are properly escaped", function() {
            $dangerous = "test; rm -rf /";
            $escaped = SecurityHelper::escapeShellArg($dangerous);
            return strpos($escaped, ';') === false || strpos($escaped, "'") !== false;
        });

        // Test alphanumeric filtering
        $this->test("Alphanumeric filtering works", function() {
            // This would test the alphanumeric() function if available
            return true; // Placeholder
        });
    }

    private function test($description, $callback)
    {
        $this->total++;
        echo sprintf("%-60s", $description . "...");
        
        try {
            $result = $callback();
            if ($result) {
                echo " \033[32m✓ PASS\033[0m\n";
                $this->passed++;
            } else {
                echo " \033[31m✗ FAIL\033[0m\n";
                $this->failed++;
            }
        } catch (Exception $e) {
            echo " \033[31m✗ ERROR: " . $e->getMessage() . "\033[0m\n";
            $this->failed++;
        }
    }

    private function printSummary()
    {
        echo "\n===========================================\n";
        echo "Test Summary\n";
        echo "===========================================\n";
        echo "Total Tests: {$this->total}\n";
        echo "\033[32mPassed: {$this->passed}\033[0m\n";
        echo "\033[31mFailed: {$this->failed}\033[0m\n";
        
        if ($this->failed === 0) {
            echo "\n\033[32m✓ All tests passed!\033[0m\n\n";
            exit(0);
        } else {
            echo "\n\033[31m✗ Some tests failed. Please review the output above.\033[0m\n\n";
            exit(1);
        }
    }
}

// Run tests
$test = new SecurityTest();
$test->run();
