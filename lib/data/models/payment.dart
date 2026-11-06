enum PaymentType { initialAdvance, billPayment, generalAdvance }
enum PaymentStatus { completed, reversed }

class Payment {
  final String id;
  final String customerId;
  final String? goodsEntryId;
  final String? billId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMode; // Cash, UPI, Bank Transfer, Other
  final PaymentType paymentType;
  final String reference;
  final String notes;
  final PaymentStatus status;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.customerId,
    this.goodsEntryId,
    this.billId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    this.paymentType = PaymentType.billPayment,
    this.reference = '',
    this.notes = '',
    this.status = PaymentStatus.completed,
    required this.createdAt,
  });

  String get typeLabel {
    switch (paymentType) {
      case PaymentType.initialAdvance:
        return 'Initial Advance';
      case PaymentType.billPayment:
        return 'Bill Payment';
      case PaymentType.generalAdvance:
        return 'General Advance';
    }
  }

  Payment copyWith({
    String? id,
    String? customerId,
    String? goodsEntryId,
    String? billId,
    double? amount,
    DateTime? paymentDate,
    String? paymentMode,
    PaymentType? paymentType,
    String? reference,
    String? notes,
    PaymentStatus? status,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      goodsEntryId: goodsEntryId ?? this.goodsEntryId,
      billId: billId ?? this.billId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentType: paymentType ?? this.paymentType,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
