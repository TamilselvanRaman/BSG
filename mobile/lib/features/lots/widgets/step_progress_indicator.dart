import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final Function(int) onStepTapped;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Counter & Current Title Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'STEP ${currentStep + 1} OF $totalSteps',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.primary,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stepTitles[currentStep],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.text,
                    ),
                  ),
                ],
              ),
              Text(
                '${((currentStep + 1) / totalSteps * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Progress Bar with Segmented Dots
          Row(
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (index <= currentStep) {
                      onStepTapped(index);
                    }
                  },
                  child: Container(
                    height: 5,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 2,
                      right: index == totalSteps - 1 ? 0 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? theme.primary
                          : isCompleted
                              ? theme.primary.withValues(alpha: 0.5)
                              : theme.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 10),

          // Horizontal Scrollable Step Pills for direct navigation
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: totalSteps,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final isCompleted = index < currentStep;
                final isCurrent = index == currentStep;

                return GestureDetector(
                  onTap: () {
                    if (index <= currentStep) {
                      onStepTapped(index);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? theme.primary
                          : isCompleted
                              ? theme.accent
                              : theme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent
                            ? theme.primary
                            : isCompleted
                                ? theme.border
                                : theme.border.withValues(alpha: 0.6),
                        width: isCurrent ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCompleted)
                          Icon(
                            Icons.check,
                            size: 12,
                            color: theme.primary,
                          )
                        else
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent
                                  ? Colors.white
                                  : isCompleted
                                      ? theme.text
                                      : theme.textMuted,
                            ),
                          ),
                        const SizedBox(width: 4),
                        Text(
                          stepTitles[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isCurrent
                                ? Colors.white
                                : isCompleted
                                    ? theme.text
                                    : theme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

