import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../features/seller_loads/create_seller_load_dialog.dart';

class MandiQuickActionSheet extends StatelessWidget {
  const MandiQuickActionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MandiQuickActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.bolt_rounded, color: AppColors.primaryGreen, size: 22),
                SizedBox(width: 8),
                Text(
                  'Quick Mandi Entry',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'Sell Bill',
                    subtitle: 'Farmer Inward Entry',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF16A34A),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/goods-entries/new');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'Buy Bill',
                    subtitle: 'Wholesale Invoice',
                    icon: Icons.point_of_sale_rounded,
                    color: const Color(0xFF2563EB),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/bills/new');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'Seller Load',
                    subtitle: 'Truck Arrival & Lot',
                    icon: Icons.local_shipping_rounded,
                    color: const Color(0xFFD97706),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => const CreateSellerLoadDialog(),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'Advance / Receipt',
                    subtitle: 'Record Payment',
                    icon: Icons.savings_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/payments/new');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'Stock / Inventory',
                    subtitle: 'Warehouse Bags Balance',
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFF0F8B8D),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/inventory');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'Add Partner',
                    subtitle: 'New Buyer or Farmer',
                    icon: Icons.person_add_alt_1_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/customers/new');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
