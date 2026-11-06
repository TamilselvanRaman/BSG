import 'dart:math';
import 'bill_item.dart';

enum BillStatus { paid, partiallyPaid, unpaid, cancelled }

class Bill {
  final String id;
  final String billNumber;
  final String customerId;
  final String? goodsEntryId;
  final DateTime billDate;
  final List<BillItem> items;
  final double subtotal;
  final double labourCharge;
  final double previousBalanceSnapshot;
  final double initialPaymentApplied;
  final double otherPaymentsApplied;
  final BillStatus status;
  final String cancellationReason;
  final DateTime? cancelledAt;
  final String cancelledBy;
  final DateTime createdAt;

  const Bill({
    required this.id,
    required this.billNumber,
    required this.customerId,
    this.goodsEntryId,
    required this.billDate,
    required this.items,
    required this.subtotal,
    this.labourCharge = 0.0,
    this.previousBalanceSnapshot = 0.0,
    this.initialPaymentApplied = 0.0,
    this.otherPaymentsApplied = 0.0,
    this.status = BillStatus.unpaid,
    this.cancellationReason = '',
    this.cancelledAt,
    this.cancelledBy = '',
    required this.createdAt,
  });

  /// Current Bill Total = Subtotal + Labour Charge
  double get currentBillTotal => subtotal + labourCharge;

  /// Amount Payable = Previous Outstanding Balance + Current Bill Total
  double get amountPayable => previousBalanceSnapshot + currentBillTotal;

  /// Total Amount Paid = Eligible Initial Payment + Other Payments Applied
  double get totalPaymentsApplied => initialPaymentApplied + otherPaymentsApplied;

  /// Remaining Due = Max(0, Amount Payable - Total Payments Applied)
  double get remainingBalance {
    if (status == BillStatus.cancelled) return 0.0;
    return max(0.0, amountPayable - totalPaymentsApplied);
  }

  /// Excess Customer Credit = Max(0, Total Payments Applied - Amount Payable)
  double get excessCredit {
    if (status == BillStatus.cancelled) return totalPaymentsApplied;
    return max(0.0, totalPaymentsApplied - amountPayable);
  }

  String get statusLabel {
    switch (status) {
      case BillStatus.paid:
        return 'Paid';
      case BillStatus.partiallyPaid:
        return 'Partially Paid';
      case BillStatus.unpaid:
        return 'Unpaid';
      case BillStatus.cancelled:
        return 'Cancelled';
    }
  }

  Bill copyWith({
    String? id,
    String? billNumber,
    String? customerId,
    String? goodsEntryId,
    DateTime? billDate,
    List<BillItem>? items,
    double? subtotal,
    double? labourCharge,
    double? previousBalanceSnapshot,
    double? initialPaymentApplied,
    double? otherPaymentsApplied,
    BillStatus? status,
    String? cancellationReason,
    DateTime? cancelledAt,
    String? cancelledBy,
    DateTime? createdAt,
  }) {
    return Bill(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      customerId: customerId ?? this.customerId,
      goodsEntryId: goodsEntryId ?? this.goodsEntryId,
      billDate: billDate ?? this.billDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      labourCharge: labourCharge ?? this.labourCharge,
      previousBalanceSnapshot: previousBalanceSnapshot ?? this.previousBalanceSnapshot,
      initialPaymentApplied: initialPaymentApplied ?? this.initialPaymentApplied,
      otherPaymentsApplied: otherPaymentsApplied ?? this.otherPaymentsApplied,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
