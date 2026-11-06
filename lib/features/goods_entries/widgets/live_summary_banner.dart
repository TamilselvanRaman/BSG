import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/formatters/currency_formatter.dart';

class LiveSummaryBanner extends StatelessWidget {
  final int totalBags;
  final double totalWeight;
  final double totalAmount;
  final double initialPayment;
  final double netDue;

  const LiveSummaryBanner({
    super.key,
    required this.totalBags,
    required this.totalWeight,
    required this.totalAmount,
    required this.initialPayment,
    required this.netDue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // High-contrast Corporate Slate Navy
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Top Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981), // Emerald green pulse
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'LIVE FINANCIAL SUMMARY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'REAL-TIME AUDIT',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Primary Stats Row
          Row(
            children: [
              // Bags
              Expanded(
                child: _buildMetricTile(
                  label: 'TOTAL BAGS',
                  value: '$totalBags Bags',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.white,
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFF334155)),
              // Weight
              Expanded(
                child: _buildMetricTile(
                  label: 'TOTAL WEIGHT',
                  value: '${totalWeight.toStringAsFixed(0)} kg',
                  icon: Icons.scale_outlined,
                  color: Colors.white,
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFF334155)),
              // Est Gross
              Expanded(
                child: _buildMetricTile(
                  label: 'EST. GROSS',
                  value: CurrencyFormatter.format(totalAmount),
                  icon: Icons.payments_outlined,
                  color: const Color(0xFFFBBF24), // Gold
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFF334155)),

          // Bottom Settlement Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_downward, color: Color(0xFF34D399), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Advance Deducted: ${CurrencyFormatter.format(initialPayment)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1)),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Net Due: ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                  ),
                  Text(
                    CurrencyFormatter.format(netDue > 0 ? netDue : 0),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF34D399), // Emerald
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
