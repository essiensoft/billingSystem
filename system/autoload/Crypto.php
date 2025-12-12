<?php

/**
 * Cryptography Utility Class
 * Provides encryption/decryption for sensitive data
 * 
 * Usage:
 *   $encrypted = Crypto::encrypt($password);
 *   $decrypted = Crypto::decrypt($encrypted);
 */
class Crypto
{
    /**
     * Get encryption key derived from database password
     * 
     * @return string Binary encryption key (32 bytes for AES-256)
     */
    private static function getKey()
    {
        global $db_pass, $config;
        
        // Derive encryption key from database password and app secret
        // This ensures key is unique per installation
        $salt = $config['app_secret'] ?? 'phpnuxbill_default_salt_change_me';
        
        return hash('sha256', $db_pass . $salt, true);
    }

    /**
     * Encrypt sensitive data using AES-256-CBC
     * 
     * @param string $data Data to encrypt
     * @return string Base64 encoded encrypted data with IV
     */
    public static function encrypt($data)
    {
        if (empty($data)) {
            return $data;
        }

        try {
            $key = self::getKey();
            
            // Generate random IV (Initialization Vector)
            $iv = random_bytes(16);
            
            // Encrypt using AES-256-CBC
            $encrypted = openssl_encrypt(
                $data,
                'AES-256-CBC',
                $key,
                OPENSSL_RAW_DATA,
                $iv
            );
            
            if ($encrypted === false) {
                throw new Exception('Encryption failed');
            }
            
            // Return base64 encoded IV + encrypted data
            // IV is prepended so we can extract it during decryption
            return base64_encode($iv . $encrypted);
            
        } catch (Exception $e) {
            _log("Crypto::encrypt() failed: " . $e->getMessage(), 'System', 0);
            throw new Exception('Encryption failed. Please contact administrator.');
        }
    }

    /**
     * Decrypt data encrypted with encrypt()
     * 
     * @param string $data Base64 encoded encrypted data
     * @return string Decrypted plaintext data
     */
    public static function decrypt($data)
    {
        if (empty($data)) {
            return $data;
        }

        try {
            $key = self::getKey();
            
            // Decode base64
            $decoded = base64_decode($data, true);
            
            if ($decoded === false) {
                throw new Exception('Invalid base64 data');
            }
            
            // Extract IV (first 16 bytes)
            $iv = substr($decoded, 0, 16);
            $encrypted = substr($decoded, 16);
            
            // Decrypt
            $decrypted = openssl_decrypt(
                $encrypted,
                'AES-256-CBC',
                $key,
                OPENSSL_RAW_DATA,
                $iv
            );
            
            if ($decrypted === false) {
                throw new Exception('Decryption failed');
            }
            
            return $decrypted;
            
        } catch (Exception $e) {
            _log("Crypto::decrypt() failed: " . $e->getMessage(), 'System', 0);
            throw new Exception('Decryption failed. Please contact administrator.');
        }
    }

    /**
     * Check if data appears to be encrypted
     * 
     * @param string $data Data to check
     * @return bool True if data looks encrypted
     */
    public static function isEncrypted($data)
    {
        if (empty($data)) {
            return false;
        }
        
        // Check if it's valid base64 and has minimum length (IV + some data)
        $decoded = base64_decode($data, true);
        return $decoded !== false && strlen($decoded) > 16;
    }

    /**
     * Generate cryptographically secure random string
     * 
     * @param int $length Length of random string
     * @param string $characters Character set to use
     * @return string Random string
     */
    public static function randomString($length = 32, $characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz')
    {
        $charactersLength = strlen($characters);
        $randomString = '';
        
        try {
            for ($i = 0; $i < $length; $i++) {
                $randomString .= $characters[random_int(0, $charactersLength - 1)];
            }
        } catch (Exception $e) {
            _log("Crypto::randomString() failed: " . $e->getMessage(), 'System', 0);
            throw new Exception('Random string generation failed');
        }
        
        return $randomString;
    }

    /**
     * Generate HMAC signature for data integrity
     * 
     * @param string $data Data to sign
     * @param string $context Context/purpose of signature
     * @return string HMAC signature
     */
    public static function sign($data, $context = 'default')
    {
        global $db_pass;
        
        // Create context-specific key
        $key = hash('sha256', $db_pass . '_signature_' . $context);
        
        return hash_hmac('sha256', $data, $key);
    }

    /**
     * Verify HMAC signature
     * 
     * @param string $data Data to verify
     * @param string $signature Signature to check
     * @param string $context Context/purpose of signature
     * @return bool True if signature is valid
     */
    public static function verify($data, $signature, $context = 'default')
    {
        $expected = self::sign($data, $context);
        
        // Use hash_equals to prevent timing attacks
        return hash_equals($expected, $signature);
    }
}
