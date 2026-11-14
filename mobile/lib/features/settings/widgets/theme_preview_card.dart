import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';

/// Card component that presents an interactive theme option with a miniature live dashboard preview.
class ThemePreviewCard extends StatelessWidget {
  final AppThemeColors theme;
  final bool isSelected;
  final VoidCallback onSelect;

  const ThemePreviewCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onSelect,
  });

  String _getThemeCode(String id) {
    switch (id) {
      case 'classic':
        return 'THEME 01';
      case 'green':
        return 'THEME 02';
      case 'navy':
        return 'THEME 03';
      case 'burgundy':
        return 'THEME 04';
      case 'midnight':
        return 'THEME 05';
      default:
        return 'THEME';
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = Theme.of(context).extension<AppThemeColors>() ?? AppThemeColors.classic;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: activeTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? theme.primary : activeTheme.border,
          width: isSelected ? 2.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? theme.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Theme Title, Subtitle, and Selection Indicator
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getThemeCode(theme.id),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  theme.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: activeTheme.text,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: activeTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Active Checkmark Badge
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? theme.primary : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? theme.primary : activeTheme.border,
                          width: 2.0,
                        ),
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Miniature Live Dashboard Preview (as specified in requirement #7)
                _buildMiniDashboardPreview(),

                const SizedBox(height: 14),

                // Palette Swatches
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSwatchItem('Background', theme.background, _colorToHex(theme.background)),
                    _buildSwatchItem('Card', theme.surface, _colorToHex(theme.surface)),
                    _buildSwatchItem('Primary', theme.primary, _colorToHex(theme.primary)),
                    _buildSwatchItem('Text', theme.text, _colorToHex(theme.text)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Miniature Live Dashboard Preview: Header, 2 Action Cards, 2 Summary KPIs, Bottom Bar
  Widget _buildMiniDashboardPreview() {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        children: [
          // Mini Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primary,
                    ),
                    child: Center(
                      child: Text(
                        'B',
                        style: TextStyle(
                          fontSize: 8,
                          color: theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'BSG Trading Corp',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.text,
                    ),
                  ),
                ],
              ),
              Icon(Icons.search, size: 13, color: theme.textSecondary),
            ],
          ),
          const SizedBox(height: 6),

          // Mini Quick Actions (2 cards)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt, size: 10, color: theme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Create Bill',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: theme.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_box, size: 10, color: theme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Create Lot',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: theme.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Mini Today's Overview (2 KPI cards)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Sales',
                        style: TextStyle(fontSize: 7, color: theme.textSecondary),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '₹21,400',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: theme.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Received',
                        style: TextStyle(fontSize: 7, color: theme.textSecondary),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '₹7,200',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: theme.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),

          // Mini Bottom Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.home, size: 9, color: theme.primary),
                Icon(Icons.receipt_long, size: 9, color: theme.textSecondary),
                Icon(Icons.account_balance_wallet, size: 9, color: theme.textSecondary),
                Icon(Icons.people, size: 9, color: theme.textSecondary),
                Icon(Icons.bar_chart, size: 9, color: theme.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwatchItem(String label, Color color, String hex) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.15), width: 1.0),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          hex,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

