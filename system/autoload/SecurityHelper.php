<?php

/**
 * Security Helper Utility Class
 * Common security functions for access control and validation
 */
class SecurityHelper
{
    /**
     * Verify ownership of a database record
     * 
     * @param string $table Table name
     * @param int $recordId Record ID to check
     * @param int $userId User ID that should own the record
     * @param string $userField Field name for user ID (default: customer_id)
     * @return bool True if user owns the record
     */
    public static function verifyOwnership($table, $recordId, $userId, $userField = 'customer_id')
    {
        $record = ORM::for_table($table)
            ->where('id', $recordId)
            ->where($userField, $userId)
            ->find_one();
        
        return $record !== false;
    }

    /**
     * Require admin permission or redirect
     * 
     * @param array $allowedTypes Allowed user types (default: SuperAdmin, Admin)
     * @throws void Redirects if permission denied
     */
    public static function requireAdminPermission($allowedTypes = ['SuperAdmin', 'Admin'])
    {
        $admin = Admin::_info();
        if (!in_array($admin['user_type'], $allowedTypes)) {
            _alert(Lang::T('You do not have permission to access this page'), 'danger', "dashboard");
        }
    }

    /**
     * Check if user has admin permission
     * 
     * @param array $allowedTypes Allowed user types
     * @return bool True if user has permission
     */
    public static function hasAdminPermission($allowedTypes = ['SuperAdmin', 'Admin'])
    {
        $admin = Admin::_info();
        return in_array($admin['user_type'], $allowedTypes);
    }

    /**
     * Sanitize HTML for safe display
     * Allows only safe HTML tags
     * 
     * @param string $html HTML to sanitize
     * @return string Sanitized HTML
     */
    public static function sanitizeHtml($html)
    {
        if (empty($html)) {
            return $html;
        }
        
        // Allow only safe HTML tags
        $allowed_tags = '<p><br><b><i><u><strong><em><ul><ol><li><a><span><div><h1><h2><h3><h4><h5><h6><table><tr><td><th><thead><tbody>';
        
        $sanitized = strip_tags($html, $allowed_tags);
        
        // Remove dangerous attributes
        $sanitized = preg_replace('/<([^>]+)\s+(on\w+)=["\'].*?["\']/i', '<$1', $sanitized);
        
        return $sanitized;
    }

    /**
     * Validate IP address format
     * 
     * @param string $ip IP address to validate
     * @param bool $allowIPv6 Allow IPv6 addresses (default: true)
     * @return bool True if valid IP address
     */
    public static function validateIpAddress($ip, $allowIPv6 = true)
    {
        if (empty($ip)) {
            return false;
        }
        
        $flags = FILTER_FLAG_IPV4;
        if ($allowIPv6) {
            $flags = FILTER_FLAG_IPV4 | FILTER_FLAG_IPV6;
        }
        
        return filter_var($ip, FILTER_VALIDATE_IP, $flags) !== false;
    }

    /**
     * Validate email address format
     * 
     * @param string $email Email to validate
     * @return bool True if valid email
     */
    public static function validateEmail($email)
    {
        if (empty($email)) {
            return false;
        }
        
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }

    /**
     * Get client IP address (handles proxies and load balancers)
     * 
     * @return string Client IP address
     */
    public static function getClientIp()
    {
        // Check for Cloudflare
        if (!empty($_SERVER['HTTP_CF_CONNECTING_IP'])) {
            return $_SERVER['HTTP_CF_CONNECTING_IP'];
        }
        
        // Check for proxy
        if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            // X-Forwarded-For can contain multiple IPs, get the first one
            $ips = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
            return trim($ips[0]);
        }
        
        // Check for shared internet
        if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            return $_SERVER['HTTP_CLIENT_IP'];
        }
        
        // Default
        if (isset($_SERVER['REMOTE_ADDR'])) {
            return $_SERVER['REMOTE_ADDR'];
        }
        
        return 'Unknown';
    }

    /**
     * Rate limiting check
     * 
     * @param string $action Action being rate limited
     * @param string $identifier Identifier (IP, user ID, etc.)
     * @param int $maxAttempts Maximum attempts allowed
     * @param int $timeWindow Time window in seconds
     * @return bool True if action is allowed, false if rate limited
     */
    public static function checkRateLimit($action, $identifier, $maxAttempts = 5, $timeWindow = 60)
    {
        $key = 'ratelimit_' . $action . '_' . $identifier;
        $cacheFile = $GLOBALS['CACHE_PATH'] . DIRECTORY_SEPARATOR . md5($key) . '.cache';
        
        $now = time();
        $attempts = [];
        
        // Load existing attempts
        if (file_exists($cacheFile)) {
            $data = json_decode(file_get_contents($cacheFile), true);
            if ($data && isset($data['attempts'])) {
                $attempts = $data['attempts'];
            }
        }
        
        // Remove old attempts outside time window
        $attempts = array_filter($attempts, function($timestamp) use ($now, $timeWindow) {
            return ($now - $timestamp) < $timeWindow;
        });
        
        // Check if rate limit exceeded
        if (count($attempts) >= $maxAttempts) {
            return false;
        }
        
        // Add current attempt
        $attempts[] = $now;
        
        // Save attempts
        file_put_contents($cacheFile, json_encode(['attempts' => $attempts]));
        
        return true;
    }

    /**
     * Clear rate limit for identifier
     * 
     * @param string $action Action being rate limited
     * @param string $identifier Identifier to clear
     */
    public static function clearRateLimit($action, $identifier)
    {
        $key = 'ratelimit_' . $action . '_' . $identifier;
        $cacheFile = $GLOBALS['CACHE_PATH'] . DIRECTORY_SEPARATOR . md5($key) . '.cache';
        
        if (file_exists($cacheFile)) {
            unlink($cacheFile);
        }
    }

    /**
     * Generate CSRF token
     * 
     * @return string CSRF token
     */
    public static function generateCsrfToken()
    {
        if (!isset($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }
        return $_SESSION['csrf_token'];
    }

    /**
     * Validate CSRF token
     * 
     * @param string $token Token to validate
     * @return bool True if valid
     */
    public static function validateCsrfToken($token)
    {
        if (!isset($_SESSION['csrf_token'])) {
            return false;
        }
        
        return hash_equals($_SESSION['csrf_token'], $token);
    }

    /**
     * Escape shell argument safely
     * 
     * @param string $arg Argument to escape
     * @return string Escaped argument
     */
    public static function escapeShellArg($arg)
    {
        return escapeshellarg($arg);
    }

    /**
     * Log security event
     * 
     * @param string $event Event description
     * @param string $severity Severity level (low, medium, high, critical)
     * @param array $context Additional context
     */
    public static function logSecurityEvent($event, $severity = 'medium', $context = [])
    {
        $ip = self::getClientIp();
        $userId = 0;
        
        if (User::getID()) {
            $userId = User::getID();
        } elseif (Admin::getID()) {
            $userId = Admin::getID();
        }
        
        $contextStr = !empty($context) ? json_encode($context) : '';
        
        _log(
            "SECURITY [{$severity}]: {$event} | IP: {$ip} | Context: {$contextStr}",
            'Security',
            $userId
        );
    }
}
