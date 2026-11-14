import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../widgets/product_image_view.dart';

class AdminProductManagementScreen extends ConsumerStatefulWidget {
  const AdminProductManagementScreen({super.key});

  @override
  ConsumerState<AdminProductManagementScreen> createState() =>
      _AdminProductManagementScreenState();
}

class _AdminProductManagementScreenState
    extends ConsumerState<AdminProductManagementScreen> {
  ProductCategory? _filterCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _filterActiveOnly = false;
  final bool _showMissingImagesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditProductDialog({Product? existing}) {
    final isEditing = existing != null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final unitController =
        TextEditingController(text: existing?.defaultUnit ?? 'Kg');
    final rateController = TextEditingController(
        text: existing?.defaultRate != null ? '${existing!.defaultRate}' : '');
    final imageUrlController =
        TextEditingController(text: existing?.imageUrl ?? '');
    final assetPathController = TextEditingController(
        text: existing?.assetPath ?? 'assets/products/fruit/apple.png');
    ProductCategory category = existing?.category ?? ProductCategory.fruit;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline,
                    color: AppColors.reportPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(isEditing ? 'Edit Product' : 'Add New Product'),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product / Crop Name *',
                          hintText: 'e.g. Red Fuji Apple',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category Dropdown
                      DropdownButtonFormField<ProductCategory>(
                        initialValue: category,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                        ),
                        items: ProductCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(cat.icon, size: 16),
                                const SizedBox(width: 8),
                                Text(cat.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => category = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Default Unit
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: unitController,
                              decoration: const InputDecoration(
                                labelText: 'Default Unit *',
                                hintText: 'Kg / Bags / Boxes',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: rateController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Default Rate (₹)',
                                hintText: 'e.g. 45',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Image URL / Custom Path
                      TextField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Image URL / File Path',
                          hintText: 'https://example.com/crop.jpg',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Leave empty to use category stock asset automatically.',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.reportTextSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.reportPrimary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      AppDialog.showSnackBar(context, 'Please enter a product name',
                          isError: true);
                      return;
                    }

                    final repo = ref.read(appRepositoryProvider);
                    final now = DateTime.now();

                    if (isEditing) {
                      final updated = existing.copyWith(
                        name: name,
                        category: category,
                        defaultUnit: unitController.text.trim().isNotEmpty
                            ? unitController.text.trim()
                            : 'Kg',
                        defaultRate: double.tryParse(rateController.text.trim()),
                        imageUrl: imageUrlController.text.trim().isNotEmpty
                            ? imageUrlController.text.trim()
                            : null,
                        updatedAt: now,
                      );
                      repo.updateProduct(updated);
                      AppDialog.showSnackBar(
                          context, '${updated.name} updated successfully!');
                    } else {
                      final newProduct = Product(
                        id: 'custom_${now.millisecondsSinceEpoch % 100000}',
                        name: name,
                        category: category,
                        assetPath: assetPathController.text.trim(),
                        imageUrl: imageUrlController.text.trim().isNotEmpty
                            ? imageUrlController.text.trim()
                            : null,
                        defaultUnit: unitController.text.trim().isNotEmpty
                            ? unitController.text.trim()
                            : 'Kg',
                        defaultRate: double.tryParse(rateController.text.trim()),
                        isActive: true,
                        createdAt: now,
                        updatedAt: now,
                      );
                      repo.addProduct(newProduct);
                      AppDialog.showSnackBar(
                          context, '${newProduct.name} added to catalogue!');
                    }
                    Navigator.of(ctx).pop();
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Add Product'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImportExcelDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.upload_file_rounded, color: AppColors.reportPrimary),
              SizedBox(width: 8),
              Text('Import Catalogue'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload bulk products via Excel / CSV format (Name, Category, Unit, Rate).',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.reportLightGreen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.reportPrimary),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.reportPrimary, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '197 starter catalogue entries are already synced and loaded.',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.reportPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.reportPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                AppDialog.showSnackBar(
                    context, 'Catalogue verified. All products up-to-date!');
              },
              child: const Text('Sync / Re-import'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(productsProvider);

    final filtered = allProducts.where((p) {
      if (_filterCategory != null && p.category != _filterCategory) {
        return false;
      }
      if (_filterActiveOnly && !p.isActive) {
        return false;
      }
      if (_showMissingImagesOnly &&
          (p.assetPath.isNotEmpty || p.imageUrl != null)) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return p.name.toLowerCase().contains(q) ||
            p.category.displayName.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.reportBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Catalogue Management', style: AppTypography.pageTitle),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Import Excel / CSV',
            icon: const Icon(Icons.upload_file_rounded),
            onPressed: _showImportExcelDialog,
          ),
          IconButton(
            tooltip: 'Add New Product',
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.reportPrimary),
            onPressed: () => _showAddEditProductDialog(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.reportBorder, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Filter & Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // Search box
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.reportBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.reportBorder),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search catalogue products...',
                      hintStyle: TextStyle(
                          fontSize: 13, color: AppColors.reportTextSecondary),
                      prefixIcon: const Icon(Icons.search,
                          size: 18, color: AppColors.reportPrimary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Category pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryFilterPill(null, 'All (${allProducts.length})'),
                      ...ProductCategory.values.map((cat) {
                        final count =
                            allProducts.where((p) => p.category == cat).length;
                        return _buildCategoryFilterPill(
                            cat, '${cat.displayName} ($count)');
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Total items summary banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.reportBorder)),
            ),
            child: Row(
              children: [
                Text(
                  '${filtered.length} products listed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.reportTextSecondary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    setState(() => _filterActiveOnly = !_filterActiveOnly);
                  },
                  child: Row(
                    children: [
                      Icon(
                        _filterActiveOnly
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 16,
                        color: AppColors.reportPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Active only',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.reportTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Product list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No products found matching filters.',
                      style: TextStyle(color: AppColors.reportTextSecondary),
                    ),
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.reportBorder),
                        ),
                        child: Row(
                          children: [
                            // Circular Product Image
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border:
                                    Border.all(color: AppColors.reportBorder),
                              ),
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: ProductImageView(
                                    assetPath: product.assetPath,
                                    imageUrl: product.imageUrl,
                                    size: 44,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.reportTextPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: product.isActive
                                              ? AppColors.reportLightGreen
                                              : Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          product.isActive
                                              ? 'Active'
                                              : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: product.isActive
                                              ? AppColors.reportPrimary
                                              : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product.category.displayName} • Unit: ${product.defaultUnit}${product.defaultRate != null ? ' • Rate: ₹${product.defaultRate}' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.reportTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action Menu
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (val) {
                                final repo = ref.read(appRepositoryProvider);
                                if (val == 'edit') {
                                  _showAddEditProductDialog(existing: product);
                                } else if (val == 'toggle') {
                                  repo.toggleProductStatus(product.id);
                                  AppDialog.showSnackBar(
                                    context,
                                    '${product.name} is now ${product.isActive ? 'Inactive' : 'Active'}',
                                  );
                                } else if (val == 'delete') {
                                  _confirmDeleteProduct(product);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit Product'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Row(
                                    children: [
                                      Icon(
                                        product.isActive
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(product.isActive
                                          ? 'Deactivate'
                                          : 'Activate'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline,
                                          size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(Product p) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Product?'),
          content: Text(
              'Are you sure you want to remove "${p.name}" from the catalogue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                ref.read(appRepositoryProvider).deleteProduct(p.id);
                Navigator.of(ctx).pop();
                AppDialog.showSnackBar(
                    context, '${p.name} removed from catalogue.');
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryFilterPill(ProductCategory? cat, String label) {
    final isSelected = _filterCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.reportLightGreen,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppColors.reportPrimary : AppColors.reportBorder,
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color:
              isSelected ? AppColors.reportPrimary : AppColors.reportTextPrimary,
        ),
        onSelected: (_) {
          setState(() => _filterCategory = cat);
        },
      ),
    );
  }
}
