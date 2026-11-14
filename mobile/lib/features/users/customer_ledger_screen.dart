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

class CustomerLedgerScreen extends ConsumerWidget {
  final String customerId;

  const CustomerLedgerScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final repo = ref.watch(appRepositoryProvider);
    final customer = repo.getCustomer(customerId);

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Ledger')),
        body: const AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Customer Not Found',
          description: 'The requested customer does not exist.',
        ),
      );
    }

    final ledger = repo.getCustomerLedger(customerId);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Customer Ledger', style: AppTypography.pageTitle),
      ),
      body: Column(
        children: [
          // Header Card with Outstanding summary
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
                        Text(customer.name, style: AppTypography.cardTitle.copyWith(fontSize: 18)),
                        Text('${customer.phone}${customer.city != null ? ' • ${customer.city}' : ''}',
                            style: AppTypography.bodySecondary),
                      ],
                    ),
                    AppButton(
                      text: 'Receive Amount',
                      icon: Icons.arrow_downward_rounded,
                      isFullWidth: false,
                      height: 40,
                      onPressed: () => context.push('/payments/received-amount?customerId=${customer.id}'),
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
                      const Text('Total Outstanding Due', style: AppTypography.body),
                      Text(
                        AppFormatters.currency(customer.currentOutstanding),
                        style: AppTypography.amount.copyWith(
                          color: customer.currentOutstanding > 0 ? AppColors.warning : AppColors.textPrimary,
                        ),
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
                    description: 'Transactions and credit bills will appear here chronologically.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ledger.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = ledger[index];
                      final isDebit = item.debit > 0;

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
                                      isDebit ? '+ ${AppFormatters.currency(item.debit)}' : '- ${AppFormatters.currency(item.credit)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isDebit ? AppColors.warning : AppColors.success,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isDebit ? '(Debit / Bill)' : '(Credit / Payment)',
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

