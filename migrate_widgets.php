<?php
/**
 * Widget Content Migration Script
 * 
 * This script reviews and migrates widgets containing PHP code
 * to safe HTML format after eval() removal
 * 
 * IMPORTANT: 
 * - Backup database before running
 * - Manual review required for each widget
 * - Some widgets may need manual conversion
 * 
 * Usage: php migrate_widgets.php
 */

// Load PHPNuxBill
require_once __DIR__ . '/init.php';

echo "========================================\n";
echo "Widget Content Migration\n";
echo "========================================\n\n";

// Check if tbl_widgets table exists
if (!isTableExist('tbl_widgets')) {
    echo "WARNING: tbl_widgets table not found.\n";
    echo "This system may not use widgets or table name is different.\n";
    exit(0);
}

// Find widgets with PHP code
$widgets_with_php = ORM::for_table('tbl_widgets')
    ->where_raw("content LIKE '%<?php%' OR content LIKE '%<?%'")
    ->find_many();

$total = count($widgets_with_php);

if ($total == 0) {
    echo "No widgets with PHP code found. Migration not needed.\n";
    exit(0);
}

echo "Found {$total} widgets containing PHP code.\n\n";
echo "========================================\n";
echo "WIDGET REVIEW REQUIRED\n";
echo "========================================\n\n";

$review_needed = [];

foreach ($widgets_with_php as $widget) {
    echo "Widget ID: {$widget->id}\n";
    echo "Title: {$widget->title}\n";
    echo "Type: {$widget->type}\n";
    echo "Content:\n";
    echo "----------------------------------------\n";
    echo $widget->content . "\n";
    echo "----------------------------------------\n\n";
    
    $review_needed[] = [
        'id' => $widget->id,
        'title' => $widget->title,
        'type' => $widget->type,
        'content' => $widget->content
    ];
}

echo "========================================\n";
echo "MIGRATION OPTIONS\n";
echo "========================================\n\n";

echo "For each widget above, you have the following options:\n\n";
echo "1. DISABLE: Comment out PHP code (safest, preserves content)\n";
echo "2. STRIP: Remove all PHP tags (may break functionality)\n";
echo "3. CONVERT: Manually convert to safe HTML/Smarty (recommended)\n";
echo "4. DELETE: Delete the widget entirely\n\n";

echo "Select migration strategy:\n";
echo "1. Disable all PHP code (recommended for review)\n";
echo "2. Strip all PHP tags\n";
echo "3. Manual conversion (exit and convert manually)\n";
echo "4. Delete all widgets with PHP code\n";
echo "5. Cancel migration\n\n";

echo "Enter choice (1-5): ";
$handle = fopen("php://stdin", "r");
$choice = trim(fgets($handle));
fclose($handle);

$migrated_count = 0;

switch ($choice) {
    case '1':
        // Disable PHP code by commenting it out
        echo "\nDisabling PHP code in widgets...\n\n";
        
        foreach ($widgets_with_php as $widget) {
            $original_content = $widget->content;
            
            // Replace <?php with <!-- PHP CODE DISABLED:
            $new_content = str_replace('<?php', '<!-- PHP CODE DISABLED: <?php', $original_content);
            $new_content = str_replace('<?', '<!-- PHP CODE DISABLED: <?', $new_content);
            $new_content = str_replace('?>', '?> -->', $new_content);
            
            $widget->content = $new_content;
            $widget->save();
            
            echo "Disabled PHP in widget: {$widget->title} (ID: {$widget->id})\n";
            $migrated_count++;
            
            _log(
                "Widget PHP code disabled: {$widget->title} (ID: {$widget->id})",
                'Migration',
                0
            );
        }
        break;
        
    case '2':
        // Strip PHP tags
        echo "\nStripping PHP tags from widgets...\n\n";
        
        foreach ($widgets_with_php as $widget) {
            $original_content = $widget->content;
            
            // Remove all PHP tags and code
            $new_content = preg_replace('/<\?php.*?\?>/s', '', $original_content);
            $new_content = preg_replace('/<\?.*?\?>/s', '', $new_content);
            
            $widget->content = $new_content;
            $widget->save();
            
            echo "Stripped PHP from widget: {$widget->title} (ID: {$widget->id})\n";
            $migrated_count++;
            
            _log(
                "Widget PHP code stripped: {$widget->title} (ID: {$widget->id})",
                'Migration',
                0
            );
        }
        break;
        
    case '3':
        // Manual conversion
        echo "\nExporting widget data for manual conversion...\n\n";
        
        $export_file = __DIR__ . '/widgets_to_migrate.json';
        file_put_contents($export_file, json_encode($review_needed, JSON_PRETTY_PRINT));
        
        echo "Widget data exported to: {$export_file}\n";
        echo "Please manually convert each widget and update the database.\n";
        echo "After conversion, run this script again to verify.\n";
        exit(0);
        
    case '4':
        // Delete widgets
        echo "\nWARNING: This will permanently delete all widgets with PHP code!\n";
        echo "Are you sure? (yes/no): ";
        $handle = fopen("php://stdin", "r");
        $confirm = trim(fgets($handle));
        fclose($handle);
        
        if (strtolower($confirm) === 'yes') {
            echo "\nDeleting widgets...\n\n";
            
            foreach ($widgets_with_php as $widget) {
                $widget_title = $widget->title;
                $widget_id = $widget->id;
                
                $widget->delete();
                
                echo "Deleted widget: {$widget_title} (ID: {$widget_id})\n";
                $migrated_count++;
                
                _log(
                    "Widget deleted (contained PHP code): {$widget_title} (ID: {$widget_id})",
                    'Migration',
                    0
                );
            }
        } else {
            echo "Deletion cancelled.\n";
            exit(0);
        }
        break;
        
    case '5':
        echo "Migration cancelled.\n";
        exit(0);
        
    default:
        echo "Invalid choice. Migration cancelled.\n";
        exit(1);
}

echo "\n========================================\n";
echo "Migration Complete\n";
echo "========================================\n";
echo "Widgets processed: {$migrated_count}\n";
echo "\nMigration log saved to database (tbl_logs).\n";

echo "\n========================================\n";
echo "NEXT STEPS\n";
echo "========================================\n";
echo "1. Review migrated widgets in admin panel\n";
echo "2. Test widget functionality\n";
echo "3. Manually convert any widgets that need custom logic\n";
echo "4. Deploy updated widget files (html_php.php, etc.)\n";
echo "========================================\n";
