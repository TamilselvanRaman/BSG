enum LotStatus { active, partiallySold, fullySold, cancelled }

class LotItem {
  final String id;
  final String? productId;
  final String productName;
  final String? assetPath;
  final String? imageUrl;
  final int goodsCount;
  final double quantity;
  final double weight;
  final String unit;
  final double costRate;

  const LotItem({
    required this.id,
    this.productId,
    required this.productName,
    this.assetPath,
    this.imageUrl,
    this.goodsCount = 1,
    required this.quantity,
    required this.weight,
    this.unit = 'Kg',
    required this.costRate,
  });

  double get lineTotal => quantity * costRate;
}

class Lot {
  final String id;
  final String lotNumber;
  final String supplierId;
  final String supplierName;
  final DateTime date;
  final String? entryNumber;
  final String? vehicleNumber;
  final String productName;
  final int goodsCount;
  final double initialQuantity;
  final double remainingQuantity;
  final double initialWeight;
  final double remainingWeight;
  final String unit; // 'Kg', 'Bags', 'Boxes', 'Quintal'
  final double costRate;
  final double labourCharge;
  final double transportCharge;
  final double otherCharges;
  final LotStatus status;
  final List<LotItem> items;
  final DateTime createdAt;

  const Lot({
    required this.id,
    required this.lotNumber,
    required this.supplierId,
    required this.supplierName,
    required this.date,
    this.entryNumber,
    this.vehicleNumber,
    required this.productName,
    required this.goodsCount,
    required this.initialQuantity,
    required this.remainingQuantity,
    required this.initialWeight,
    required this.remainingWeight,
    this.unit = 'Kg',
    required this.costRate,
    this.labourCharge = 0.0,
    this.transportCharge = 0.0,
    this.otherCharges = 0.0,
    this.status = LotStatus.active,
    this.items = const [],
    required this.createdAt,
  });

  double get totalInitialCost {
    if (items.isNotEmpty) {
      final itemsTotal = items.fold(0.0, (acc, item) => acc + item.lineTotal);
      return itemsTotal + labourCharge + transportCharge + otherCharges;
    }
    return (initialQuantity * costRate) + labourCharge + transportCharge + otherCharges;
  }

  bool get isAvailable => (status == LotStatus.active || status == LotStatus.partiallySold) && remainingQuantity > 0;

  Lot copyWith({
    String? id,
    String? lotNumber,
    String? supplierId,
    String? supplierName,
    DateTime? date,
    String? entryNumber,
    String? vehicleNumber,
    String? productName,
    int? goodsCount,
    double? initialQuantity,
    double? remainingQuantity,
    double? initialWeight,
    double? remainingWeight,
    String? unit,
    double? costRate,
    double? labourCharge,
    double? transportCharge,
    double? otherCharges,
    LotStatus? status,
    List<LotItem>? items,
    DateTime? createdAt,
  }) {
    return Lot(
      id: id ?? this.id,
      lotNumber: lotNumber ?? this.lotNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      date: date ?? this.date,
      entryNumber: entryNumber ?? this.entryNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      productName: productName ?? this.productName,
      goodsCount: goodsCount ?? this.goodsCount,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      initialWeight: initialWeight ?? this.initialWeight,
      remainingWeight: remainingWeight ?? this.remainingWeight,
      unit: unit ?? this.unit,
      costRate: costRate ?? this.costRate,
      labourCharge: labourCharge ?? this.labourCharge,
      transportCharge: transportCharge ?? this.transportCharge,
      otherCharges: otherCharges ?? this.otherCharges,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

