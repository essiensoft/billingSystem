<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{Lang::T('Forgot Password')} - {$_c['CompanyName']}</title>
    <link rel="stylesheet" href="{$app_url}/ui/ui/styles/bootstrap.min.css">
    <style>
    {literal}
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }

        .forgot-container {
            display: flex;
            min-height: 100vh;
            width: 100%;
        }

        /* Left Side - Illustration & Info (Desktop Only) */
        .left-section {
            flex: 0 0 60%;
            background: linear-gradient(135deg, rgba(99, 102, 241, 0.95) 0%, rgba(139, 92, 246, 0.95) 100%);
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 60px;
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
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
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
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .tagline {
            position: absolute;
            top: 120px;
            left: 60px;
            max-width: 400px;
            z-index: 10;
        }

        .tagline h2 {
            font-size: 32px;
            font-weight: 400;
            line-height: 1.4;
            margin: 0;
        }

        .illustration {
            position: relative;
            z-index: 10;
            max-width: 550px;
            width: 100%;
            margin-top: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .illustration svg {
            width: 100%;
            height: auto;
            max-width: 100%;
        }

        /* Info Card (Desktop Only) */
        .info-card {
            position: relative;
            z-index: 10;
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 16px;
            padding: 30px;
            max-width: 450px;
            width: 100%;
            margin-top: 40px;
        }

        .info-card h3 {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 15px;
        }

        .info-card p {
            font-size: 14px;
            line-height: 1.6;
            opacity: 0.95;
        }

        /* Right Side - Form */
        .right-section {
            flex: 0 0 40%;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 60px 40px;
            position: relative;
        }

        .form-container {
            width: 100%;
            max-width: 420px;
        }

        .welcome-title {
            font-size: 48px;
            font-weight: 700;
            background: linear-gradient(135deg, #4F46E5 0%, #6366F1 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 12px;
        }

        .welcome-subtitle {
            font-size: 16px;
            color: #6B7280;
            margin-bottom: 40px;
        }

        .form-group {
            margin-bottom: 24px;
        }

        .form-group label {
            display: block;
            font-size: 14px;
            font-weight: 600;
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
            font-size: 18px;
        }

        .form-control {
            width: 100%;
            padding: 14px 16px 14px 48px;
            border: 2px solid #E5E7EB;
            border-radius: 12px;
            font-size: 15px;
            transition: all 0.3s;
            background: #F9FAFB;
        }

        .form-control:focus {
            outline: none;
            border-color: #6366F1;
            background: white;
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1);
        }

        .form-control:read-only {
            background: #F3F4F6;
            cursor: not-allowed;
        }

        .btn {
            width: 100%;
            padding: 14px 24px;
            border: none;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .btn-primary {
            background: #4F46E5;
            color: white;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
        }

        .btn-primary:hover {
            background: #4338CA;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(79, 70, 229, 0.4);
        }

        .btn-link {
            background: transparent;
            color: #4F46E5;
            padding: 12px 24px;
            margin-top: 12px;
        }

        .btn-link:hover {
            background: #F9FAFB;
        }

        .help-block {
            margin-top: 12px;
            padding: 12px;
            background: #FEF3C7;
            border-left: 4px solid #F59E0B;
            border-radius: 8px;
            font-size: 14px;
            color: #92400E;
            line-height: 1.6;
        }

        .success-message {
            background: #D1FAE5;
            border-left: 4px solid #4F46E5;
            color: #065F46;
        }

        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .alert-danger {
            background: #FEE2E2;
            color: #991B1B;
            border-left: 4px solid #DC2626;
        }

        .alert-info {
            background: #DBEAFE;
            color: #1E40AF;
            border-left: 4px solid #3B82F6;
        }

        /* Mobile Styles */
        .mobile-wave-pattern {
            display: none;
        }

        .mobile-logo {
            display: none;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .forgot-container {
                flex-direction: column;
                background: white;
            }

            .left-section {
                display: none;
            }

            .mobile-wave-pattern {
                display: block;
                position: relative;
                height: 180px;
                background: linear-gradient(135deg, #4F46E5 0%, #6366F1 100%);
                overflow: hidden;
            }

            .mobile-wave-pattern svg {
                position: absolute;
                bottom: 0;
                width: 100%;
                height: auto;
            }

            .mobile-logo {
                display: block;
                text-align: center;
                padding: 30px 20px 20px;
            }

            .mobile-logo .logo {
                width: 80px;
                height: 80px;
                background: white;
                border-radius: 16px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 12px;
                box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
                font-size: 40px;
                color: #6366F1;
            }

            .mobile-logo .logo img {
                max-width: 90%;
                max-height: 90%;
                object-fit: contain;
            }

            .mobile-logo .company-name-header {
                font-size: 20px;
                font-weight: 700;
                color: #1F2937;
                text-shadow: none;
            }

            .right-section {
                flex: 1;
                background: white;
                padding: 40px 30px;
            }

            .welcome-title {
                font-size: 36px;
            }

            .welcome-subtitle {
                font-size: 15px;
                margin-bottom: 32px;
            }
        }

        @media (max-width: 480px) {
            .right-section {
                padding: 30px 20px;
            }

            .welcome-title {
                font-size: 32px;
            }

            .mobile-wave-pattern {
                height: 150px;
            }

            .mobile-logo {
                padding: 20px;
            }

            .mobile-logo .logo {
                width: 70px;
                height: 70px;
                font-size: 35px;
            }
        }
    {/literal}
    </style>
</head>
<body>
    <div class="forgot-container">
        <!-- Mobile Wave Pattern (Mobile Only) -->
        <div class="mobile-wave-pattern">
            <svg viewBox="0 0 1200 120" preserveAspectRatio="none">
                <path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z" fill="rgba(255,255,255,0.2)"></path>
            </svg>
        </div>

        <!-- Mobile Logo Section (Mobile Only) -->
        <div class="mobile-logo">
            <div class="logo">
                <img src="{$app_url}/ui/ui/images/logo.png" alt="{$_c['CompanyName']}" onerror="this.parentElement.innerHTML='<div style=\'font-size:40px;color:#6366F1;font-weight:700\'>{$_c['CompanyName'][0]|upper}</div>'">
            </div>
            <div class="company-name-header">{$_c['CompanyName']}</div>
        </div>

        <!-- Left Section - Illustration & Info (Desktop Only) -->
        <div class="left-section">
            <div class="logo-section">
                <div class="logo">
                    <img src="{$app_url}/ui/ui/images/logo.png" alt="{$_c['CompanyName']}" onerror="this.parentElement.innerHTML='<div style=\'font-size:24px;color:#6366F1;font-weight:700\'>{$_c['CompanyName'][0]|upper}</div>'">
                </div>
                <div class="company-name-header">{$_c['CompanyName']}</div>
            </div>
            <div class="tagline">
                <h2>Account Recovery Made Simple</h2>
            </div>
            <div class="illustration">
                <svg viewBox="0 0 500 400" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <!-- Key Icon -->
                    <g transform="translate(250, 150)">
                        <!-- Key Body -->
                        <circle cx="0" cy="0" r="50" fill="rgba(255,255,255,0.3)" stroke="white" stroke-width="4"/>
                        <circle cx="0" cy="0" r="30" fill="transparent" stroke="white" stroke-width="4"/>
                        <!-- Key Teeth -->
                        <rect x="30" y="-10" width="80" height="20" rx="4" fill="rgba(255,255,255,0.3)" stroke="white" stroke-width="4"/>
                        <rect x="70" y="-20" width="15" height="10" fill="white"/>
                        <rect x="90" y="-20" width="15" height="10" fill="white"/>
                        <!-- Shield Background -->
                        <path d="M -80 -120 L 0 -150 L 80 -120 L 80 -50 Q 80 0 0 40 Q -80 0 -80 -50 Z"
                              fill="rgba(255,255,255,0.2)" stroke="white" stroke-width="3"/>
                        <!-- Lock Icon -->
                        <rect x="-20" y="-70" width="40" height="45" rx="6" fill="rgba(255,255,255,0.4)"/>
                        <path d="M -15 -70 L -15 -85 Q -15 -100 0 -100 Q 15 -100 15 -85 L 15 -70"
                              stroke="white" stroke-width="4" fill="none"/>
                        <circle cx="0" cy="-50" r="6" fill="white"/>
                    </g>
                    <!-- Floating Elements -->
                    <circle cx="100" cy="100" r="20" fill="rgba(255,255,255,0.2)"/>
                    <circle cx="400" cy="120" r="15" fill="rgba(255,255,255,0.15)"/>
                    <circle cx="380" cy="300" r="25" fill="rgba(255,255,255,0.2)"/>
                </svg>
            </div>

            <!-- Info Card -->
            <div class="info-card">
                <h3>Need Help?</h3>
                <p>If you're having trouble recovering your account, please contact our support team for assistance. We're here to help!</p>
            </div>
        </div>

        <!-- Right Section - Forgot Password Form -->
        <div class="right-section">
            <div class="form-container">
                <div class="welcome-title">Recovery</div>
                <div class="welcome-subtitle">
                    {if $step == 1}
                        Enter the verification code sent to you
                    {elseif $step == 2}
                        Your password has been reset successfully
                    {elseif $step == 6}
                        Find your username
                    {else}
                        Enter your details to recover your account
                    {/if}
                </div>

                {if isset($notify)}
                    <div class="alert alert-danger">{$notify}</div>
                {/if}
                {if isset($notify_t)}
                    <div class="alert alert-info">{$notify_t}</div>
                {/if}

                <form action="{Text::url('forgot&step=')}{$step+1}" method="post">
                    {if $step == 1}
                        <!-- Step 1: Verification Code -->
                        <div class="form-group">
                            <label>{if $_c['country_code_phone']!= ''}{Lang::T('Phone Number')}{else}{Lang::T('Usernames')}{/if}</label>
                            <div class="input-wrapper">
                                <span class="input-icon">
                                    {if $_c['country_code_phone']!= ''}
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                                        </svg>
                                    {else}
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                            <circle cx="12" cy="7" r="4"></circle>
                                        </svg>
                                    {/if}
                                </span>
                                <input type="text" readonly class="form-control" name="username" value="{$username}"
                                    placeholder="{if $_c['country_code_phone']!= ''}{$_c['country_code_phone']} {Lang::T('Phone Number')}{else}{Lang::T('Usernames')}{/if}">
                            </div>
                        </div>

                        <div class="form-group">
                            <label>{Lang::T('Verification Code')}</label>
                            <div class="input-wrapper">
                                <span class="input-icon">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 2L2 7l10 5 10-5-10-5z"></path>
                                        <path d="M2 17l10 5 10-5M2 12l10 5 10-5"></path>
                                    </svg>
                                </span>
                                <input type="text" required class="form-control" id="otp_code"
                                    placeholder="{Lang::T('Verification Code')}" name="otp_code">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary">{Lang::T('Validate')}</button>
                        <a href="{Text::url('forgot&step=-1')}" class="btn btn-link">{Lang::T('Cancel')}</a>

                    {elseif $step == 2}
                        <!-- Step 2: Success -->
                        <div class="form-group">
                            <label>{if $_c['country_code_phone']!= ''}{Lang::T('Phone Number')}{else}{Lang::T('Usernames')}{/if}</label>
                            <div class="input-wrapper">
                                <span class="input-icon">
                                    {if $_c['country_code_phone']!= ''}
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                                        </svg>
                                    {else}
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                            <circle cx="12" cy="7" r="4"></circle>
                                        </svg>
                                    {/if}
                                </span>
                                <input type="text" readonly class="form-control" name="username" value="{$username}"
                                    placeholder="{if $_c['country_code_phone']!= ''}{$_c['country_code_phone']} {Lang::T('Phone Number')}{else}{Lang::T('Usernames')}{/if}">
                            </div>
                        </div>

                        <div class="form-group">
                            <label>{Lang::T('Your Password has been change to')}</label>
                            <input type="text" readonly class="form-control" value="{$passsword}" onclick="this.select()" style="padding-left: 16px;">
                        </div>

                        <div class="help-block success-message">
                            {Lang::T('Use the password to login, and change the password from password change page')}
                        </div>

                        <a href="{Text::url('login')}" class="btn btn-primary">{Lang::T('Back to Login')}</a>

                    {elseif $step == 6}
                        <!-- Step 6: Forgot Username -->
                        <div class="form-group">
                            <label>{Lang::T('Please input your Email or Phone number')}</label>
                            <div class="input-wrapper">
                                <span class="input-icon">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                                        <polyline points="22,6 12,13 2,6"></polyline>
                                    </svg>
                                </span>
                                <input type="text" name="find" class="form-control" required value="" placeholder="Email or Phone Number">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary">{Lang::T('Validate')}</button>
                        <a href="{Text::url('forgot')}" class="btn btn-link">{Lang::T('Back')}</a>

                    {else}
                        <!-- Step 0: Initial Form -->
                        <div class="form-group">
                            <label>{if $_c['country_code_phone']!= ''}{Lang::T('Phone Number')}{else}{Lang::T('Usernames')}{/if}</label>
                            <div class="input-wrapper">
                                <span class="input-icon">
                                    {if $_c['country_code_phone']!= ''}
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                                        </svg>
                                    {else}
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                            <circle cx="12" cy="7" r="4"></circle>
                                        </svg>
                                    {/if}
                                </span>
                                <input type="text" class="form-control" name="username" required
                                    placeholder="{if $_c['country_code_phone']!= ''}{$_c['country_code_phone']} {Lang::T('Phone Number')}{else}{Lang::T('Usernames')}{/if}">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary">{Lang::T('Send Verification Code')}</button>
                        <a href="{Text::url('forgot&step=6')}" class="btn btn-link">{Lang::T('Forgot Usernames')}</a>
                        <a href="{Text::url('login')}" class="btn btn-link">{Lang::T('Back to Login')}</a>
                    {/if}
                </form>
            </div>
        </div>
    </div>
</body>
</html>
