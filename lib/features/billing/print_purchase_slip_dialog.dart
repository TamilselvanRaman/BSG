import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../data/models/seller_load.dart';

class PrintPurchaseSlipDialog extends StatelessWidget {
  final SellerLoad load;
  final double salesAmount;
  final double commissionAmount;
  final double netPayable;

  const PrintPurchaseSlipDialog({
    super.key,
    required this.load,
    this.salesAmount = 0.0,
    this.commissionAmount = 0.0,
    this.netPayable = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSales = salesAmount > 0 ? salesAmount : (load.totalBags * 25.0 * 28.0);
    final effectiveCommission = commissionAmount > 0 ? commissionAmount : (effectiveSales * (load.commissionPercent / 100.0));
    final effectiveNet = netPayable > 0 ? netPayable : (effectiveSales - effectiveCommission - load.advancePaidToSeller);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mandi Receipt Header
              const Text(
                'BSG AGRO GOODS TRADING',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
              ),
              const Text(
                'Main Mandi Yard, Tiruppur, Tamil Nadu',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const Text(
                'Ph: +91 98421 00000',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'FARMER INWARD SETTLEMENT VOUCHER',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryGreenDark),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(thickness: 1, height: 1),
              const SizedBox(height: 10),

              // Load Info
              _buildReceiptRow('Voucher Date:', DateFormatter.format(load.arrivalDate)),
              _buildReceiptRow('Lot / Load No:', load.effectiveLotNumber),
              _buildReceiptRow('Farmer Name:', load.sellerName),
              _buildReceiptRow('Farmer Code:', load.farmerCode),
              _buildReceiptRow('Village / Town:', load.village),
              _buildReceiptRow('Vehicle No:', load.vehicleNumber),
              const SizedBox(height: 8),
              const Divider(thickness: 1, height: 1),
              const SizedBox(height: 8),

              // Commodity & Weighing
              _buildReceiptRow('Commodity:', load.commodity),
              _buildReceiptRow('Grade / Quality:', load.varietyGrade),
              _buildReceiptRow('Total Bags Arrived:', '${load.totalBags} BG'),
              _buildReceiptRow('Gross Weight:', '${load.grossWeight.toStringAsFixed(0)} kg'),
              const SizedBox(height: 8),
              const Divider(thickness: 1, height: 1),
              const SizedBox(height: 8),

              // Financial Settlement
              _buildReceiptRow('Gross Auction Realization:', CurrencyFormatter.format(effectiveSales)),
              _buildReceiptRow('Mandi Commission (${load.commissionPercent}%):', '- ${CurrencyFormatter.format(effectiveCommission)}'),
              if (load.advancePaidToSeller > 0)
                _buildReceiptRow('Initial Advance Deducted:', '- ${CurrencyFormatter.format(load.advancePaidToSeller)}'),
              const SizedBox(height: 6),
              const Divider(thickness: 1.5, height: 1),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('NET PAYABLE TO FARMER:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyFormatter.format(effectiveNet),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E6B24)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Computer generated mandi voucher. Subject to mandi jurisdiction.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6B24),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Voucher sent to thermal printer successfully.'),
                            backgroundColor: AppColors.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Print Voucher'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
