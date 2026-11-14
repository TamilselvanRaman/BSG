import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/repositories/app_repository.dart';

class DailyCashReconciliationScreen extends ConsumerStatefulWidget {
  const DailyCashReconciliationScreen({super.key});

  @override
  ConsumerState<DailyCashReconciliationScreen> createState() => _DailyCashReconciliationScreenState();
}

class _DailyCashReconciliationScreenState extends ConsumerState<DailyCashReconciliationScreen> {
  final Map<int, int> _counts = {
    500: 0,
    200: 0,
    100: 0,
    50: 0,
    20: 0,
    10: 0,
  };
  int _coins = 0;

  final Map<int, TextEditingController> _controllers = {};
  final TextEditingController _coinsController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    for (final denom in _counts.keys) {
      _controllers[denom] = TextEditingController(text: '0');
    }

    // Default sample for demonstration
    _counts[500] = 20; // 10,000
    _counts[200] = 10; // 2,000
    _counts[100] = 15; // 1,500
    _counts[50] = 2;   // 100
    _counts[20] = 1;   // 20
    _counts[10] = 1;   // 10
    _coins = 0;

    _counts.forEach((k, v) {
      _controllers[k]?.text = v.toString();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _coinsController.dispose();
    super.dispose();
  }

  double get _totalCounted {
    double sum = _coins.toDouble();
    _counts.forEach((denom, count) {
      sum += (denom * count);
    });
    return sum;
  }

  void _updateCount(int denom, int delta) {
    setState(() {
      final current = _counts[denom] ?? 0;
      final updated = (current + delta).clamp(0, 99999);
      _counts[denom] = updated;
      _controllers[denom]?.text = updated.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final allTallies = ref.watch(dailyTalliesProvider);
    final todayTally = allTallies.firstOrNull;

    final expectedCash = todayTally?.expectedClosingCash ?? 13630.0;
    final difference = _totalCounted - expectedCash;
    final isBalanced = difference.abs() < 0.01;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Cash Reconciliation', style: AppTypography.pageTitle.copyWith(color: theme.text)),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _counts.updateAll((key, value) => 0);
                _coins = 0;
                for (final c in _controllers.values) {
                  c.text = '0';
                }
                _coinsController.text = '0';
              });
            },
            child: Text('Reset', style: TextStyle(color: theme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.border, height: 1),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(top: BorderSide(color: theme.border, width: 1)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Physical Cash Counted', style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
                      Text(
                        AppFormatters.currency(_totalCounted),
                        style: AppTypography.amountLarge.copyWith(color: theme.primary, fontWeight: FontWeight.w800, fontSize: 24),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isBalanced
                          ? theme.success.withValues(alpha: 0.15)
                          : (difference > 0 ? theme.info.withValues(alpha: 0.15) : theme.error.withValues(alpha: 0.15)),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Text(
                      isBalanced
                          ? 'BALANCED'
                          : (difference > 0 ? '+${AppFormatters.currency(difference)}' : AppFormatters.currency(difference)),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isBalanced ? theme.success : (difference > 0 ? theme.info : theme.error),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Apply to Tally',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () {
                        Navigator.of(context).pop(_totalCounted);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Audit Comparison Hero Card
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _heroStat('Expected Cash', AppFormatters.currency(expectedCash), theme.textSecondary, theme),
                    Container(width: 1, height: 36, color: theme.border),
                    _heroStat('Actual Counted', AppFormatters.currency(_totalCounted), theme.primary, theme),
                    Container(width: 1, height: 36, color: theme.border),
                    _heroStat(
                      'Difference',
                      isBalanced ? '₹0.00' : AppFormatters.currency(difference),
                      isBalanced ? theme.success : (difference > 0 ? theme.info : theme.error),
                      theme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Currency Denominations Counter',
            style: AppTypography.sectionHeading.copyWith(color: theme.text),
          ),
          const SizedBox(height: 10),

          // Denomination items
          ..._counts.keys.map((denom) {
            final count = _counts[denom] ?? 0;
            final lineTotal = denom * count;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Denomination Pill
                    Container(
                      width: 58,
                      height: 38,
                      decoration: BoxDecoration(
                        color: theme.accent,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Center(
                        child: Text(
                          '₹$denom',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Counter buttons & input
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: theme.textSecondary, size: 22),
                      onPressed: () => _updateCount(denom, -1),
                    ),
                    SizedBox(
                      width: 48,
                      child: TextField(
                        controller: _controllers[denom],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.text, fontWeight: FontWeight.bold, fontSize: 15),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val) ?? 0;
                          setState(() => _counts[denom] = parsed.clamp(0, 99999));
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: theme.primary, size: 22),
                      onPressed: () => _updateCount(denom, 1),
                    ),

                    const Spacer(),

                    // Line total
                    Text(
                      AppFormatters.currency(lineTotal.toDouble()),
                      style: AppTypography.cardTitle.copyWith(
                        color: theme.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Coins entry
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Center(
                    child: Text(
                      'Coins',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: theme.textSecondary, size: 22),
                  onPressed: () {
                    setState(() {
                      _coins = (_coins - 10).clamp(0, 99999);
                      _coinsController.text = _coins.toString();
                    });
                  },
                ),
                SizedBox(
                  width: 48,
                  child: TextField(
                    controller: _coinsController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.text, fontWeight: FontWeight.bold, fontSize: 15),
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 0;
                      setState(() => _coins = parsed.clamp(0, 99999));
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: theme.primary, size: 22),
                  onPressed: () {
                    setState(() {
                      _coins = (_coins + 10).clamp(0, 99999);
                      _coinsController.text = _coins.toString();
                    });
                  },
                ),
                const Spacer(),
                Text(
                  AppFormatters.currency(_coins.toDouble()),
                  style: AppTypography.cardTitle.copyWith(color: theme.text, fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _heroStat(String title, String val, Color color, AppThemeColors theme) {
    return Column(
      children: [
        Text(title, style: AppTypography.labelMuted.copyWith(color: theme.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
