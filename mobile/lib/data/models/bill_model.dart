import 'payment_model.dart';

enum BillType { cash, credit }

enum BillStatus { paid, unpaid, partiallyPaid, cancelled }

class BillBagItem {
  final int serialNumber;
  final double weight;
  final double rate;
  final double amount;

  const BillBagItem({
    required this.serialNumber,
    required this.weight,
    required this.rate,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'serialNumber': serialNumber,
        'weight': weight,
        'rate': rate,
        'amount': amount,
      };

  factory BillBagItem.fromJson(Map<String, dynamic> json) => BillBagItem(
        serialNumber: json['serialNumber'] as int? ?? 1,
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
        rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      );
}

class BillItem {
  final String id;
  final String lotId;
  final String lotNumber;
  final String productName;
  final double quantity; // Bags
  final double weight; // Kg
  final String unit;
  final double sellRate;
  final double grossAmount;
  final List<BillBagItem> bagItems;

  const BillItem({
    required this.id,
    required this.lotId,
    required this.lotNumber,
    required this.productName,
    required this.quantity,
    required this.weight,
    this.unit = 'Kg',
    required this.sellRate,
    required this.grossAmount,
    this.bagItems = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'lotId': lotId,
        'lotNumber': lotNumber,
        'productName': productName,
        'quantity': quantity,
        'weight': weight,
        'unit': unit,
        'sellRate': sellRate,
        'grossAmount': grossAmount,
        'bagItems': bagItems.map((e) => e.toJson()).toList(),
      };

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
        id: json['id'] as String? ?? '',
        lotId: json['lotId'] as String? ?? '',
        lotNumber: json['lotNumber'] as String? ?? '',
        productName: json['productName'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
        unit: json['unit'] as String? ?? 'Kg',
        sellRate: (json['sellRate'] as num?)?.toDouble() ?? 0.0,
        grossAmount: (json['grossAmount'] as num?)?.toDouble() ?? 0.0,
        bagItems: (json['bagItems'] as List<dynamic>?)
                ?.map((e) => BillBagItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class BillExtraCharge {
  final String id;
  final String name;
  final double amount;
  final String? description;

  const BillExtraCharge({
    required this.id,
    required this.name,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'description': description,
      };

  factory BillExtraCharge.fromJson(Map<String, dynamic> json) => BillExtraCharge(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] as String?,
      );
}

class Bill {
  final String id;
  final String billNumber;
  final BillType type;
  final String? customerId;
  final String customerName;
  final String? customerPhone;
  final String lotId;
  final String lotNumber;
  final String productName;
  final DateTime date;
  final double quantity;
  final double weight;
  final String unit;
  final double sellRate;
  final double grossAmount;
  final double labourCharge;
  final double transportFee;
  final double mandiFee;
  final double otherCharges;
  final double discount;
  final double totalAmount;
  final double amountReceived;
  final double balanceDue;
  final BillStatus status;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final List<BillBagItem> bagItems;
  final List<BillItem> items;
  final List<BillExtraCharge> extraCharges;
  final String? sellerName;
  final String? sellerPhone;
  final String? village;
  final String? lotRefNumber;
  final PaymentMethod paymentMethod;
  final String? paymentReference;
  final String? notes;
  final DateTime createdAt;

  const Bill({
    required this.id,
    required this.billNumber,
    required this.type,
    this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.lotId,
    required this.lotNumber,
    required this.productName,
    required this.date,
    required this.quantity,
    required this.weight,
    required this.unit,
    required this.sellRate,
    required this.grossAmount,
    this.labourCharge = 0.0,
    this.transportFee = 0.0,
    this.mandiFee = 0.0,
    this.otherCharges = 0.0,
    this.discount = 0.0,
    required this.totalAmount,
    required this.amountReceived,
    required this.balanceDue,
    required this.status,
    this.cancellationReason,
    this.cancelledAt,
    this.bagItems = const [],
    this.items = const [],
    this.extraCharges = const [],
    this.sellerName,
    this.sellerPhone,
    this.village,
    this.lotRefNumber,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentReference,
    this.notes,
    required this.createdAt,
  });

  bool get isPaid => status == BillStatus.paid;
  bool get isCancelled => status == BillStatus.cancelled;

  List<BillItem> get allItems {
    if (items.isNotEmpty) return items;
    return [
      BillItem(
        id: 'item_1',
        lotId: lotId,
        lotNumber: lotNumber,
        productName: productName,
        quantity: quantity,
        weight: weight,
        unit: unit,
        sellRate: sellRate,
        grossAmount: grossAmount,
        bagItems: bagItems,
      ),
    ];
  }

  Bill copyWith({
    String? id,
    String? billNumber,
    BillType? type,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? lotId,
    String? lotNumber,
    String? productName,
    DateTime? date,
    double? quantity,
    double? weight,
    String? unit,
    double? sellRate,
    double? grossAmount,
    double? labourCharge,
    double? transportFee,
    double? mandiFee,
    double? otherCharges,
    double? discount,
    double? totalAmount,
    double? amountReceived,
    double? balanceDue,
    BillStatus? status,
    String? cancellationReason,
    DateTime? cancelledAt,
    List<BillBagItem>? bagItems,
    List<BillItem>? items,
    List<BillExtraCharge>? extraCharges,
    String? sellerName,
    String? sellerPhone,
    String? village,
    String? lotRefNumber,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    String? notes,
    DateTime? createdAt,
  }) {
    return Bill(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      type: type ?? this.type,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      lotId: lotId ?? this.lotId,
      lotNumber: lotNumber ?? this.lotNumber,
      productName: productName ?? this.productName,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      sellRate: sellRate ?? this.sellRate,
      grossAmount: grossAmount ?? this.grossAmount,
      labourCharge: labourCharge ?? this.labourCharge,
      transportFee: transportFee ?? this.transportFee,
      mandiFee: mandiFee ?? this.mandiFee,
      otherCharges: otherCharges ?? this.otherCharges,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      amountReceived: amountReceived ?? this.amountReceived,
      balanceDue: balanceDue ?? this.balanceDue,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      bagItems: bagItems ?? this.bagItems,
      items: items ?? this.items,
      extraCharges: extraCharges ?? this.extraCharges,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      village: village ?? this.village,
      lotRefNumber: lotRefNumber ?? this.lotRefNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
