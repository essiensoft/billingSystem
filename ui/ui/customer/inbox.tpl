{include file="customer/header.tpl"}

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

    .input-group-btn .btn {
        border-radius: 0 10px 10px 0 !important;
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

    .btn-primary {
        background: linear-gradient(135deg, #C9A86A 0%, #E8AA42 100%) !important;
        color: white !important;
        box-shadow: 0 2px 8px rgba(201, 168, 106, 0.3) !important;
    }

    .btn-primary:hover {
        background: linear-gradient(135deg, #B89959 0%, #D49931 100%) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 6px 16px rgba(201, 168, 106, 0.4) !important;
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

    .btn-danger {
        background: linear-gradient(135deg, #EF4444 0%, #DC2626 100%) !important;
        color: white !important;
        box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3) !important;
    }

    .btn-danger:hover {
        background: linear-gradient(135deg, #DC2626 0%, #B91C1C 100%) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 6px 16px rgba(239, 68, 68, 0.4) !important;
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

    .btn-sm {
        padding: 8px 16px !important;
        font-size: 13px !important;
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

    .box-body {
        padding: 20px !important;
        background: white !important;
    }

    .box-footer {
        padding: 16px 20px !important;
        background: #f8f9fa !important;
        border-top: 1px solid #E5E7EB !important;
        border-radius: 0 0 12px 12px !important;
    }

    /* Enhanced Table Styling */
    .table {
        border-radius: 8px;
        overflow: hidden;
    }

    .table thead {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    }

    .table thead th {
        font-weight: 600;
        color: #374151;
        border-bottom: 2px solid #C9A86A !important;
        padding: 14px 12px;
    }

    .table tbody tr {
        transition: background-color 0.2s ease;
    }

    .table tbody tr:hover {
        background-color: #f9fafb;
    }

    /* Mailbox Specific Styling */
    .mailbox-read-info h3 {
        color: #1F2937;
        font-weight: 700;
        font-size: 22px;
        margin-bottom: 12px;
    }

    .mailbox-read-info h5 {
        color: #6B7280;
        font-weight: 500;
        font-size: 14px;
    }

    .mailbox-read-message {
        padding: 20px;
        background: #F9FAFB;
        border-radius: 10px;
        margin: 20px 0;
        line-height: 1.6;
        color: #374151;
    }

    .mailbox-controls {
        padding: 12px 20px;
        background: #f8f9fa;
        border-radius: 8px;
        margin-bottom: 15px;
    }

    .mailbox-subject a {
        color: #1F2937;
        font-weight: 500;
        text-decoration: none;
        transition: color 0.2s ease;
    }

    .mailbox-subject a:hover {
        color: #C9A86A;
    }

    .mailbox-name {
        color: #6B7280;
        font-weight: 500;
    }

    .mailbox-date {
        color: #9CA3AF;
        font-size: 13px;
    }

    /* Mobile Responsiveness */
    @media (max-width: 768px) {
        .box {
            margin-bottom: 15px;
        }

        .box-header {
            padding: 14px 16px !important;
        }

        .box-body {
            padding: 16px !important;
        }

        .box-footer {
            padding: 14px 16px !important;
        }

        .btn {
            padding: 10px 20px !important;
            font-size: 14px !important;
        }

        .btn-sm {
            padding: 6px 12px !important;
            font-size: 12px !important;
        }

        .table {
            font-size: 14px;
        }

        .table thead th {
            padding: 10px 8px;
            font-size: 13px;
        }

        .table tbody td {
            padding: 10px 8px;
            font-size: 13px;
        }

        .mailbox-read-info h3 {
            font-size: 18px;
        }

        .mailbox-read-message {
            padding: 15px;
        }
    }

    @media (max-width: 480px) {
        .box-header {
            padding: 12px 14px !important;
        }

        .box-body {
            padding: 14px !important;
        }

        .mailbox-read-info h3 {
            font-size: 16px;
        }
    }
{/literal}
</style>

{if $tipe == 'view'}
    <div class="box box-primary">
        <div class="box-body no-padding">
            <div class="mailbox-read-info">
                <h3>{$mail.subject|escape:'html':'UTF-8'}</h3>
                <h5>From: {$mail.from|escape:'html':'UTF-8'}
                    <span class="mailbox-read-time pull-right" data-toggle="tooltip" data-placement="top"
                        title="Read at {Lang::dateTimeFormat($mail.date_read)}">{Lang::dateTimeFormat($mail.date_created)}</span>
                </h5>
            </div>
            <div class="mailbox-read-message">
                {if Text::is_html($mail.body)}
                    {$mail.body}
                {else}
                    {nl2br($mail.body|htmlspecialchars_decode)}
                {/if}
            </div>
        </div>
        <div class="box-footer">
            <div class="pull-right">
                {if $prev}
                    <a href="{Text::url('mail/view/', $prev)}" class="btn btn-default"><i class="fa fa-chevron-left"></i>
                        {Lang::T("Previous")}</a>
                {/if}
                {if $next}
                    <a href="{Text::url('mail/view/', $next)}" class="btn btn-default"><i class="fa fa-chevron-right"></i>
                        {Lang::T("Next")}</a>
                {/if}
            </div>
            <a href="{Text::url('mail')}" class="btn btn-primary"><i class="fa fa-arrow-left"></i> {Lang::T("Back")}</a>
            <a href="{Text::url('mail/delete/')}{$mail.id}" class="btn btn-danger"
                onclick="return ask(this, '{Lang::T("Delete")}?')"><i class="fa fa-trash-o"></i>
                {Lang::T("Delete")}</a>
            <a href="https://api.whatsapp.com/send?text={if Text::is_html($mail.body)}{urlencode(strip_tags($mail.body))}{else}{urlencode($mail.body)}{/if}"
                class="btn btn-success"><i class="fa fa-share"></i> {Lang::T("Share")}</a>
        </div>
        <!-- /.box-footer -->
    </div>
{else}
    <div class="box box-primary">
        <div class="box-header with-border">
            <form method="post">
                <div class="box-tools pull-right">
                    <div class="input-group">
                        <input type="text" name="q" class="form-control" placeholder="{Lang::T('Search')}..." value="{$q|escape:'html':'UTF-8'}">
                        <div class="input-group-btn">
                            <button type="submit" class="btn btn-success"><span
                                    class="glyphicon glyphicon-search"></span></button>
                        </div>
                    </div>
                </div>
            </form>
        </div>
        <div class="box-body no-padding">
            <div class="mailbox-controls">
                <a href="{Text::url('mail')}" class="btn btn-default btn-sm"><i class="fa fa-refresh"></i></a>
                <div class="pull-right">
                    <div class="btn-group">
                        {if $p>0}
                            <a href="{Text::url('mail&p=')}{$p-1}&q={urlencode($q)}" class="btn btn-default btn-sm"><i
                                    class="fa fa-chevron-left"></i></a>
                        {/if}
                        <a href="{Text::url('mail&p=')}{$p+1}&q={urlencode($q)}" class="btn btn-default btn-sm"><i
                                class="fa fa-chevron-right"></i></a>
                    </div>
                </div>
            </div>
            <div class="table-responsive mailbox-messages">
                <table class="table table-hover table-striped table-bordered">
                    <tbody>
                        {foreach $mails as $mail}
                            <tr>
                                <td class="mailbox-subject">
                                    <a href="{Text::url('mail/view/')}{$mail.id}">
                                        <div>
                                            {if $mail.date_read == null}
                                                <i class="fa fa-envelope text-yellow" title="unread"></i>
                                            {else}
                                                <i class="fa fa-envelope-o text-yellow" title="read"></i>
                                            {/if}
                                            <b>{$mail.subject|escape:'html':'UTF-8'}</b>
                                        </div>
                                    </a>
                                </td>
                                <td class="mailbox-name">{$mail.from|escape:'html':'UTF-8'}</td>
                                <td class="mailbox-attachment"></td>
                                <td class="mailbox-date">{Lang::dateTimeFormat($mail.date_created)}</td>
                            </tr>
                        {/foreach}
                        {if empty($mails)}
                            <tr>
                                <td colspan="4">{Lang::T("No email found.")}</td>
                            </tr>
                        {/if}
                    </tbody>
                </table>
            </div>
        </div>
        <div class="box-footer no-padding">
            <div class="mailbox-controls">
                <a href="{Text::url('mail')}" class="btn btn-default btn-sm"><i class="fa fa-refresh"></i></a>
                <div class="pull-right">
                    <div class="btn-group">
                        {if $p>0}
                            <a href="{Text::url('mail&p=')}{$p-1}&q={urlencode($q)}" class="btn btn-default btn-sm"><i
                                    class="fa fa-chevron-left"></i></a>
                        {/if}
                        <a href="{Text::url('mail&p=')}{$p+1}&q={urlencode($q)}" class="btn btn-default btn-sm"><i
                                class="fa fa-chevron-right"></i></a>
                    </div>
                </div>
            </div>
        </div>
    </div>
{/if}

{include file="customer/footer.tpl"}
