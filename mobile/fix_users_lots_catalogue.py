import os
import re

# 1. Fix product_crop_selector_sheet.dart
pcs_path = r"mobile\lib\features\catalogue\widgets\product_crop_selector_sheet.dart"
with open(pcs_path, "r", encoding="utf-8") as f:
    c = f.read()

if "AppThemeColors get theme => context.appTheme;" not in c:
    c = re.sub(
        r'(class _ProductCropSelectorSheetState extends State<ProductCropSelectorSheet>[^{]*\{)',
        r'\1\n  AppThemeColors get theme => context.appTheme;\n',
        c
    )

c = c.replace("color: Colors.white,\n        borderRadius: const BorderRadius.vertical", "color: theme.surface,\n        borderRadius: const BorderRadius.vertical")
c = c.replace("color: Colors.white,\n        borderRadius: BorderRadius.vertical", "color: theme.surface,\n        borderRadius: BorderRadius.vertical")
c = c.replace("color: const Color(0xFF1F2937)", "color: theme.text")
c = c.replace("color: Color(0xFF1F2937)", "color: theme.text")
c = c.replace("color: const Color(0xFF1E293B)", "color: theme.text")
c = c.replace("color: Color(0xFF1E293B)", "color: theme.text")
c = c.replace("color: const Color(0xFF159B3D)", "color: theme.primary")
c = c.replace("color: Color(0xFF159B3D)", "color: theme.primary")
c = c.replace("backgroundColor: const Color(0xFF159B3D)", "backgroundColor: theme.primary")
c = c.replace("color: const Color(0xFFE2E8F0)", "color: theme.border")
c = c.replace("color: const Color(0xFFD6E4F0)", "color: theme.border")
c = c.replace("color: const Color(0xFF64748B)", "color: theme.textSecondary")
c = c.replace("color: const Color(0xFF94A3B8)", "color: theme.textMuted")
c = c.replace("color: Color(0xFF94A3B8)", "color: theme.textMuted")
c = c.replace("foregroundColor: Colors.white,\n            elevation: 0,", "foregroundColor: theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white,\n            elevation: 0,")
c = c.replace("decoration: const BoxDecoration(\n        color: Colors.white,", "decoration: BoxDecoration(\n        color: theme.surface,")
c = c.replace("decoration: BoxDecoration(\n                  color: Colors.white,", "decoration: BoxDecoration(\n                  color: theme.surface,")
c = c.replace("style: const TextStyle(fontSize: 14, color: theme.text)", "style: TextStyle(fontSize: 14, color: theme.text)")
c = c.replace("hintStyle: const TextStyle(fontSize: 13, color: theme.textMuted)", "hintStyle: TextStyle(fontSize: 13, color: theme.textMuted)")
c = c.replace("border: Border.all(\n                    color: theme.border,", "border: Border.all(\n                    color: theme.border,")
c = c.replace("border: Border.all(\n                        color: Colors.white,", "border: Border.all(\n                        color: theme.surface,")

with open(pcs_path, "w", encoding="utf-8") as f:
    f.write(c)
print("Updated product_crop_selector_sheet.dart")

# Remaining screens
other_files = [
    r"mobile\lib\features\users\users_landing_screen.dart",
    r"mobile\lib\features\users\customer_ledger_screen.dart",
    r"mobile\lib\features\users\supplier_ledger_screen.dart",
    r"mobile\lib\features\users\partner_dialogs.dart",
    r"mobile\lib\features\lots\create_lot_screen.dart",
    r"mobile\lib\features\lots\lots_list_screen.dart",
    r"mobile\lib\features\lots\lot_details_screen.dart",
    r"mobile\lib\features\lots\stock_summary_screen.dart",
    r"mobile\lib\features\search\global_search_screen.dart",
]

for fp in other_files:
    with open(fp, "r", encoding="utf-8") as f:
        c = f.read()

    # Add theme getter to State classes
    state_pattern = r'(class _\w+State extends (?:ConsumerState|State)<\w+>[^{]*\{)'
    def add_theme_getter(m):
        return m.group(1) + "\n  AppThemeColors get theme => context.appTheme;\n"

    if "AppThemeColors get theme => context.appTheme;" not in c:
        c = re.sub(state_pattern, add_theme_getter, c)

    # For dialogs / stateless widgets
    c = re.sub(r'Widget build\(BuildContext context\)\s*\{', r'Widget build(BuildContext context) {\n    final theme = context.appTheme;', c)

    # Replace AppColors.textPrimary and textSecondary
    c = c.replace("color: AppColors.textPrimary", "color: theme.text")
    c = c.replace("color: AppColors.textSecondary", "color: theme.textSecondary")
    c = c.replace("color: AppColors.primaryAction", "color: theme.primary")
    c = c.replace("backgroundColor: AppColors.primaryAction", "backgroundColor: theme.primary")

    # Clean up invalid const
    c = re.sub(r'const\s+TextStyle\(([^)]*theme\.[^)]*)\)', r'TextStyle(\1)', c)
    c = re.sub(r'const\s+Icon\(([^)]*theme\.[^)]*)\)', r'Icon(\1)', c)
    c = re.sub(r'const\s+Text\(([^)]*theme\.[^)]*)\)', r'Text(\1)', c)
    c = re.sub(r'const\s+Divider\(([^)]*theme\.[^)]*)\)', r'Divider(\1)', c)
    c = re.sub(r'const\s+BorderSide\(([^)]*theme\.[^)]*)\)', r'BorderSide(\1)', c)

    with open(fp, "w", encoding="utf-8") as f:
        f.write(c)
    print(f"Updated {fp}")
