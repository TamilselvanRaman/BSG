enum SellerLoadStatus {
  arrived,
  unloading,
  partiallySold,
  completed,
}

class SellerLoad {
  final String id;
  final String loadNumber; // e.g. LOAD-2026-001 or Aditya-578
  final String lotNumber; // e.g. Aditya-578, Selvam-582, Ravi-6
  final String sellerId; // Farmer / Supplier Customer ID
  final String sellerName; // e.g. Aditya - Aditya, Selvam - Selvam
  final String farmerCode; // e.g. 134277, 134194
  final String village;
  final String phone;
  final String vehicleNumber; // e.g. TN36Av8530, TN52AA4487
  final String commodity; // e.g. Onion, Tomato
  final String varietyGrade; // e.g. A(3), S(4), Gw(1)
  final int totalBags; // e.g. 50
  final double unsoldBags; // e.g. 432.0 BG
  final double soldBags; // e.g. 146.0 BG
  final double grossWeight; // e.g. 1250 kg
  final double advancePaidToSeller; // e.g. 5000.0
  final double commissionPercent; // e.g. 5.0%
  final String notes;
  final SellerLoadStatus status;
  final DateTime arrivalDate;
  final DateTime createdAt;

  const SellerLoad({
    required this.id,
    required this.loadNumber,
    this.lotNumber = '',
    required this.sellerId,
    required this.sellerName,
    this.farmerCode = '134000',
    required this.village,
    required this.phone,
    required this.vehicleNumber,
    required this.commodity,
    this.varietyGrade = 'A-Grade',
    required this.totalBags,
    this.unsoldBags = 0.0,
    this.soldBags = 0.0,
    required this.grossWeight,
    this.advancePaidToSeller = 0.0,
    this.commissionPercent = 5.0,
    this.notes = '',
    this.status = SellerLoadStatus.arrived,
    required this.arrivalDate,
    required this.createdAt,
  });

  String get effectiveLotNumber => lotNumber.isNotEmpty ? lotNumber : loadNumber;

  String get maskedPhone {
    if (phone.length >= 4) {
      final last4 = phone.substring(phone.length - 4);
      return 'XXXXXX$last4';
    }
    return phone;
  }

  String get statusLabel {
    switch (status) {
      case SellerLoadStatus.arrived:
        return 'Arrived';
      case SellerLoadStatus.unloading:
        return 'Unloading';
      case SellerLoadStatus.partiallySold:
        return 'Partially Sold';
      case SellerLoadStatus.completed:
        return 'Settled / Sold';
    }
  }

  SellerLoad copyWith({
    String? id,
    String? loadNumber,
    String? lotNumber,
    String? sellerId,
    String? sellerName,
    String? farmerCode,
    String? village,
    String? phone,
    String? vehicleNumber,
    String? commodity,
    String? varietyGrade,
    int? totalBags,
    double? unsoldBags,
    double? soldBags,
    double? grossWeight,
    double? advancePaidToSeller,
    double? commissionPercent,
    String? notes,
    SellerLoadStatus? status,
    DateTime? arrivalDate,
    DateTime? createdAt,
  }) {
    return SellerLoad(
      id: id ?? this.id,
      loadNumber: loadNumber ?? this.loadNumber,
      lotNumber: lotNumber ?? this.lotNumber,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      farmerCode: farmerCode ?? this.farmerCode,
      village: village ?? this.village,
      phone: phone ?? this.phone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      commodity: commodity ?? this.commodity,
      varietyGrade: varietyGrade ?? this.varietyGrade,
      totalBags: totalBags ?? this.totalBags,
      unsoldBags: unsoldBags ?? this.unsoldBags,
      soldBags: soldBags ?? this.soldBags,
      grossWeight: grossWeight ?? this.grossWeight,
      advancePaidToSeller: advancePaidToSeller ?? this.advancePaidToSeller,
      commissionPercent: commissionPercent ?? this.commissionPercent,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
