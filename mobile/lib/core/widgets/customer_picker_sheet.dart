import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import 'app_text_field.dart';
import 'app_dialog.dart';
import '../../data/models/partner_models.dart';
import '../../data/repositories/app_repository.dart';

/// Modal bottom sheet allowing users to search, pick an existing customer
/// with their outstanding dues, choose a walk-in counter sale, or create a new customer on the spot.
class CustomerPickerSheet extends ConsumerStatefulWidget {
  final bool allowCounterSale;
  final String? selectedCustomerId;

  const CustomerPickerSheet({
    super.key,
    this.allowCounterSale = true,
    this.selectedCustomerId,
  });

  static Future<dynamic> show(
    BuildContext context, {
    bool allowCounterSale = true,
    String? selectedCustomerId,
  }) {
    final theme = context.appTheme;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CustomerPickerSheet(
        allowCounterSale: allowCounterSale,
        selectedCustomerId: selectedCustomerId,
      ),
    );
  }

  @override
  ConsumerState<CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends ConsumerState<CustomerPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openNewCustomerDialog() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    final created = await showDialog<Customer>(
      context: context,
      builder: (ctx) {
        final theme = context.appTheme;
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_add_rounded, color: theme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Add New Customer',
                  style: AppTypography.cardTitle.copyWith(color: theme.text),
                ),
              ),
            ],
          ),
          content: Form(
            key: dialogFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'Customer / Buyer Name *',
                    hint: 'e.g. Ramesh Traders',
                    controller: nameCtrl,
                    validator: (v) => AppValidators.required(v, 'Customer name is required'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Phone Number *',
                    hint: '10-digit mobile number',
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'City / Market Location (Optional)',
                    hint: 'e.g. Madurai Market',
                    controller: cityCtrl,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: theme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (!dialogFormKey.currentState!.validate()) return;
                final newCust = await ref.read(appRepositoryProvider).addCustomer(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  city: cityCtrl.text.trim().isNotEmpty ? cityCtrl.text.trim() : null,
                );
                if (ctx.mounted) Navigator.pop(ctx, newCust);
              },
              child: const Text('Save Customer'),
            ),
          ],
        );
      },
    );

    if (created != null && mounted) {
      AppDialog.showSnackBar(context, 'Customer "${created.name}" created successfully');
      Navigator.pop(context, created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final customers = ref.watch(customersProvider);

    final filtered = customers.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          (c.city?.toLowerCase().contains(q) ?? false);
    }).toList();

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Handle & Title
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Customer / Buyer',
                    style: AppTypography.pageTitle.copyWith(
                      color: theme.text,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: theme.text),
                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search by name, phone or market...',
                  hintStyle: TextStyle(color: theme.textMuted, fontSize: 13),
                  prefixIcon: Icon(Icons.search, size: 20, color: theme.primary),
                  filled: true,
                  fillColor: theme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Top Quick Action Row: Add New Customer & Counter Sale
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openNewCustomerDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primary,
                        side: BorderSide(color: theme.primary, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                      label: const Text(
                        'New Customer',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (widget.allowCounterSale) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, 'COUNTER_SALE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.selectedCustomerId == 'COUNTER_SALE'
                              ? theme.primary
                              : theme.accent,
                          foregroundColor: widget.selectedCustomerId == 'COUNTER_SALE'
                              ? Colors.white
                              : theme.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: theme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.storefront_outlined, size: 16),
                        label: const Text(
                          'Cash Walk-in',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: theme.border),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Text(
                'EXISTING CUSTOMERS (${filtered.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Customer List
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_off_outlined, size: 36, color: theme.textMuted),
                            const SizedBox(height: 8),
                            Text(
                              'No customers found',
                              style: TextStyle(color: theme.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: theme.border),
                      itemBuilder: (context, index) {
                        final customer = filtered[index];
                        final isSelected = widget.selectedCustomerId == customer.id;

                        return InkWell(
                          onTap: () => Navigator.pop(context, customer),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? theme.accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isSelected
                                      ? theme.primary
                                      : theme.primary.withValues(alpha: 0.12),
                                  foregroundColor: isSelected ? Colors.white : theme.primary,
                                  child: Text(
                                    customer.name.isNotEmpty
                                        ? customer.name[0].toUpperCase()
                                        : 'C',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.name,
                                        style: AppTypography.cardTitle.copyWith(
                                          color: theme.text,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        [
                                          customer.phone,
                                          if (customer.city != null && customer.city!.isNotEmpty)
                                            customer.city
                                        ].join(' • '),
                                        style: AppTypography.labelMuted.copyWith(
                                          color: theme.textMuted,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (customer.currentOutstanding > 0) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Due: ${AppFormatters.currency(customer.currentOutstanding)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'No Due',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ),
                                    ],
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
