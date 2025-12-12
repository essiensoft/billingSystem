<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>{Lang::T('Admin Login')} - {$_c['CompanyName']}</title>
    <link rel="shortcut icon" href="{$app_url}/ui/ui/images/logo.png" type="image/x-icon" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

    <style>
    {literal}
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            overflow-x: hidden;
        }

        /* Desktop Layout - Split Screen Design */
        .login-container {
            display: flex;
            min-height: 100vh;
            width: 100%;
        }

        /* Left Side - Illustration (Desktop Only) */
        .left-section {
            flex: 0 0 55%;
            background: linear-gradient(135deg, rgba(31, 41, 55, 0.95) 0%, rgba(55, 65, 81, 0.95) 50%, rgba(75, 85, 99, 0.95) 100%);
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 80px 60px;
            color: white;
            overflow: hidden;
        }

        .left-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-image: url({/literal}'{$app_url}/ui/ui/images/wifi-community.jpg'{literal});
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            opacity: 0.12;
            z-index: 1;
        }

        .left-section::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            backdrop-filter: blur(4px);
            -webkit-backdrop-filter: blur(4px);
            z-index: 2;
        }

        .logo-section {
            position: absolute;
            top: 40px;
            left: 60px;
            z-index: 10;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .logo {
            width: 55px;
            height: 55px;
            background: linear-gradient(135deg, #C9A86A 0%, #E8AA42 100%);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            font-weight: 700;
            color: white;
            box-shadow: 0 10px 25px rgba(201, 168, 106, 0.3);
            flex-shrink: 0;
        }

        .logo img {
            max-width: 90%;
            max-height: 90%;
            object-fit: contain;
        }

        .company-name-header {
            font-size: 19px;
            font-weight: 700;
            color: white;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
        }

        .illustration-content {
            position: relative;
            z-index: 10;
            text-align: center;
            max-width: 520px;
        }

        .illustration-content h1 {
            font-size: 42px;
            font-weight: 700;
            line-height: 1.3;
            margin-bottom: 24px;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
        }

        .illustration-content p {
            font-size: 18px;
            line-height: 1.6;
            opacity: 0.9;
            font-weight: 400;
        }

        .admin-badge-large {
            display: inline-block;
            background: linear-gradient(135deg, #C9A86A, #E8AA42);
            color: white;
            padding: 8px 20px;
            border-radius: 24px;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            margin-bottom: 30px;
            box-shadow: 0 4px 12px rgba(201, 168, 106, 0.3);
        }

        /* Right Side - Form (Desktop) */
        .right-section {
            flex: 0 0 45%;
            background: #FFFFFF;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 80px 70px;
            position: relative;
        }

        .form-container {
            width: 100%;
            max-width: 420px;
        }

        .welcome-text {
            margin-bottom: 40px;
            text-align: center;
        }

        .admin-badge {
            display: inline-block;
            background: linear-gradient(135deg, #C9A86A, #E8AA42);
            color: white;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.5px;
            margin-bottom: 20px;
        }

        .welcome-title {
            font-size: 32px;
            font-weight: 700;
            color: #1F2937;
            margin-bottom: 8px;
        }

        .welcome-subtitle {
            font-size: 15px;
            color: #6B7280;
            font-weight: 400;
        }

        .alert {
            padding: 13px 16px;
            border-radius: 10px;
            margin-bottom: 24px;
            font-size: 14px;
            font-weight: 500;
        }

        .alert-danger {
            background: #FEF2F2;
            border: 1px solid #FCA5A5;
            color: #991B1B;
        }

        .alert-success {
            background: #F0FDF4;
            border: 1px solid #86EFAC;
            color: #065F46;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 8px;
        }

        .input-wrapper {
            position: relative;
        }

        .form-input {
            width: 100%;
            padding: 13px 16px;
            border: 1.5px solid #E5E7EB;
            border-radius: 10px;
            font-size: 15px;
            color: #1F2937;
            background: white;
            transition: all 0.2s;
            outline: none;
            font-weight: 400;
        }

        .form-input:focus {
            border-color: #C9A86A;
            box-shadow: 0 0 0 3px rgba(201, 168, 106, 0.08);
        }

        .form-input::placeholder {
            color: #9CA3AF;
            font-weight: 400;
        }

        .password-toggle {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #9CA3AF;
            user-select: none;
            transition: color 0.2s;
        }

        .password-toggle:hover {
            color: #6B7280;
        }

        .btn-primary {
            width: 100%;
            padding: 14px 24px;
            background: linear-gradient(135deg, #C9A86A 0%, #E8AA42 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 14px rgba(201, 168, 106, 0.35);
            text-transform: none;
            margin-top: 8px;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(201, 168, 106, 0.45);
        }

        .btn-primary:active {
            transform: translateY(0);
        }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 24px;
            font-size: 14px;
            color: #6B7280;
            font-weight: 500;
        }

        .back-link a {
            color: #C9A86A;
            font-weight: 700;
            text-decoration: none;
            transition: color 0.2s;
        }

        .back-link a:hover {
            color: #B89959;
            text-decoration: underline;
        }

        /* Mobile Styles */
        .mobile-header {
            display: none;
        }

        .mobile-logo {
            display: none;
        }

        /* ============================================
           MOBILE RESPONSIVE DESIGN (768px and below)
           ============================================ */
        @media (max-width: 768px) {
            .left-section {
                display: none !important;
            }

            .login-container {
                flex-direction: column;
                background: #FFFFFF;
            }

            .mobile-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 20px;
                background: linear-gradient(135deg, #1F2937 0%, #4B5563 100%);
            }

            .mobile-logo {
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .mobile-logo .logo {
                width: 45px;
                height: 45px;
                background: linear-gradient(135deg, #C9A86A 0%, #E8AA42 100%);
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 22px;
                font-weight: 700;
                color: white;
                box-shadow: 0 4px 12px rgba(201, 168, 106, 0.3);
            }

            .mobile-logo .logo img {
                max-width: 90%;
                max-height: 90%;
                object-fit: contain;
            }

            .mobile-logo .company-name-header {
                font-size: 17px;
                font-weight: 700;
                color: white;
            }

            .right-section {
                flex: 1;
                background: white;
                padding: 40px 30px;
            }

            .form-container {
                max-width: 100%;
            }

            .welcome-title {
                font-size: 28px;
            }
        }

        @media (max-width: 480px) {
            .right-section {
                padding: 30px 20px;
            }

            .welcome-title {
                font-size: 26px;
            }
        }
    {/literal}
    </style>
</head>
<body>
    <div class="login-container">
        <!-- Mobile Header (Mobile Only) -->
        <div class="mobile-header">
            <div class="mobile-logo">
                <div class="logo">
                    <img src="{$app_url}/ui/ui/images/logo.png" alt="{$_c['CompanyName']}" onerror="this.parentElement.innerHTML='<div style=\'font-size:22px;color:white;font-weight:700\'>{$_c['CompanyName'][0]|upper}</div>'">
                </div>
                <div class="company-name-header">{$_c['CompanyName']}</div>
            </div>
        </div>

        <!-- Left Section - Illustration (Desktop Only) -->
        <div class="left-section">
            <div class="logo-section">
                <div class="logo">
                    <img src="{$app_url}/ui/ui/images/logo.png" alt="{$_c['CompanyName']}" onerror="this.parentElement.innerHTML='<div style=\'font-size:26px;color:white;font-weight:700\'>{$_c['CompanyName'][0]|upper}</div>'">
                </div>
                <div class="company-name-header">{$_c['CompanyName']}</div>
            </div>

            <div class="illustration-content">
                <span class="admin-badge-large">ADMIN PORTAL</span>
                <h1>Secure Admin Access</h1>
                <p>Manage your network, monitor users, and configure system settings from your administrator dashboard.</p>
            </div>
        </div>

        <!-- Right Section - Login Form -->
        <div class="right-section">
            <div class="form-container">
                <div class="welcome-text">
                    <span class="admin-badge">ADMIN ACCESS</span>
                    <h1 class="welcome-title">Welcome Back!</h1>
                    <p class="welcome-subtitle">Sign in to your admin account.</p>
                </div>

                {if isset($notify)}
                    {$notify}
                {/if}

                <form action="{Text::url('admin/post')}" method="post">
                    <input type="hidden" name="csrf_token" value="{$csrf_token}">

                    <!-- Username Field -->
                    <div class="form-group">
                        <label class="form-label">Username</label>
                        <div class="input-wrapper">
                            <input type="text" class="form-input" name="username" required placeholder="Enter your admin username">
                        </div>
                    </div>

                    <!-- Password Field -->
                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <div class="input-wrapper">
                            <input type="password" class="form-input" name="password" id="password" required placeholder="Enter your password">
                            <span class="password-toggle" onclick="togglePassword()">
                                <svg id="eye-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </span>
                        </div>
                    </div>

                    <button type="submit" class="btn-primary">Sign in</button>

                    <div class="back-link">
                        <a href="{Text::url('login')}">← Back to Customer Login</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
    {literal}
        function togglePassword() {
            const passwordInput = document.getElementById('password');
            const eyeIcon = document.getElementById('eye-icon');

            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeIcon.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line>';
            } else {
                passwordInput.type = 'password';
                eyeIcon.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle>';
            }
        }
    {/literal}
    </script>
</body>
</html>
