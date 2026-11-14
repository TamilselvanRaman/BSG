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
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/models/partner_models.dart';
import '../../data/repositories/app_repository.dart';
import 'partner_dialogs.dart';

class UsersLandingScreen extends ConsumerStatefulWidget {
  const UsersLandingScreen({super.key});

  @override
  ConsumerState<UsersLandingScreen> createState() => _UsersLandingScreenState();
}

class _UsersLandingScreenState extends ConsumerState<UsersLandingScreen> with SingleTickerProviderStateMixin {
  AppThemeColors get theme => context.appTheme;

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Users & Directory', style: AppTypography.pageTitle),
        backgroundColor: theme.background,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              icon: Icon(Icons.eco_rounded, size: 18, color: theme.primary),
              label: Text(
                'Crop Catalogue',
                style: TextStyle(
                  color: theme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: theme.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => context.push('/admin/products'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: theme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search suppliers, customers or transporters...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryAction,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  tabs: const [
                    Tab(text: 'Suppliers'),
                    Tab(text: 'Customers'),
                    Tab(text: 'Transporters'),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.border),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSupplierList(),
                _buildCustomerList(),
                _buildTransporterList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(_getAddButtonLabel(), style: const TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => _openAddDialog(context),
      ),
    );
  }

  String _getAddButtonLabel() {
    switch (_tabController.index) {
      case 0:
        return 'Add Supplier';
      case 1:
        return 'Add Customer';
      case 2:
        return 'Add Transporter';
      default:
        return 'Add Partner';
    }
  }

  void _openAddDialog(BuildContext context) {
    if (_tabController.index == 0) {
      showDialog(context: context, builder: (_) => const AddSupplierDialog());
    } else if (_tabController.index == 1) {
      showDialog(context: context, builder: (_) => const AddCustomerDialog());
    } else {
      showDialog(context: context, builder: (_) => const AddTransporterDialog());
    }
  }

  Widget _buildSupplierList() {
    final suppliers = ref.watch(suppliersProvider);
    final filtered = suppliers.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.name.toLowerCase().contains(_searchQuery) ||
          s.phone.contains(_searchQuery) ||
          (s.city?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    if (filtered.isEmpty) {
      return AppEmptyState(
        icon: Icons.people_outline_rounded,
        title: 'No Suppliers Found',
        description: _searchQuery.isEmpty
            ? 'Add your first supplier (farmer/source) to start tracking incoming lots.'
            : 'No suppliers match your search.',
        actionText: _searchQuery.isEmpty ? 'Add Supplier' : null,
        onAction: () => showDialog(context: context, builder: (_) => const AddSupplierDialog()),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final supplier = filtered[index];
        return AppCard(
          onTap: () => _showSupplierDetails(supplier),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.accent,
                child: Text(
                  supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : 'S',
                  style: TextStyle(fontWeight: FontWeight.w700, color: theme.text),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(supplier.name, style: AppTypography.cardTitle),
                    const SizedBox(height: 2),
                    Text(
                      '${supplier.phone}${supplier.city != null ? ' • ${supplier.city}' : ''}',
                      style: AppTypography.bodySecondary,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Payable Balance', style: AppTypography.labelMuted),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.currency(supplier.currentBalance),
                    style: AppTypography.cardTitle,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerList() {
    final customers = ref.watch(customersProvider);
    final filtered = customers.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery) ||
          c.phone.contains(_searchQuery) ||
          (c.city?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    if (filtered.isEmpty) {
      return AppEmptyState(
        icon: Icons.storefront_outlined,
        title: 'No Customers Found',
        description: _searchQuery.isEmpty
            ? 'Add your first customer (buyer/retailer) to issue credit bills and track receivables.'
            : 'No customers match your search.',
        actionText: _searchQuery.isEmpty ? 'Add Customer' : null,
        onAction: () => showDialog(context: context, builder: (_) => const AddCustomerDialog()),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final customer = filtered[index];
        final hasOutstanding = customer.currentOutstanding > 0;
        return AppCard(
          onTap: () => _showCustomerDetails(customer),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.accent,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                  style: TextStyle(fontWeight: FontWeight.w700, color: theme.text),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: AppTypography.cardTitle),
                    const SizedBox(height: 2),
                    Text(
                      '${customer.phone}${customer.city != null ? ' • ${customer.city}' : ''}',
                      style: AppTypography.bodySecondary,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Outstanding Due', style: AppTypography.labelMuted),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.currency(customer.currentOutstanding),
                    style: AppTypography.cardTitle.copyWith(
                      color: hasOutstanding ? AppColors.warning : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransporterList() {
    final transporters = ref.watch(transportersProvider);
    final filtered = transporters.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.name.toLowerCase().contains(_searchQuery) ||
          t.phone.contains(_searchQuery) ||
          (t.vehicleNumber?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    if (filtered.isEmpty) {
      return AppEmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'No Transporters Found',
        description: 'Add logistics partners and vehicle numbers to link with incoming lots.',
        actionText: _searchQuery.isEmpty ? 'Add Transporter' : null,
        onAction: () => showDialog(context: context, builder: (_) => const AddTransporterDialog()),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final transporter = filtered[index];
        return AppCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(Icons.local_shipping_outlined, size: 20, color: theme.text),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transporter.name, style: AppTypography.cardTitle),
                    const SizedBox(height: 2),
                    Text(transporter.phone, style: AppTypography.bodySecondary),
                    if (transporter.notes != null)
                      Text(transporter.notes!, style: AppTypography.labelMuted),
                  ],
                ),
              ),
              if (transporter.vehicleNumber != null)
                AppBadge(
                  label: transporter.vehicleNumber!,
                  variant: BadgeVariant.neutral,
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSupplierDetails(Supplier supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Supplier Details', style: AppTypography.sectionHeading),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Text(supplier.name, style: AppTypography.pageTitle),
            Text('Contact: ${supplier.phone}', style: AppTypography.bodySecondary),
            if (supplier.city != null) Text('Location: ${supplier.city}', style: AppTypography.bodySecondary),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.accent,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payable Balance', style: AppTypography.body),
                  Text(AppFormatters.currency(supplier.currentBalance), style: AppTypography.amount),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'View Ledger',
                    icon: Icons.receipt_long_outlined,
                    variant: ButtonVariant.secondary,
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/users/supplier-ledger/${supplier.id}');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    text: 'Create Lot',
                    icon: Icons.add_box_outlined,
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/lots/create?supplierId=${supplier.id}');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerDetails(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Customer Details', style: AppTypography.sectionHeading),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Text(customer.name, style: AppTypography.pageTitle),
            Text('Contact: ${customer.phone}', style: AppTypography.bodySecondary),
            if (customer.city != null) Text('Location: ${customer.city}', style: AppTypography.bodySecondary),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.accent,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Outstanding Balance', style: AppTypography.body),
                  Text(
                    AppFormatters.currency(customer.currentOutstanding),
                    style: AppTypography.amount.copyWith(
                      color: customer.currentOutstanding > 0 ? AppColors.warning : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'View Customer Ledger',
              icon: Icons.receipt_long_outlined,
              variant: ButtonVariant.secondary,
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/users/customer-ledger/${customer.id}');
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Receive Amount',
                    icon: Icons.arrow_downward_rounded,
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/payments/received-amount?customerId=${customer.id}');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    text: 'Credit Bill',
                    icon: Icons.receipt_outlined,
                    variant: ButtonVariant.outline,
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/bills/create-credit?customerId=${customer.id}');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
