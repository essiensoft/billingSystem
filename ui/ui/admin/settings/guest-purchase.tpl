{include file="sections/header.tpl"}

<style>
    .panel-title {
        font-weight: bolder;
        font-size: large;
    }
    .switch {
        position: relative;
        display: inline-block;
        width: 60px;
        height: 34px;
    }
    .switch input {
        opacity: 0;
        width: 0;
        height: 0;
    }
    .slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: #ccc;
        transition: .4s;
        border-radius: 34px;
    }
    .slider:before {
        position: absolute;
        content: "";
        height: 26px;
        width: 26px;
        left: 4px;
        bottom: 4px;
        background-color: white;
        transition: .4s;
        border-radius: 50%;
    }
    input:checked + .slider {
        background-color: #28a745;
    }
    input:checked + .slider:before {
        transform: translateX(26px);
    }
</style>

<form class="form-horizontal" method="post" role="form" action="{Text::url('')}settings/guest-purchase-post">
    <input type="hidden" name="csrf_token" value="{$csrf_token}">
    
    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-primary panel-hovered panel-stacked mb30">
                <div class="panel-heading">{Lang::T('Guest Purchase Settings')}</div>
                <div class="panel-body">
                    
                    <!-- Auto-Activation -->
                    <div class="form-group">
                        <label class="col-md-3 control-label">
                            <i class="glyphicon glyphicon-flash"></i> {Lang::T('Auto-Activation')}
                        </label>
                        <div class="col-md-5">
                            <label class="switch">
                                <input type="checkbox" name="guest_auto_activate" value="yes" 
                                    {if $_c['guest_auto_activate']=='yes'}checked{/if}>
                                <span class="slider"></span>
                            </label>
                        </div>
                        <p class="help-block col-md-4">
                            <strong>Enable:</strong> Vouchers activate automatically after payment. Customers get instant internet access.<br>
                            <strong>Disable:</strong> Customers must manually enter voucher code to activate.
                        </p>
                    </div>

                    <hr>

                    <!-- Allowed Plan Types -->
                    <div class="form-group">
                        <label class="col-md-3 control-label">
                            <i class="glyphicon glyphicon-list"></i> {Lang::T('Allowed Plan Types')}
                        </label>
                        <div class="col-md-5">
                            <div class="checkbox">
                                <label>
                                    <input type="checkbox" name="plan_type_hotspot" value="1" 
                                        {if strpos($_c['guest_allowed_plan_types'], 'Hotspot') !== false}checked{/if}>
                                    Hotspot
                                </label>
                            </div>
                            <div class="checkbox">
                                <label>
                                    <input type="checkbox" name="plan_type_pppoe" value="1"
                                        {if strpos($_c['guest_allowed_plan_types'], 'PPPOE') !== false}checked{/if}>
                                    PPPoE
                                </label>
                            </div>
                            <div class="checkbox">
                                <label>
                                    <input type="checkbox" name="plan_type_vpn" value="1"
                                        {if strpos($_c['guest_allowed_plan_types'], 'VPN') !== false}checked{/if}>
                                    VPN
                                </label>
                            </div>
                        </div>
                        <p class="help-block col-md-4">
                            Select which plan types guests can purchase. At least one type must be selected.
                        </p>
                    </div>

                    <hr>

                    <!-- Transaction Expiry -->
                    <div class="form-group">
                        <label class="col-md-3 control-label">
                            <i class="glyphicon glyphicon-time"></i> {Lang::T('Transaction Expiry')}
                        </label>
                        <div class="col-md-5">
                            <div class="input-group">
                                <input type="number" class="form-control" name="guest_transaction_expiry_hours" 
                                    value="{$_c['guest_transaction_expiry_hours']}" min="1" max="168" required>
                                <span class="input-group-addon">hours</span>
                            </div>
                        </div>
                        <p class="help-block col-md-4">
                            How long unpaid transactions remain valid before expiring.<br>
                            <strong>Recommended:</strong> 6-24 hours
                        </p>
                    </div>

                    <hr>

                    <!-- Cleanup Retention -->
                    <div class="form-group">
                        <label class="col-md-3 control-label">
                            <i class="glyphicon glyphicon-trash"></i> {Lang::T('Cleanup Retention')}
                        </label>
                        <div class="col-md-5">
                            <div class="input-group">
                                <input type="number" class="form-control" name="guest_transaction_cleanup_days" 
                                    value="{$_c['guest_transaction_cleanup_days']}" min="1" max="365" required>
                                <span class="input-group-addon">days</span>
                            </div>
                        </div>
                        <p class="help-block col-md-4">
                            How long to keep expired transactions before automatic deletion.<br>
                            <strong>Recommended:</strong> 30 days
                        </p>
                    </div>

                    <hr>

                    <!-- Info Panel -->
                    <div class="alert alert-info">
                        <h4><i class="glyphicon glyphicon-info-sign"></i> Guest Purchase Features</h4>
                        <ul>
                            <li><strong>Auto-Activation:</strong> Customers get instant internet access without manual voucher entry</li>
                            <li><strong>Resend Mechanism:</strong> Customers can resend vouchers via email/SMS if delivery fails</li>
                            <li><strong>Auto-Polling:</strong> Payment status automatically checked every 10 seconds</li>
                            <li><strong>Automated Cleanup:</strong> Old expired transactions removed automatically via cron job</li>
                        </ul>
                    </div>

                    <!-- Save Button -->
                    <div class="form-group">
                        <div class="col-md-12">
                            <button class="btn btn-success btn-block btn-lg" type="submit">
                                <i class="glyphicon glyphicon-floppy-disk"></i> {Lang::T('Save Changes')}
                            </button>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</form>

<script>
// Handle plan type checkboxes
$('form').on('submit', function(e) {
    var planTypes = [];
    if ($('input[name="plan_type_hotspot"]').is(':checked')) planTypes.push('Hotspot');
    if ($('input[name="plan_type_pppoe"]').is(':checked')) planTypes.push('PPPOE');
    if ($('input[name="plan_type_vpn"]').is(':checked')) planTypes.push('VPN');
    
    if (planTypes.length === 0) {
        e.preventDefault();
        alert('Please select at least one plan type');
        return false;
    }
    
    // Create hidden input with comma-separated plan types
    $('<input>').attr({
        type: 'hidden',
        name: 'guest_allowed_plan_types',
        value: planTypes.join(',')
    }).appendTo('form');
});
</script>

{include file="sections/footer.tpl"}
