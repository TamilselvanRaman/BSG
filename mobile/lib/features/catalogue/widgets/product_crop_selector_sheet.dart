import '../../../core/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/app_repository.dart';
import 'product_image_view.dart';

class ProductCropSelectorSheet extends ConsumerStatefulWidget {
  final List<String> initialSelectedProductIds;
  final bool allowMultiple;

  const ProductCropSelectorSheet({
    super.key,
    this.initialSelectedProductIds = const [],
    this.allowMultiple = true,
  });

  /// Helper to present bottom sheet
  static Future<List<Product>?> show(
    BuildContext context, {
    List<String> initialSelectedProductIds = const [],
    bool allowMultiple = true,
  }) {
    return showModalBottomSheet<List<Product>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.90,
        child: ProductCropSelectorSheet(
          initialSelectedProductIds: initialSelectedProductIds,
          allowMultiple: allowMultiple,
        ),
      ),
    );
  }

  @override
  ConsumerState<ProductCropSelectorSheet> createState() => _ProductCropSelectorSheetState();
}

class _ProductCropSelectorSheetState extends ConsumerState<ProductCropSelectorSheet> {
  AppThemeColors get theme => context.appTheme;

  ProductCategory _selectedCategory = ProductCategory.fruit;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedProductIds = {};

  @override
  void initState() {
    super.initState();
    _selectedProductIds.addAll(widget.initialSelectedProductIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleProductSelection(Product product) {
    setState(() {
      if (_selectedProductIds.contains(product.id)) {
        _selectedProductIds.remove(product.id);
      } else {
        if (!widget.allowMultiple) {
          _selectedProductIds.clear();
        }
        _selectedProductIds.add(product.id);
      }
    });
  }

  void _onContinue() {
    final allProducts = ref.read(productsProvider);
    final selected = allProducts
        .where((p) => _selectedProductIds.contains(p.id))
        .toList();
    Navigator.of(context).pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(productsProvider).where((p) => p.isActive).toList();

    // Filter products by selected category and search query
    final filtered = allProducts.where((p) {
      if (_searchQuery.isEmpty) {
        if (p.category != _selectedCategory) return false;
      } else {
        final query = _searchQuery.toLowerCase();
        final matchName = p.name.toLowerCase().contains(query);
        final matchCat = p.category.displayName.toLowerCase().contains(query);
        if (!matchName && !matchCat) return false;
      }
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Top Header: "Select Crop" & Pink/Red Circular Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Crop',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: theme.text,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFEBEE), // Soft pink/red background as in reference
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFFEF5350), // Vivid red X
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Category Navigation Tabs: Fruit, Veg, Flower, Spices, Crop
            _buildCategoryTabs(),

            const SizedBox(height: 16),

            // Search Bar: Full-width rounded box with green search icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.border,
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: TextStyle(fontSize: 14, color: theme.text),
                  decoration: InputDecoration(
                    hintText: 'Search in ${_selectedCategory.displayName}...',
                    hintStyle: TextStyle(fontSize: 13, color: theme.textMuted),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 24,
                      color: theme.primary, // Green magnifying glass
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Product Grid (3 Columns)
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.74,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        final isSelected = _selectedProductIds.contains(product.id);

                        return _buildProductItem(product, isSelected);
                      },
                    ),
            ),

            // Fixed Full-Width "CONTINUE" Button Bar
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  /// Minimal clean text category tabs with green underline indicator (matching references 3, 4, 5)
  Widget _buildCategoryTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ProductCategory.values.map((cat) {
          final isSelected = cat == _selectedCategory;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = cat;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cat.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF159B3D) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 3.5,
                  width: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF159B3D) : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Individual 3-column product item with circular ring outline and radio selection indicator
  Widget _buildProductItem(Product product, bool isSelected) {
    return InkWell(
      onTap: () => _toggleProductSelection(product),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Circular Ring Container
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF159B3D) : const Color(0xFFD6E4F0),
                    width: isSelected ? 2.0 : 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ProductImageView(
                      assetPath: product.assetPath,
                      imageUrl: product.imageUrl,
                      size: 68,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Only display checkmark badge when product is selected
              if (isSelected)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primary,
                      border: Border.all(
                        color: theme.surface,
                        width: 2.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x28000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Product Name
          Expanded(
            child: Text(
              product.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: theme.text,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Full-width vibrant green "CONTINUE" button bar (matching references 3, 4, 5)
  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            'CONTINUE',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              'No crops found matching "$_searchQuery"',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
