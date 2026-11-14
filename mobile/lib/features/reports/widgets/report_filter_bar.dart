import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';

class ReportDateNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const ReportDateNavigator({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: theme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: theme.text),
            tooltip: 'Previous Day',
            onPressed: () => onDateChanged(selectedDate.subtract(const Duration(days: 1))),
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) onDateChanged(picked);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: theme.primary),
                  const SizedBox(width: 8),
                  Text(
                    AppFormatters.date(selectedDate),
                    style: AppTypography.cardTitle.copyWith(fontSize: 14.5, color: theme.text),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: theme.text),
            tooltip: 'Next Day',
            onPressed: () => onDateChanged(selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }
}

class ReportDateRangePickerBar extends StatelessWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final Function(DateTime start, DateTime end) onRangeChanged;

  const ReportDateRangePickerBar({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: theme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.date_range_outlined, size: 18, color: theme.primary),
              const SizedBox(width: 8),
              Text(
                '${AppFormatters.date(fromDate)}  –  ${AppFormatters.date(toDate)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDateRange: DateTimeRange(start: fromDate, end: toDate),
              );
              if (range != null) {
                onRangeChanged(range.start, range.end);
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Change',
              style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
