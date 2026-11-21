import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';

enum WeightEntryMode {
  fullWeighbridge, // Gross - Tare = Net
  directNet, // Direct Net Weight
}

class WeightDetailsStep extends StatefulWidget {
  final TextEditingController netWeightController;
  final int totalPackages;
  final VoidCallback onChanged;
  final bool isEmbedded;
  final WeightEntryMode? mode;
  final ValueChanged<WeightEntryMode>? onModeChanged;
  final TextEditingController? grossWeightController;
  final TextEditingController? tareWeightController;

  const WeightDetailsStep({
    super.key,
    required this.netWeightController,
    required this.totalPackages,
    required this.onChanged,
    this.isEmbedded = false,
    this.mode,
    this.onModeChanged,
    this.grossWeightController,
    this.tareWeightController,
  });

  @override
  State<WeightDetailsStep> createState() => _WeightDetailsStepState();
}

class _WeightDetailsStepState extends State<WeightDetailsStep> {
  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    final net = double.tryParse(widget.netWeightController.text) ?? 0.0;
    final avgPerBag = (widget.totalPackages > 0 && net > 0) ? (net / widget.totalPackages) : 0.0;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Consignment Weight Card (Auto-Calculated from Bags)
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.scale_rounded, color: theme.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Consignment Weight',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.text,
                          ),
                        ),
                        Text(
                          'Calculated automatically from all bag entries',
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
                      color: theme.accent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Calculated',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: theme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Calculated Net Agricultural Weight * [Kg]',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: widget.netWeightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => widget.onChanged(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.primary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 5000',
                  suffixText: 'Kg',
                  suffixStyle: TextStyle(fontWeight: FontWeight.w700, color: theme.primary),
                  filled: true,
                  fillColor: theme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

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
              const SizedBox(height: 8),
              Divider(color: theme.border, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Consignment Packages:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.textSecondary,
                    ),
                  ),
                  Text(
                    '${widget.totalPackages} Bags',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.text,
                    ),
                  ),
                ],
              ),
              if (avgPerBag > 0) ...[
                const SizedBox(height: 6),
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
}
