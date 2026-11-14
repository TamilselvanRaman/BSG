enum TallyPaymentMode {
  cash,
  gpay1,
  gpay2,
  bankTransfer,
}

extension TallyPaymentModeExt on TallyPaymentMode {
  String get displayName {
    switch (this) {
      case TallyPaymentMode.cash:
        return 'Cash';
      case TallyPaymentMode.gpay1:
        return 'GPay 1';
      case TallyPaymentMode.gpay2:
        return 'GPay 2';
      case TallyPaymentMode.bankTransfer:
        return 'Bank Transfer';
    }
  }
}

class TallyPartyPayment {
  final String id;
  final String partyName;
  final double amount;
  final TallyPaymentMode mode;
  final String? reference;

  const TallyPartyPayment({
    required this.id,
    required this.partyName,
    required this.amount,
    this.mode = TallyPaymentMode.cash,
    this.reference,
  });

  bool get isCash => mode == TallyPaymentMode.cash;

  Map<String, dynamic> toJson() => {
        'id': id,
        'partyName': partyName,
        'amount': amount,
        'mode': mode.name,
        'reference': reference,
      };

  factory TallyPartyPayment.fromJson(Map<String, dynamic> json) => TallyPartyPayment(
        id: json['id'] as String? ?? '',
        partyName: json['partyName'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        mode: json['mode'] == 'bankTransfer'
            ? TallyPaymentMode.bankTransfer
            : json['mode'] == 'gpay1'
                ? TallyPaymentMode.gpay1
                : json['mode'] == 'gpay2'
                    ? TallyPaymentMode.gpay2
                    : TallyPaymentMode.cash,
        reference: json['reference'] as String?,
      );
}

class DailyTally {
  final String id;
  final String tallyNumber;
  final DateTime date;
  final double openingCash; // Yesterday's closing cash

  // Cash Receipts
  final double cashSales;
  final double outstandingReceived;
  final double otherCashReceived;
  final double gpay1Received;
  final double gpay2Received;

  // Expenses Breakdown
  final double labourExpense;
  final double transportExpense;
  final double rentExpense;
  final double utilitiesExpense;
  final double teaRefreshmentsExpense;
  final double otherExpense;

  // Party Payments
  final List<TallyPartyPayment> partyPayments;

  // Other Transactions
  final double bankDeposit;
  final double otherCashInflow;
  final double otherCashOutflow;

  // Cash Verification
  final double actualCashCounted;
  final double pettyCashInHand;
  final String? notes;
  final DateTime createdAt;

  const DailyTally({
    required this.id,
    required this.tallyNumber,
    required this.date,
    required this.openingCash,
    this.cashSales = 0.0,
    this.outstandingReceived = 0.0,
    this.otherCashReceived = 0.0,
    this.gpay1Received = 0.0,
    this.gpay2Received = 0.0,
    this.labourExpense = 0.0,
    this.transportExpense = 0.0,
    this.rentExpense = 0.0,
    this.utilitiesExpense = 0.0,
    this.teaRefreshmentsExpense = 0.0,
    this.otherExpense = 0.0,
    this.partyPayments = const [],
    this.bankDeposit = 0.0,
    this.otherCashInflow = 0.0,
    this.otherCashOutflow = 0.0,
    required this.actualCashCounted,
    this.pettyCashInHand = 0.0,
    this.notes,
    required this.createdAt,
  });

  // Automatic Mathematical Formulas
  double get totalAvailableCash =>
      openingCash + cashSales + outstandingReceived + otherCashReceived + otherCashInflow;

  double get totalCashExpenses =>
      labourExpense +
      transportExpense +
      rentExpense +
      utilitiesExpense +
      teaRefreshmentsExpense +
      otherExpense;

  double get totalCashPartyPayments =>
      partyPayments.where((p) => p.isCash).fold(0.0, (acc, p) => acc + p.amount);

  double get totalDigitalPartyPayments =>
      partyPayments.where((p) => !p.isCash).fold(0.0, (acc, p) => acc + p.amount);

  double get expectedClosingCash =>
      totalAvailableCash -
      totalCashExpenses -
      totalCashPartyPayments -
      bankDeposit -
      otherCashOutflow;

  double get cashDifference => actualCashCounted - expectedClosingCash;

  double get totalDigitalReceived => gpay1Received + gpay2Received;

  bool get isBalanced => cashDifference.abs() < 0.01;
  bool get isSurplus => cashDifference >= 0.01;
  bool get isShortage => cashDifference <= -0.01;

  DailyTally copyWith({
    String? id,
    String? tallyNumber,
    DateTime? date,
    double? openingCash,
    double? cashSales,
    double? outstandingReceived,
    double? otherCashReceived,
    double? gpay1Received,
    double? gpay2Received,
    double? labourExpense,
    double? transportExpense,
    double? rentExpense,
    double? utilitiesExpense,
    double? teaRefreshmentsExpense,
    double? otherExpense,
    List<TallyPartyPayment>? partyPayments,
    double? bankDeposit,
    double? otherCashInflow,
    double? otherCashOutflow,
    double? actualCashCounted,
    double? pettyCashInHand,
    String? notes,
    DateTime? createdAt,
  }) {
    return DailyTally(
      id: id ?? this.id,
      tallyNumber: tallyNumber ?? this.tallyNumber,
      date: date ?? this.date,
      openingCash: openingCash ?? this.openingCash,
      cashSales: cashSales ?? this.cashSales,
      outstandingReceived: outstandingReceived ?? this.outstandingReceived,
      otherCashReceived: otherCashReceived ?? this.otherCashReceived,
      gpay1Received: gpay1Received ?? this.gpay1Received,
      gpay2Received: gpay2Received ?? this.gpay2Received,
      labourExpense: labourExpense ?? this.labourExpense,
      transportExpense: transportExpense ?? this.transportExpense,
      rentExpense: rentExpense ?? this.rentExpense,
      utilitiesExpense: utilitiesExpense ?? this.utilitiesExpense,
      teaRefreshmentsExpense:
          teaRefreshmentsExpense ?? this.teaRefreshmentsExpense,
      otherExpense: otherExpense ?? this.otherExpense,
      partyPayments: partyPayments ?? this.partyPayments,
      bankDeposit: bankDeposit ?? this.bankDeposit,
      otherCashInflow: otherCashInflow ?? this.otherCashInflow,
      otherCashOutflow: otherCashOutflow ?? this.otherCashOutflow,
      actualCashCounted: actualCashCounted ?? this.actualCashCounted,
      pettyCashInHand: pettyCashInHand ?? this.pettyCashInHand,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

