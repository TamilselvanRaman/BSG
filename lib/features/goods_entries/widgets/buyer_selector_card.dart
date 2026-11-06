import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../data/models/customer.dart';

class BuyerSelectorCard extends StatelessWidget {
  final Customer? selectedCustomer;
  final List<Customer> customers;
  final ValueChanged<Customer> onSelected;
  final VoidCallback? onAddNewCustomer;

  const BuyerSelectorCard({
    super.key,
    required this.selectedCustomer,
    required this.customers,
    required this.onSelected,
    this.onAddNewCustomer,
  });

  void _openBuyerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BuyerPickerSheet(
        customers: customers,
        selectedId: selectedCustomer?.id,
        onSelected: (c) {
          Navigator.of(ctx).pop();
          onSelected(c);
        },
        onAddNew: () {
          Navigator.of(ctx).pop();
          onAddNewCustomer?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCustomer != null) {
      final c = selectedCustomer!;
      final hasDues = c.openingBalance > 0;

      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.primaryGreen, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryGreenDark,
              child: Text(
                c.name.isNotEmpty ? c.name.substring(0, 1).toUpperCase() : 'B',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreenSurface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'BUYER SELECTED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreenDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${c.village} • ${c.phone}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: hasDues ? AppColors.pendingBg : AppColors.successBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        hasDues
                            ? 'Outstanding Due: ${CurrencyFormatter.format(c.openingBalance)}'
                            : 'Account Settled (₹0 Due)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: hasDues ? AppColors.pending : AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => _openBuyerPicker(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => _openBuyerPicker(context),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border, width: 1.4),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightGreenSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_search_rounded, color: AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Buyer / Mandi Trader *',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap to select from directory with live balance lookup',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _BuyerPickerSheet extends StatefulWidget {
  final List<Customer> customers;
  final String? selectedId;
  final ValueChanged<Customer> onSelected;
  final VoidCallback onAddNew;

  const _BuyerPickerSheet({
    required this.customers,
    required this.selectedId,
    required this.onSelected,
    required this.onAddNew,
  });

  @override
  State<_BuyerPickerSheet> createState() => _BuyerPickerSheetState();
}

class _BuyerPickerSheetState extends State<_BuyerPickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.customers.where((c) {
      final q = _search.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.village.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Buyer Directory', style: AppTypography.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
              child: TextField(
                autofocus: true,
                onChanged: (val) => setState(() => _search = val),
                decoration: InputDecoration(
                  hintText: 'Search buyer name, village, or phone...',
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_off_outlined, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          Text('No buyers matching "$_search"', style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person_add),
                            label: const Text('Register New Buyer'),
                            onPressed: widget.onAddNew,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final c = filtered[index];
                        final isSelected = c.id == widget.selectedId;

                        return InkWell(
                          onTap: () => widget.onSelected(c),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.lightGreenSurface : AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryGreen : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isSelected ? AppColors.primaryGreen : AppColors.background,
                                  child: Text(
                                    c.name.isNotEmpty ? c.name[0].toUpperCase() : 'B',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? Colors.white : AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: isSelected ? AppColors.primaryGreenDark : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${c.village} • ${c.phone}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(c.openingBalance),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: c.openingBalance > 0 ? AppColors.pending : AppColors.primaryGreen,
                                      ),
                                    ),
                                    Text(
                                      c.openingBalance > 0 ? 'Dues' : 'Zero Due',
                                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                    ),
                                  ],
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
      ),
    );
  }
}
