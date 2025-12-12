<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>{Lang::T('Login')} - {$_c['CompanyName']}</title>
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
            background: #F5F5F5;
        }

        /* Desktop Layout - Split Screen Design */
        .login-container {
            display: flex;
            min-height: 100vh;
            width: 100%;
        }

        /* Left Side - Illustration (Desktop Only) */
        .left-section {
            flex: 0 0 50%;
            background: linear-gradient(135deg, rgba(99, 102, 241, 0.95) 0%, rgba(139, 92, 246, 0.95) 100%);
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 60px;
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
            opacity: 0.15;
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
            z-index: 20;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo {
            width: 50px;
            height: 50px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            font-weight: 700;
            color: #6366F1;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
            flex-shrink: 0;
        }

        .logo img {
            max-width: 90%;
            max-height: 90%;
            object-fit: contain;
        }

        .company-name-header {
            font-size: 18px;
            font-weight: 700;
            color: white;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
        }

        .illustration-content {
            position: relative;
            z-index: 10;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            width: 100%;
            max-width: 500px;
        }

        .welcome-message {
            margin-bottom: 30px;
        }

        .welcome-message h1 {
            font-size: 42px;
            font-weight: 800;
            color: white;
            margin-bottom: 16px;
            text-shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
            letter-spacing: -0.02em;
        }

        .welcome-message p {
            font-size: 18px;
            color: rgba(255, 255, 255, 0.95);
            line-height: 1.6;
            font-weight: 400;
        }

        .illustration-graphic {
            width: 100%;
            max-width: 450px;
            position: relative;
        }

        .illustration-graphic img {
            width: 100%;
            height: auto;
            border-radius: 16px;
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2);
        }

        .desktop-announcement {
            position: relative;
            z-index: 10;
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            border-radius: 12px;
            padding: 16px 20px;
            margin-top: 30px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            cursor: pointer;
            transition: all 0.3s;
            max-width: 450px;
        }

        .desktop-announcement:hover {
            background: rgba(255, 255, 255, 0.25);
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
        }

        .desktop-announcement .announcement-icon {
            display: inline-block;
            width: 28px;
            height: 28px;
            background: white;
            border-radius: 50%;
            color: #4F46E5;
            text-align: center;
            line-height: 28px;
            margin-right: 12px;
            font-size: 16px;
            font-weight: 700;
            vertical-align: middle;
        }

        .desktop-announcement .announcement-text {
            display: inline-block;
            vertical-align: middle;
            font-size: 15px;
            font-weight: 600;
            color: white;
        }

        /* Right Side - Form (Desktop) */
        .right-section {
            flex: 0 0 50%;
            background: #FFFFFF;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 60px 80px;
            position: relative;
        }

        .signup-link-top {
            position: absolute;
            top: 40px;
            right: 60px;
            font-size: 15px;
            color: #6B7280;
            font-weight: 400;
        }

        .signup-link-top a {
            color: #1F2937;
            font-weight: 600;
            text-decoration: none;
            margin-left: 8px;
            transition: color 0.2s;
        }

        .signup-link-top a:hover {
            color: #4F46E5;
        }

        .form-container {
            width: 100%;
            max-width: 380px;
        }

        .welcome-title {
            font-size: 48px;
            font-weight: 700;
            color: #1F2937;
            margin-bottom: 8px;
            letter-spacing: -0.02em;
        }

        .welcome-subtitle {
            font-size: 16px;
            color: #6B7280;
            font-weight: 400;
            margin-bottom: 40px;
        }

        .alert {
            padding: 14px 16px;
            border-radius: 12px;
            margin-bottom: 24px;
            font-size: 14px;
            font-weight: 500;
            border: 1px solid;
        }

        .alert-danger {
            background: #FEF2F2;
            border-color: #FCA5A5;
            color: #991B1B;
        }

        .alert-success {
            background: #F0FDF4;
            border-color: #86EFAC;
            color: #065F46;
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-label {
            display: block;
            font-size: 14px;
            font-weight: 500;
            color: #374151;
            margin-bottom: 8px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #9CA3AF;
            pointer-events: none;
        }

        .form-input {
            width: 100%;
            padding: 14px 16px 14px 48px;
            border: 1px solid #E5E7EB;
            border-radius: 10px;
            font-size: 15px;
            color: #1F2937;
            background: #F9FAFB;
            transition: all 0.2s;
            outline: none;
            font-weight: 400;
        }

        .form-input:focus {
            background: #FFFFFF;
            border-color: #D1D5DB;
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.05);
        }

        .form-input::placeholder {
            color: #9CA3AF;
            font-weight: 400;
        }

        .password-toggle {
            position: absolute;
            right: 16px;
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

        .forgot-link {
            text-align: right;
            margin-top: 12px;
            margin-bottom: 24px;
        }

        .forgot-link a {
            color: #6B7280;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: color 0.2s;
        }

        .forgot-link a:hover {
            color: #1F2937;
        }

        .btn-primary {
            width: 100%;
            padding: 15px 24px;
            background: #4F46E5;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            text-transform: none;
        }

        .btn-primary:hover {
            background: #4338CA;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
        }

        .btn-primary:active {
            transform: translateY(1px);
        }

        /* Mobile Styles */
        .mobile-header {
            display: none;
        }

        .back-button {
            display: none;
        }

        .signup-link-bottom {
            display: none;
        }

        .mobile-logo-section {
            display: none;
        }

        .announcement-banner {
            display: none;
        }

        /* Announcement Modal Styles (Desktop & Mobile) */
        .modal-backdrop {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 9999;
            backdrop-filter: blur(4px);
        }

        .modal-backdrop.show {
            display: block;
        }

        .announcement-modal {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 90%;
            max-width: 600px;
            max-height: 80vh;
            background: white;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            z-index: 10000;
            overflow: hidden;
        }

        .announcement-modal.show {
            display: block;
        }

        .announcement-modal-header {
            padding: 20px 24px;
            background: linear-gradient(135deg, #3B82F6 0%, #2563EB 100%);
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .announcement-modal-header h3 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
        }

        .announcement-modal-close {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            color: white;
            cursor: pointer;
            font-size: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s;
        }

        .announcement-modal-close:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        .announcement-modal-body {
            padding: 24px;
            max-height: 60vh;
            overflow-y: auto;
            color: #374151;
            line-height: 1.6;
            font-size: 15px;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(4px);
        }

        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-dialog {
            width: 90%;
            max-width: 600px;
        }

        .modal-content {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }

        .modal-header {
            padding: 20px 24px;
            border-bottom: 1px solid #E5E7EB;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .modal-header .close {
            background: none;
            border: none;
            font-size: 28px;
            color: #6B7280;
            cursor: pointer;
            line-height: 1;
        }

        .modal-body {
            padding: 24px;
            max-height: 60vh;
            overflow-y: auto;
        }

        .modal-footer {
            padding: 16px 24px;
            border-top: 1px solid #E5E7EB;
            text-align: right;
        }

        /* ============================================
           MOBILE RESPONSIVE DESIGN (768px and below)
           ============================================ */
        @media (max-width: 768px) {
            body {
                background: #FFFFFF;
            }

            .left-section {
                display: none !important;
            }

            .login-container {
                flex-direction: column;
                background: #FFFFFF;
                min-height: 100vh;
            }

            .back-button {
                display: block;
                position: absolute;
                top: 20px;
                left: 20px;
                width: 40px;
                height: 40px;
                background: transparent;
                border: none;
                cursor: pointer;
                padding: 0;
                z-index: 10;
            }

            .back-button svg {
                width: 24px;
                height: 24px;
                color: #1F2937;
            }

            .right-section {
                flex: 1;
                background: white;
                padding: 80px 24px 40px 24px;
                display: flex;
                align-items: flex-start;
                justify-content: flex-start;
            }

            .signup-link-top {
                display: none;
            }

            .form-container {
                max-width: 100%;
                width: 100%;
            }

            .welcome-title {
                font-size: 28px;
                font-weight: 700;
                color: #1F2937;
                margin-bottom: 8px;
                letter-spacing: -0.01em;
            }

            .welcome-subtitle {
                font-size: 14px;
                color: #6B7280;
                font-weight: 400;
                margin-bottom: 32px;
            }

            .form-group {
                margin-bottom: 20px;
            }

            .form-input {
                padding: 14px 16px 14px 48px;
                border: 1.5px solid #E5E7EB;
                border-radius: 12px;
                font-size: 15px;
                background: white;
            }

            .form-input:focus {
                border-color: #4F46E5;
                box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
            }

            .input-icon {
                left: 14px;
                color: #6B7280;
            }

            .forgot-link {
                text-align: left;
                margin-top: 12px;
                margin-bottom: 28px;
            }

            .forgot-link a {
                color: #4F46E5;
                font-size: 14px;
                font-weight: 600;
            }

            .forgot-link a:hover {
                color: #059669;
                text-decoration: underline;
            }

            .btn-primary {
                width: 100%;
                padding: 16px 24px;
                background: #4F46E5;
                color: white;
                border: none;
                border-radius: 12px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.2s;
                box-shadow: 0 2px 8px rgba(16, 185, 129, 0.2);
                margin-bottom: 24px;
            }

            .btn-primary:hover {
                background: #059669;
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
            }

            .btn-primary:active {
                transform: translateY(1px);
            }

            .signup-link-bottom {
                display: block;
                text-align: center;
                font-size: 14px;
                color: #6B7280;
                font-weight: 400;
            }

            .signup-link-bottom a {
                color: #4F46E5;
                font-weight: 600;
                text-decoration: none;
            }

            .signup-link-bottom a:hover {
                text-decoration: underline;
            }

            .mobile-logo-section {
                display: flex;
                flex-direction: column;
                align-items: center;
                margin-bottom: 32px;
            }

            .mobile-logo-section .logo {
                width: 80px;
                height: 80px;
                background: linear-gradient(135deg, #e6e5f1ff 0%, #eef2f1ff 100%);
                border-radius: 20px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 16px;
                box-shadow: 0 4px 16px rgba(16, 185, 129, 0.3);
            }

            .mobile-logo-section .logo img {
                max-width: 85%;
                max-height: 85%;
                object-fit: contain;
            }

            .mobile-logo-section .company-name {
                font-size: 20px;
                font-weight: 700;
                color: #1F2937;
                text-align: center;
            }

            .announcement-banner {
                display: block;
                background: linear-gradient(135deg, #DBEAFE 0%, #BFDBFE 100%);
                border: 1px solid #93C5FD;
                border-radius: 12px;
                padding: 14px 16px;
                margin-bottom: 24px;
                cursor: pointer;
                transition: all 0.2s;
            }

            .announcement-banner:hover {
                background: linear-gradient(135deg, #BFDBFE 0%, #93C5FD 100%);
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(59, 130, 246, 0.2);
            }

            .announcement-banner .banner-icon {
                display: inline-block;
                width: 24px;
                height: 24px;
                background: #3B82F6;
                border-radius: 50%;
                color: white;
                text-align: center;
                line-height: 24px;
                margin-right: 10px;
                font-size: 14px;
                font-weight: 700;
                vertical-align: middle;
            }

            .announcement-banner .banner-text {
                display: inline-block;
                vertical-align: middle;
                font-size: 14px;
                font-weight: 600;
                color: #1E40AF;
            }
        }

        @media (max-width: 480px) {
            .right-section {
                padding: 70px 20px 30px 20px;
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

        <!-- Left Section - Illustration (Desktop Only) -->
        <div class="left-section">
            <div class="logo-section">
                <div class="logo">
                    <img src="{$app_url}/ui/ui/images/logo.png" alt="{$_c['CompanyName']}" onerror="this.parentElement.innerHTML='<div style=\'font-size:24px;color:#6366F1;font-weight:700\'>{$_c['CompanyName'][0]|upper}</div>'">
                </div>
                <div class="company-name-header">{$_c['CompanyName']}</div>
            </div>

            <div class="illustration-content">
                <div class="welcome-message">
                    <h1>Connect & Thrive</h1>
                    <p>Join our community and enjoy seamless internet connectivity with exclusive benefits and personalized service.</p>
                </div>
                <div class="illustration-graphic">
                    <img src="{$app_url}/ui/ui/images/wifi-community.jpg" alt="WiFi Community" onerror="this.style.display='none'">
                </div>

                <!-- Desktop Announcement Banner -->
                <div class="desktop-announcement" onclick="showAnnouncement()">
                    <span class="announcement-icon">!</span>
                    <span class="announcement-text">View Important Announcements</span>
                </div>
            </div>
        </div>

        <!-- Right Section - Login Form -->
        <div class="right-section">
            {if $_c['disable_registration'] != 'noreg'}
                <div class="signup-link-top">
                    Don't have an account? <a href="{Text::url('register')}">Sign up</a>
                </div>
            {/if}

            <div class="form-container">
                <!-- Mobile Logo Section (Mobile Only) -->
                <div class="mobile-logo-section">
                    <div class="logo">
                        <img src="{$app_url}/ui/ui/images/logo.png" alt="{$_c['CompanyName']}" onerror="this.parentElement.innerHTML='<div style=\'font-size:36px;color:white;font-weight:700\'>{$_c['CompanyName'][0]|upper}</div>'">
                    </div>
                    <div class="company-name">{$_c['CompanyName']}</div>
                </div>

                <!-- Announcement Banner (Mobile Only) -->
                <div class="announcement-banner" onclick="showAnnouncement()">
                    <span class="banner-icon">!</span>
                    <span class="banner-text">View Announcements</span>
                </div>

                <h1 class="welcome-title">Sign in</h1>
                <p class="welcome-subtitle">Sign in with Open account</p>

                {if isset($notify)}
                    {$notify}
                {/if}

                <form action="{Text::url('login/post')}" method="post">
                    <input type="hidden" name="csrf_token" value="{$csrf_token}">

                    <!-- Username Field -->
                    <div class="form-group">
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                                    <polyline points="22,6 12,13 2,6"></polyline>
                                </svg>
                            </span>
                            <input type="text" class="form-input" name="username" required
                                placeholder="{if $_c['registration_username'] == 'phone'}Phone number{elseif $_c['registration_username'] == 'email'}Email address{else}Username{/if}">
                        </div>
                    </div>

                    <!-- Password Field -->
                    <div class="form-group">
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                                </svg>
                            </span>
                            <input type="password" class="form-input" name="password" id="password" required placeholder="Password" style="padding-right: 48px;">
                            <span class="password-toggle" onclick="togglePassword()">
                                <svg id="eye-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </span>
                        </div>
                    </div>

                    <div class="forgot-link">
                        <a href="{Text::url('forgot')}">{Lang::T('Forgot Password')}?</a>
                    </div>

                    <button type="submit" class="btn-primary">Sign in</button>
                </form>

                {if $_c['disable_registration'] != 'noreg'}
                    <div class="signup-link-bottom">
                        Don't have an account? <a href="{Text::url('register')}">Sign up here</a>
                    </div>
                {/if}
            </div>
        </div>
    </div>

    <!-- Announcement Modal (Mobile Only) -->
    <div class="modal-backdrop" id="announcementBackdrop" onclick="closeAnnouncement()"></div>
    <div class="announcement-modal" id="announcementModal">
        <div class="announcement-modal-header">
            <h3>Announcements</h3>
            <button class="announcement-modal-close" onclick="closeAnnouncement()">&times;</button>
        </div>
        <div class="announcement-modal-body" id="announcementContent">
            {$Announcement = "{$PAGES_PATH}/Announcement.html"}
            {if file_exists($Announcement)}
                {include file=$Announcement}
            {else}
                <p style="text-align: center; color: #6B7280; padding: 20px;">No announcements at this time.</p>
            {/if}
        </div>
    </div>

    <!-- Privacy Modal -->
    <div class="modal fade" id="HTMLModal" tabindex="-1" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" id="HTMLModal_konten"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>

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

        function showAnnouncement() {
            document.getElementById('announcementModal').classList.add('show');
            document.getElementById('announcementBackdrop').classList.add('show');
            document.body.style.overflow = 'hidden';
        }

        function closeAnnouncement() {
            document.getElementById('announcementModal').classList.remove('show');
            document.getElementById('announcementBackdrop').classList.remove('show');
            document.body.style.overflow = '';
        }

        // Auto-show announcement twice per day
        function shouldShowAnnouncement() {
            const now = new Date().getTime();
            const lastShown = localStorage.getItem('lastAnnouncementShown');

            if (!lastShown) {
                return true;
            }

            const timeDiff = now - parseInt(lastShown);
            const hoursDiff = timeDiff / (1000 * 60 * 60);

            // Show every 12 hours (twice per day)
            return hoursDiff >= 12;
        }

        function autoShowAnnouncement() {
            if (shouldShowAnnouncement()) {
                // Delay showing by 1.5 seconds for better UX
                setTimeout(function() {
                    showAnnouncement();
                    localStorage.setItem('lastAnnouncementShown', new Date().getTime().toString());
                }, 1500);
            }
        }

        // Run on page load
        window.addEventListener('load', autoShowAnnouncement);
    {/literal}
    </script>
</body>
</html>
