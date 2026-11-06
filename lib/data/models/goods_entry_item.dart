class GoodsEntryItem {
  final String id;
  final String productName;
  final String goodsName;
  final double quantity; // Bags / boxes
  final double weight;   // kg
  final double costRate; // Internal procurement cost (not shown to buyer)
  final double sellRate; // Selling rate per kg (or unit)
  final double labourCharge; // Labour / Hamali charges
  
  const GoodsEntryItem({
    required this.id,
    required this.productName,
    required this.goodsName,
    this.quantity = 0.0,
    this.weight = 0.0,
    this.costRate = 0.0,
    required this.sellRate,
    this.labourCharge = 0.0,
  });

  /// Base goods amount without labour
  double get goodsAmount {
    final billableBasis = weight > 0 ? weight : quantity;
    return billableBasis * sellRate;
  }

  /// Billable amount: goods amount + labour charge
  double get lineTotal => goodsAmount + labourCharge;

  GoodsEntryItem copyWith({
    String? id,
    String? productName,
    String? goodsName,
    double? quantity,
    double? weight,
    double? costRate,
    double? sellRate,
    double? labourCharge,
  }) {
    return GoodsEntryItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      goodsName: goodsName ?? this.goodsName,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      costRate: costRate ?? this.costRate,
      sellRate: sellRate ?? this.sellRate,
      labourCharge: labourCharge ?? this.labourCharge,
    );
  }
}
