{include file="customer/header.tpl"}
<!-- user-change-password -->

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
    }

    @media (max-width: 480px) {
        .panel-heading {
            padding: 12px 14px !important;
            font-size: 15px;
        }

        .panel-body {
            padding: 16px !important;
        }
    }
{/literal}
</style>

<div class="row">
    <div class="col-sm-12 col-md-12">
        <div class="panel panel-primary panel-hovered panel-stacked mb30">
            <div class="panel-heading">{Lang::T('Change Password')}</div>
            <div class="panel-body">
                <form class="form-horizontal" method="post" role="form"
                    action="{Text::url('accounts/change-password-post')}">
                    <input type="hidden" name="csrf_token" value="{$csrf_token|escape:'html'}">
                    <div class="form-group">
                        <label class="col-md-2 control-label">{Lang::T('Current Password')}</label>
                        <div class="col-md-6">
                            <input type="password" class="form-control" id="password" name="password">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-2 control-label">{Lang::T('New Password')}</label>
                        <div class="col-md-6">
                            <input type="password" class="form-control" id="npass" name="npass">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-2 control-label">{Lang::T('Confirm New Password')}</label>
                        <div class="col-md-6">
                            <input type="password" class="form-control" id="cnpass" name="cnpass">
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="col-lg-offset-2 col-lg-10">
                            <button class="btn btn-success" type="submit">{Lang::T('Save Changes')}</button>
                            Or <a href="{Text::url('home')}">{Lang::T('Cancel')}</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

{include file="customer/footer.tpl"}
