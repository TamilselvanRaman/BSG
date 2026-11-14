import '../../../data/models/bill_model.dart';

enum PricingMode {
  common,
  individual,
}

class BagRowCalculation {
  final int serialNumber;
  final double weight;
  final double rate;
  final double amount;

  const BagRowCalculation({
    required this.serialNumber,
    required this.weight,
    required this.rate,
    required this.amount,
  });

  BagRowCalculation copyWith({
    int? serialNumber,
    double? weight,
    double? rate,
  }) {
    final w = weight ?? this.weight;
    final r = rate ?? this.rate;
    // Decimal-safe rounded to 2 decimal places
    final a = double.parse((w * r).toStringAsFixed(2));
    return BagRowCalculation(
      serialNumber: serialNumber ?? this.serialNumber,
      weight: w,
      rate: r,
      amount: a,
    );
  }

  BillBagItem toBillBagItem() => BillBagItem(
        serialNumber: serialNumber,
        weight: weight,
        rate: rate,
        amount: amount,
      );
}

class BillCalculationResult {
  final List<BagRowCalculation> bags;
  final int totalBags;
  final double totalWeight;
  final double averageBagWeight;
  final double goodsAmount;
  final double transportFee;
  final double labourFee;
  final double mandiFee;
  final double totalExtraCharges;
  final double totalCharges;
  final double grandTotal;

  const BillCalculationResult({
    required this.bags,
    required this.totalBags,
    required this.totalWeight,
    required this.averageBagWeight,
    required this.goodsAmount,
    required this.transportFee,
    required this.labourFee,
    required this.mandiFee,
    required this.totalExtraCharges,
    required this.totalCharges,
    required this.grandTotal,
  });

  factory BillCalculationResult.empty() => const BillCalculationResult(
        bags: [],
        totalBags: 0,
        totalWeight: 0.0,
        averageBagWeight: 0.0,
        goodsAmount: 0.0,
        transportFee: 0.0,
        labourFee: 0.0,
        mandiFee: 0.0,
        totalExtraCharges: 0.0,
        totalCharges: 0.0,
        grandTotal: 0.0,
      );
}

/// Centralized Bill Calculation Engine
/// Ensures exact decimal-safe financial calculations and no duplication across screens.
class BillCalculationEngine {
  /// Calculates bag amount: Individual Weight × Applicable Rate
  static double calculateBagAmount(double weight, double rate) {
    if (weight <= 0 || rate <= 0) return 0.0;
    return double.parse((weight * rate).toStringAsFixed(2));
  }

  /// Generates initial list of bags based on total bag quantity and default values
  static List<BagRowCalculation> generateBagRows({
    required int count,
    double defaultWeight = 50.0,
    double defaultRate = 0.0,
    List<BagRowCalculation>? existingBags,
  }) {
    if (count <= 0) return [];

    final result = <BagRowCalculation>[];

    for (int i = 0; i < count; i++) {
      final serial = i + 1;
      if (existingBags != null && i < existingBags.length) {
        // Preserve existing entered values
        final existing = existingBags[i];
        final rate = defaultRate > 0 && existing.rate == 0 ? defaultRate : existing.rate;
        result.add(BagRowCalculation(
          serialNumber: serial,
          weight: existing.weight,
          rate: rate,
          amount: calculateBagAmount(existing.weight, rate),
        ));
      } else {
        result.add(BagRowCalculation(
          serialNumber: serial,
          weight: defaultWeight,
          rate: defaultRate,
          amount: calculateBagAmount(defaultWeight, defaultRate),
        ));
      }
    }

    return result;
  }

  /// Re-calculates full bill summary with decimal safety
  static BillCalculationResult compute({
    required List<BagRowCalculation> bags,
    required double transportFee,
    required double labourFee,
    required double mandiFee,
    required List<BillExtraCharge> extraCharges,
  }) {
    final totalBags = bags.length;

    // Sum total weight
    double totalWeight = 0.0;
    double goodsAmount = 0.0;

    for (final bag in bags) {
      totalWeight += bag.weight;
      goodsAmount += bag.amount;
    }

    // Decimal rounding
    totalWeight = double.parse(totalWeight.toStringAsFixed(2));
    goodsAmount = double.parse(goodsAmount.toStringAsFixed(2));

    final avgBagWeight = totalBags > 0
        ? double.parse((totalWeight / totalBags).toStringAsFixed(2))
        : 0.0;

    // Extra charges sum
    double totalExtraCharges = 0.0;
    for (final ec in extraCharges) {
      totalExtraCharges += ec.amount;
    }
    totalExtraCharges = double.parse(totalExtraCharges.toStringAsFixed(2));

    final cleanTransport = double.parse(transportFee.toStringAsFixed(2));
    final cleanLabour = double.parse(labourFee.toStringAsFixed(2));
    final cleanMandi = double.parse(mandiFee.toStringAsFixed(2));

    final totalCharges = double.parse(
        (cleanTransport + cleanLabour + cleanMandi + totalExtraCharges).toStringAsFixed(2));

    final grandTotal = double.parse((goodsAmount + totalCharges).toStringAsFixed(2));

    return BillCalculationResult(
      bags: List.unmodifiable(bags),
      totalBags: totalBags,
      totalWeight: totalWeight,
      averageBagWeight: avgBagWeight,
      goodsAmount: goodsAmount,
      transportFee: cleanTransport,
      labourFee: cleanLabour,
      mandiFee: cleanMandi,
      totalExtraCharges: totalExtraCharges,
      totalCharges: totalCharges,
      grandTotal: grandTotal,
    );
  }
}

