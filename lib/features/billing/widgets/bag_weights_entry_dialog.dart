import 'package:flutter/material.dart';

class BagWeightsResult {
  final int totalBags;
  final List<double> weights;
  final double tarePerBag;
  final double grossWeight;
  final double totalTare;
  final double netWeight;

  const BagWeightsResult({
    required this.totalBags,
    required this.weights,
    required this.tarePerBag,
    required this.grossWeight,
    required this.totalTare,
    required this.netWeight,
  });
}

class BagWeightsEntryDialog extends StatefulWidget {
  final int initialBags;
  final double initialTarePerBag;
  final List<double>? initialWeights;

  const BagWeightsEntryDialog({
    super.key,
    this.initialBags = 10,
    this.initialTarePerBag = 1.0,
    this.initialWeights,
  });

  static Future<BagWeightsResult?> show(
    BuildContext context, {
    int initialBags = 10,
    double initialTarePerBag = 1.0,
    List<double>? initialWeights,
  }) {
    return showModalBottomSheet<BagWeightsResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BagWeightsEntryDialog(
        initialBags: initialBags,
        initialTarePerBag: initialTarePerBag,
        initialWeights: initialWeights,
      ),
    );
  }

  @override
  State<BagWeightsEntryDialog> createState() => _BagWeightsEntryDialogState();
}

class _BagWeightsEntryDialogState extends State<BagWeightsEntryDialog> {
  late int _bagCount;
  late double _tarePerBag;
  final List<TextEditingController> _weightControllers = [];

  @override
  void initState() {
    super.initState();
    _bagCount = widget.initialBags > 0 ? widget.initialBags : 10;
    _tarePerBag = widget.initialTarePerBag;

    final initialList = widget.initialWeights ?? [];
    for (int i = 0; i < _bagCount; i++) {
      final initialVal = i < initialList.length ? initialList[i] : 50.0;
      _weightControllers.add(TextEditingController(text: initialVal.toStringAsFixed(1)));
    }
  }

  @override
  void dispose() {
    for (final ctrl in _weightControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _updateBagCount(int newCount) {
    if (newCount < 1 || newCount > 200) return;
    setState(() {
      if (newCount > _bagCount) {
        final lastVal = _weightControllers.isNotEmpty
            ? double.tryParse(_weightControllers.last.text) ?? 50.0
            : 50.0;
        for (int i = _bagCount; i < newCount; i++) {
          _weightControllers.add(TextEditingController(text: lastVal.toStringAsFixed(1)));
        }
      } else {
        while (_weightControllers.length > newCount) {
          _weightControllers.removeLast().dispose();
        }
      }
      _bagCount = newCount;
    });
  }

  void _quickFill(double value) {
    setState(() {
      for (final ctrl in _weightControllers) {
        ctrl.text = value.toStringAsFixed(1);
      }
    });
  }

  double get _grossWeight {
    double sum = 0.0;
    for (final ctrl in _weightControllers) {
      sum += double.tryParse(ctrl.text) ?? 0.0;
    }
    return sum;
  }

  double get _totalTare => _bagCount * _tarePerBag;

  double get _netWeight {
    final net = _grossWeight - _totalTare;
    return net > 0 ? net : 0.0;
  }

  double get _avgWeight => _bagCount > 0 ? _netWeight / _bagCount : 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 14),

            // Header: Title & Bag Count Stepper
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.scale_rounded, color: Color(0xFF1E6B24), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bag-by-Bag Weighing Entry',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Enter weights for each of the $_bagCount bags',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  // Bag Count Increment / Decrement
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          onPressed: () => _updateBagCount(_bagCount - 1),
                        ),
                        Text(
                          '$_bagCount BG',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          onPressed: () => _updateBagCount(_bagCount + 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Presets Toolbar: Quick-fill buttons & Gunny Bag Tare setting
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              color: const Color(0xFFF8FAFC),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Quick Fill:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                    const SizedBox(width: 8),
                    _buildPresetChip('25 kg All', 25.0),
                    const SizedBox(width: 6),
                    _buildPresetChip('40 kg All', 40.0),
                    const SizedBox(width: 6),
                    _buildPresetChip('50 kg All', 50.0),
                    const SizedBox(width: 6),
                    _buildPresetChip('60 kg All', 60.0),
                    const SizedBox(width: 14),
                    Container(height: 20, width: 1, color: const Color(0xFFCBD5E1)),
                    const SizedBox(width: 14),
                    const Text('Tare / Bag:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                    const SizedBox(width: 6),
                    _buildTareChip('0 kg', 0.0),
                    const SizedBox(width: 4),
                    _buildTareChip('0.5 kg', 0.5),
                    const SizedBox(width: 4),
                    _buildTareChip('1.0 kg', 1.0),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Bag Grid of Inputs
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 130,
                  mainAxisExtent: 74,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _weightControllers.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bag #${index + 1}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: TextField(
                            controller: _weightControllers[index],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            decoration: const InputDecoration(
                              suffixText: 'kg',
                              suffixStyle: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Live Calculation Footer & Apply Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.2)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // KPI Row: Gross | Tare | Net | Avg
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildCalcMetric('Gross Weight', '${_grossWeight.toStringAsFixed(1)} kg', const Color(0xFF334155)),
                        const SizedBox(width: 14),
                        _buildCalcMetric('Total Tare (${_tarePerBag}x$_bagCount)', '- ${_totalTare.toStringAsFixed(1)} kg', const Color(0xFFDC2626)),
                        const SizedBox(width: 14),
                        _buildCalcMetric('Average / Bag', '${_avgWeight.toStringAsFixed(1)} kg', const Color(0xFF2563EB)),
                        const SizedBox(width: 14),
                        _buildCalcMetric('Net Weight', '${_netWeight.toStringAsFixed(1)} kg', const Color(0xFF16A34A), isBold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Apply Button
                  Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.check_circle_rounded, size: 20),
                          label: Text(
                            'Apply ${_netWeight.toStringAsFixed(1)} kg ($_bagCount BG)',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          onPressed: () {
                            final list = _weightControllers
                                .map((c) => double.tryParse(c.text) ?? 0.0)
                                .toList();
                            final result = BagWeightsResult(
                              totalBags: _bagCount,
                              weights: list,
                              tarePerBag: _tarePerBag,
                              grossWeight: _grossWeight,
                              totalTare: _totalTare,
                              netWeight: _netWeight,
                            );
                            Navigator.pop(context, result);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, double val) {
    return InkWell(
      onTap: () => _quickFill(val),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        ),
      ),
    );
  }

  Widget _buildTareChip(String label, double val) {
    final isSelected = _tarePerBag == val;
    return InkWell(
      onTap: () => setState(() => _tarePerBag = val),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildCalcMetric(String label, String value, Color color, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12.5,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
