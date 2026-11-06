enum CustomerType { buyer, seller, both }

class Customer {
  final String id;
  final String name;
  final String village;
  final String phone;
  final CustomerType customerType;
  final double openingBalance;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.village,
    required this.phone,
    required this.customerType,
    this.openingBalance = 0.0,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  String get typeLabel {
    switch (customerType) {
      case CustomerType.buyer:
        return 'Buyer';
      case CustomerType.seller:
        return 'Seller';
      case CustomerType.both:
        return 'Buyer & Seller';
    }
  }

  Customer copyWith({
    String? id,
    String? name,
    String? village,
    String? phone,
    CustomerType? customerType,
    double? openingBalance,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      village: village ?? this.village,
      phone: phone ?? this.phone,
      customerType: customerType ?? this.customerType,
      openingBalance: openingBalance ?? this.openingBalance,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
