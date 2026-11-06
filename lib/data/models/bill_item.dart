class BillItem {
  final String id;
  final String description;
  final double quantity;
  final double weight;
  final double rate;
  final double lineTotal;

  const BillItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.weight,
    required this.rate,
    required this.lineTotal,
  });

  BillItem copyWith({
    String? id,
    String? description,
    double? quantity,
    double? weight,
    double? rate,
    double? lineTotal,
  }) {
    return BillItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      rate: rate ?? this.rate,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }
}
