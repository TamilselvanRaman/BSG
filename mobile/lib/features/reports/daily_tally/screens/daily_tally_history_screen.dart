import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../data/repositories/app_repository.dart';
import '../models/daily_tally_model.dart';

class DailyTallyHistoryScreen extends ConsumerStatefulWidget {
  const DailyTallyHistoryScreen({super.key});

  @override
  ConsumerState<DailyTallyHistoryScreen> createState() => _DailyTallyHistoryScreenState();
}

class _DailyTallyHistoryScreenState extends ConsumerState<DailyTallyHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final allTallies = ref.watch(dailyTalliesProvider);

    final filtered = allTallies.where((t) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return t.tallyNumber.toLowerCase().contains(q) ||
          (t.notes?.toLowerCase().contains(q) ?? false) ||
          AppFormatters.date(t.date).toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Daily Tally History', style: AppTypography.pageTitle.copyWith(color: theme.text)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: theme.text),
            tooltip: 'Create Daily Tally',
            onPressed: () => context.push('/reports/daily-tally/create'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.border, height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primary,
        foregroundColor: theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Tally'),
        onPressed: () => context.push('/reports/daily-tally/create'),
      ),
      body: Column(
        children: [
          // Search box
          Container(
            color: theme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: theme.text),
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search tally number, date or remarks...',
                hintStyle: TextStyle(color: theme.textMuted),
                prefixIcon: Icon(Icons.search, size: 20, color: theme.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          Divider(height: 1, color: theme.border),

          Expanded(
            child: filtered.isEmpty
                ? AppEmptyState(
                    icon: Icons.history_edu_outlined,
                    title: 'No Tallies Found',
                    description: 'No daily cash registers match your search query.',
                    actionText: 'Record First Tally',
                    onAction: () => context.push('/reports/daily-tally/create'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tally = filtered[index];
                      return _buildTallyCard(tally, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTallyCard(DailyTally tally, AppThemeColors theme) {
    Color badgeBg;
    Color badgeFg;
    String badgeText;

    if (tally.isBalanced) {
      badgeBg = theme.success.withValues(alpha: 0.15);
      badgeFg = theme.success;
      badgeText = 'BALANCED';
    } else if (tally.isSurplus) {
      badgeBg = theme.info.withValues(alpha: 0.15);
      badgeFg = theme.info;
      badgeText = 'SURPLUS +${AppFormatters.currency(tally.cashDifference)}';
    } else {
      badgeBg = theme.error.withValues(alpha: 0.15);
      badgeFg = theme.error;
      badgeText = 'SHORTAGE ${AppFormatters.currency(tally.cashDifference)}';
    }

    return AppCard(
      onTap: () => context.push('/reports/daily-tally/${tally.id}'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(Icons.calculate_outlined, color: theme.primary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tally.tallyNumber, style: AppTypography.cardTitle.copyWith(color: theme.text, fontWeight: FontWeight.bold)),
                      Text(AppFormatters.date(tally.date), style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeFg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: theme.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric('Opening Cash', AppFormatters.currency(tally.openingCash), theme),
              _metric('Available', AppFormatters.currency(tally.totalAvailableCash), theme),
              _metric('Expenses', AppFormatters.currency(tally.totalCashExpenses), theme),
              _metric('Closing Cash', AppFormatters.currency(tally.actualCashCounted), theme, isPrimary: true),
            ],
          ),
          if (tally.notes != null && tally.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Remarks: ${tally.notes}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMuted.copyWith(color: theme.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String label, String value, AppThemeColors theme, {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMuted.copyWith(color: theme.textMuted, fontSize: 10.5)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isPrimary ? theme.primary : theme.text,
          ),
        ),
      ],
    );
  }
}

