import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';
import '../utils/formatters.dart';

/// Interactive date selector banner designed to be placed at the top of transaction & entry screens.
/// Defaults to current date (Today), allows quick 1-tap previous/next day stepping,
/// full calendar picker dialog, and 1-tap reset to Today when backdated.
class AppDateSelectorBanner extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String label;
  final bool allowFutureDates;

  const AppDateSelectorBanner({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.label = 'Entry Date',
    this.allowFutureDates = true,
  });

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isYesterday(DateTime d) {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return d.year == y.year && d.month == y.month && d.day == y.day;
  }

  void _previousDay() {
    onDateChanged(selectedDate.subtract(const Duration(days: 1)));
  }

  void _nextDay() {
    final next = selectedDate.add(const Duration(days: 1));
    if (!allowFutureDates) {
      final now = DateTime.now();
      if (next.isAfter(DateTime(now.year, now.month, now.day, 23, 59, 59))) {
        return;
      }
    }
    onDateChanged(next);
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: allowFutureDates
          ? now.add(const Duration(days: 365))
          : DateTime(now.year, now.month, now.day, 23, 59, 59),
      builder: (context, child) {
        final theme = context.appTheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: theme.primary,
              onPrimary: Colors.white,
              surface: theme.surface,
              onSurface: theme.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final isToday = _isToday(selectedDate);
    final isYesterday = _isYesterday(selectedDate);
    final isPast = !isToday && !isYesterday && selectedDate.isBefore(DateTime.now());

    String badgeLabel;
    Color badgeColor;
    Color badgeTextColor;

    if (isToday) {
      badgeLabel = 'Today';
      badgeColor = theme.accent;
      badgeTextColor = theme.primary;
    } else if (isYesterday) {
      badgeLabel = 'Yesterday';
      badgeColor = Colors.orange.withValues(alpha: 0.15);
      badgeTextColor = Colors.orange.shade800;
    } else if (isPast) {
      final daysAgo = DateTime.now().difference(selectedDate).inDays;
      badgeLabel = daysAgo > 0 ? '$daysAgo days ago' : 'Past Date';
      badgeColor = Colors.blueGrey.withValues(alpha: 0.15);
      badgeTextColor = theme.textSecondary;
    } else {
      badgeLabel = 'Future Date';
      badgeColor = Colors.purple.withValues(alpha: 0.15);
      badgeTextColor = Colors.purple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? theme.border : theme.primary.withValues(alpha: 0.4),
          width: isToday ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Calendar icon container
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isToday
                        ? theme.accent
                        : theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: theme.primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),

                // Date information text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: theme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              AppFormatters.date(selectedDate),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: theme.text,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Date control buttons: sleek segmented pill [< | 📅 | >]
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: theme.border.withValues(alpha: 0.8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Previous day button
                          InkWell(
                            onTap: _previousDay,
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 6),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 19,
                                color: theme.textSecondary,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 16,
                            color: theme.border.withValues(alpha: 0.7),
                          ),
                          // Calendar picker button
                          InkWell(
                            onTap: () => _pickDate(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 6),
                              child: Icon(
                                Icons.edit_calendar_rounded,
                                size: 16,
                                color: theme.primary,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 16,
                            color: theme.border.withValues(alpha: 0.7),
                          ),
                          // Next day button
                          InkWell(
                            onTap: (!allowFutureDates && isToday)
                                ? null
                                : _nextDay,
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 6),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: 19,
                                color: (!allowFutureDates && isToday)
                                    ? theme.textMuted.withValues(alpha: 0.3)
                                    : theme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // If not today, show a quick "Today" pill
                    if (!isToday) ...[
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () => onDateChanged(DateTime.now()),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 5),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

