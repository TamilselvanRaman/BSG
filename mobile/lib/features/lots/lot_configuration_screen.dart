import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_dialog.dart';
import '../../data/models/lot_config_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/app_repository.dart';
import '../catalogue/widgets/product_image_view.dart';

class LotConfigurationScreen extends ConsumerStatefulWidget {
  const LotConfigurationScreen({super.key});

  @override
  ConsumerState<LotConfigurationScreen> createState() => _LotConfigurationScreenState();
}

class _LotConfigurationScreenState extends ConsumerState<LotConfigurationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Weight & Numbering Config State
  String _weightMode = 'full'; // 'full' or 'total'
  String _defaultWeightUnit = 'Kg';
  int _decimalPrecision = 2;
  final TextEditingController _lotPrefixCtrl = TextEditingController(text: 'LOT-2026-');
  bool _autoLotNumbering = true;
  bool _requireParty = true;
  bool _requireLorry = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lotPrefixCtrl.dispose();
    super.dispose();
  }

  void _showAddExpenseDialog(BuildContext context, {LotExpenseConfig? existing}) {
    final messenger = ScaffoldMessenger.of(context);
    final theme = context.appTheme;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final tamilCtrl = TextEditingController(text: existing?.tamilName ?? '');
    final amountCtrl = TextEditingController(text: existing?.defaultAmount.toStringAsFixed(0) ?? '0');
    LotExpenseCalcType calcType = existing?.calcType ?? LotExpenseCalcType.fixed;
    bool isRequired = existing?.isRequired ?? false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  existing == null ? Icons.add_circle_outline : Icons.edit_note_rounded,
                  color: theme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                existing == null ? 'Add Custom Expense' : 'Edit Expense Field',
                style: AppTypography.cardTitle.copyWith(color: theme.text),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Expense Field Name (English) *',
                    hint: 'e.g. Loading Charge, Sorting Fee',
                    controller: nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Tamil Label (Optional)',
                    hint: 'e.g. ஏற்றுக்கூலி, தரம் பிரித்தல்',
                    controller: tamilCtrl,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Calculation Type',
                    style: AppTypography.label.copyWith(color: theme.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<LotExpenseCalcType>(
                    isExpanded: true,
                    initialValue: calcType,
                    dropdownColor: theme.surface,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: LotExpenseCalcType.fixed,
                        child: Text('Fixed Amount (நிலையான தொகை)'),
                      ),
                      DropdownMenuItem(
                        value: LotExpenseCalcType.perBag,
                        child: Text('Per Bag / Package (மூட்டைக்கு)'),
                      ),
                      DropdownMenuItem(
                        value: LotExpenseCalcType.perKg,
                        child: Text('Per Kg / Weight (கிலோவுக்கு)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => calcType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Default Rate / Amount (₹)',
                    hint: '0',
                    prefixText: '₹ ',
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text('Required Field', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
                    subtitle: Text('Must be entered when creating a lot', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                    value: isRequired,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setDialogState(() => isRequired = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: theme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final name = nameCtrl.text.trim();
                final tamil = tamilCtrl.text.trim();
                final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;

                if (existing != null) {
                  final updated = existing.copyWith(
                    name: name,
                    tamilName: tamil.isNotEmpty ? tamil : null,
                    calcType: calcType,
                    defaultAmount: amt,
                    isRequired: isRequired,
                  );
                  await ref.read(appRepositoryProvider).updateLotExpenseConfig(updated);
                  if (ctx.mounted) Navigator.pop(ctx);
                  messenger.showSnackBar(SnackBar(content: Text('Expense "$name" updated')));
                } else {
                  await ref.read(appRepositoryProvider).addLotExpenseConfig(
                    name: name,
                    tamilName: tamil.isNotEmpty ? tamil : null,
                    calcType: calcType,
                    defaultAmount: amt,
                    isRequired: isRequired,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  messenger.showSnackBar(SnackBar(content: Text('Custom expense "$name" added to future lots')));
                }
              },
              child: Text(existing == null ? 'Save Expense' : 'Update Expense'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final configs = ref.watch(lotExpenseConfigsProvider);
    final products = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Lot Configuration & Customization', style: AppTypography.pageTitle.copyWith(color: theme.text, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: theme.primary,
          unselectedLabelColor: theme.textSecondary,
          indicatorColor: theme.primary,
          tabs: const [
            Tab(text: 'Expenses & Charges'),
            Tab(text: 'Produce Catalogue'),
            Tab(text: 'Weight & Bags'),
            Tab(text: 'Numbering & Rules'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Expenses Configuration
          _buildExpensesTab(theme, configs),

          // Tab 2: Produce Catalogue
          _buildProduceTab(theme, products),

          // Tab 3: Weight & Bags
          _buildWeightTab(theme),

          // Tab 4: Numbering & Rules
          _buildNumberingTab(theme),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(AppThemeColors theme, List<LotExpenseConfig> configs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.tune_rounded, color: theme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configurable Mandi Expenses',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Customize Labour, Sangam, Rent, Mamool, and add business-specific charges automatically loaded in Create Lot.',
                        style: TextStyle(fontSize: 11, color: theme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Configured Expense Fields (${configs.length})', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
              ElevatedButton.icon(
                onPressed: () => _showAddExpenseDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Expense', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...configs.map((cfg) {
            final isDefault = cfg.id.startsWith('exp_');
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cfg.isActive ? theme.border : theme.border.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cfg.isActive ? theme.accent : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: cfg.isActive ? theme.primary : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              cfg.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: cfg.isActive ? theme.text : theme.textMuted,
                              ),
                            ),
                            if (cfg.tamilName != null && cfg.tamilName!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: theme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  cfg.tamilName!,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.primary),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${cfg.calcTypeLabel} • Default: ${AppFormatters.currency(cfg.defaultAmount)} ${cfg.isRequired ? '• Required' : ''}',
                          style: TextStyle(fontSize: 11, color: theme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: cfg.isActive,
                    onChanged: (_) {
                      ref.read(appRepositoryProvider).toggleLotExpenseConfig(cfg.id);
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 18, color: theme.textSecondary),
                    onSelected: (val) async {
                      if (val == 'edit') {
                        _showAddExpenseDialog(context, existing: cfg);
                      } else if (val == 'delete') {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Delete Expense Field?'),
                            content: Text('Delete "${cfg.name}"? It will not appear in future lots.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await ref.read(appRepositoryProvider).deleteLotExpenseConfig(cfg.id);
                          if (mounted) AppDialog.showSnackBar(context, 'Expense field deleted');
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit Field')),
                      if (!isDefault) const PopupMenuItem(value: 'delete', child: Text('Delete Field', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProduceTab(AppThemeColors theme, List<Product> products) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.eco_rounded, color: theme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${products.length} Agricultural Products configured in your procurement catalogue.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.text),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Available Produce Gallery', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: products.take(18).length,
            itemBuilder: (ctx, idx) {
              final p = products[idx];
              return Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: ProductImageView(
                        assetPath: p.assetPath,
                        imageUrl: p.imageUrl,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.text),
                    ),
                    Text(
                      p.categoryName,
                      style: TextStyle(fontSize: 9, color: theme.textMuted),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTab(AppThemeColors theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weight Calculation Mode', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _weightMode = 'full'),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          _weightMode == 'full' ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: _weightMode == 'full' ? theme.primary : theme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Full Weighbridge Measurement', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text)),
                              const SizedBox(height: 2),
                              Text('Enter Gross weight and Tare weight directly to calculate net consignment weight.', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(color: theme.border),
                InkWell(
                  onTap: () => setState(() => _weightMode = 'total'),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          _weightMode == 'total' ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: _weightMode == 'total' ? theme.primary : theme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Bags Combined Weight', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text)),
                              const SizedBox(height: 2),
                              Text('Use the sum of all individual bag entries without duplicate count.', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Default Units & Precision', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Default Unit:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
                    DropdownButton<String>(
                      value: _defaultWeightUnit,
                      dropdownColor: theme.surface,
                      items: const [
                        DropdownMenuItem(value: 'Kg', child: Text('Kilogram (Kg)')),
                        DropdownMenuItem(value: 'Ton', child: Text('Metric Ton (T)')),
                        DropdownMenuItem(value: 'Quintal', child: Text('Quintal (Q)')),
                      ],
                      onChanged: (val) => setState(() => _defaultWeightUnit = val!),
                    ),
                  ],
                ),
                Divider(color: theme.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Decimal Precision:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
                    DropdownButton<int>(
                      value: _decimalPrecision,
                      dropdownColor: theme.surface,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('0 Decimals (1250 Kg)')),
                        DropdownMenuItem(value: 1, child: Text('1 Decimal (1250.5 Kg)')),
                        DropdownMenuItem(value: 2, child: Text('2 Decimals (1250.50 Kg)')),
                        DropdownMenuItem(value: 3, child: Text('3 Decimals (1.250 Ton)')),
                      ],
                      onChanged: (val) => setState(() => _decimalPrecision = val!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberingTab(AppThemeColors theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lot Numbering Format', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: Text('Automatic Lot Numbering', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text)),
                  subtitle: Text('Auto-increment unique lot numbers', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                  value: _autoLotNumbering,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _autoLotNumbering = val),
                ),
                const SizedBox(height: 10),
                AppTextField(
                  label: 'Lot Prefix',
                  hint: 'LOT-2026-',
                  controller: _lotPrefixCtrl,
                ),
                const SizedBox(height: 8),
                Text('Sample Generated: ${_lotPrefixCtrl.text}104', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Form Field Validations', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Require Party / Supplier Selection', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
                  value: _requireParty,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _requireParty = val),
                ),
                Divider(color: theme.border),
                SwitchListTile(
                  title: Text('Require Lorry / Vehicle Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
                  value: _requireLorry,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _requireLorry = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
