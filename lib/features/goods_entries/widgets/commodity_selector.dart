import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/app_state.dart';
import '../../../data/models/commodity.dart';
import 'add_commodity_dialog.dart';

class CommoditySelector extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onNext;
  final ValueChanged<Commodity>? onCommodityChanged;
  final String? Function(String?)? validator;

  const CommoditySelector({
    super.key,
    required this.controller,
    this.focusNode,
    this.onNext,
    this.onCommodityChanged,
    this.validator,
  });

  @override
  ConsumerState<CommoditySelector> createState() => _CommoditySelectorState();
}

class _CommoditySelectorState extends ConsumerState<CommoditySelector> {
  String? _selectedCommodityId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncSelectionFromText);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSelectionFromText();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncSelectionFromText);
    _scrollController.dispose();
    super.dispose();
  }

  void _syncSelectionFromText() {
    final text = widget.controller.text.trim().toLowerCase();
    final commodities = ref.read(commoditiesProvider);
    if (text.isEmpty) {
      if (_selectedCommodityId != null) {
        setState(() => _selectedCommodityId = null);
      }
      return;
    }

    final match = commodities.where((c) => c.name.toLowerCase() == text).firstOrNull;
    if (match != null && match.id != _selectedCommodityId) {
      setState(() => _selectedCommodityId = match.id);
    } else if (match == null && _selectedCommodityId != null) {
      // Partial check
      final partial = commodities.where((c) => text.contains(c.name.toLowerCase()) || c.name.toLowerCase().contains(text)).firstOrNull;
      if (partial != null && partial.id != _selectedCommodityId) {
        setState(() => _selectedCommodityId = partial.id);
      }
    }
  }

  void _chooseCommodity(Commodity commodity, {bool triggerNext = true}) {
    setState(() {
      _selectedCommodityId = commodity.id;
    });

    widget.controller.text = commodity.name;
    widget.onCommodityChanged?.call(commodity);

    // Show instant confirmation toast
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(commodity.iconEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Selected "${commodity.name}" • Next: Vehicle / Products',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      ),
    );

    // "click to choose it then move next"
    if (triggerNext) {
      widget.onNext?.call();
    }
  }

  void _openAddCommodityDialog() {
    AddCommodityDialog.show(
      context,
      ref,
      initialName: widget.controller.text.trim().isNotEmpty ? widget.controller.text.trim() : null,
      onAdded: (newCommodity) {
        _chooseCommodity(newCommodity, triggerNext: true);
        // Animate scroll to front
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  void _openViewAllSheet(List<Commodity> commodities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AllCommoditiesSheet(
        commodities: commodities,
        selectedId: _selectedCommodityId,
        onSelected: (c) {
          Navigator.of(ctx).pop();
          _chooseCommodity(c, triggerNext: true);
        },
        onAddNew: () {
          Navigator.of(ctx).pop();
          _openAddCommodityDialog();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commodities = ref.watch(commoditiesProvider);
    final activeCommodity = commodities.where((c) => c.id == _selectedCommodityId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label & Quick Actions Bar
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 6,
          spacing: 6,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.primaryGreen),
                SizedBox(width: 6),
                Text(
                  'Commodity / Goods Name *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick + Add Button
                InkWell(
                  onTap: _openAddCommodityDialog,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreenSurface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline, size: 13, color: AppColors.primaryGreen),
                        SizedBox(width: 4),
                        Text(
                          '+ Add Goods',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // View All button
                InkWell(
                  onTap: () => _openViewAllSheet(commodities),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.grid_view_outlined, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'View All (${commodities.length})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Visual Goods Images Carousel
        SizedBox(
          height: 122,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: commodities.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              // First item: "+ Add New Goods" Card
              if (index == 0) {
                return _buildAddNewCard();
              }

              final commodity = commodities[index - 1];
              final isSelected = commodity.id == _selectedCommodityId ||
                  widget.controller.text.trim().toLowerCase() == commodity.name.toLowerCase();

              return _buildCommodityCard(commodity, isSelected);
            },
          ),
        ),
        const SizedBox(height: 10),

        // Synchronized Text Field with custom refinement & search
        CustomTextField(
          label: 'Selected Goods Name (Tap to Edit or Type Custom)',
          hint: 'e.g. Country Tomatoes, Hill Potatoes',
          controller: widget.controller,
          focusNode: widget.focusNode,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => widget.onNext?.call(),
          validator: widget.validator ?? (val) => val == null || val.trim().isEmpty ? 'Required' : null,
          prefixWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: activeCommodity != null
                        ? Color(activeCommodity.colorValue).withValues(alpha: 0.15)
                        : AppColors.lightGreenSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      activeCommodity?.iconEmoji ?? '📦',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          suffix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (activeCommodity == null && widget.controller.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: _openAddCommodityDialog,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreenSurface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_add_outlined, size: 14, color: AppColors.primaryGreen),
                          SizedBox(width: 4),
                          Text(
                            'Save to Goods',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.primaryGreen),
                tooltip: 'Move to Next Field',
                onPressed: () => widget.onNext?.call(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddNewCard() {
    return InkWell(
      onTap: _openAddCommodityDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 86,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.5),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.lightGreenSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: const Center(
                child: Icon(Icons.add_rounded, color: AppColors.primaryGreen, size: 24),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add New',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Goods Item',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommodityCard(Commodity commodity, bool isSelected) {
    return InkWell(
      onTap: () => _chooseCommodity(commodity, triggerNext: true),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 90,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightGreenSurface : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.border,
            width: isSelected ? 2.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryGreen.withValues(alpha: 0.2)
                  : const Color(0x08000000),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Image Container with Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Color(commodity.colorValue).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: commodity.imageUrl != null
                      ? Image.network(
                          commodity.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildFallbackEmoji(commodity),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: Text(commodity.iconEmoji, style: const TextStyle(fontSize: 24)),
                            );
                          },
                        )
                      : _buildFallbackEmoji(commodity),
                ),

                // Selected Checkmark Badge
                if (isSelected)
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 3),
                        ],
                      ),
                      child: const Icon(Icons.check, size: 10, color: Colors.white),
                    ),
                  ),

                // Emoji overlay badge when showing photo
                if (commodity.imageUrl != null)
                  Positioned(
                    bottom: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(commodity.iconEmoji, style: const TextStyle(fontSize: 10)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),

            // Produce Name
            Expanded(
              child: Text(
                commodity.name,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.primaryGreenDark : AppColors.textPrimary,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Price / Unit indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withValues(alpha: 0.15)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '₹${commodity.defaultSellRate.toStringAsFixed(0)}/${commodity.defaultUnit == 'Bags' ? 'bag' : 'kg'}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primaryGreenDark : AppColors.textSecondary,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackEmoji(Commodity commodity) {
    return Center(
      child: Text(
        commodity.iconEmoji,
        style: const TextStyle(fontSize: 26),
      ),
    );
  }
}

class _AllCommoditiesSheet extends StatefulWidget {
  final List<Commodity> commodities;
  final String? selectedId;
  final ValueChanged<Commodity> onSelected;
  final VoidCallback onAddNew;

  const _AllCommoditiesSheet({
    required this.commodities,
    required this.selectedId,
    required this.onSelected,
    required this.onAddNew,
  });

  @override
  State<_AllCommoditiesSheet> createState() => _AllCommoditiesSheetState();
}

class _AllCommoditiesSheetState extends State<_AllCommoditiesSheet> {
  String _search = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...widget.commodities.map((c) => c.category).toSet()];
    final filtered = widget.commodities.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(_search.toLowerCase()) ||
          c.category.toLowerCase().contains(_search.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || c.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreenSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.grid_view, color: AppColors.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('Goods & Commodity Catalog', style: AppTypography.titleMedium),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),

            // Search & Add Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _search = val),
                      decoration: InputDecoration(
                        hintText: 'Search produce by name...',
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    onPressed: widget.onAddNew,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Category Filter Chips
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories.elementAt(index);
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                    selected: isSelected,
                    selectedColor: AppColors.lightGreenSurface,
                    labelStyle: TextStyle(color: isSelected ? AppColors.primaryGreenDark : AppColors.textSecondary),
                    side: BorderSide(color: isSelected ? AppColors.primaryGreen : AppColors.border),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Produce Grid
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          Text('No goods matching "$_search"', style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: Text('Add "$_search" to Goods Catalog'),
                            onPressed: widget.onAddNew,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final c = filtered[index];
                        final isSel = c.id == widget.selectedId;
                        return InkWell(
                          onTap: () => widget.onSelected(c),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.lightGreenSurface : AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppColors.primaryGreen : AppColors.border,
                                width: isSel ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Color(c.colorValue).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: c.imageUrl != null
                                          ? Image.network(
                                              c.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => Center(child: Text(c.iconEmoji, style: const TextStyle(fontSize: 26))),
                                            )
                                          : Center(child: Text(c.iconEmoji, style: const TextStyle(fontSize: 26))),
                                    ),
                                    if (isSel)
                                      const Positioned(
                                        top: 2,
                                        right: 2,
                                        child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: AppColors.primaryGreen,
                                          child: Icon(Icons.check, size: 10, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  c.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                    color: isSel ? AppColors.primaryGreenDark : AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${c.defaultSellRate.toStringAsFixed(0)} / ${c.defaultUnit}',
                                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
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
