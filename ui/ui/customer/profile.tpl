{include file="customer/header.tpl"}
<!-- user-profile -->

<style>
{literal}
    /* Enhanced Input Field Styling */
    .form-control {
        border-radius: 10px !important;
        border: 2px solid #E5E7EB !important;
        padding: 21px 16px !important;
        font-size: 15px !important;
        transition: all 0.3s ease !important;
        background: white !important;
        color: #1F2937 !important;
    }

    .form-control:focus {
        border-color: #C9A86A !important;
        box-shadow: 0 0 0 3px rgba(201, 168, 106, 0.1) !important;
        outline: none !important;
        background: white !important;
    }

    .form-control::placeholder {
        color: #9CA3AF !important;
    }

    .form-control[readonly] {
        background: #F9FAFB !important;
        color: #6B7280 !important;
    }

    /* Input Group Styling */
    .input-group {
        border-radius: 10px;
        overflow: hidden;
    }

    .input-group .form-control {
        border-radius: 0 !important;
    }

    .input-group .form-control:first-child {
        border-radius: 10px 0 0 10px !important;
    }

    .input-group .form-control:last-child {
        border-radius: 0 10px 10px 0 !important;
    }

    .input-group-addon {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%) !important;
        border: 2px solid #E5E7EB !important;
        border-right: none !important;
        border-radius: 10px 0 0 10px !important;
        padding: 21px 16px !important;
        color: #6B7280 !important;
    }

    .input-group:focus-within .input-group-addon {
        border-color: #C9A86A !important;
        background: linear-gradient(135deg, #FFF9F0 0%, #FFF5E6 100%) !important;
        color: #C9A86A !important;
    }

    .input-group-btn .btn {
        border-radius: 0 10px 10px 0 !important;
        margin: 0 !important;
    }

    /* Textarea Styling */
    textarea.form-control {
        min-height: 100px;
        resize: vertical;
    }

    /* File Input Styling */
    input[type="file"] {
        padding: 10px;
        border: 2px dashed #D1D5DB;
        border-radius: 10px;
        background: #F9FAFB;
        cursor: pointer;
        transition: all 0.3s ease;
        width: 100%;
    }

    input[type="file"]:hover {
        border-color: #C9A86A;
        background: #FFF9F0;
    }

    /* Enhanced Button Styling */
    .btn {
        border-radius: 10px !important;
        padding: 12px 24px !important;
        font-weight: 600 !important;
        font-size: 15px !important;
        transition: all 0.3s ease !important;
        border: none !important;
        cursor: pointer;
        position: relative;
        overflow: hidden;
    }

    .btn::before {
        content: '';
        position: absolute;
        top: 50%;
        left: 50%;
        width: 0;
        height: 0;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.3);
        transform: translate(-50%, -50%);
        transition: width 0.6s, height 0.6s;
    }

    .btn:active::before {
        width: 300px;
        height: 300px;
    }

    .btn-success {
        background: linear-gradient(135deg, #4F46E5 0%, #059669 100%) !important;
        color: white !important;
        box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3) !important;
    }

    .btn-success:hover {
        background: linear-gradient(135deg, #059669 0%, #047857 100%) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 6px 16px rgba(16, 185, 129, 0.4) !important;
    }

    .btn-info {
        background: linear-gradient(135deg, #3B82F6 0%, #2563EB 100%) !important;
        color: white !important;
        box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3) !important;
    }

    .btn-info:hover {
        background: linear-gradient(135deg, #2563EB 0%, #1D4ED8 100%) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 6px 16px rgba(59, 130, 246, 0.4) !important;
    }

    .btn-link {
        background: transparent !important;
        color: #C9A86A !important;
        box-shadow: none !important;
        text-decoration: none !important;
    }

    .btn-link:hover {
        background: rgba(201, 168, 106, 0.05) !important;
        color: #B89959 !important;
        transform: none !important;
    }

    .btn-block {
        width: 100%;
        display: block;
    }

    /* Panel Styling */
    .panel {
        border-radius: 12px !important;
        border: 1px solid rgba(0, 0, 0, 0.06) !important;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08) !important;
        margin-bottom: 20px;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .panel:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12) !important;
    }

    .panel-heading {
        border-radius: 12px 12px 0 0 !important;
        background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%) !important;
        border-bottom: 2px solid #C9A86A !important;
        padding: 18px 20px !important;
        font-weight: 700;
        color: #1F2937;
        font-size: 18px;
    }

    .panel-body {
        padding: 25px !important;
        background: white !important;
    }

    /* Form Groups */
    .form-group {
        margin-bottom: 20px;
    }

    .form-group label,
    .control-label {
        font-weight: 600 !important;
        color: #374151 !important;
        font-size: 14px !important;
        margin-bottom: 8px !important;
        display: block;
    }

    /* Checkbox Styling */
    input[type="checkbox"] {
        appearance: none;
        width: 20px;
        height: 20px;
        border: 2px solid #D1D5DB;
        border-radius: 6px;
        background: white;
        cursor: pointer;
        position: relative;
        transition: all 0.2s ease;
        vertical-align: middle;
        margin-right: 8px;
    }

    input[type="checkbox"]:hover {
        border-color: #C9A86A;
    }

    input[type="checkbox"]:checked {
        background: linear-gradient(135deg, #C9A86A 0%, #E8AA42 100%);
        border-color: #C9A86A;
    }

    input[type="checkbox"]:checked::after {
        content: '';
        position: absolute;
        left: 6px;
        top: 2px;
        width: 5px;
        height: 10px;
        border: solid white;
        border-width: 0 2px 2px 0;
        transform: rotate(45deg);
    }

    input[type="checkbox"]:focus {
        outline: none;
        box-shadow: 0 0 0 3px rgba(201, 168, 106, 0.2);
    }

    /* Image Styling */
    .img-circle {
        border: 4px solid #E5E7EB;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        transition: all 0.3s ease;
        cursor: pointer;
    }

    .img-circle:hover {
        transform: scale(1.05);
        border-color: #C9A86A;
        box-shadow: 0 8px 20px rgba(201, 168, 106, 0.3);
    }

    /* Mobile Responsiveness */
    @media (max-width: 768px) {
        .panel {
            margin-bottom: 15px;
        }

        .panel-heading {
            padding: 14px 16px !important;
            font-size: 16px;
        }

        .panel-body {
            padding: 20px !important;
        }

        .btn {
            padding: 10px 20px !important;
            font-size: 14px !important;
        }

        .img-circle {
            max-width: 150px !important;
        }
    }

    @media (max-width: 480px) {
        .panel-heading {
            padding: 12px 14px !important;
            font-size: 15px;
        }

        .panel-body {
            padding: 16px !important;
        }

        .img-circle {
            max-width: 120px !important;
        }
    }
{/literal}
</style>

<div class="row">
    <div class="col-md-6 col-md-offset-3">
        <div class="panel panel-primary panel-hovered panel-stacked mb30">
            <div class="panel-heading">{Lang::T('Data Change')}</div>
            <div class="panel-body">
                <form class="form-horizontal" enctype="multipart/form-data" method="post" role="form"
                    action="{Text::url('accounts/edit-profile-post')}">
                    <input type="hidden" name="csrf_token" value="{$csrf_token}">
                    <input type="hidden" name="id" value="{$_user['id']}">
                    <center>
                        <img src="{$app_url}/{$UPLOAD_PATH}{$_user['photo']}.thumb.jpg" width="200"
                            onerror="this.src='{$app_url}/{$UPLOAD_PATH}/user.default.jpg'"
                            class="img-circle img-responsive" alt="Foto" onclick="return deletePhoto({$d['id']})">
                    </center><br>
                    <div class="form-group">
                        <label class="col-md-3 col-xs-12 control-label">{Lang::T('Photo')}</label>
                        <div class="col-md-6 col-xs-8">
                            <input type="file" class="form-control" name="photo" accept="image/*">
                        </div>
                        <div class="form-group col-md-3 col-xs-4" title="Not always Working">
                            <label class=""><input type="checkbox" checked name="faceDetect" value="yes">
                                {Lang::T('Face Detect')}</label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 control-label">{Lang::T('Usernames')}</label>
                        <div class="col-md-9">
                            <div class="input-group">
                                {if $_c['registration_username'] == 'phone'}
                                    <span class="input-group-addon" id="basic-addon1"><i
                                            class="glyphicon glyphicon-phone-alt"></i></span>
                                {elseif $_c['registration_username'] == 'email'}
                                    <span class="input-group-addon" id="basic-addon1"><i
                                            class="glyphicon glyphicon-envelope"></i></span>
                                {else}
                                    <span class="input-group-addon" id="basic-addon1"><i
                                            class="glyphicon glyphicon-user"></i></span>
                                {/if}
                                <input type="text" class="form-control" name="username" id="username" readonly
                                    value="{$_user['username']}"
                                    placeholder="{if $_c['country_code_phone']!= '' || $_c['registration_username'] == 'phone'}{$_c['country_code_phone']} {Lang::T('Phone Number')}{elseif $_c['registration_username'] == 'email'}{Lang::T('Email')}{else}{Lang::T('Username')}{/if}">
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 control-label">{Lang::T('Full Name')}</label>
                        <div class="col-md-9">
                            <input type="text" class="form-control" id="fullname" name="fullname"
                                value="{$_user['fullname']}">
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="col-md-3 control-label">{Lang::T('Home Address')}</label>
                        <div class="col-md-9">
                            <textarea name="address" id="address" class="form-control">{$_user['address']}</textarea>
                        </div>
                    </div>
                    {if $_c['allow_phone_otp'] != 'yes'}
                        <div class="form-group">
                            <label class="col-md-3 control-label">{Lang::T('Phone Number')}</label>
                            <div class="col-md-9">
                                <div class="input-group">
                                    <span class="input-group-addon" id="basic-addon1"><i
                                            class="glyphicon glyphicon-phone-alt"></i></span>
                                    <input type="text" class="form-control" name="phonenumber" id="phonenumber"
                                        value="{$_user['phonenumber']}"
                                        placeholder="{if $_c['country_code_phone']!= ''}{$_c['country_code_phone']}{/if} {Lang::T('Phone Number')}">
                                </div>
                            </div>
                        </div>
                    {else}
                        <div class="form-group">
                            <label class="col-md-3 control-label">{Lang::T('Phone Number')}</label>
                            <div class="col-md-9">
                                <div class="input-group">
                                    <span class="input-group-addon" id="basic-addon1"><i
                                            class="glyphicon glyphicon-phone-alt"></i></span>
                                    <input type="text" class="form-control" name="phonenumber" id="phonenumber"
                                        value="{$_user['phonenumber']}" readonly
                                        placeholder="{if $_c['country_code_phone']!= ''}{$_c['country_code_phone']}{/if} {Lang::T('Phone Number')}">
                                    <span class="input-group-btn">
                                        <a href="{Text::url('accounts/phone-update')}" type="button"
                                            class="btn btn-info btn-flat">{Lang::T('Change')}</a>
                                    </span>
                                </div>
                            </div>
                        </div>
                    {/if}
                    {if $_c['allow_email_otp'] != 'yes'}
                        <div class="form-group">
                            <label class="col-md-3 control-label">{Lang::T('Email Address')}</label>
                            <div class="col-md-9">
                                <input type="text" class="form-control" id="email" name="email" value="{$_user['email']}">
                            </div>
                        </div>
                    {else}
                        <div class="form-group">
                            <label class="col-md-3 control-label">{Lang::T('Email Address')}</label>
                            <div class="col-md-9">
                                <div class="input-group">
                                    <span class="input-group-addon"><i class="glyphicon glyphicon-envelope"></i></span>
                                    <input type="text" class="form-control" name="email" id="email"
                                        value="{$_user['email']}" readonly>
                                    <span class="input-group-btn">
                                        <a href="{Text::url('accounts/email-update')}" type="button"
                                            class="btn btn-info btn-flat">{Lang::T('Change')}</a>
                                    </span>
                                </div>
                            </div>
                        </div>
                    {/if}
                    {$customFields}
                    <div class="form-group">
                        <div class="col-md-offset-3 col-md-9">
                            <button class="btn btn-success btn-block" type="submit">
                                {Lang::T('Save Changes')}</button>
                            <br>
                            <a href="{Text::url('home')}" class="btn btn-link btn-block">{Lang::T('Cancel')}</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

{include file="customer/footer.tpl"}