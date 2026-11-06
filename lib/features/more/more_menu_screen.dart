import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/responsive/responsive_container.dart';
import '../../data/app_state.dart';
import '../../data/models/customer.dart';
import '../seller_loads/create_seller_load_dialog.dart';
import '../goods_entries/widgets/add_commodity_dialog.dart';

class MoreMenuScreen extends ConsumerWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);
    final sellerLoads = ref.watch(sellerLoadsProvider);
    final payments = ref.watch(paymentsProvider);

    final buyersCount = customers.where((c) => c.customerType != CustomerType.seller).length;
    final sellersCount = customers.where((c) => c.customerType == CustomerType.seller).length + sellerLoads.length;
    final advancesCount = payments.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.more_horiz_rounded, color: AppColors.primaryGreen, size: 24),
            SizedBox(width: 8),
            Text(
              'More',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'App Settings',
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 1000,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Header Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BSG Agro Goods Mandi',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Thennampalayam Vegetable Market, Tiruppur',
                            style: TextStyle(color: Color(0xFFC8E6C9), fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Section Label
              const Text(
                'MANDI REGISTERS & MODULES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // The 6 Grid Tiles matching Image 2 exactly!
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 550;
                  final crossAxisCount = isWide ? 3 : 2;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: isWide ? 1.25 : 1.05,
                    children: [
                      // 1. Seller Ledger
                      _buildMenuCard(
                        title: 'Seller Ledger',
                        subtitle: '$sellersCount Farmer Accounts',
                        icon: Icons.receipt_long_rounded,
                        onTap: () => context.push('/seller-loads'),
                      ),

                      // 2. Buyer Ledger
                      _buildMenuCard(
                        title: 'Buyer Ledger',
                        subtitle: '$buyersCount Wholesale Buyers',
                        icon: Icons.table_chart_rounded,
                        onTap: () => context.push('/customers'),
                      ),

                      // 3. Reports
                      _buildMenuCard(
                        title: 'Reports',
                        subtitle: 'Sales, Volume & Audit',
                        icon: Icons.assessment_rounded,
                        onTap: () => context.push('/reports'),
                      ),

                      // 4. Advances
                      _buildMenuCard(
                        title: 'Advances',
                        subtitle: '$advancesCount Payment Records',
                        icon: Icons.savings_rounded,
                        onTap: () => context.push('/advances'),
                      ),

                      // 5. Transport (Transporto)
                      _buildMenuCard(
                        title: 'Transporto',
                        subtitle: '${sellerLoads.length} Trucks Inward',
                        icon: Icons.local_shipping_rounded,
                        onTap: () => context.push('/transporto'),
                      ),

                      // 6. Partners
                      _buildMenuCard(
                        title: 'Partners',
                        subtitle: '${customers.length} Contacts',
                        icon: Icons.people_alt_rounded,
                        onTap: () => context.push('/partners'),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Secondary Quick Mandi Tools
              const Text(
                'QUICK MASTER & UTILITIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.add_circle_outline_rounded,
                      iconColor: AppColors.primaryGreen,
                      title: 'Add Inward Seller Load',
                      subtitle: 'Record truck load, arrival bags, vehicle & advance',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const CreateSellerLoadDialog(),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildListTile(
                      icon: Icons.eco_outlined,
                      iconColor: const Color(0xFF059669),
                      title: 'Commodity Master & Rates',
                      subtitle: 'Add new vegetable / fruit goods and daily mandi price',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddCommodityDialog(
                            onAdded: (c) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${c.name} to commodity catalog.'),
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildListTile(
                      icon: Icons.receipt_outlined,
                      iconColor: const Color(0xFF0284C7),
                      title: 'Daily Financial Summary',
                      subtitle: 'Reconcile day sales, cash in drawer & initial advances',
                      onTap: () => context.push('/reports/daily-summary'),
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildListTile(
                      icon: Icons.tune_rounded,
                      iconColor: const Color(0xFF64748B),
                      title: 'Settings & Mandi Configuration',
                      subtitle: 'Shop details, invoice format, backup & data reset',
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // App Version & License
              const Center(
                child: Column(
                  children: [
                    Text(
                      'BSG Agro Mandi ERP • v2.4.0 (Enterprise)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Designed for High-Speed Mandi Unloading & Billing',
                      style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.lightGreenSurface,
        highlightColor: AppColors.lightGreenSurface.withValues(alpha: 0.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Green Icon Container matching Image 2
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 26,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title matching photo
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 3),
              // Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)),
    );
  }
}
