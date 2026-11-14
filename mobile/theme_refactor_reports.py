import os
import re

files_to_update = [
    r"mobile\lib\features\reports\screens\gross_profit_screen.dart",
    r"mobile\lib\features\reports\screens\purchase_report_screen.dart",
    r"mobile\lib\features\reports\screens\rmc_report_screen.dart",
    r"mobile\lib\features\reports\screens\sales_report_screen.dart",
    r"mobile\lib\features\reports\screens\stock_report_screen.dart",
]

for file_path in files_to_update:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Add theme_extension import if missing
    if "theme_extension.dart" not in content:
        content = content.replace(
            "import '../../../core/theme/app_colors.dart';",
            "import '../../../core/theme/theme_extension.dart';\nimport '../../../core/theme/app_colors.dart';"
        )

    # 2. Add final theme = context.appTheme; in Widget build(BuildContext context)
    def insert_theme_in_build(match):
        build_header = match.group(0)
        return build_header + "\n    final theme = context.appTheme;"

    if "final theme = context.appTheme;" not in content:
        content = re.sub(r'Widget build\(BuildContext context\)\s*\{', insert_theme_in_build, content, count=1)

    # 3. Scaffold background
    content = content.replace("backgroundColor: AppColors.reportBackground,", "backgroundColor: theme.background,")
    content = content.replace("backgroundColor: AppColors.background,", "backgroundColor: theme.background,")

    # 4. AppBar title
    content = content.replace("style: AppTypography.pageTitle", "style: AppTypography.pageTitle.copyWith(color: theme.text)")

    # 5. Container color: Colors.white
    content = content.replace("color: Colors.white,", "color: theme.surface,")

    # 6. Report border and text
    content = content.replace("AppColors.reportBorder", "theme.border")
    content = content.replace("AppColors.reportTextPrimary", "theme.text")
    content = content.replace("AppColors.reportTextSecondary", "theme.textSecondary")
    content = content.replace("AppColors.reportLightGreen", "theme.accent")
    content = content.replace("AppColors.reportPrimary", "theme.primary")
    content = content.replace("AppColors.subtleSurface", "theme.accent")

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Updated {file_path}")

