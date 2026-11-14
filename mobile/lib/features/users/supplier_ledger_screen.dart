import '../../core/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/repositories/app_repository.dart';

class SupplierLedgerScreen extends ConsumerWidget {
  final String supplierId;

  const SupplierLedgerScreen({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final repo = ref.watch(appRepositoryProvider);
    final supplier = repo.getSupplier(supplierId);

    if (supplier == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Supplier Ledger')),
        body: const AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Supplier Not Found',
          description: 'The requested supplier does not exist.',
        ),
      );
    }

    final ledger = repo.getSupplierLedger(supplierId);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Supplier Ledger', style: AppTypography.pageTitle),
      ),
      body: Column(
        children: [
          // Header Card with Payable summary
          Container(
            color: theme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(supplier.name, style: AppTypography.cardTitle.copyWith(fontSize: 18)),
                        Text('${supplier.phone}${supplier.city != null ? ' • ${supplier.city}' : ''}',
                            style: AppTypography.bodySecondary),
                      ],
                    ),
                    AppButton(
                      text: 'Create Lot',
                      icon: Icons.add_box_outlined,
                      isFullWidth: false,
                      height: 40,
                      onPressed: () => context.push('/lots/create?supplierId=${supplier.id}'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payable Balance to Supplier', style: AppTypography.body),
                      Text(
                        AppFormatters.currency(supplier.currentBalance),
                        style: AppTypography.amount,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.border),

          // Ledger Entries List
          Expanded(
            child: ledger.isEmpty
                ? const AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Ledger Entries',
                    description: 'Inward lots and payments will appear here chronologically.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ledger.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = ledger[index];
                      final isCredit = item.credit > 0;

                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppFormatters.date(item.date), style: AppTypography.labelMuted),
                                Text(
                                  item.refNumber,
                                  style: AppTypography.label.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(item.description, style: AppTypography.cardTitle),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isCredit ? '+ ${AppFormatters.currency(item.credit)}' : '- ${AppFormatters.currency(item.debit)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isCredit ? AppColors.textPrimary : AppColors.success,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isCredit ? '(Inward Lot)' : '(Payout)',
                                      style: AppTypography.labelMuted,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Bal: ', style: AppTypography.labelMuted),
                                    Text(
                                      AppFormatters.currency(item.runningBalance),
                                      style: AppTypography.cardTitle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
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

