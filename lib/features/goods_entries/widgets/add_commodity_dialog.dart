import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/app_state.dart';
import '../../../data/models/commodity.dart';

class AddCommodityDialog extends ConsumerStatefulWidget {
  final String? initialName;
  final ValueChanged<Commodity> onAdded;

  const AddCommodityDialog({
    super.key,
    this.initialName,
    required this.onAdded,
  });

  static Future<Commodity?> show(
    BuildContext context,
    WidgetRef ref, {
    String? initialName,
    required ValueChanged<Commodity> onAdded,
  }) {
    return showModalBottomSheet<Commodity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddCommodityDialog(
        initialName: initialName,
        onAdded: onAdded,
      ),
    );
  }

  @override
  ConsumerState<AddCommodityDialog> createState() => _AddCommodityDialogState();
}

class _AddCommodityDialogState extends ConsumerState<AddCommodityDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _imageUrlCtrl;
  late TextEditingController _costRateCtrl;
  late TextEditingController _sellRateCtrl;

  String _category = 'Vegetables';
  String _selectedEmoji = '🍅';
  String _selectedUnit = 'Bags';
  int _selectedColor = 0xFF15803D;

  static const List<Map<String, dynamic>> _presetEmojis = [
    {'emoji': '🍅', 'name': 'Tomato', 'color': 0xFFDC2626},
    {'emoji': '🧅', 'name': 'Onion', 'color': 0xFF9333EA},
    {'emoji': '🥔', 'name': 'Potato', 'color': 0xFFD97706},
    {'emoji': '🌶️', 'name': 'Chilli', 'color': 0xFF16A34A},
    {'emoji': '🥬', 'name': 'Cabbage', 'color': 0xFF059669},
    {'emoji': '🫚', 'name': 'Ginger', 'color': 0xFFB45309},
    {'emoji': '🥕', 'name': 'Carrot', 'color': 0xFFEA580C},
    {'emoji': '🧄', 'name': 'Garlic', 'color': 0xFF64748B},
    {'emoji': '🥦', 'name': 'Cauliflower', 'color': 0xFF15803D},
    {'emoji': '🫑', 'name': 'Capsicum', 'color': 0xFF10B981},
    {'emoji': '🌿', 'name': 'Moringa', 'color': 0xFF15803D},
    {'emoji': '🍠', 'name': 'Beetroot', 'color': 0xFFBE185D},
    {'emoji': '🍋', 'name': 'Lemon', 'color': 0xFFEAB308},
    {'emoji': '🌽', 'name': 'Corn', 'color': 0xFFF59E0B},
    {'emoji': '🥒', 'name': 'Cucumber', 'color': 0xFF22C55E},
    {'emoji': '🍆', 'name': 'Brinjal', 'color': 0xFF7C3AED},
    {'emoji': '🍏', 'name': 'Apple', 'color': 0xFFEF4444},
    {'emoji': '🥭', 'name': 'Mango', 'color': 0xFFF97316},
    {'emoji': '🥥', 'name': 'Coconut', 'color': 0xFF78350F},
    {'emoji': '📦', 'name': 'Other Goods', 'color': 0xFF15803D},
  ];

  static const List<String> _categories = [
    'Vegetables',
    'Tubers & Bulbs',
    'Spices',
    'Greens & Veg',
    'Fruits',
    'Grains & Pulses',
    'Other Produce',
  ];

  static const List<String> _units = [
    'Bags',
    'Kg',
    'Crates',
    'Boxes',
    'Bundles',
    'Quintal',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _imageUrlCtrl = TextEditingController();
    _costRateCtrl = TextEditingController(text: '24');
    _sellRateCtrl = TextEditingController(text: '30');

    // Auto-detect emoji from name
    final name = (widget.initialName ?? '').toLowerCase();
    for (final p in _presetEmojis) {
      if (name.contains((p['name'] as String).toLowerCase())) {
        _selectedEmoji = p['emoji'] as String;
        _selectedColor = p['color'] as int;
        break;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _imageUrlCtrl.dispose();
    _costRateCtrl.dispose();
    _sellRateCtrl.dispose();
    super.dispose();
  }

  void _saveAndChoose() {
    if (!_formKey.currentState!.validate()) return;

    final id = 'comm-custom-${const Uuid().v4().substring(0, 8)}';
    final name = _nameCtrl.text.trim();
    final cost = double.tryParse(_costRateCtrl.text.trim()) ?? 20.0;
    final sell = double.tryParse(_sellRateCtrl.text.trim()) ?? 25.0;
    final imageUrl = _imageUrlCtrl.text.trim().isNotEmpty ? _imageUrlCtrl.text.trim() : null;

    final newCommodity = Commodity(
      id: id,
      name: name,
      category: _category,
      imageUrl: imageUrl,
      iconEmoji: _selectedEmoji,
      defaultUnit: _selectedUnit,
      defaultCostRate: cost,
      defaultSellRate: sell,
      colorValue: _selectedColor,
      isCustom: true,
    );

    // Save to AppState
    ref.read(appStateProvider.notifier).addCommodity(newCommodity);

    // Trigger callback
    widget.onAdded(newCommodity);

    Navigator.of(context).pop(newCommodity);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: 40, bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Dialog Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreenSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryGreen, size: 22),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add New Commodity / Goods', style: AppTypography.titleMedium),
                            Text('Add to catalog for fast one-tap selection', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Goods Name
                CustomTextField(
                  label: 'Commodity / Goods Name *',
                  hint: 'e.g. Ooty Fresh Carrots, White Garlic',
                  controller: _nameCtrl,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter goods name' : null,
                  prefixIcon: Icons.shopping_basket_outlined,
                  onChanged: (val) {
                    final lower = val.toLowerCase();
                    for (final p in _presetEmojis) {
                      if (lower.contains((p['name'] as String).toLowerCase())) {
                        setState(() {
                          _selectedEmoji = p['emoji'] as String;
                          _selectedColor = p['color'] as int;
                        });
                        break;
                      }
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Choose Icon / Visual Preset
                const Text('Choose Goods Icon & Color *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetEmojis.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = _presetEmojis[index];
                      final emoji = item['emoji'] as String;
                      final name = item['name'] as String;
                      final color = item['color'] as int;
                      final isSelected = _selectedEmoji == emoji;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedEmoji = emoji;
                            _selectedColor = color;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(color).withValues(alpha: 0.15) : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Color(color) : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 2),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Color(color) : AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Optional Custom Image URL
                CustomTextField(
                  label: 'Custom Image URL (Optional)',
                  hint: 'https://example.com/produce.jpg',
                  controller: _imageUrlCtrl,
                  prefixIcon: Icons.image_outlined,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.md),

                // Category & Unit Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _category,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                            ),
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _category = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Default Unit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                            ),
                            items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedUnit = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Default Rates Row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Default Cost Rate (₹)',
                        hint: 'e.g. 24',
                        controller: _costRateCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.currency_rupee,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: CustomTextField(
                        label: 'Default Sell Rate (₹)',
                        hint: 'e.g. 30',
                        controller: _sellRateCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.currency_rupee,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Preview Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(_selectedColor).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(_selectedColor), width: 1.5),
                        ),
                        child: Center(
                          child: Text(_selectedEmoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameCtrl.text.trim().isEmpty ? 'Goods Name Preview' : _nameCtrl.text.trim(),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_category • $_selectedUnit • Cost ₹${_costRateCtrl.text} / Sell ₹${_sellRateCtrl.text}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancel',
                        isOutlined: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Save & Choose Goods',
                        icon: Icons.check,
                        onPressed: _saveAndChoose,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
