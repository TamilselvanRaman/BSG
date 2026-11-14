import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';

class BagWeightsResult {
  final int bagCount;
  final double totalWeight;
  final List<double> weights;

  const BagWeightsResult({
    required this.bagCount,
    required this.totalWeight,
    required this.weights,
  });
}

class BagWeightsTableModal extends StatefulWidget {
  final int initialBagCount;
  final double initialTotalWeight;
  final String unit;
  final List<double>? existingWeights;

  const BagWeightsTableModal({
    super.key,
    required this.initialBagCount,
    required this.initialTotalWeight,
    this.unit = 'Kg',
    this.existingWeights,
  });

  static Future<BagWeightsResult?> show(
    BuildContext context, {
    required int initialBagCount,
    required double initialTotalWeight,
    String unit = 'Kg',
    List<double>? existingWeights,
  }) {
    return showModalBottomSheet<BagWeightsResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BagWeightsTableModal(
        initialBagCount: initialBagCount,
        initialTotalWeight: initialTotalWeight,
        unit: unit,
        existingWeights: existingWeights,
      ),
    );
  }

  @override
  State<BagWeightsTableModal> createState() => _BagWeightsTableModalState();
}

class _BagWeightsTableModalState extends State<BagWeightsTableModal> {
  final List<TextEditingController> _controllers = [];
  final TextEditingController _bulkWeightController = TextEditingController(text: '50');

  @override
  void initState() {
    super.initState();
    _initRows();
  }

  void _initRows() {
    if (widget.existingWeights != null && widget.existingWeights!.isNotEmpty) {
      for (final w in widget.existingWeights!) {
        _controllers.add(TextEditingController(
          text: w > 0 ? (w % 1 == 0 ? w.toInt().toString() : w.toStringAsFixed(1)) : '',
        ));
      }
    } else {
      final count = widget.initialBagCount > 0 ? widget.initialBagCount : 5;
      final avgWeight = (widget.initialTotalWeight > 0 && count > 0)
          ? (widget.initialTotalWeight / count)
          : 50.0;
      final defaultWeightText = avgWeight > 0
          ? (avgWeight % 1 == 0 ? avgWeight.toInt().toString() : avgWeight.toStringAsFixed(1))
          : '50';

      for (int i = 0; i < count; i++) {
        _controllers.add(TextEditingController(text: defaultWeightText));
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _bulkWeightController.dispose();
    super.dispose();
  }

  double get _totalWeight {
    double sum = 0.0;
    for (final c in _controllers) {
      sum += double.tryParse(c.text.trim()) ?? 0.0;
    }
    return sum;
  }

  int get _bagCount => _controllers.length;

  double get _averageWeight => _bagCount > 0 ? _totalWeight / _bagCount : 0.0;

  void _addBag() {
    setState(() {
      final defaultVal = _controllers.isNotEmpty ? _controllers.last.text : '50';
      _controllers.add(TextEditingController(text: defaultVal));
    });
  }

  void _removeBag(int index) {
    if (_controllers.length > 1) {
      setState(() {
        final c = _controllers.removeAt(index);
        c.dispose();
      });
    }
  }

  void _applyBulkWeight() {
    final bulkVal = _bulkWeightController.text.trim();
    if (bulkVal.isNotEmpty) {
      setState(() {
        for (final c in _controllers) {
          c.text = bulkVal;
        }
      });
    }
  }

  void _onApply() {
    final weights = _controllers
        .map((c) => double.tryParse(c.text.trim()) ?? 0.0)
        .toList();
    Navigator.pop(
      context,
      BagWeightsResult(
        bagCount: _bagCount,
        totalWeight: _totalWeight,
        weights: weights,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final totalW = _totalWeight;
    final avgW = _averageWeight;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: theme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.scale_rounded, color: theme.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Individual Bag Weights Entry',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
                      ),
                      Text(
                        'Enter weight for each bag or use total weight',
                        style: TextStyle(fontSize: 11, color: theme.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  color: theme.textSecondary,
                ),
              ],
            ),
          ),

          // Live Summary Metrics Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Total Bags', style: TextStyle(fontSize: 10.5, color: theme.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '$_bagCount',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: theme.primary),
                    ),
                  ],
                ),
                Container(width: 1, height: 28, color: theme.primary.withValues(alpha: 0.2)),
                Column(
                  children: [
                    Text('Total Weight', style: TextStyle(fontSize: 10.5, color: theme.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '${totalW.toStringAsFixed(1)} ${widget.unit}',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: theme.primary),
                    ),
                  ],
                ),
                Container(width: 1, height: 28, color: theme.primary.withValues(alpha: 0.2)),
                Column(
                  children: [
                    Text('Avg Weight', style: TextStyle(fontSize: 10.5, color: theme.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '${avgW.toStringAsFixed(1)} ${widget.unit}',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: theme.text),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bulk Weight Quick Fill Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('Fill all bags with:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  height: 32,
                  child: TextField(
                    controller: _bulkWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.text),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      filled: true,
                      fillColor: theme.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: theme.border)),
                      isDense: true,
                    ),
                  ),
                ),
                Text(' ${widget.unit}', style: TextStyle(fontSize: 11, color: theme.textMuted)),
                const SizedBox(width: 6),
                InkWell(
                  onTap: _applyBulkWeight,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.accent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text('Apply All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primary)),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _addBag,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: Colors.white),
                        SizedBox(width: 2),
                        Text('Add Bag', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 14),

          // Scrollable Bag Rows Table
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _controllers.length,
              separatorBuilder: (_, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final ctrl = _controllers[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.border.withValues(alpha: 0.7)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: theme.border),
                        ),
                        child: Center(
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Bag Weight:', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: TextField(
                            controller: ctrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text),
                            decoration: InputDecoration(
                              hintText: '50',
                              suffixText: widget.unit,
                              suffixStyle: TextStyle(fontSize: 11, color: theme.textMuted),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              filled: true,
                              fillColor: theme.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                      if (_controllers.length > 1) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: theme.error),
                          onPressed: () => _removeBag(index),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(top: BorderSide(color: theme.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total: ${totalW.toStringAsFixed(1)} ${widget.unit}',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: theme.primary),
                      ),
                      Text(
                        'for $_bagCount bags',
                        style: TextStyle(fontSize: 11, color: theme.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Apply to Bill', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _onApply,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
