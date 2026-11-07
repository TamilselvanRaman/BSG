import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';

class MandiBranch {
  final String id;
  final String name;
  final String location;
  final String code;
  final bool isMain;

  const MandiBranch({
    required this.id,
    required this.name,
    required this.location,
    required this.code,
    this.isMain = false,
  });
}

final mandiBranches = [
  const MandiBranch(
    id: 'br-tup',
    name: 'BSG Agro Goods Mandi - Thennampalayam',
    location: 'Thennampalayam Vegetable Market, Tiruppur',
    code: 'YARD-01',
    isMain: true,
  ),
  const MandiBranch(
    id: 'br-slm',
    name: 'BSG Agro Yard - Salem Central',
    location: 'Leigh Bazaar Mandi Complex, Salem',
    code: 'YARD-02',
  ),
  const MandiBranch(
    id: 'br-cbe',
    name: 'BSG Commission Mundy - Coimbatore',
    location: 'MGR Wholesale Market, Coimbatore',
    code: 'YARD-03',
  ),
];

class SelectedBranchNotifier extends Notifier<MandiBranch> {
  @override
  MandiBranch build() => mandiBranches.first;

  void selectBranch(MandiBranch branch) {
    state = branch;
  }
}

final selectedBranchProvider = NotifierProvider<SelectedBranchNotifier, MandiBranch>(SelectedBranchNotifier.new);

class BusinessBranchDialog extends ConsumerWidget {
  const BusinessBranchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const BusinessBranchDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBranch = ref.watch(selectedBranchProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreenSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: AppColors.primaryGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mandi Branches & Yards',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Select active market yard for trading records',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...mandiBranches.map((branch) {
                final isSelected = branch.id == selectedBranch.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lightGreenSurface : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        branch.code,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    title: Text(
                      branch.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 14,
                        color: isSelected ? AppColors.primaryGreenDark : const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      branch.location,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 22)
                        : null,
                    onTap: () {
                      ref.read(selectedBranchProvider.notifier).selectBranch(branch);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Switched to ${branch.name}'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
