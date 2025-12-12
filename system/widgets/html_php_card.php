<?php

class html_php
{

    public function getWidget($data = null)
    {
        global $ui;
        $ui->assign('card_header', $data['title']);
        
        // SECURITY FIX: Remove eval() to prevent RCE
        // Sanitize HTML content to allow only safe tags
        $content = SecurityHelper::sanitizeHtml($data['content']);
        
        // Log security event if PHP code detected
        if (stripos($data['content'], '<?php') !== false || stripos($data['content'], '<?') !== false) {
            SecurityHelper::logSecurityEvent(
                "Widget contains PHP code (disabled): " . $data['title'],
                'high',
                ['widget_id' => $data['id'] ?? 'unknown']
            );
        }
        
        $ui->assign('card_body', $content);
        return $ui->fetch('widget/card_html.tpl');
    }
}