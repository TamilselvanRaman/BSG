enum LotExpenseCalcType {
  fixed,
  perBag,
  perKg,
}

enum LotExpenseFieldType {
  amount,
  number,
  text,
}

class LotExpenseConfig {
  final String id;
  final String name;
  final String? tamilName;
  final LotExpenseFieldType fieldType;
  final LotExpenseCalcType calcType;
  final double defaultAmount;
  final bool isRequired;
  final bool isActive;
  final int order;

  const LotExpenseConfig({
    required this.id,
    required this.name,
    this.tamilName,
    this.fieldType = LotExpenseFieldType.amount,
    this.calcType = LotExpenseCalcType.fixed,
    this.defaultAmount = 0.0,
    this.isRequired = false,
    this.isActive = true,
    this.order = 0,
  });

  String get calcTypeLabel {
    switch (calcType) {
      case LotExpenseCalcType.fixed:
        return 'Fixed Amount';
      case LotExpenseCalcType.perBag:
        return 'Per Bag';
      case LotExpenseCalcType.perKg:
        return 'Per Kg';
    }
  }

  double calculateAmount({required int bagCount, required double netWeight, double? enteredRate}) {
    final rate = enteredRate ?? defaultAmount;
    switch (calcType) {
      case LotExpenseCalcType.fixed:
        return rate;
      case LotExpenseCalcType.perBag:
        return rate * bagCount;
      case LotExpenseCalcType.perKg:
        return rate * netWeight;
    }
  }

  LotExpenseConfig copyWith({
    String? id,
    String? name,
    String? tamilName,
    LotExpenseFieldType? fieldType,
    LotExpenseCalcType? calcType,
    double? defaultAmount,
    bool? isRequired,
    bool? isActive,
    int? order,
  }) {
    return LotExpenseConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      tamilName: tamilName ?? this.tamilName,
      fieldType: fieldType ?? this.fieldType,
      calcType: calcType ?? this.calcType,
      defaultAmount: defaultAmount ?? this.defaultAmount,
      isRequired: isRequired ?? this.isRequired,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }
}

