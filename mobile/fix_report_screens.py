import re

files = [
    r"mobile\lib\features\reports\screens\gross_profit_screen.dart",
    r"mobile\lib\features\reports\screens\purchase_report_screen.dart",
    r"mobile\lib\features\reports\screens\rmc_report_screen.dart",
    r"mobile\lib\features\reports\screens\sales_report_screen.dart",
    r"mobile\lib\features\reports\screens\stock_report_screen.dart",
]

for fp in files:
    with open(fp, "r", encoding="utf-8") as f:
        c = f.read()

    # 1. Remove "final theme = context.appTheme;" in build if added
    c = c.replace("    final theme = context.appTheme;\n", "")
    c = c.replace("    final theme = context.appTheme;", "")

    # 2. Add "AppThemeColors get theme => context.appTheme;" at the top of the State class
    state_pattern = r'(class _\w+State extends ConsumerState<\w+>[^{]*\{)'
    def add_theme_getter(m):
        return m.group(1) + "\n  AppThemeColors get theme => context.appTheme;\n"

    # Avoid duplicate
    if "AppThemeColors get theme => context.appTheme;" not in c:
        c = re.sub(state_pattern, add_theme_getter, c, count=1)

    # 3. Replace "const Text(..., style: ...copyWith" -> "Text(..., style: ...copyWith"
    c = re.sub(r'const\s+Text\(', 'Text(', c)

    # 4. Replace "const Divider(color: theme." -> "Divider(color: theme."
    c = re.sub(r'const\s+Divider\(', 'Divider(', c)

    # 5. Replace any "const ... theme."
    c = re.sub(r'const\s+([A-Za-z0-9_]+)\(([^)]*theme\.[^)]*)\)', r'\1(\2)', c)

    # 6. Specifically clean up const SizedBox/Container/Row with theme inside
    c = re.sub(r'const\s+BoxDecoration\(([^)]*theme\.[^)]*)\)', r'BoxDecoration(\1)', c)
    c = re.sub(r'const\s+Border\(([^)]*theme\.[^)]*)\)', r'Border(\1)', c)
    c = re.sub(r'const\s+TextStyle\(([^)]*theme\.[^)]*)\)', r'TextStyle(\1)', c)
    c = re.sub(r'const\s+Icon\(([^)]*theme\.[^)]*)\)', r'Icon(\1)', c)

    with open(fp, "w", encoding="utf-8") as f:
        f.write(c)
    print(f"Fixed {fp}")

