import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../catalogue/widgets/product_image_view.dart';

class ProductSelectionStep extends ConsumerStatefulWidget {
  final Product? selectedProduct;
  final ValueChanged<Product> onProductSelected;
  final VoidCallback? onAddCustomProduct;
  final bool isEmbedded;

  const ProductSelectionStep({
    super.key,
    required this.selectedProduct,
    required this.onProductSelected,
    this.onAddCustomProduct,
    this.isEmbedded = false,
  });

  @override
  ConsumerState<ProductSelectionStep> createState() => _ProductSelectionStepState();
}

class _ProductSelectionStepState extends ConsumerState<ProductSelectionStep> {
  final TextEditingController _searchController = TextEditingController();
  ProductCategory? _selectedCategory; // null = all
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final allProducts = ref.watch(appRepositoryProvider).products;

    // Filter products by category and search
    final filtered = allProducts.where((p) {
      if (_selectedCategory != null && p.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = p.name.toLowerCase().contains(query);
        final matchesCategory = p.categoryName.toLowerCase().contains(query);
        return matchesName || matchesCategory;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Top Search & Category Filter Section
        Container(
          color: theme.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Produce Crop',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.text,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showAddCustomCropDialog(context, theme),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 14, color: theme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Add New Crop',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search, size: 20, color: theme.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.text,
                        ),
                        decoration: InputDecoration(
                          hintText: _selectedCategory != null
                              ? 'Search in ${_selectedCategory!.displayName}...'
                              : 'Search agricultural crops...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: theme.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        color: theme.textMuted,
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryPill(
                      label: 'All',
                      count: allProducts.length,
                      isSelected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                      theme: theme,
                    ),
                    ...ProductCategory.values.map((cat) {
                      final count = allProducts.where((p) => p.category == cat).length;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: _buildCategoryPill(
                          label: cat.displayName,
                          count: count,
                          isSelected: _selectedCategory == cat,
                          onTap: () => setState(() => _selectedCategory = cat),
                          theme: theme,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Selected Product Notification Banner (if any)
        if (widget.selectedProduct != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(color: theme.primary.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: theme.primary, width: 1.5),
                  ),
                  child: ClipOval(
                    child: ProductImageView(
                      assetPath: widget.selectedProduct!.assetPath,
                      imageUrl: widget.selectedProduct!.imageUrl,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected: ${widget.selectedProduct!.name}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${widget.selectedProduct!.categoryName} • Unit: ${widget.selectedProduct!.defaultUnit}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Ready',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Products Grid
        if (widget.isEmbedded)
          filtered.isEmpty
              ? _buildEmptyState(theme)
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    final isSelected = widget.selectedProduct?.id == product.id;
                    return _buildProductCard(product, isSelected, theme);
                  },
                )
        else
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(theme)
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final isSelected = widget.selectedProduct?.id == product.id;
                      return _buildProductCard(product, isSelected, theme);
                    },
                  ),
          ),

        // Add Custom Crop Footer Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border(top: BorderSide(color: theme.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filtered.length} products available',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.textSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddCustomCropDialog(context, theme),
                icon: Icon(Icons.add_circle_outline, size: 16, color: theme.primary),
                label: Text(
                  'Add Custom Crop',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPill({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeColors theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : theme.accent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primary : theme.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : theme.text,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : theme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : theme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isSelected, AppThemeColors theme) {
    return GestureDetector(
      onTap: () {
        widget.onProductSelected(product);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.primary : theme.border.withValues(alpha: 0.8),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular image container with clean white background
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: isSelected ? theme.primary : const Color(0xFFE5E7EB),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: ClipOval(
                        child: ProductImageView(
                          assetPath: product.assetPath,
                          imageUrl: product.imageUrl,
                          size: 56,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Product Name
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: theme.text,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),

            // ONLY display checkmark badge when product is selected
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppThemeColors theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 54, color: theme.textMuted),
            const SizedBox(height: 12),
            Text(
              'No crops found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try searching with another name or add a custom crop',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddCustomCropDialog(context, theme),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Custom Crop'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomCropDialog(BuildContext context, AppThemeColors theme) {
    final nameCtrl = TextEditingController(text: _searchQuery);
    ProductCategory chosenCat = _selectedCategory ?? ProductCategory.fruit;
    String chosenUnit = 'Kg';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Custom Agricultural Crop',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.text,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: theme.textSecondary,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    style: TextStyle(color: theme.text),
                    decoration: InputDecoration(
                      labelText: 'Crop / Product Name *',
                      labelStyle: TextStyle(color: theme.textSecondary),
                      hintText: 'e.g. Kashmiri Garlic, Alphonso Grade A',
                      hintStyle: TextStyle(color: theme.textMuted),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ProductCategory>(
                          isExpanded: true,
                          initialValue: chosenCat,
                          dropdownColor: theme.surface,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(color: theme.textSecondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: ProductCategory.values.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat.displayName, style: TextStyle(color: theme.text)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => chosenCat = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: chosenUnit,
                          dropdownColor: theme.surface,
                          decoration: InputDecoration(
                            labelText: 'Default Unit',
                            labelStyle: TextStyle(color: theme.textSecondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: ['Kg', 'Bags', 'Boxes', 'Crates', 'Quintal', 'Ton']
                              .map((u) => DropdownMenuItem(value: u, child: Text(u, style: TextStyle(color: theme.text))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => chosenUnit = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;

                        final customProduct = Product(
                          id: 'prod_custom_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          category: chosenCat,
                          assetPath: 'assets/products/crop_apple.png', // fallback
                          defaultUnit: chosenUnit,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        widget.onProductSelected(customProduct);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add & Select Crop', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

