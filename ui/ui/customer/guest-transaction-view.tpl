{include file="customer/header-public.tpl"}

<div class="hidden-xs" style="height:100px"></div>

<div class="row">
    <div class="col-md-8 col-md-offset-2">
        {if $trx['status'] == 2}
            <!-- Payment Successful -->
            <div class="panel panel-success">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-ok-circle"></i> {Lang::T('Payment Successful!')}
                    </h3>
                </div>
                <div class="panel-body text-center">
                    <i class="glyphicon glyphicon-ok-sign" style="font-size: 64px; color: #5cb85c;"></i>
                    <h2>{Lang::T('Thank you for your purchase!')}</h2>
                    <p class="lead">{Lang::T('Your payment has been confirmed')}</p>

                    {if $voucher}
                        <div class="panel panel-info" style="margin-top: 30px;">
                            <div class="panel-heading">
                                <strong><i class="glyphicon glyphicon-qrcode"></i> {Lang::T('Your Voucher Code')}</strong>
                            </div>
                            <div class="panel-body">
                                <div style="background: #f5f5f5; padding: 20px; border-radius: 5px; margin: 15px 0;">
                                    <h1 style="margin: 0; font-family: monospace; letter-spacing: 3px;">
                                        {$voucher['code']}
                                    </h1>
                                </div>

                                <div class="text-center" style="margin: 20px 0;">
                                    <img src="{Text::url('qrcode/?data=')}{$voucher['code']}" alt="QR Code">
                                </div>

                                <div class="alert alert-success">
                                    <strong><i class="glyphicon glyphicon-info-sign"></i> {Lang::T('How to use your voucher:')}</strong>
                                    <ol style="margin-top: 10px; margin-bottom: 0; text-align: left;">
                                        <li>{Lang::T('Connect to the WiFi network')}</li>
                                        <li>{Lang::T('Open your browser and you will be redirected to login page')}</li>
                                        <li>{Lang::T('Enter the voucher code above')}</li>
                                        <li>{Lang::T('Click Activate and enjoy your internet!')}</li>
                                    </ol>
                                </div>

                                <div class="well well-sm">
                                    <strong>{Lang::T('Package Details:')}</strong><br>
                                    <i class="glyphicon glyphicon-tag"></i> {$trx['plan_name']}<br>
                                    <i class="glyphicon glyphicon-usd"></i> {Lang::moneyFormat($trx['price'])}<br>
                                    <i class="glyphicon glyphicon-time"></i> {Lang::T('Valid for')} {$voucher['validity']} {$voucher['validity_unit']}
                                </div>
                            </div>
                        </div>

                        <a href="{Text::url('login')}" class="btn btn-success btn-lg">
                            <i class="glyphicon glyphicon-log-in"></i> {Lang::T('Activate Voucher Now')}
                        </a>
                    {else}
                        <div class="alert alert-warning" style="margin-top: 30px;">
                            <i class="glyphicon glyphicon-warning-sign"></i>
                            {Lang::T('Your voucher code has been sent to your email')}
                        </div>
                        <a href="{Text::url('login')}" class="btn btn-primary btn-lg">
                            <i class="glyphicon glyphicon-home"></i> {Lang::T('Go to Login')}
                        </a>
                    {/if}
                </div>
            </div>

        {elseif $trx['status'] == 1}
            <!-- Payment Pending -->
            <div class="panel panel-warning">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-time"></i> {Lang::T('Payment Pending')}
                    </h3>
                </div>
                <div class="panel-body text-center">
                    <i class="glyphicon glyphicon-hourglass" style="font-size: 64px; color: #f0ad4e;"></i>
                    <h2>{Lang::T('Waiting for Payment Confirmation')}</h2>
                    <p class="lead">{Lang::T('Your payment is being processed')}</p>

                    <div class="well" style="margin-top: 30px;">
                        <strong>{Lang::T('Transaction Details:')}</strong><br>
                        <table class="table table-condensed" style="margin-top: 15px;">
                            <tr>
                                <th>{Lang::T('Transaction ID')}</th>
                                <td>{$trx['id']}</td>
                            </tr>
                            <tr>
                                <th>{Lang::T('Package')}</th>
                                <td>{$trx['plan_name']}</td>
                            </tr>
                            <tr>
                                <th>{Lang::T('Amount')}</th>
                                <td>{Lang::moneyFormat($trx['price'])}</td>
                            </tr>
                            <tr>
                                <th>{Lang::T('Status')}</th>
                                <td><span class="label label-warning">{Lang::T('Pending')}</span></td>
                            </tr>
                            <tr>
                                <th>{Lang::T('Created')}</th>
                                <td>{$trx['created_date']}</td>
                            </tr>
                        </table>
                    </div>

                    <div class="alert alert-info">
                        <i class="glyphicon glyphicon-info-sign"></i>
                        {Lang::T('If you have completed the payment, click the button below to check status')}
                    </div>

                    <div class="btn-group btn-group-lg">
                        <a href="{Text::url('guest/order/view/')}{$trx['id']}/check" class="btn btn-primary">
                            <i class="glyphicon glyphicon-refresh"></i> {Lang::T('Check Payment Status')}
                        </a>
                        <a href="{Text::url('login')}" class="btn btn-default">
                            <i class="glyphicon glyphicon-home"></i> {Lang::T('Back to Home')}
                        </a>
                    </div>
                </div>
            </div>

        {elseif $trx['status'] == 3}
            <!-- Payment Failed -->
            <div class="panel panel-danger">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-remove-circle"></i> {Lang::T('Payment Failed')}
                    </h3>
                </div>
                <div class="panel-body text-center">
                    <i class="glyphicon glyphicon-remove-sign" style="font-size: 64px; color: #d9534f;"></i>
                    <h2>{Lang::T('Payment was not successful')}</h2>
                    <p class="lead">{Lang::T('There was an issue processing your payment')}</p>

                    <div class="alert alert-danger" style="margin-top: 30px;">
                        <i class="glyphicon glyphicon-exclamation-sign"></i>
                        {Lang::T('Please try again or contact support if the problem persists')}
                    </div>

                    <div class="btn-group btn-group-lg">
                        <a href="{Text::url('login')}" class="btn btn-primary">
                            <i class="glyphicon glyphicon-repeat"></i> {Lang::T('Try Again')}
                        </a>
                    </div>
                </div>
            </div>

        {else}
            <!-- Unknown Status -->
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-question-sign"></i> {Lang::T('Transaction Status')}
                    </h3>
                </div>
                <div class="panel-body text-center">
                    <p>{Lang::T('Transaction status is unknown')}</p>
                    <a href="{Text::url('login')}" class="btn btn-default">
                        <i class="glyphicon glyphicon-home"></i> {Lang::T('Back to Home')}
                    </a>
                </div>
            </div>
        {/if}

        <center style="margin-top: 30px;">
            <small class="text-muted">
                <i class="glyphicon glyphicon-lock"></i> {Lang::T('Secure Transaction')} |
                <a href="./pages/Terms_of_Conditions.html" target="_blank">{Lang::T('Terms')}</a> |
                <a href="./pages/Privacy_Policy.html" target="_blank">{Lang::T('Privacy')}</a>
            </small>
        </center>
    </div>
</div>

{include file="customer/footer-public.tpl"}
