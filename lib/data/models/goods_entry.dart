import 'goods_entry_item.dart';

enum GoodsEntryStatus { draft, confirmed, billed, cancelled }

class GoodsEntry {
  final String id;
  final String entryNumber;
  final String customerId; // Buyer
  final DateTime entryDate;
  final String lotNumber;
  final int goodsCount; // Total physical count of goods / bags
  final String goodsName;
  final String productName;
  final String vehicleNumber;
  final String notes;
  final List<GoodsEntryItem> items;
  final double initialPaymentAmount;
  final String initialPaymentMode; // Cash, UPI, Bank Transfer, Other
  final String initialPaymentRef;
  final String initialPaymentNotes;
  final GoodsEntryStatus status;
  final DateTime createdAt;

  const GoodsEntry({
    required this.id,
    required this.entryNumber,
    required this.customerId,
    required this.entryDate,
    required this.lotNumber,
    required this.goodsCount,
    this.goodsName = '',
    this.productName = '',
    this.vehicleNumber = '',
    this.notes = '',
    required this.items,
    this.initialPaymentAmount = 0.0,
    this.initialPaymentMode = 'Cash',
    this.initialPaymentRef = '',
    this.initialPaymentNotes = '',
    this.status = GoodsEntryStatus.confirmed,
    required this.createdAt,
  });

  double get totalWeight => items.fold(0.0, (sum, item) => sum + item.weight);
  double get totalQuantity => items.fold(0.0, (sum, item) => sum + item.quantity);
  double get totalLabourCharge => items.fold(0.0, (sum, item) => sum + item.labourCharge);
  double get goodsSubtotal => items.fold(0.0, (sum, item) => sum + item.goodsAmount);
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.lineTotal);

  GoodsEntry copyWith({
    String? id,
    String? entryNumber,
    String? customerId,
    DateTime? entryDate,
    String? lotNumber,
    int? goodsCount,
    String? goodsName,
    String? productName,
    String? vehicleNumber,
    String? notes,
    List<GoodsEntryItem>? items,
    double? initialPaymentAmount,
    String? initialPaymentMode,
    String? initialPaymentRef,
    String? initialPaymentNotes,
    GoodsEntryStatus? status,
    DateTime? createdAt,
  }) {
    return GoodsEntry(
      id: id ?? this.id,
      entryNumber: entryNumber ?? this.entryNumber,
      customerId: customerId ?? this.customerId,
      entryDate: entryDate ?? this.entryDate,
      lotNumber: lotNumber ?? this.lotNumber,
      goodsCount: goodsCount ?? this.goodsCount,
      goodsName: goodsName ?? this.goodsName,
      productName: productName ?? this.productName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      initialPaymentAmount: initialPaymentAmount ?? this.initialPaymentAmount,
      initialPaymentMode: initialPaymentMode ?? this.initialPaymentMode,
      initialPaymentRef: initialPaymentRef ?? this.initialPaymentRef,
      initialPaymentNotes: initialPaymentNotes ?? this.initialPaymentNotes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
