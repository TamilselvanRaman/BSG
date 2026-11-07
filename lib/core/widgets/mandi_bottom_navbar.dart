import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/language_provider.dart';

class MandiBottomNavBar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const MandiBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E6B24), Color(0xFF2E7D32)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildNavItem(
                index: 0,
                label: ref.tr('smartboard'),
                icon: Icons.grid_view_rounded,
              ),
              _buildNavItem(
                index: 1,
                label: ref.tr('smartChart'),
                icon: Icons.description_outlined,
              ),
              _buildNavItem(
                index: 2,
                label: ref.tr('sellBillBook'),
                icon: Icons.menu_book_rounded,
              ),
              _buildNavItem(
                index: 3,
                label: ref.tr('buyBillBook'),
                icon: Icons.scale_rounded,
              ),
              _buildNavItem(
                index: 4,
                label: ref.tr('more'),
                customIcon: _buildMoreIcon(selectedIndex == 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreIcon(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : const Color(0xFFC8E6C9),
          width: 1.8,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.more_horiz_rounded,
          size: 16,
          color: isSelected ? Colors.white : const Color(0xFFC8E6C9),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    IconData? icon,
    Widget? customIcon,
  }) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        splashColor: Colors.white.withValues(alpha: 0.15),
        highlightColor: Colors.white.withValues(alpha: 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            customIcon ??
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? Colors.white : const Color(0xFFC8E6C9),
                ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFFC8E6C9),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 3),
            // Yellow / Gold horizontal active indicator bar matching Image 1
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: 3,
              width: isSelected ? 34 : 0,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFEB3B) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFEB3B).withValues(alpha: 0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
