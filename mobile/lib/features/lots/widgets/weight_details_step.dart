import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';

enum WeightEntryMode {
  fullWeighbridge, // Gross - Tare = Net
  directNet, // Direct Net Weight
}

class WeightDetailsStep extends StatefulWidget {
  final WeightEntryMode mode;
  final ValueChanged<WeightEntryMode> onModeChanged;
  final TextEditingController grossWeightController;
  final TextEditingController tareWeightController;
  final TextEditingController netWeightController;
  final int totalPackages;
  final VoidCallback onChanged;
  final bool isEmbedded;

  const WeightDetailsStep({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.grossWeightController,
    required this.tareWeightController,
    required this.netWeightController,
    required this.totalPackages,
    required this.onChanged,
    this.isEmbedded = false,
  });

  @override
  State<WeightDetailsStep> createState() => _WeightDetailsStepState();
}

class _WeightDetailsStepState extends State<WeightDetailsStep> {
  void _calculateNet() {
    if (widget.mode == WeightEntryMode.fullWeighbridge) {
      final gross = double.tryParse(widget.grossWeightController.text) ?? 0.0;
      final tare = double.tryParse(widget.tareWeightController.text) ?? 0.0;
      final net = (gross - tare).clamp(0.0, double.infinity);
      widget.netWeightController.text = net > 0 ? net.toStringAsFixed(2) : '';
    }
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    final gross = double.tryParse(widget.grossWeightController.text) ?? 0.0;
    final tare = double.tryParse(widget.tareWeightController.text) ?? 0.0;
    final net = double.tryParse(widget.netWeightController.text) ?? 0.0;
    final avgPerBag = (widget.totalPackages > 0 && net > 0) ? (net / widget.totalPackages) : 0.0;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Selectable Weighing Method Cards
          Text(
            'Select Weighing Method',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildModeCard(
                  title: 'Weighbridge Mode',
                  subtitle: 'Gross - Tare = Net',
                  icon: Icons.scale_outlined,
                  isSelected: widget.mode == WeightEntryMode.fullWeighbridge,
                  onTap: () {
                    widget.onModeChanged(WeightEntryMode.fullWeighbridge);
                    _calculateNet();
                  },
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModeCard(
                  title: 'Direct Weight',
                  subtitle: 'Scale / Platform Net',
                  icon: Icons.speed_outlined,
                  isSelected: widget.mode == WeightEntryMode.directNet,
                  onTap: () {
                    widget.onModeChanged(WeightEntryMode.directNet);
                    widget.onChanged();
                  },
                  theme: theme,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Inputs based on selected mode
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mode == WeightEntryMode.fullWeighbridge
                      ? 'Lorry & Tare Weight Entry'
                      : 'Direct Net Weight Entry',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
                const SizedBox(height: 14),

                if (widget.mode == WeightEntryMode.fullWeighbridge) ...[
                  // Gross Weight
                  Text(
                    'Gross Weight (Lorry + Goods) * [Kg]',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: widget.grossWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _calculateNet(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
                    decoration: InputDecoration(
                      hintText: 'e.g. 12500',
                      suffixText: 'Kg',
                      suffixStyle: TextStyle(fontWeight: FontWeight.w600, color: theme.textSecondary),
                      filled: true,
                      fillColor: theme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tare Weight
                  Text(
                    'Tare Weight (Empty Lorry / Vehicle) * [Kg]',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: widget.tareWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _calculateNet(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
                    decoration: InputDecoration(
                      hintText: 'e.g. 4500',
                      suffixText: 'Kg',
                      suffixStyle: TextStyle(fontWeight: FontWeight.w600, color: theme.textSecondary),
                      filled: true,
                      fillColor: theme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 14),
                ],

                // Net Weight
                Text(
                  widget.mode == WeightEntryMode.fullWeighbridge
                      ? 'Calculated Net Agricultural Weight [Kg]'
                      : 'Total Net Agricultural Weight * [Kg]',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: widget.netWeightController,
                  readOnly: widget.mode == WeightEntryMode.fullWeighbridge,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => widget.onChanged(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. 8000',
                    suffixText: 'Kg',
                    suffixStyle: TextStyle(fontWeight: FontWeight.w700, color: theme.primary),
                    filled: true,
                    fillColor: widget.mode == WeightEntryMode.fullWeighbridge
                        ? theme.accent.withValues(alpha: 0.5)
                        : theme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Highlighted Net Weight & Bag Average Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net Billable Weight',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                      ),
                    ),
                    Text(
                      '${net.toStringAsFixed(1)} Kg',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
                if (widget.mode == WeightEntryMode.fullWeighbridge && gross > 0 && tare > 0) ...[
                  const SizedBox(height: 8),
                  Divider(color: theme.border, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gross: ${gross.toStringAsFixed(0)} Kg',
                        style: TextStyle(fontSize: 11, color: theme.textMuted),
                      ),
                      Text(
                        'Tare: ${tare.toStringAsFixed(0)} Kg',
                        style: TextStyle(fontSize: 11, color: theme.textMuted),
                      ),
                      Text(
                        'Diff: ${(gross - tare).toStringAsFixed(0)} Kg',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.text),
                      ),
                    ],
                  ),
                ],
                if (avgPerBag > 0) ...[
                  const SizedBox(height: 8),
                  Divider(color: theme.border, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calculated Average Weight / Bag:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.textSecondary,
                        ),
                      ),
                      Text(
                        '${avgPerBag.toStringAsFixed(2)} Kg / Bag',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.text,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      );

    if (widget.isEmbedded) {
      return content;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeColors theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary.withValues(alpha: 0.1) : theme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? theme.primary : theme.border,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? theme.primary : theme.textMuted,
                ),
                if (isSelected)
                  Icon(Icons.check_circle, size: 16, color: theme.primary)
                else
                  const SizedBox(height: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? theme.primary : theme.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

