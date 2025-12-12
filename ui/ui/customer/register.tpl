<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>{Lang::T('Register')} - {$_c['CompanyName']}</title>
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
        .register-container {
            display: flex;
            min-height: 100vh;
            width: 100%;
        }

        /* Left Side - Info (Desktop Only) */
        .left-section {
            flex: 0 0 40%;
            background: linear-gradient(135deg, rgba(99, 102, 241, 0.95) 0%, rgba(139, 92, 246, 0.95) 100%);
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
            z-index: 10;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .logo {
            width: 55px;
            height: 55px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            font-weight: 700;
            color: #6366F1;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
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
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .illustration-content {
            position: relative;
            z-index: 10;
            text-align: center;
            max-width: 450px;
        }

        .illustration-content h1 {
            font-size: 38px;
            font-weight: 800;
            line-height: 1.3;
            margin-bottom: 24px;
            color: white;
            text-shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
        }

        .illustration-content p {
            font-size: 17px;
            line-height: 1.6;
            color: white;
            opacity: 0.95;
            font-weight: 400;
        }

        /* Right Side - Form */
        .right-section {
            flex: 0 0 60%;
            background: #FFFFFF;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 60px 70px;
            position: relative;
            overflow-y: auto;
        }

        .form-container {
            width: 100%;
            max-width: 520px;
        }

        .welcome-text {
            margin-bottom: 36px;
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
            margin-bottom: 18px;
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
            padding: 12px 40px;
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
            border-color: #6366F1;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.08);
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

        .btn-group-justified {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-top: 28px;
            margin-bottom: 20px;
        }

        .btn {
            padding: 13px 24px;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: #4F46E5;
            color: white;
            box-shadow: 0 4px 14px rgba(79, 70, 229, 0.35);
        }

        .btn-primary:hover {
            background: #4338CA;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(79, 70, 229, 0.45);
        }

        .btn-warning {
            background: #6B7280;
            color: white;
        }

        .btn-warning:hover {
            background: #4B5563;
            transform: translateY(-2px);
        }

        .login-link {
            margin-top: 24px;
            text-align: center;
            font-size: 14px;
            color: #6B7280;
            font-weight: 500;
        }

        .login-link a {
            color: #4F46E5;
            font-weight: 700;
            text-decoration: none;
            transition: color 0.2s;
        }

        .login-link a:hover {
            color: #4338CA;
            text-decoration: underline;
        }

        .footer-links {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #E5E7EB;
            text-align: center;
        }

        .footer-links a {
            color: #6B7280;
            text-decoration: none;
            font-size: 13px;
            margin: 0 8px;
            transition: color 0.2s;
        }

        .footer-links a:hover {
            color: #4F46E5;
        }

        /* Mobile Styles */
        .mobile-header {
            display: none;
        }

        .mobile-logo {
            display: none;
        }

        .back-button {
            display: none;
        }

        .input-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #9CA3AF;
            pointer-events: none;
        }

        .form-input-with-icon {
            padding-left: 48px !important;
        }

        .signin-link-bottom {
            display: none;
        }

        .social-divider {
            display: none;
        }

        .mobile-logo-section {
            display: none;
        }

        .announcement-banner {
            display: none;
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
                background: #F5F5F5;
            }

            .left-section {
                display: none !important;
            }

            .register-container {
                flex-direction: column;
                background: #F5F5F5;
                min-height: 100vh;
            }

            .mobile-header {
                display: none !important;
            }

            .back-button {
                display: block;
                position: absolute;
                top: 20px;
                left: 20px;
                width: 40px;
                height: 40px;
                background: white;
                border: none;
                cursor: pointer;
                padding: 0;
                z-index: 10;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            }

            .back-button svg {
                width: 20px;
                height: 20px;
                color: #1F2937;
            }

            .right-section {
                flex: 1;
                background: white;
                padding: 80px 24px 40px 24px;
                display: flex;
                align-items: flex-start;
                justify-content: flex-start;
                margin: 20px;
                border-radius: 24px;
                box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
            }

            .form-container {
                max-width: 100%;
                width: 100%;
            }

            .welcome-text {
                margin-bottom: 32px;
                text-align: center;
            }

            .welcome-title {
                font-size: 28px;
                font-weight: 800;
                color: #1F2937;
                margin-bottom: 8px;
            }

            .welcome-subtitle {
                font-size: 14px;
                color: #6B7280;
            }

            .form-label {
                display: none;
            }

            .form-group {
                margin-bottom: 16px;
            }

            .input-wrapper {
                position: relative;
            }

            .input-icon {
                display: block;
                left: 14px;
                color: #6B7280;
            }

            .form-input {
                padding: 14px 16px 14px 48px;
                border: 1.5px solid #E5E7EB;
                border-radius: 12px;
                font-size: 15px;
                background: #F9FAFB;
            }

            .form-input:focus {
                border-color: #4F46E5;
                box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
                background: white;
            }

            .password-toggle {
                right: 14px;
            }

            .btn-group-justified {
                grid-template-columns: 1fr;
                gap: 0;
                margin-top: 24px;
                margin-bottom: 20px;
            }

            .btn-warning {
                display: none;
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
                box-shadow: 0 2px 8px rgba(16, 185, 129, 0.2);
            }

            .btn-primary:hover {
                background: #059669;
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
                transform: translateY(0);
            }

            .login-link {
                display: none;
            }

            .signin-link-bottom {
                display: block;
                text-align: center;
                font-size: 14px;
                color: #6B7280;
                font-weight: 400;
                margin-top: 20px;
            }

            .signin-link-bottom a {
                color: #4F46E5;
                font-weight: 600;
                text-decoration: none;
            }

            .signin-link-bottom a:hover {
                text-decoration: underline;
            }

            .footer-links {
                display: none;
            }

            .social-divider {
                display: block;
                text-align: center;
                margin: 24px 0;
                color: #9CA3AF;
                font-size: 13px;
                position: relative;
            }

            .social-divider::before,
            .social-divider::after {
                content: '';
                position: absolute;
                top: 50%;
                width: 40%;
                height: 1px;
                background: #E5E7EB;
            }

            .social-divider::before {
                left: 0;
            }

            .social-divider::after {
                right: 0;
            }

            .mobile-logo-section {
                display: flex;
                flex-direction: column;
                align-items: center;
                margin-bottom: 28px;
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
                margin: 15px;
                border-radius: 20px;
            }

            .welcome-title {
                font-size: 26px;
            }
        }
    {/literal}
    </style>
</head>
<body>
    <div class="register-container">
        <!-- Back Button (Mobile Only) -->
        <button class="back-button" onclick="window.history.back()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
        </button>

        <!-- Left Section - Info (Desktop Only) -->
        <div class="left-section">
            <div class="logo-section">
                <div class="logo">
                    <img src="{$app_url}/ui/ui/images/logo.png" alt="{$_c['CompanyName']}" onerror="this.parentElement.innerHTML='<div style=\'font-size:26px;color:#6366F1;font-weight:700\'>{$_c['CompanyName'][0]|upper}</div>'">
                </div>
                <div class="company-name-header">{$_c['CompanyName']}</div>
            </div>

            <div class="illustration-content">
                <h1>Join our community</h1>
                <p>Create your account and enjoy seamless internet connectivity with exclusive benefits and personalized service.</p>

                <!-- Desktop Announcement Banner -->
                <div class="desktop-announcement" onclick="showAnnouncement()">
                    <span class="announcement-icon">!</span>
                    <span class="announcement-text">View Important Announcements</span>
                </div>
            </div>
        </div>

        <!-- Right Section - Registration Form -->
        <div class="right-section">
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

                <div class="welcome-text">
                    <h1 class="welcome-title">Create an account</h1>
                    <p class="welcome-subtitle">Get started with your free account today.</p>
                </div>

                {if isset($notify)}
                    {$notify}
                {/if}

                <form enctype="multipart/form-data" action="{Text::url('register/post')}" method="post">
                    <!-- Username Field -->
                    <div class="form-group">
                        <label class="form-label">
                            {if $_c['registration_username'] == 'phone'}
                                {Lang::T('Phone Number')}
                            {elseif $_c['registration_username'] == 'email'}
                                {Lang::T('Email')}
                            {else}
                                {Lang::T('Usernames')}
                            {/if}
                        </label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                    <circle cx="12" cy="7" r="4"></circle>
                                </svg>
                            </span>
                            <input type="text" class="form-input" name="username" required
                                placeholder="{if $_c['country_code_phone']!= '' || $_c['registration_username'] == 'phone'}{$_c['country_code_phone']} {Lang::T('Phone Number')}{elseif $_c['registration_username'] == 'email'}Email address{else}Name{/if}">
                        </div>
                    </div>

                    <!-- Photo Upload (if enabled) -->
                    {if $_c['photo_register'] == 'yes'}
                        <div class="form-group">
                            <label class="form-label">{Lang::T('Photo')}</label>
                            <input type="file" required class="form-input" name="photo" accept="image/*">
                        </div>
                    {/if}

                    <!-- Full Name Field -->
                    <div class="form-group">
                        <label class="form-label">{Lang::T('Full Name')}</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                    <circle cx="12" cy="7" r="4"></circle>
                                </svg>
                            </span>
                            <input type="text" {if $_c['man_fields_fname'] neq 'no'}required{/if} class="form-input" name="fullname" value="{$fullname}" placeholder="Enter your full name">
                        </div>
                    </div>

                    <!-- Email Field -->
                    <div class="form-group">
                        <label class="form-label">{Lang::T('Email')}</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                                    <polyline points="22,6 12,13 2,6"></polyline>
                                </svg>
                            </span>
                            <input type="email" {if $_c['man_fields_email'] neq 'no'}required{/if} class="form-input" name="email" value="{$email}" placeholder="Email address">
                        </div>
                    </div>

                    <!-- Address Field -->
                    <div class="form-group">
                        <label class="form-label">{Lang::T('Home Address')}</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                                    <circle cx="12" cy="10" r="3"></circle>
                                </svg>
                            </span>
                            <input type="text" {if $_c['man_fields_address'] neq 'no'}required{/if} class="form-input" name="address" value="{$address}" placeholder="Enter your address">
                        </div>
                    </div>

                    <!-- Custom Fields -->
                    {$customFields}

                    <!-- Password Field -->
                    <div class="form-group">
                        <label class="form-label">{Lang::T('Password')}</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                                </svg>
                            </span>
                            <input type="password" required class="form-input" name="password" id="password" placeholder="Password" style="padding-right: 48px;">
                            <span class="password-toggle" onclick="togglePassword('password', 'eye-icon-1')">
                                <svg id="eye-icon-1" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                                    <line x1="1" y1="1" x2="23" y2="23"></line>
                                </svg>
                            </span>
                        </div>
                    </div>

                    <!-- Confirm Password Field -->
                    <div class="form-group">
                        <label class="form-label">{Lang::T('Confirm Password')}</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                                </svg>
                            </span>
                            <input type="password" required class="form-input" name="cpassword" id="cpassword" placeholder="Confirm Password" style="padding-right: 48px;">
                            <span class="password-toggle" onclick="togglePassword('cpassword', 'eye-icon-2')">
                                <svg id="eye-icon-2" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                                    <line x1="1" y1="1" x2="23" y2="23"></line>
                                </svg>
                            </span>
                        </div>
                    </div>

                    <!-- Register & Cancel Buttons -->
                    <div class="btn-group-justified">
                        <a href="{Text::url('login')}" class="btn btn-warning">Cancel</a>
                        <button type="submit" class="btn btn-primary">Sign up</button>
                    </div>

                    <!-- Login Link -->
                    <div class="login-link">
                        Already have an account? <a href="{Text::url('login')}">Sign in</a>
                    </div>

                    <!-- Privacy & T&C Links -->
                    <div class="footer-links">
                        <a href="javascript:showPrivacy()">Privacy</a>
                        <span style="color: #D1D5DB;">•</span>
                        <a href="javascript:showTaC()">T &amp; C</a>
                    </div>
                </form>

                <!-- Sign In Link (Mobile Only) -->
                <div class="signin-link-bottom">
                    Already have an account? <a href="{Text::url('login')}">Sign In here</a>
                </div>

                <!-- Social Divider (Mobile Only) -->
                <!-- div class="social-divider">Or Continue With Account</div-->
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
        function togglePassword(inputId, iconId) {
            const passwordInput = document.getElementById(inputId);
            const eyeIcon = document.getElementById(iconId);

            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeIcon.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line>';
            } else {
                passwordInput.type = 'password';
                eyeIcon.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle>';
            }
        }

        function showPrivacy() {
            $('#HTMLModal_konten').html('<h4>Privacy Policy</h4><p>Loading privacy policy...</p>');
            $('#HTMLModal').modal('show');
            $.get('{/literal}{Text::url("pages/Privacy")}{literal}', function(data) {
                $('#HTMLModal_konten').html(data);
            }).fail(function() {
                $('#HTMLModal_konten').html('<h4>Privacy Policy</h4><p>Privacy policy content not available.</p>');
            });
        }

        function showTaC() {
            $('#HTMLModal_konten').html('<h4>Terms &amp; Conditions</h4><p>Loading terms and conditions...</p>');
            $('#HTMLModal').modal('show');
            $.get('{/literal}{Text::url("pages/TaC")}{literal}', function(data) {
                $('#HTMLModal_konten').html(data);
            }).fail(function() {
                $('#HTMLModal_konten').html('<h4>Terms &amp; Conditions</h4><p>Terms and conditions content not available.</p>');
            });
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
