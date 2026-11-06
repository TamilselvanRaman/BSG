import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class EnterpriseAccordionSection extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final String? summaryBadge;
  final bool isExpanded;
  final bool isCompleted;
  final VoidCallback onToggle;
  final Widget content;
  final VoidCallback? onContinue;
  final String? continueLabel;

  const EnterpriseAccordionSection({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    this.summaryBadge,
    required this.isExpanded,
    this.isCompleted = false,
    required this.onToggle,
    required this.content,
    this.onContinue,
    this.continueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isExpanded ? AppColors.primaryGreen : AppColors.border,
          width: isExpanded ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? AppColors.primaryGreen.withValues(alpha: 0.08)
                : const Color(0x06000000),
            blurRadius: isExpanded ? 8 : 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accordion Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(AppSpacing.radiusMd),
              bottom: Radius.circular(isExpanded ? 0 : AppSpacing.radiusMd),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Step Badge / Checkmark
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primaryGreen
                          : (isExpanded ? AppColors.lightGreenSurface : AppColors.background),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.primaryGreen
                            : (isExpanded ? AppColors.primaryGreen : AppColors.border),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : Text(
                              '$stepNumber',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isExpanded ? AppColors.primaryGreenDark : AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Title & Subtitle / Summary
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (isCompleted && !isExpanded) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreenSurface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'COMPLETED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryGreenDark,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          !isExpanded && summaryBadge != null && summaryBadge!.isNotEmpty
                              ? summaryBadge!
                              : subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: !isExpanded && summaryBadge != null
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: !isExpanded && summaryBadge != null
                                ? AppColors.primaryGreenDark
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Expand/Collapse Chevron
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isExpanded ? AppColors.lightGreenSurface : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: isExpanded ? AppColors.primaryGreen : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Content
          if (isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  content,
                  if (onContinue != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.elevatedSurface,
                          foregroundColor: AppColors.primaryGreenDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            side: const BorderSide(color: AppColors.border, width: 1.2),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_downward, size: 16),
                        label: Text(
                          continueLabel ?? 'Continue to Next Step',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
