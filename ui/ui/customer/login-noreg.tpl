<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>{Lang::T('Login')} - {$_c['CompanyName']|escape:'html'}</title>
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

        /* Desktop Layout */
        .main-container {
            display: flex;
            min-height: 100vh;
            width: 100%;
        }

        /* Left Section - Illustration */
        .left-section {
            flex: 0 0 40%;
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
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
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
            word-wrap: break-word;
        }

        .illustration-content {
            position: relative;
            z-index: 10;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            width: 100%;
            max-width: 450px;
        }

        .welcome-message h1 {
            font-size: 38px;
            font-weight: 800;
            color: white;
            margin-bottom: 16px;
            text-shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
        }

        .welcome-message p {
            font-size: 16px;
            color: rgba(255, 255, 255, 0.95);
            line-height: 1.6;
            margin-bottom: 20px;
        }

        .illustration-graphic img {
            width: 100%;
            max-width: 400px;
            border-radius: 16px;
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2);
            margin-top: 20px;
        }

        /* Right Section - Content */
        .right-section {
            flex: 0 0 60%;
            background: #FFFFFF;
            padding: 40px;
            overflow-y: auto;
        }

        .content-wrapper {
            max-width: 900px;
            margin: 0 auto;
        }

        /* Tab Navigation */
        .tab-navigation {
            display: flex;
            gap: 12px;
            margin-bottom: 32px;
            border-bottom: 2px solid #E5E7EB;
            padding-bottom: 0;
        }

        .tab-btn {
            padding: 14px 24px;
            background: transparent;
            border: none;
            border-bottom: 3px solid transparent;
            font-size: 15px;
            font-weight: 600;
            color: #6B7280;
            cursor: pointer;
            transition: all 0.3s;
            margin-bottom: -2px;
        }

        .tab-btn:hover {
            color: #4F46E5;
        }

        .tab-btn.active {
            color: #4F46E5;
            border-bottom-color: #4F46E5;
        }

        /* Tab Content */
        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
            animation: fadeIn 0.3s;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Package Grid */
        .packages-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }

        .package-card {
            background: #FFFFFF;
            border: 2px solid #E5E7EB;
            border-radius: 16px;
            padding: 24px;
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }

        .package-card:hover {
            border-color: #4F46E5;
            box-shadow: 0 8px 24px rgba(79, 70, 229, 0.15);
            transform: translateY(-4px);
        }

        .package-badge {
            position: absolute;
            top: 12px;
            right: 12px;
            background: linear-gradient(135deg, #10B981 0%, #059669 100%);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .package-name {
            font-size: 20px;
            font-weight: 700;
            color: #1F2937;
            margin-bottom: 16px;
        }

        .package-price {
            font-size: 36px;
            font-weight: 800;
            color: #4F46E5;
            margin-bottom: 8px;
            display: flex;
            align-items: baseline;
            gap: 8px;
        }

        .package-price .old-price {
            font-size: 20px;
            color: #9CA3AF;
            text-decoration: line-through;
            font-weight: 500;
        }

        .package-details {
            margin: 20px 0;
            padding: 16px 0;
            border-top: 1px solid #F3F4F6;
            border-bottom: 1px solid #F3F4F6;
        }

        .package-detail-item {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
            font-size: 14px;
            color: #6B7280;
        }

        .package-detail-item:last-child {
            margin-bottom: 0;
        }

        .package-detail-item svg {
            width: 18px;
            height: 18px;
            color: #10B981;
            flex-shrink: 0;
        }

        .btn-buy {
            width: 100%;
            padding: 14px 24px;
            background: linear-gradient(135deg, #4F46E5 0%, #6366F1 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .btn-buy:hover {
            background: linear-gradient(135deg, #4338CA 0%, #4F46E5 100%);
            box-shadow: 0 6px 16px rgba(79, 70, 229, 0.4);
            transform: translateY(-2px);
        }

        /* Voucher Activation Section */
        .voucher-section {
            max-width: 500px;
            margin: 0 auto;
        }

        .section-title {
            font-size: 28px;
            font-weight: 700;
            color: #1F2937;
            margin-bottom: 8px;
        }

        .section-subtitle {
            font-size: 15px;
            color: #6B7280;
            margin-bottom: 32px;
        }

        .form-group {
            margin-bottom: 20px;
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
        }

        .form-input:focus {
            background: #FFFFFF;
            border-color: #4F46E5;
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.05);
            outline: none;
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
        }

        .btn-primary:hover {
            background: #4338CA;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
        }

        /* Alert Styles */
        .alert {
            padding: 14px 16px;
            border-radius: 12px;
            margin-bottom: 24px;
            font-size: 14px;
            font-weight: 500;
        }

        .alert-info {
            background: #EFF6FF;
            border: 1px solid #BFDBFE;
            color: #1E40AF;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }

        .empty-state svg {
            width: 80px;
            height: 80px;
            color: #D1D5DB;
            margin-bottom: 16px;
        }

        .empty-state h3 {
            font-size: 18px;
            font-weight: 600;
            color: #6B7280;
            margin-bottom: 8px;
        }

        .empty-state p {
            font-size: 14px;
            color: #9CA3AF;
        }

        /* Announcement Styles */
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

        /* Announcement Modal */
        .modal-backdrop {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%!;
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

        /* Mobile Responsiveness */
        @media (max-width: 1024px) {
            .left-section {
                flex: 0 0 35%;
            }

            .right-section {
                flex: 0 0 65%;
            }
        }

        @media (max-width: 768px) {
            body {
                background: #FFFFFF;
            }

            .main-container {
                flex-direction: column;
            }

            .left-section {
                display: none;
            }

            .right-section {
                padding: 20px;
            }

            .mobile-header {
                display: flex;
                flex-direction: column;
                align-items: center;
                margin-bottom: 32px;
            }

            .mobile-logo {
                width: 80px;
                height: 80px;
                border-radius: 20px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 16px;
                box-shadow: 0 4px 16px rgba(99, 102, 241, 0.3);
            }

            .mobile-logo img {
                max-width: 85%;
                max-height: 85%;
                object-fit: contain;
            }

            .mobile-company-name {
                font-size: 20px;
                font-weight: 700;
                color: #1F2937;
                text-align: center;
            }

            .tab-navigation {
                flex-wrap: wrap;
                gap: 8px;
            }

            .tab-btn {
                font-size: 14px;
                padding: 12px 16px;
            }

            .packages-grid {
                grid-template-columns: 1fr;
                gap: 16px;
            }

            .section-title {
                font-size: 24px;
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

            .desktop-announcement {
                display: none;
            }
        }
    {/literal}
    </style>
</head>
<body>
    <div class="main-container">
        <!-- Left Section - Illustration (Desktop Only) -->
        <div class="left-section">
            <div class="logo-section">
                <div class="logo">
                    <img src="{$app_url}/ui/ui/images/logo.png" alt="{$_c['CompanyName']|escape:'html'}" onerror="this.parentElement.innerHTML='<div style=\'font-size:24px;color:#6366F1;font-weight:700\'>{$_c['CompanyName'][0]|upper|escape:'html'}</div>'">
                </div>
                <div class="company-name-header">{$_c['CompanyName']|escape:'html'}</div>
            </div>

            <div class="illustration-content">
                <div class="welcome-message">
                    <h1>Welcome Back!</h1>
                    <p>Connect instantly to fast, reliable internet. Purchase vouchers without registration or login with your account.</p>
                </div>
                <div class="illustration-graphic">
                    <img src="{$app_url}/ui/ui/images/wifi-hotspot-login.png" alt="WiFi Login" onerror="this.style.display='none'">
                </div>
                
                <!-- Desktop Announcement Banner -->
                {$Announcement = "{$PAGES_PATH}/Announcement.html"}
                {if file_exists($Announcement)}
                <div class="desktop-announcement" onclick="showAnnouncement()">
                    <span class="announcement-icon">!</span>
                    <span class="announcement-text">View Important Announcements</span>
                </div>
                {/if}
            </div>
        </div>

        <!-- Right Section - Content -->
        <div class="right-section">
            <!-- Mobile Header (Mobile Only) -->
            <div class="mobile-header" style="display: none;">
                <div class="mobile-logo">
                    <img src="{$app_url}/ui/ui/images/logo.png" alt="{$_c['CompanyName']|escape:'html'}" onerror="this.parentElement.innerHTML='<div style=\'font-size:36px;color:white;font-weight:700\'>{$_c['CompanyName'][0]|upper|escape:'html'}</div>'">
                </div>
                <div class="mobile-company-name">{$_c['CompanyName']|escape:'html'}</div>
            </div>

            <div class="content-wrapper">
                <!-- Mobile Announcement Banner -->
                {$Announcement = "{$PAGES_PATH}/Announcement.html"}
                {if file_exists($Announcement)}
                <div class="announcement-banner" onclick="showAnnouncement()">
                    <span class="banner-icon">!</span>
                    <span class="banner-text">View Announcements</span>
                </div>
                {/if}
                
                <!-- Tab Navigation -->
                <div class="tab-navigation">
                    <button class="tab-btn active" onclick="switchTab('buy')">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: inline-block; vertical-align: middle; margin-right: 6px;">
                            <circle cx="9" cy="21" r="1"></circle>
                            <circle cx="20" cy="21" r="1"></circle>
                            <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path>
                        </svg>
                        {Lang::T('Buy Internet Package')}
                    </button>
                    <button class="tab-btn" onclick="switchTab('activate')">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: inline-block; vertical-align: middle; margin-right: 6px;">
                            <polyline points="20 6 9 17 4 12"></polyline>
                        </svg>
                        {Lang::T('Activate Voucher')}
                    </button>
                </div>

                <!-- Buy Package Tab -->
                <div id="buy-tab" class="tab-content active">
                    {if $router_error}
                        <div class="alert alert-danger">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: inline-block; vertical-align: middle; margin-right: 8px;">
                                <circle cx="12" cy="12" r="10"></circle>
                                <line x1="15" y1="9" x2="9" y2="15"></line>
                                <line x1="9" y1="9" x2="15" y2="15"></line>
                            </svg>
                            <strong>{Lang::T('Service Unavailable')}</strong><br>
                            {$router_error|escape:'html'}
                        </div>
                    {else}
                        <div class="alert alert-info">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: inline-block; vertical-align: middle; margin-right: 8px;">
                                <circle cx="12" cy="12" r="10"></circle>
                                <line x1="12" y1="16" x2="12" y2="12"></line>
                                <line x1="12" y1="8" x2="12.01" y2="8"></line>
                            </svg>
                            {Lang::T('Purchase internet access instantly without registration. Pay online and receive your voucher code immediately!')}
                        </div>
                    {/if}

                    {if $guest_plans}
                        <div class="packages-grid">
                            {foreach $guest_plans as $plan}
                                <div class="package-card">
                                    {if $plan.old_price > 0}
                                        <div class="package-badge">Sale</div>
                                    {/if}
                                    <div class="package-name">{$plan.name_plan|escape:'html'}</div>
                                    <div class="package-price">
                                        <span>{Lang::moneyFormat($plan.price)}</span>
                                        {if $plan.old_price > 0}
                                            <span class="old-price">{Lang::moneyFormat($plan.old_price)}</span>
                                        {/if}
                                    </div>
                                    <div class="package-details">
                                        <div class="package-detail-item">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <polyline points="20 6 9 17 4 12"></polyline>
                                            </svg>
                                            <span>{$plan.validity|escape:'html'} {$plan.validity_unit|escape:'html'} validity</span>
                                        </div>
                                        <div class="package-detail-item">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <polyline points="20 6 9 17 4 12"></polyline>
                                            </svg>
                                            <span>{$plan.name_bw|escape:'html'} speed</span>
                                        </div>
                                        <div class="package-detail-item">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <polyline points="20 6 9 17 4 12"></polyline>
                                            </svg>
                                            <span>Instant activation</span>
                                        </div>
                                    </div>
                                    <a href="{Text::url('guest/order/gateway/')}{$plan.router_id}/{$plan.id}" class="btn-buy">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: inline-block; vertical-align: middle; margin-right: 6px;">
                                            <rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect>
                                            <line x1="1" y1="10" x2="23" y2="10"></line>
                                        </svg>
                                        {Lang::T('Buy Now')}
                                    </a>
                                </div>
                            {/foreach}
                        </div>
                    {else}
                        <div class="empty-state">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="10"></circle>
                                <line x1="12" y1="8" x2="12" y2="12"></line>
                                <line x1="12" y1="16" x2="12.01" y2="16"></line>
                            </svg>
                            <h3>{Lang::T('No packages available at the moment')}</h3>
                            <p>Please check back later or contact support for assistance.</p>
                        </div>
                    {/if}
                </div>

                <!-- Activate Voucher Tab -->
                <div id="activate-tab" class="tab-content">
                    <div class="voucher-section">
                        <h2 class="section-title">{Lang::T('Activate Voucher')}</h2>
                        <p class="section-subtitle">{Lang::T('Enter your voucher code here')}</p>

                        <form action="{Text::url('login/activation')}" method="post">
                            <input type="hidden" name="csrf_token" value="{$csrf_token}">

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
                                        {if $_c['registration_username'] == 'phone'}
                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                                            </svg>
                                        {elseif $_c['registration_username'] == 'email'}
                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                                                <polyline points="22,6 12,13 2,6"></polyline>
                                            </svg>
                                        {else}
                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                                <circle cx="12" cy="7" r="4"></circle>
                                            </svg>
                                        {/if}
                                    </span>
                                    <input type="text" class="form-input" name="username"
                                        placeholder="{if $_c['country_code_phone']!= '' || $_c['registration_username'] == 'phone'}{$_c['country_code_phone']} {Lang::T('Phone Number')}{elseif $_c['registration_username'] == 'email'}{Lang::T('Email')}{else}{Lang::T('Usernames')}{/if}">
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="form-label">{Lang::T('Voucher Code')}</label>
                                <div class="input-wrapper">
                                    <span class="input-icon">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"></path>
                                        </svg>
                                    </span>
                                    <input type="text" class="form-input" name="voucher" required value="{$code|escape:'html'}"
                                        placeholder="{Lang::T('Enter voucher code here')}">
                                </div>
                            </div>

                            <button type="submit" class="btn-primary">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: inline-block; vertical-align: middle; margin-right: 6px;">
                                    <polyline points="20 6 9 17 4 12"></polyline>
                                </svg>
                                {Lang::T('Login / Activate Voucher')}
                            </button>
                        </form>

                        <div style="margin-top: 32px; padding-top: 32px; border-top: 1px solid #E5E7EB;">
                            <h3 style="font-size: 16px; font-weight: 600; color: #1F2937; margin-bottom: 12px;">Quick Activation (No Login)</h3>
                            <form action="{Text::url('login/activation')}" method="post">
                                <input type="hidden" name="csrf_token" value="{$csrf_token}">
                                <div class="form-group">
                                    <label class="form-label">{Lang::T('Voucher Code Only')}</label>
                                    <div class="input-wrapper">
                                        <span class="input-icon">
                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"></path>
                                            </svg>
                                        </span>
                                        <input type="text" class="form-input" name="voucher_only" required value="{$code|escape:'html'}"
                                            placeholder="{Lang::T('Enter voucher code here')}">
                                    </div>
                                </div>
                                <button type="submit" class="btn-primary">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: inline-block; vertical-align: middle; margin-right: 6px;">
                                        <polyline points="20 6 9 17 4 12"></polyline>
                                    </svg>
                                    {Lang::T('Activate Voucher')}
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Footer Links -->
                <div style="text-align: center; margin-top: 40px; padding-top: 24px; border-top: 1px solid #E5E7EB; font-size: 14px; color: #6B7280;">
                    <a href="./pages/Privacy_Policy.html" target="_blank" style="color: #6B7280; text-decoration: none; margin: 0 12px;">Privacy</a>
                    <span>•</span>
                    <a href="./pages/Terms_of_Conditions.html" target="_blank" style="color: #6B7280; text-decoration: none; margin: 0 12px;">Terms</a>
                </div>
            </div>
        </div>
    </div>

    <!-- Announcement Modal -->
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

    <script>
    {literal}
        function switchTab(tab) {
            // Update buttons
            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));

            // Find which button to activate
            const buttons = document.querySelectorAll('.tab-btn');
            if (tab === 'buy') {
                buttons[0].classList.add('active');
            } else if (tab === 'activate') {
                buttons[1].classList.add('active');
            }

            // Update content
            document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
            document.getElementById(tab + '-tab').classList.add('active');
        }

        // Auto-switch to activation tab if voucher code is provided
        document.addEventListener('DOMContentLoaded', function() {
            {/literal}
            {if $code != ''}
            {literal}
            // Switch to activate tab if voucher code is in URL
            switchTab('activate');
            {/literal}
            {/if}
            {literal}
        });

        // Show mobile header on mobile devices
        if (window.innerWidth <= 768) {
            document.querySelector('.mobile-header').style.display = 'flex';
        }

        window.addEventListener('resize', function() {
            if (window.innerWidth <= 768) {
                document.querySelector('.mobile-header').style.display = 'flex';
            } else {
                document.querySelector('.mobile-header').style.display = 'none';
            }
        });

        // Announcement modal functions
        function showAnnouncement() {
            document.getElementById('announcementModal').classList.add('show');
            document.getElementById('announcementBackdrop').classList.add('show');
            document.body.style.overflow = 'hidden';
        }

        function closeAnnouncement() {
            document.getElementById('announcementModal').classList.remove('show');
            document.getElementById('announcementBackdrop').classList.remove('show');
            document.body.style.overflow = 'auto';
            
            // Update last shown time when user closes modal
            localStorage.setItem('announcementLastShown', new Date().getTime());
        }

        // Auto-popup announcement twice per day (every 12 hours)
        function checkAndShowAnnouncement() {
            // Check if announcement exists
            var announcementModal = document.getElementById('announcementModal');
            if (!announcementModal) return;

            var lastShown = localStorage.getItem('announcementLastShown');
            var currentTime = new Date().getTime();
            var twelveHours = 12 * 60 * 60 * 1000; // 12 hours in milliseconds

            // Show if never shown before OR if 12 hours have passed
            if (!lastShown || (currentTime - parseInt(lastShown)) > twelveHours) {
                // Wait 2 seconds after page load before showing
                setTimeout(function() {
                    showAnnouncement();
                }, 2000);
            }
        }

        // Check and auto-show announcement on page load
        document.addEventListener('DOMContentLoaded', function() {
            checkAndShowAnnouncement();
        });
    {/literal}
    </script>
</body>
</html>
