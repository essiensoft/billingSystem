<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>{Lang::T('Login')} - {$_c['CompanyName']}</title>
    <link rel="shortcut icon" href="{$app_url}/ui/ui/images/logo.png" type="image/x-icon" />

    <!-- Volt CSS -->
    <link type="text/css" href="{$app_url}/ui/ui/styles/volt/volt.css" rel="stylesheet">
    <!-- Notyf CSS -->
    <link type="text/css" href="{$app_url}/ui/ui/scripts/volt/notyf/notyf.min.css" rel="stylesheet">

    <style>
    {literal}
        /* Custom Volt Theme Colors for phpnuxbill */
        :root {
            --primary: #262B40;
            --secondary: #31344B;
            --success: #18634B;
            --info: #0056B3;
            --warning: #F0B400;
            --danger: #A91E2C;
            --purple: #6E00FF;
            --light: #F4F5F7;
            --dark: #31344B;
            --gray-100: #F3F4F6;
            --gray-800: #1F2937;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: #F4F5F7;
        }

        /* Custom Background Pattern */
        .bg-soft {
            background: linear-gradient(135deg, #FAFBFE 0%, #F4F5F7 100%) !important;
            position: relative;
        }

        .bg-soft::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-image:
                radial-gradient(circle at 20% 50%, rgba(110, 0, 255, 0.03) 0%, transparent 50%),
                radial-gradient(circle at 80% 80%, rgba(38, 43, 64, 0.03) 0%, transparent 50%);
            pointer-events: none;
        }

        /* Logo Section */
        .brand-logo-section {
            text-align: center;
            margin-bottom: 2rem;
        }

        .brand-logo {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, var(--purple) 0%, var(--primary) 100%);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            box-shadow: 0 8px 20px rgba(110, 0, 255, 0.2);
        }

        .brand-logo img {
            max-width: 80%;
            max-height: 80%;
            object-fit: contain;
        }

        .brand-logo-fallback {
            font-size: 36px;
            font-weight: 700;
            color: white;
        }

        .brand-name {
            font-size: 24px;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .brand-tagline {
            font-size: 14px;
            color: #6B7280;
        }

        /* Custom Card Styling */
        .fmxw-500 {
            max-width: 500px;
        }

        .shadow {
            box-shadow: 0 2px 20px rgba(31, 41, 55, 0.08) !important;
        }

        .border-light {
            border: 1px solid rgba(0, 0, 0, 0.05) !important;
        }

        .rounded {
            border-radius: 1rem !important;
        }

        /* Form Enhancements */
        .form-control {
            border-radius: 0.5rem;
            border: 2px solid #E5E7EB;
            padding: 0.75rem 1rem;
            font-size: 0.9375rem;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            border-color: var(--purple);
            box-shadow: 0 0 0 3px rgba(110, 0, 255, 0.1);
        }

        .input-group-text {
            background-color: #F9FAFB;
            border: 2px solid #E5E7EB;
            border-right: none;
            border-radius: 0.5rem 0 0 0.5rem;
            padding: 0.75rem 1rem;
        }

        .input-group .form-control {
            border-left: none;
            border-radius: 0 0.5rem 0.5rem 0;
        }

        .input-group:focus-within .input-group-text {
            border-color: var(--purple);
            background-color: rgba(110, 0, 255, 0.05);
        }

        .input-group:focus-within .form-control {
            border-color: var(--purple);
        }

        /* Button Styling */
        .btn-gray-800 {
            background: linear-gradient(135deg, var(--purple) 0%, var(--primary) 100%);
            border: none;
            color: white;
            font-weight: 600;
            padding: 0.75rem 1.5rem;
            border-radius: 0.5rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(110, 0, 255, 0.3);
        }

        .btn-gray-800:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(110, 0, 255, 0.4);
            background: linear-gradient(135deg, #5D00CC 0%, #1F2437 100%);
            color: white;
        }

        .btn-gray-800:active {
            transform: translateY(0);
        }

        /* Custom Checkbox */
        .form-check-input {
            width: 1.25rem;
            height: 1.25rem;
            border: 2px solid #D1D5DB;
            border-radius: 0.375rem;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .form-check-input:checked {
            background-color: var(--purple);
            border-color: var(--purple);
        }

        .form-check-input:focus {
            box-shadow: 0 0 0 3px rgba(110, 0, 255, 0.1);
            border-color: var(--purple);
        }

        /* Social Buttons */
        .btn-icon-only {
            width: 44px;
            height: 44px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            transition: all 0.3s ease;
        }

        .btn-outline-gray-500 {
            border: 2px solid #E5E7EB;
            background: white;
            color: #6B7280;
        }

        .btn-outline-gray-500:hover {
            border-color: var(--purple);
            background: rgba(110, 0, 255, 0.05);
            color: var(--purple);
            transform: translateY(-2px);
        }

        /* Alert Styling */
        .alert {
            border-radius: 0.75rem;
            border: none;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
        }

        .alert-danger {
            background: linear-gradient(135deg, #FEE2E2 0%, #FECACA 100%);
            color: #991B1B;
            border-left: 4px solid var(--danger);
        }

        .alert-success {
            background: linear-gradient(135deg, #D1FAE5 0%, #A7F3D0 100%);
            color: #065F46;
            border-left: 4px solid var(--success);
        }

        /* Links */
        a {
            color: var(--purple);
            text-decoration: none;
            transition: all 0.2s ease;
        }

        a:hover {
            color: #5D00CC;
            text-decoration: underline;
        }

        /* Password Toggle */
        .password-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #6B7280;
            z-index: 10;
        }

        .password-toggle:hover {
            color: var(--purple);
        }

        .input-group-password {
            position: relative;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .brand-logo {
                width: 64px;
                height: 64px;
            }

            .brand-name {
                font-size: 20px;
            }

            .bg-soft {
                padding: 2rem 0 !important;
            }
        }

        /* Loading State */
        .btn-gray-800.loading {
            pointer-events: none;
            opacity: 0.7;
        }

        .btn-gray-800.loading::after {
            content: '';
            position: absolute;
            width: 16px;
            height: 16px;
            top: 50%;
            left: 50%;
            margin-left: -8px;
            margin-top: -8px;
            border: 2px solid #ffffff;
            border-radius: 50%;
            border-top-color: transparent;
            animation: spinner 0.6s linear infinite;
        }

        @keyframes spinner {
            to {
                transform: rotate(360deg);
            }
        }

        /* Announcement Section */
        .announcement-section {
            background: rgba(110, 0, 255, 0.05);
            border: 1px solid rgba(110, 0, 255, 0.1);
            border-radius: 0.75rem;
            padding: 1rem;
            margin-top: 2rem;
            text-align: center;
        }

        .announcement-section h5 {
            color: var(--purple);
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .announcement-section p {
            color: #6B7280;
            font-size: 13px;
            margin: 0;
        }
    {/literal}
    </style>
</head>
<body>
    <main>
        <section class="vh-lg-100 mt-5 mt-lg-0 bg-soft d-flex align-items-center">
            <div class="container">
                <!-- Back to Home Link -->
                <p class="text-center">
                    <a href="{$app_url}" class="d-flex align-items-center justify-content-center">
                        <svg class="icon icon-xs me-2" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg" style="width: 16px; height: 16px;">
                            <path fill-rule="evenodd" d="M7.707 14.707a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l2.293 2.293a1 1 0 010 1.414z" clip-rule="evenodd"></path>
                        </svg>
                        Back to homepage
                    </a>
                </p>

                <div class="row justify-content-center">
                    <div class="col-12 d-flex align-items-center justify-content-center">
                        <div class="bg-white shadow border-0 rounded border-light p-4 p-lg-5 w-100 fmxw-500">

                            <!-- Brand Logo & Name -->
                            <div class="brand-logo-section">
                                <div class="brand-logo">
                                    <img src="{$app_url}/ui/ui/images/logo.png" alt="{$_c['CompanyName']}"
                                         onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                                    <div class="brand-logo-fallback" style="display: none;">{$_c['CompanyName'][0]|upper}</div>
                                </div>
                                <h2 class="brand-name">{$_c['CompanyName']}</h2>
                                <p class="brand-tagline">Sign in to your account</p>
                            </div>

                            <!-- Alerts -->
                            {if isset($notify)}
                                <div class="alert alert-danger" role="alert">
                                    {$notify}
                                </div>
                            {/if}

                            {if isset($notify_t) && $notify_t == 's'}
                                <div class="alert alert-success" role="alert">
                                    {$notify}
                                </div>
                            {/if}

                            <!-- Login Form -->
                            <form action="{Text::url('login-post')}" method="post" class="mt-4">
                                <!-- Username/Email Field -->
                                <div class="form-group mb-4">
                                    <label for="username">{Lang::T('Username or Email')}</label>
                                    <div class="input-group">
                                        <span class="input-group-text" id="basic-addon1">
                                            <svg class="icon icon-xs text-gray-600" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg" style="width: 18px; height: 18px;">
                                                <path d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"></path>
                                            </svg>
                                        </span>
                                        <input type="text" class="form-control" placeholder="Enter your username or email"
                                               id="username" name="username" autofocus required>
                                    </div>
                                </div>

                                <!-- Password Field -->
                                <div class="form-group mb-4">
                                    <label for="password">{Lang::T('Password')}</label>
                                    <div class="input-group input-group-password">
                                        <span class="input-group-text" id="basic-addon2">
                                            <svg class="icon icon-xs text-gray-600" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg" style="width: 18px; height: 18px;">
                                                <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"></path>
                                            </svg>
                                        </span>
                                        <input type="password" placeholder="Password" class="form-control"
                                               id="password" name="password" required>
                                        <span class="password-toggle" onclick="togglePassword()">
                                            <svg class="icon icon-xs" id="eye-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" style="width: 20px; height: 20px;">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                            </svg>
                                        </span>
                                    </div>
                                </div>

                                <!-- Remember Me & Forgot Password -->
                                <div class="d-flex justify-content-between align-items-top mb-4">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" value="" id="remember">
                                        <label class="form-check-label mb-0" for="remember">
                                            Remember me
                                        </label>
                                    </div>
                                    <div>
                                        <a href="{Text::url('forgot')}" class="small text-right">Lost password?</a>
                                    </div>
                                </div>

                                <!-- Login Button -->
                                <div class="d-grid">
                                    <button type="submit" class="btn btn-gray-800">Sign in</button>
                                </div>
                            </form>

                            <!-- Social Login (Optional) -->
                            {if $_c['facebook_app_id'] != '' || $_c['google_client_id'] != ''}
                            <div class="mt-3 mb-4 text-center">
                                <span class="fw-normal">or login with</span>
                            </div>
                            <div class="d-flex justify-content-center my-4">
                                {if $_c['facebook_app_id'] != ''}
                                <a href="#" class="btn btn-icon-only btn-pill btn-outline-gray-500 me-2" aria-label="facebook" title="Login with Facebook">
                                    <svg class="icon icon-xxs" aria-hidden="true" focusable="false" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512" style="width: 16px; height: 16px;">
                                        <path fill="currentColor" d="M279.14 288l14.22-92.66h-88.91v-60.13c0-25.35 12.42-50.06 52.24-50.06h40.42V6.26S260.43 0 225.36 0c-73.22 0-121.08 44.38-121.08 124.72v70.62H22.89V288h81.39v224h100.17V288z"></path>
                                    </svg>
                                </a>
                                {/if}
                                {if $_c['google_client_id'] != ''}
                                <a href="#" class="btn btn-icon-only btn-pill btn-outline-gray-500" aria-label="google" title="Login with Google">
                                    <svg class="icon icon-xxs" aria-hidden="true" focusable="false" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 488 512" style="width: 16px; height: 16px;">
                                        <path fill="currentColor" d="M488 261.8C488 403.3 391.1 504 248 504 110.8 504 0 393.2 0 256S110.8 8 248 8c66.8 0 123 24.5 166.3 64.9l-67.5 64.9C258.5 52.6 94.3 116.6 94.3 256c0 86.5 69.1 156.6 153.7 156.6 98.2 0 135-70.4 140.8-106.9H248v-85.3h236.1c2.3 12.7 3.9 24.9 3.9 41.4z"></path>
                                    </svg>
                                </a>
                                {/if}
                            </div>
                            {/if}

                            <!-- Register Link -->
                            <div class="d-flex justify-content-center align-items-center mt-4">
                                <span class="fw-normal">
                                    Not registered?
                                    <a href="{Text::url('register')}" class="fw-bold">Create account</a>
                                </span>
                            </div>

                            <!-- Announcement -->
                            {if file_exists("{$PAGES_PATH}/Announcement.html")}
                            <div class="announcement-section">
                                <h5>
                                    <svg fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg" style="width: 16px; height: 16px; display: inline-block; vertical-align: middle;">
                                        <path d="M10 2a6 6 0 00-6 6v3.586l-.707.707A1 1 0 004 14h12a1 1 0 00.707-1.707L16 11.586V8a6 6 0 00-6-6zM10 18a3 3 0 01-3-3h6a3 3 0 01-3 3z"></path>
                                    </svg>
                                    Announcement
                                </h5>
                                <div class="announcement-content">
                                    {include file="{$PAGES_PATH}/Announcement.html"}
                                </div>
                            </div>
                            {/if}

                            <!-- Footer Links -->
                            <div class="text-center mt-4" style="font-size: 13px; color: #6B7280;">
                                <a href="javascript:showPrivacy()">Privacy Policy</a>
                                <span class="mx-2">•</span>
                                <a href="javascript:showTaC()">Terms & Conditions</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>

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
            </div>
        </div>
    </div>

    <!-- Core Scripts -->
    <script src="{$app_url}/ui/ui/scripts/jquery.min.js"></script>
    <script src="{$app_url}/ui/ui/scripts/volt/bootstrap/dist/js/bootstrap.min.js"></script>

    <!-- Notyf -->
    <script src="{$app_url}/ui/ui/scripts/volt/notyf/notyf.min.js"></script>

    <!-- Volt JS -->
    <script src="{$app_url}/ui/ui/scripts/volt/volt.js"></script>

    <script>
    {literal}
        // Password Toggle
        function togglePassword() {
            const passwordInput = document.getElementById('password');
            const eyeIcon = document.getElementById('eye-icon');

            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"></path>';
            } else {
                passwordInput.type = 'password';
                eyeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>';
            }
        }

        // Show Privacy Policy
        function showPrivacy() {
            $('#HTMLModal_konten').html('<h4>Privacy Policy</h4><p>Loading privacy policy...</p>');
            $('#HTMLModal').modal('show');
            $.get('{/literal}{Text::url("pages/Privacy")}{literal}', function(data) {
                $('#HTMLModal_konten').html(data);
            }).fail(function() {
                $('#HTMLModal_konten').html('<h4>Privacy Policy</h4><p>Privacy policy content not available.</p>');
            });
        }

        // Show Terms & Conditions
        function showTaC() {
            $('#HTMLModal_konten').html('<h4>Terms and Conditions</h4><p>Loading terms and conditions...</p>');
            $('#HTMLModal').modal('show');
            $.get('{/literal}{Text::url("pages/Terms_and_Conditions")}{literal}', function(data) {
                $('#HTMLModal_konten').html(data);
            }).fail(function() {
                $('#HTMLModal_konten').html('<h4>Terms and Conditions</h4><p>Terms and conditions content not available.</p>');
            });
        }

        // Form Loading State
        document.querySelector('form').addEventListener('submit', function(e) {
            const submitBtn = this.querySelector('button[type="submit"]');
            submitBtn.classList.add('loading');
            submitBtn.textContent = 'Signing in...';
        });

        // Initialize Notyf for notifications
        const notyf = new Notyf({
            duration: 3000,
            position: {
                x: 'right',
                y: 'top',
            }
        });
    {/literal}
    </script>
</body>
</html>
