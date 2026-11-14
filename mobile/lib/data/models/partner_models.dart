/// Partner model representing a Supplier (formerly Seller)
class Supplier {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final String? city;
  final String? entryPrefix;
  final double openingBalance;
  final double currentBalance;
  final DateTime createdAt;

  const Supplier({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.city,
    this.entryPrefix,
    this.openingBalance = 0.0,
    this.currentBalance = 0.0,
    required this.createdAt,
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? entryPrefix,
    double? openingBalance,
    double? currentBalance,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      entryPrefix: entryPrefix ?? this.entryPrefix,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Partner model representing a Customer (formerly Buyer)
class Customer {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final String? city;
  final double openingBalance;
  final double currentOutstanding;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.city,
    this.openingBalance = 0.0,
    this.currentOutstanding = 0.0,
    required this.createdAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? city,
    double? openingBalance,
    double? currentOutstanding,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      openingBalance: openingBalance ?? this.openingBalance,
      currentOutstanding: currentOutstanding ?? this.currentOutstanding,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Partner model representing a Transporter
class Transporter {
  final String id;
  final String name;
  final String phone;
  final String? vehicleNumber;
  final String? notes;
  final DateTime createdAt;

  const Transporter({
    required this.id,
    required this.name,
    required this.phone,
    this.vehicleNumber,
    this.notes,
    required this.createdAt,
  });

  Transporter copyWith({
    String? id,
    String? name,
    String? phone,
    String? vehicleNumber,
    String? notes,
    DateTime? createdAt,
  }) {
    return Transporter(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Customer ledger line item representing a chronological transaction
class CustomerLedgerEntry {
  final DateTime date;
  final String description;
  final String refNumber;
  final double debit; // Increases customer due (e.g. Credit bill)
  final double credit; // Decreases customer due (e.g. Payment received)
  final double runningBalance;

  const CustomerLedgerEntry({
    required this.date,
    required this.description,
    required this.refNumber,
    required this.debit,
    required this.credit,
    required this.runningBalance,
  });
}

/// Supplier ledger line item
class SupplierLedgerEntry {
  final DateTime date;
  final String description;
  final String refNumber;
  final double credit; // Increases payable to supplier (e.g. Lot inwards)
  final double debit; // Decreases payable (e.g. Payout)
  final double runningBalance;

  const SupplierLedgerEntry({
    required this.date,
    required this.description,
    required this.refNumber,
    required this.credit,
    required this.debit,
    required this.runningBalance,
  });
}

/// Stock summary representation for Phase 13
class StockSummaryItem {
  final String productName;
  final double totalInwardQuantity;
  final double remainingQuantity;
  final double soldQuantity;
  final String unit;
  final int activeLotsCount;

  const StockSummaryItem({
    required this.productName,
    required this.totalInwardQuantity,
    required this.remainingQuantity,
    required this.soldQuantity,
    required this.unit,
    required this.activeLotsCount,
  });
}
