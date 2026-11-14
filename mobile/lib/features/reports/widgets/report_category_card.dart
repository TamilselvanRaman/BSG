import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';

class SubmenuOption {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const SubmenuOption({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class ReportCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<SubmenuOption> submenus;
  final Color? accentColor;
  final String? badgeText;

  const ReportCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isExpanded,
    required this.onToggle,
    required this.submenus,
    this.accentColor,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final primaryColor = accentColor ?? theme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? primaryColor.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
          width: isExpanded ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? primaryColor.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: isExpanded ? 10 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Card
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Distinct Corporate Category Icon Squircle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title, Subtitle, and Badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: theme.text,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (badgeText != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    badgeText!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: theme.textSecondary,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Elegant Rotating Chevron
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isExpanded ? primaryColor.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: isExpanded ? primaryColor : const Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Submenu List
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(13)),
              ),
              child: Column(
                children: [
                  ...submenus.asMap().entries.map((entry) {
                    final sub = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: sub.onTap,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(sub.icon, size: 16, color: primaryColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sub.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: theme.text,
                                        ),
                                      ),
                                      if (sub.subtitle != null) ...[
                                        const SizedBox(height: 1),
                                        Text(
                                          sub.subtitle!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 15,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
