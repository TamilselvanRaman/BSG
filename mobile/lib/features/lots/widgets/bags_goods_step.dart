import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/utils/formatters.dart';

class BagEntryItem {
  final String id;
  final TextEditingController itemNumberController;
  final TextEditingController titleController;
  final TextEditingController countController;
  final TextEditingController weightPerUnitController;
  final TextEditingController ratePerKgController;
  final TextEditingController remarksController;
  String unit;
  bool isExpanded;

  BagEntryItem({
    required this.id,
    String itemNumber = '',
    String title = '',
    String count = '10',
    String weightPerUnit = '25',
    String ratePerKg = '30',
    String remarks = '',
    this.unit = 'Kg',
    this.isExpanded = true,
  })  : itemNumberController = TextEditingController(text: itemNumber),
        titleController = TextEditingController(text: title),
        countController = TextEditingController(text: count),
        weightPerUnitController = TextEditingController(text: weightPerUnit),
        ratePerKgController = TextEditingController(text: ratePerKg),
        remarksController = TextEditingController(text: remarks);

  int get count => int.tryParse(countController.text) ?? 0;
  double get weightPerUnit => double.tryParse(weightPerUnitController.text) ?? 0.0;
  double get estimatedTotalWeight => count * weightPerUnit;
  double get ratePerKg => double.tryParse(ratePerKgController.text) ?? 0.0;
  double get lineTotalAmount => estimatedTotalWeight * ratePerKg;

  void dispose() {
    itemNumberController.dispose();
    titleController.dispose();
    countController.dispose();
    weightPerUnitController.dispose();
    ratePerKgController.dispose();
    remarksController.dispose();
  }
}

class BagsGoodsStep extends StatefulWidget {
  final List<BagEntryItem> bagEntries;
  final VoidCallback onAddEntry;
  final ValueChanged<int> onRemoveEntry;
  final VoidCallback onChanged;
  final String defaultUnit;
  final bool isEmbedded;

  const BagsGoodsStep({
    super.key,
    required this.bagEntries,
    required this.onAddEntry,
    required this.onRemoveEntry,
    required this.onChanged,
    required this.defaultUnit,
    this.isEmbedded = false,
  });

  @override
  State<BagsGoodsStep> createState() => _BagsGoodsStepState();
}

class _BagsGoodsStepState extends State<BagsGoodsStep> {
  final List<String> _units = [
    'Kg',
    'Bags',
    'Boxes',
    'Crates',
    'Bunch',
    'Quintal',
    'Ton',
    'Pieces',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    final totalBags = widget.bagEntries.fold<int>(0, (acc, item) => acc + item.count);
    final totalEstimatedWeight = widget.bagEntries.fold<double>(0.0, (acc, item) => acc + item.estimatedTotalWeight);
    final totalEstimatedAmount = widget.bagEntries.fold<double>(0.0, (acc, item) => acc + item.lineTotalAmount);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Bags & Weight Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.accent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Consignment Packages',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalBags Bags / Packages',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: theme.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Combined Weight',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalEstimatedWeight.toStringAsFixed(1)} Kg',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.text,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (totalEstimatedAmount > 0) ...[
                  const SizedBox(height: 10),
                  Divider(color: theme.border, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimated Goods Value:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary),
                      ),
                      Text(
                        AppFormatters.currency(totalEstimatedAmount),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.primary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bags & Goods Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.text,
                ),
              ),
              InkWell(
                onTap: widget.onAddEntry,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, size: 14, color: theme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Add Bag Details',
                        style: TextStyle(
                          fontSize: 12,
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

          // List of Expandable Bag Entries
          ...List.generate(widget.bagEntries.length, (index) {
            final entry = widget.bagEntries[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: entry.isExpanded ? theme.primary.withValues(alpha: 0.5) : theme.border,
                  width: entry.isExpanded ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expandable Header Bar
                  InkWell(
                    onTap: () {
                      setState(() => entry.isExpanded = !entry.isExpanded);
                    },
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'BAG ENTRY #${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${entry.count} Bags • ${entry.estimatedTotalWeight.toStringAsFixed(0)} Kg',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (entry.lineTotalAmount > 0)
                            Text(
                              AppFormatters.currency(entry.lineTotalAmount),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.primary,
                              ),
                            ),
                          const SizedBox(width: 6),
                          Icon(
                            entry.isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            color: theme.textSecondary,
                            size: 20,
                          ),
                          if (widget.bagEntries.length > 1) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 18, color: theme.error),
                              onPressed: () => widget.onRemoveEntry(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Expandable Content
                  if (entry.isExpanded) ...[
                    Divider(color: theme.border, height: 1),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bags Count, Weight Per Bag, Unit - Perfectly Height-Aligned
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 18,
                                      child: Text(
                                        'Bags Count *',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: entry.countController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => widget.onChanged(),
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                                      decoration: InputDecoration(
                                        hintText: '10',
                                        filled: true,
                                        fillColor: theme.background,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 18,
                                      child: Text(
                                        'Weight/Bag',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: entry.weightPerUnitController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => widget.onChanged(),
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                                      decoration: InputDecoration(
                                        hintText: '25',
                                        filled: true,
                                        fillColor: theme.background,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 18,
                                      child: Text(
                                        'Unit',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary),
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _units.contains(entry.unit) ? entry.unit : 'Kg',
                                      dropdownColor: theme.surface,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: theme.background,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                      ),
                                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: TextStyle(fontSize: 12, color: theme.text)))).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => entry.unit = val);
                                          widget.onChanged();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Rate per KG, Line Total Weight & Price Preview - Perfectly Aligned
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 18,
                                      child: Text(
                                        'Rate per ${entry.unit} (₹)',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: entry.ratePerKgController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => widget.onChanged(),
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                                      decoration: InputDecoration(
                                        prefixText: '₹ ',
                                        hintText: '30',
                                        filled: true,
                                        fillColor: theme.background,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 18,
                                      child: Text(
                                        'Total Line Value',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: theme.accent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: theme.border),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Weight', style: TextStyle(fontSize: 9.5, color: theme.textMuted)),
                                              Text(
                                                '${entry.estimatedTotalWeight.toStringAsFixed(0)} ${entry.unit}',
                                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: theme.primary),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Total', style: TextStyle(fontSize: 9.5, color: theme.textMuted)),
                                              Text(
                                                AppFormatters.currency(entry.lineTotalAmount),
                                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: theme.text),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Remarks
                          TextField(
                            controller: entry.remarksController,
                            onChanged: (_) => widget.onChanged(),
                            style: TextStyle(fontSize: 12, color: theme.text),
                            decoration: InputDecoration(
                              labelText: 'Remarks / Notes (Optional)',
                              labelStyle: TextStyle(fontSize: 11, color: theme.textMuted),
                              hintText: 'e.g. Slightly moist bags, stored in Shed B',
                              hintStyle: TextStyle(fontSize: 11, color: theme.textMuted),
                              filled: true,
                              fillColor: theme.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
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
