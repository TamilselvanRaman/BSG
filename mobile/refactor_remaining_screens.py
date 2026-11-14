import os
import re

files = [
    r"mobile\lib\features\users\users_landing_screen.dart",
    r"mobile\lib\features\users\customer_ledger_screen.dart",
    r"mobile\lib\features\users\supplier_ledger_screen.dart",
    r"mobile\lib\features\users\partner_dialogs.dart",
    r"mobile\lib\features\lots\create_lot_screen.dart",
    r"mobile\lib\features\lots\lots_list_screen.dart",
    r"mobile\lib\features\lots\lot_details_screen.dart",
    r"mobile\lib\features\lots\stock_summary_screen.dart",
    r"mobile\lib\features\search\global_search_screen.dart",
    r"mobile\lib\features\catalogue\widgets\product_crop_selector_sheet.dart",
]

for fp in files:
    if not os.path.exists(fp):
        print(f"Skipping {fp}: not found")
        continue

    with open(fp, "r", encoding="utf-8") as f:
        c = f.read()

    # 1. Ensure theme_extension import
    if "theme_extension.dart" not in c:
        # Determine relative path depth
        if "features\\catalogue\\widgets" in fp:
            rel = "../../../core/theme/theme_extension.dart"
        else:
            rel = "../../core/theme/theme_extension.dart"
        c = f"import '{rel}';\n" + c

    # 2. Add theme getter to State or build method
    # For State classes, add getter if missing
    state_pattern = r'(class _\w+State extends (?:ConsumerState|State)<\w+>[^{]*\{)'
    def add_theme_getter(m):
        return m.group(1) + "\n  AppThemeColors get theme => context.appTheme;\n"

    if "AppThemeColors get theme => context.appTheme;" not in c and "class _" in c:
        c = re.sub(state_pattern, add_theme_getter, c, count=1)

    # 3. For Stateless/ConsumerWidget build methods, ensure final theme = context.appTheme;
    # (Only if not already having getter)
    if "AppThemeColors get theme => context.appTheme;" not in c and "final theme = context.appTheme;" not in c:
        def insert_build_theme(m):
            return m.group(0) + "\n    final theme = context.appTheme;"
        c = re.sub(r'Widget build\([^{]*\)\s*\{', insert_build_theme, c)

    # 4. Standard replacements
    c = c.replace("backgroundColor: AppColors.background,", "backgroundColor: theme.background,")
    c = c.replace("backgroundColor: AppColors.surface,", "backgroundColor: theme.surface,")
    c = c.replace("color: AppColors.surface,", "color: theme.surface,")
    c = c.replace("color: AppColors.subtleSurface,", "color: theme.accent,")
    c = c.replace("backgroundColor: AppColors.subtleSurface,", "backgroundColor: theme.accent,")
    c = c.replace("AppColors.reportLightGreen", "theme.accent")
    c = c.replace("AppColors.reportPrimary", "theme.primary")
    c = c.replace("AppColors.reportBorder", "theme.border")
    c = c.replace("AppColors.reportTextPrimary", "theme.text")
    c = c.replace("AppColors.reportTextSecondary", "theme.textSecondary")

    # In AppBar
    c = c.replace("backgroundColor: Colors.white,\n        elevation: 0,", "backgroundColor: theme.background,\n        elevation: 0,")
    c = c.replace("backgroundColor: Colors.white,", "backgroundColor: theme.background,")

    # Clean up const with theme
    c = re.sub(r'const\s+Divider\(([^)]*theme\.[^)]*)\)', r'Divider(\1)', c)
    c = re.sub(r'const\s+Divider\(height:\s*\d+,\s*color:\s*AppColors\.border\)', r'Divider(height: 1, color: theme.border)', c)
    c = re.sub(r'const\s+Divider\(color:\s*AppColors\.border\)', r'Divider(color: theme.border)', c)
    c = re.sub(r'const\s+Divider\(color:\s*AppColors\.border,\s*height:\s*\d+\)', r'Divider(color: theme.border, height: 20)', c)

    c = c.replace("color: AppColors.border,", "color: theme.border,")
    c = c.replace("color: AppColors.border", "color: theme.border")

    with open(fp, "w", encoding="utf-8") as f:
        f.write(c)
    print(f"Refactored {fp}")

