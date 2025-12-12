<?php

/**
 * Session Configuration Class
 * Configures secure session settings
 */
class SessionConfig
{
    /**
     * Initialize secure session configuration
     * Should be called before session_start()
     */
    public static function init()
    {
        // Prevent session fixation - use strict mode
        ini_set('session.use_strict_mode', 1);
        
        // Session ID should only be in cookies, not URLs
        ini_set('session.use_only_cookies', 1);
        ini_set('session.use_trans_sid', 0);
        
        // Make session cookies HTTP only (not accessible via JavaScript)
        ini_set('session.cookie_httponly', 1);
        
        // Make session cookies secure (HTTPS only)
        // Note: Only enable if site uses HTTPS
        if (self::isHttps()) {
            ini_set('session.cookie_secure', 1);
        }
        
        // Set SameSite attribute to prevent CSRF
        ini_set('session.cookie_samesite', 'Strict');
        
        // Session timeout (30 minutes of inactivity)
        ini_set('session.gc_maxlifetime', 1800);
        ini_set('session.cookie_lifetime', 1800);
        
        // Use stronger session ID hashing
        ini_set('session.hash_function', 'sha256');
        ini_set('session.hash_bits_per_character', 5);
        
        // Increase entropy for session ID generation
        ini_set('session.entropy_length', 32);
        
        // Custom session name (don't use default PHPSESSID)
        session_name('PNBSESSID');
    }

    /**
     * Check if connection is HTTPS
     * 
     * @return bool True if HTTPS
     */
    private static function isHttps()
    {
        if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') {
            return true;
        }
        
        if (isset($_SERVER['SERVER_PORT']) && $_SERVER['SERVER_PORT'] == 443) {
            return true;
        }
        
        // Check for proxy/load balancer headers
        if (!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
            return true;
        }
        
        return false;
    }

    /**
     * Regenerate session ID (call after login)
     * Prevents session fixation attacks
     */
    public static function regenerate()
    {
        session_regenerate_id(true);
    }

    /**
     * Validate session is not expired
     * 
     * @return bool True if session is valid
     */
    public static function validate()
    {
        // Check if session has last activity timestamp
        if (isset($_SESSION['last_activity'])) {
            $inactive = time() - $_SESSION['last_activity'];
            
            // If inactive for more than 30 minutes, destroy session
            if ($inactive > 1800) {
                session_unset();
                session_destroy();
                return false;
            }
        }
        
        // Update last activity timestamp
        $_SESSION['last_activity'] = time();
        
        // Check if session has creation timestamp
        if (!isset($_SESSION['created'])) {
            $_SESSION['created'] = time();
        } else {
            // If session is older than 2 hours, regenerate ID
            if (time() - $_SESSION['created'] > 7200) {
                self::regenerate();
                $_SESSION['created'] = time();
            }
        }
        
        return true;
    }

    /**
     * Destroy session securely
     */
    public static function destroy()
    {
        // Unset all session variables
        $_SESSION = array();
        
        // Delete session cookie
        if (ini_get("session.use_cookies")) {
            $params = session_get_cookie_params();
            setcookie(
                session_name(),
                '',
                time() - 42000,
                $params["path"],
                $params["domain"],
                $params["secure"],
                $params["httponly"]
            );
        }
        
        // Destroy session
        session_destroy();
    }
}
