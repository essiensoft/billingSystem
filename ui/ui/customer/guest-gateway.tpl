{include file="customer/header-public.tpl"}

<div class="hidden-xs" style="height:100px"></div>

<div class="row">
    <div class="col-md-8 col-md-offset-2">
        <div class="panel panel-primary">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="glyphicon glyphicon-credit-card"></i> {Lang::T('Complete Your Purchase')}
                </h3>
            </div>
            <div class="panel-body">
                <!-- Plan Summary -->
                <div class="panel panel-info">
                    <div class="panel-heading">
                        <strong><i class="glyphicon glyphicon-list-alt"></i> {Lang::T('Order Summary')}</strong>
                    </div>
                    <div class="panel-body">
                        <table class="table">
                            <tr>
                                <th width="40%">{Lang::T('Package Name')}</th>
                                <td><strong>{$plan['name_plan']}</strong></td>
                            </tr>
                            <tr>
                                <th>{Lang::T('Bandwidth')}</th>
                                <td>{$plan['name_bw']}</td>
                            </tr>
                            <tr>
                                <th>{Lang::T('Validity')}</th>
                                <td>{$plan['validity']} {$plan['validity_unit']}</td>
                            </tr>
                            <tr>
                                <th>{Lang::T('Router')}</th>
                                <td>{$router['name']}</td>
                            </tr>
                            <tr>
                                <th>{Lang::T('Package Price')}</th>
                                <td>{Lang::moneyFormat($plan_price)}</td>
                            </tr>
                            {if $tax_amount > 0}
                            <tr>
                                <th>{Lang::T('Tax')}</th>
                                <td>{Lang::moneyFormat($tax_amount)}</td>
                            </tr>
                            {/if}
                            <tr class="success">
                                <th><h4>{Lang::T('Total Amount')}</h4></th>
                                <td><h4 class="text-success"><strong>{Lang::moneyFormat($total_price)}</strong></h4></td>
                            </tr>
                        </table>
                    </div>
                </div>

                <!-- Payment Form -->
                <form method="post" action="{Text::url('guest/order/buy/')}{$router['id']}/{$plan['id']}">
                    <input type="hidden" name="csrf_token" value="{$csrf_token}">

                    <div class="form-group">
                        <label for="email">{Lang::T('Email Address')} <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-addon"><i class="glyphicon glyphicon-envelope"></i></span>
                            <input type="email" class="form-control" id="email" name="email"
                                   placeholder="{Lang::T('Enter your email to receive voucher code')}"
                                   required>
                        </div>
                        <small class="help-block">
                            <i class="glyphicon glyphicon-info-sign"></i>
                            {Lang::T('Your voucher code will be sent to this email address')}
                        </small>
                    </div>

                    <div class="form-group">
                        <label for="phonenumber">{Lang::T('Phone Number')} <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-addon"><i class="glyphicon glyphicon-phone"></i></span>
                            <input type="tel" class="form-control" id="phonenumber" name="phonenumber"
                                   placeholder="{Lang::T('Enter your phone number to receive voucher via SMS')}"
                                   required>
                        </div>
                        <small class="help-block">
                            <i class="glyphicon glyphicon-info-sign"></i>
                            {Lang::T('Your voucher code will also be sent via SMS to this number')}
                        </small>
                    </div>

                    <div class="form-group">
                        <label>{Lang::T('Select Payment Method')} <span class="text-danger">*</span></label>
                        <div class="list-group">
                            {if $gateways}
                                {foreach $gateways as $gateway}
                                    <label class="list-group-item">
                                        <input type="radio" name="gateway" value="{$gateway}" required>
                                        <strong style="margin-left: 10px; text-transform: capitalize;">
                                            {$gateway}
                                        </strong>
                                        <span class="pull-right">
                                            <i class="glyphicon glyphicon-chevron-right"></i>
                                        </span>
                                    </label>
                                {/foreach}
                            {else}
                                <div class="alert alert-warning">
                                    <i class="glyphicon glyphicon-exclamation-sign"></i>
                                    {Lang::T('No payment gateways available. Please contact administrator')}
                                </div>
                            {/if}
                        </div>
                    </div>

                    <div class="alert alert-info">
                        <i class="glyphicon glyphicon-info-sign"></i>
                        <strong>{Lang::T('How it works:')}</strong>
                        <ol style="margin-top: 10px; margin-bottom: 0;">
                            <li>{Lang::T('Enter your email and phone number')}</li>
                            <li>{Lang::T('Select payment method and complete payment securely')}</li>
                            <li>{Lang::T('Receive your voucher code instantly via email and SMS')}</li>
                            <li>{Lang::T('Use the voucher code to activate internet access')}</li>
                        </ol>
                    </div>

                    <div class="row">
                        <div class="col-sm-6">
                            <a href="{Text::url('login')}" class="btn btn-default btn-block btn-lg">
                                <i class="glyphicon glyphicon-arrow-left"></i> {Lang::T('Cancel')}
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <button type="submit" class="btn btn-success btn-block btn-lg">
                                <i class="glyphicon glyphicon-credit-card"></i> {Lang::T('Pay Now')}
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <center>
            <small class="text-muted">
                <i class="glyphicon glyphicon-lock"></i> {Lang::T('Secure Payment Processing')}
            </small>
        </center>
    </div>
</div>

{include file="customer/footer-public.tpl"}
