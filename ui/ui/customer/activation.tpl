{include file="customer/header.tpl"}
<!-- user-activation -->

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

    /* Input Group Styling */
    .input-group {
        border-radius: 10px;
        overflow: hidden;
    }

    .input-group .form-control {
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

    .btn-default {
        background: linear-gradient(135deg, #F3F4F6 0%, #E5E7EB 100%) !important;
        color: #374151 !important;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1) !important;
    }

    .btn-default:hover {
        background: linear-gradient(135deg, #E5E7EB 0%, #D1D5DB 100%) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15) !important;
    }

    /* Enhanced Box Styling */
    .box {
        border-radius: 12px !important;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08) !important;
        border: 1px solid rgba(0, 0, 0, 0.06) !important;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        background: white !important;
        margin-bottom: 20px;
        overflow: hidden;
    }

    .box:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12) !important;
    }

    .box-header {
        background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%) !important;
        border-bottom: 2px solid #C9A86A !important;
        padding: 18px 20px !important;
        border-radius: 12px 12px 0 0 !important;
    }

    .box-header .box-title {
        font-size: 18px !important;
        font-weight: 700 !important;
        color: #1F2937 !important;
        margin: 0 !important;
    }

    .box-body {
        padding: 20px !important;
        background: white !important;
    }

    /* Form Groups */
    .form-group {
        margin-bottom: 20px;
    }

    .form-group label {
        font-weight: 600 !important;
        color: #374151 !important;
        font-size: 14px !important;
        margin-bottom: 8px !important;
        display: block;
    }

    /* Alert Boxes */
    .alert {
        border-radius: 10px;
        padding: 14px 18px;
        border: none;
        margin-bottom: 20px;
        font-size: 14px;
    }

    .alert-success {
        background: linear-gradient(135deg, #D1FAE5 0%, #A7F3D0 100%);
        color: #065F46;
        border-left: 4px solid #4F46E5;
    }

    .alert-danger {
        background: linear-gradient(135deg, #FEE2E2 0%, #FECACA 100%);
        color: #991B1B;
        border-left: 4px solid #EF4444;
    }

    .alert-warning {
        background: linear-gradient(135deg, #FEF3C7 0%, #FDE68A 100%);
        color: #92400E;
        border-left: 4px solid #F59E0B;
    }

    .alert-info {
        background: linear-gradient(135deg, #DBEAFE 0%, #BFDBFE 100%);
        color: #1E40AF;
        border-left: 4px solid #3B82F6;
    }

    /* Mobile Responsiveness */
    @media (max-width: 768px) {
        .box {
            margin-bottom: 15px;
        }

        .box-header {
            padding: 14px 16px !important;
        }

        .box-header .box-title {
            font-size: 16px !important;
        }

        .box-body {
            padding: 16px !important;
        }

        .btn {
            padding: 10px 20px !important;
            font-size: 14px !important;
        }
    }

    @media (max-width: 480px) {
        .box-header {
            padding: 12px 14px !important;
        }

        .box-body {
            padding: 14px !important;
        }
    }
{/literal}
</style>

<div class="row">
    <div class="col-md-8">
        <div class="box box-primary box-solid">
            <div class="box-header">
                <h3 class="box-title">{Lang::T('Order Voucher')}</h3>
            </div>
            <div class="box-body">
                {include file="$PAGES_PATH/Order_Voucher.html"}
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="box box-primary box-solid">
            <div class="box-header">{Lang::T('Voucher Activation')}</div>
            <div class="box-body">
                <form method="post" role="form" action="{Text::url('voucher/activation-post')}">
                    <div class="form-group">
                        <div class="input-group">
                            <input type="text" class="form-control" id="code" name="code" value="{$code|escape:'html'}"
                                placeholder="{Lang::T('Enter voucher code here')}">
                            <span class="input-group-btn">
                                <a class="btn btn-default"
                                    href="{$app_url|escape:'html'}/scan/?back={urlencode(Text::url('voucher/activation&code='))}"><i
                                        class="glyphicon glyphicon-qrcode"></i></a>
                            </span>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-lg-offset-2 col-lg-10">
                            <button class="btn btn-success" type="submit">{Lang::T('Recharge')}</button>
                            Or <a href="{Text::url('home')}">{Lang::T('Cancel')}</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

{include file="customer/footer.tpl"}
