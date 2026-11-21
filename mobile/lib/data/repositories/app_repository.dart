import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/partner_models.dart';
import '../models/lot_model.dart';
import '../models/lot_config_model.dart';
import '../models/bill_model.dart';
import '../models/payment_model.dart';
import '../models/expense_model.dart';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../seeds/product_catalog_seed.dart';
import '../../features/reports/models/report_models.dart';
import '../../features/reports/daily_tally/models/daily_tally_model.dart';

/// Central application repository managing state, financial calculations,
/// inventory stock deduction, and ledger consistency.
class AppRepository {
  AppRepository() {
    _seedInitialData();
  }

  final _updateController = StreamController<void>.broadcast();
  Stream<void> get onDataChanged => _updateController.stream;

  AppUser? _currentUser = const AppUser(
    id: 'usr_001',
    name: 'Ramanathan Agro',
    email: 'admin@bsgagro.com',
    phone: '9876543210',
    role: UserRole.admin,
    businessName: 'BSG Trading Corp',
    businessId: 'biz_001',
  );

  final List<Supplier> _suppliers = [];
  final List<Customer> _customers = [];
  final List<Transporter> _transporters = [];
  final List<Lot> _lots = [];
  final List<Bill> _bills = [];
  final List<Payment> _payments = [];
  final List<Expense> _expenses = [];
  final List<Product> _products = [];
  final List<DailyTally> _dailyTallies = [];

  int _lotSeq = 101;
  int _cashBillSeq = 201;
  int _creditBillSeq = 301;
  int _paymentSeq = 401;
  int _expenseSeq = 501;
  int _tallySeq = 101;

  void _notify() {
    _updateController.add(null);
  }

  // --- Auth ---
  AppUser? getCurrentUser() => _currentUser;

  Future<bool> login(String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (phone.isNotEmpty && password.length >= 4) {
      _currentUser = const AppUser(
        id: 'usr_001',
        name: 'Ramanathan Agro',
        email: 'admin@bsgagro.com',
        phone: '9876543210',
        role: UserRole.admin,
        businessName: 'BSG Trading Corp',
        businessId: 'biz_001',
      );
      _notify();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    _notify();
  }

  // --- Suppliers ---
  List<Supplier> getSuppliers() => List.unmodifiable(_suppliers);

  Supplier? getSupplier(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Supplier> addSupplier({
    required String name,
    required String phone,
    String? address,
    String? city,
    double openingBalance = 0.0,
  }) async {
    final supplier = Supplier(
      id: 'sup_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      phone: phone.trim(),
      address: address?.trim(),
      city: city?.trim(),
      openingBalance: openingBalance,
      currentBalance: openingBalance,
      createdAt: DateTime.now(),
    );
    _suppliers.insert(0, supplier);
    _notify();
    return supplier;
  }

  Future<void> updateSupplier(Supplier updated) async {
    final idx = _suppliers.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      _suppliers[idx] = updated;
      _notify();
    }
  }

  /// Generates or retrieves the fixed prefix for a supplier based on name.
  /// Example:
  /// - "Tamil" -> starts with 2 letters: "TA". If available, assigns "TA".
  /// - "Tamilselvan" -> tries 2 letters: "TA". But "TA" is already assigned to "Tamil"!
  ///   So it takes 3 letters: "TAM". If available, assigns "TAM".
  /// - Multi-word: "Sri Murugan Agri Traders" -> "SM".
  /// Once assigned, the prefix is fixed for that supplier.
  String getOrGenerateSupplierPrefix(String supplierId, {String? supplierName}) {
    final supplier = getSupplier(supplierId);
    if (supplier != null && supplier.entryPrefix != null && supplier.entryPrefix!.trim().isNotEmpty) {
      return supplier.entryPrefix!.trim().toUpperCase();
    }

    final rawName = (supplier?.name ?? supplierName ?? '').trim();
    if (rawName.isEmpty) return 'ENT';

    // Existing prefixes assigned to OTHER suppliers
    final existingOtherPrefixes = <String>{};
    for (final s in _suppliers) {
      if (s.id != supplierId && s.entryPrefix != null && s.entryPrefix!.trim().isNotEmpty) {
        existingOtherPrefixes.add(s.entryPrefix!.trim().toUpperCase());
      }
    }
    for (final l in _lots) {
      if (l.supplierId != supplierId && l.entryNumber != null) {
        final parts = l.entryNumber!.split('-');
        if (parts.length >= 2 && parts[0].isNotEmpty) {
          existingOtherPrefixes.add(parts[0].trim().toUpperCase());
        }
      }
    }

    final words = rawName.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    String chosenPrefix = '';

    if (words.length == 1) {
      final clean = words[0].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      if (clean.length < 2) {
        chosenPrefix = clean.padRight(2, 'X');
      } else {
        // Try 2 letters first (e.g. Tamil -> TA)
        final p2 = clean.substring(0, 2);
        if (!existingOtherPrefixes.contains(p2)) {
          chosenPrefix = p2;
        } else if (clean.length >= 3) {
          // If 2 letters is taken by another user, take 3 letters (e.g. Tamilselvan -> TAM)
          final p3 = clean.substring(0, 3);
          if (!existingOtherPrefixes.contains(p3)) {
            chosenPrefix = p3;
          } else if (clean.length >= 4) {
            final p4 = clean.substring(0, 4);
            chosenPrefix = existingOtherPrefixes.contains(p4) ? '$p3${clean[clean.length - 1]}' : p4;
          } else {
            chosenPrefix = '$p3${_suppliers.length + 1}';
          }
        } else {
          chosenPrefix = '$p2${_suppliers.length + 1}';
        }
      }
    } else {
      // Multi-word name, e.g. "Sri Murugan Agri Traders" -> "SM"
      final initials2 = words.take(2).map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase()).where((w) => w.isNotEmpty).map((w) => w[0]).join();
      final firstWordClean = words[0].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      final pFirst2 = firstWordClean.length >= 2 ? firstWordClean.substring(0, 2) : '';

      if (initials2.length >= 2 && !existingOtherPrefixes.contains(initials2)) {
        chosenPrefix = initials2;
      } else if (pFirst2.isNotEmpty && !existingOtherPrefixes.contains(pFirst2)) {
        chosenPrefix = pFirst2;
      } else if (words.length >= 3) {
        final initials3 = words.take(3).map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase()).where((w) => w.isNotEmpty).map((w) => w[0]).join();
        if (!existingOtherPrefixes.contains(initials3)) {
          chosenPrefix = initials3;
        }
      }

      if (chosenPrefix.isEmpty) {
        final pFirst3 = firstWordClean.length >= 3 ? firstWordClean.substring(0, 3) : firstWordClean;
        chosenPrefix = !existingOtherPrefixes.contains(pFirst3) ? pFirst3 : '$initials2${_suppliers.length + 1}';
      }
    }

    // Once created/assigned, fix this prefix to the supplier so it remains constant
    if (supplier != null) {
      final updated = supplier.copyWith(entryPrefix: chosenPrefix);
      final idx = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (idx != -1) {
        _suppliers[idx] = updated;
      }
    }

    return chosenPrefix;
  }

  /// Calculates the next sequential entry number for the given supplier.
  /// Example:
  /// If Tamil has prefix 'TA', and no previous lot: 'TA-001'.
  /// Next time Tamil creates a lot: 'TA-002'.
  /// For Tamilselvan with prefix 'TAM': 'TAM-001', then 'TAM-002'.
  String getNextEntryNumberForSupplier(String supplierId, {String? supplierName}) {
    final prefix = getOrGenerateSupplierPrefix(supplierId, supplierName: supplierName);

    int maxSeq = 0;
    final pattern = RegExp('^${RegExp.escape(prefix)}-(\\d+)\$', caseSensitive: false);

    for (final lot in _lots) {
      if (lot.entryNumber != null) {
        final match = pattern.firstMatch(lot.entryNumber!.trim());
        if (match != null) {
          final numVal = int.tryParse(match.group(1) ?? '0') ?? 0;
          if (numVal > maxSeq) {
            maxSeq = numVal;
          }
        }
      }
    }

    final nextSeq = maxSeq + 1;
    final formattedSeq = nextSeq.toString().padLeft(3, '0');
    return '$prefix-$formattedSeq';
  }

  /// Manually set or update the fixed prefix for a supplier
  Future<void> updateSupplierPrefix(String supplierId, String prefix) async {
    final supplier = getSupplier(supplierId);
    if (supplier != null) {
      await updateSupplier(supplier.copyWith(entryPrefix: prefix.trim().toUpperCase()));
    }
  }

  // --- Customers ---
  List<Customer> getCustomers() => List.unmodifiable(_customers);

  Customer? getCustomer(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Customer> addCustomer({
    required String name,
    required String phone,
    String? address,
    String? city,
    double openingBalance = 0.0,
  }) async {
    final customer = Customer(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      phone: phone.trim(),
      address: address?.trim(),
      city: city?.trim(),
      openingBalance: openingBalance,
      currentOutstanding: openingBalance,
      createdAt: DateTime.now(),
    );
    _customers.insert(0, customer);
    _notify();
    return customer;
  }

  Future<void> updateCustomer(Customer updated) async {
    final idx = _customers.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      _customers[idx] = updated;
      _notify();
    }
  }

  // --- Transporters ---
  List<Transporter> getTransporters() => List.unmodifiable(_transporters);

  Future<Transporter> addTransporter({
    required String name,
    required String phone,
    String? vehicleNumber,
    String? notes,
  }) async {
    final transporter = Transporter(
      id: 'trans_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      phone: phone.trim(),
      vehicleNumber: vehicleNumber?.trim(),
      notes: notes?.trim(),
      createdAt: DateTime.now(),
    );
    _transporters.insert(0, transporter);
    _notify();
    return transporter;
  }

  // --- Lots ---
  List<Lot> getLots() => List.unmodifiable(_lots);

  Lot? getLot(String id) {
    try {
      return _lots.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Lot> createLot({
    required String supplierId,
    required String supplierName,
    required DateTime date,
    String? entryNumber,
    String? vehicleNumber,
    required String productName,
    required int goodsCount,
    required double quantity,
    required double weight,
    String unit = 'Kg',
    required double costRate,
    double labourCharge = 0.0,
    double transportCharge = 0.0,
    double otherCharges = 0.0,
    List<LotItem> items = const [],
  }) async {
    final lotNumber = 'LOT-2026-$_lotSeq';
    _lotSeq++;

    final lot = Lot(
      id: 'lot_${DateTime.now().millisecondsSinceEpoch}',
      lotNumber: lotNumber,
      supplierId: supplierId,
      supplierName: supplierName,
      date: date,
      entryNumber: entryNumber,
      vehicleNumber: vehicleNumber,
      productName: productName,
      goodsCount: goodsCount,
      initialQuantity: quantity,
      remainingQuantity: quantity,
      initialWeight: weight,
      remainingWeight: weight,
      unit: unit,
      costRate: costRate,
      labourCharge: labourCharge,
      transportCharge: transportCharge,
      otherCharges: otherCharges,
      status: LotStatus.active,
      items: items,
      createdAt: DateTime.now(),
    );

    _lots.insert(0, lot);
    _notify();
    return lot;
  }

  Future<Lot> updateLot(Lot updatedLot) async {
    final index = _lots.indexWhere((l) => l.id == updatedLot.id);
    if (index != -1) {
      _lots[index] = updatedLot;
      _notify();
    }
    return updatedLot;
  }

  Future<bool> deleteLot(String id) async {
    final index = _lots.indexWhere((l) => l.id == id);
    if (index != -1) {
      _lots.removeAt(index);
      _notify();
      return true;
    }
    return false;
  }

  // --- Lot Expense Configurations ---
  final List<LotExpenseConfig> _lotExpenseConfigs = [
    const LotExpenseConfig(
      id: 'exp_labour',
      name: 'Labour Charge',
      tamilName: 'கூலி',
      fieldType: LotExpenseFieldType.amount,
      calcType: LotExpenseCalcType.fixed,
      defaultAmount: 0.0,
      isRequired: false,
      isActive: true,
      order: 0,
    ),
    const LotExpenseConfig(
      id: 'exp_sangam',
      name: 'Sangam Charge',
      tamilName: 'சங்கம்',
      fieldType: LotExpenseFieldType.amount,
      calcType: LotExpenseCalcType.fixed,
      defaultAmount: 0.0,
      isRequired: false,
      isActive: true,
      order: 1,
    ),
    const LotExpenseConfig(
      id: 'exp_rent',
      name: 'Rent / Mandi',
      tamilName: 'வாடகை',
      fieldType: LotExpenseFieldType.amount,
      calcType: LotExpenseCalcType.fixed,
      defaultAmount: 0.0,
      isRequired: false,
      isActive: true,
      order: 2,
    ),
    const LotExpenseConfig(
      id: 'exp_mamool',
      name: 'Mamool Charge',
      tamilName: 'மாமூல்',
      fieldType: LotExpenseFieldType.amount,
      calcType: LotExpenseCalcType.fixed,
      defaultAmount: 0.0,
      isRequired: false,
      isActive: true,
      order: 3,
    ),
    const LotExpenseConfig(
      id: 'exp_transport',
      name: 'Transport Charge',
      tamilName: 'ஏற்றுக்கூலி',
      fieldType: LotExpenseFieldType.amount,
      calcType: LotExpenseCalcType.fixed,
      defaultAmount: 0.0,
      isRequired: false,
      isActive: true,
      order: 4,
    ),
    const LotExpenseConfig(
      id: 'exp_other',
      name: 'Other Charges',
      tamilName: 'இதர செலவுகள்',
      fieldType: LotExpenseFieldType.amount,
      calcType: LotExpenseCalcType.fixed,
      defaultAmount: 0.0,
      isRequired: false,
      isActive: true,
      order: 5,
    ),
  ];

  List<LotExpenseConfig> getLotExpenseConfigs({bool activeOnly = false}) {
    if (activeOnly) {
      return List.unmodifiable(_lotExpenseConfigs.where((e) => e.isActive));
    }
    return List.unmodifiable(_lotExpenseConfigs);
  }

  Future<LotExpenseConfig> addLotExpenseConfig({
    required String name,
    String? tamilName,
    LotExpenseFieldType fieldType = LotExpenseFieldType.amount,
    LotExpenseCalcType calcType = LotExpenseCalcType.fixed,
    double defaultAmount = 0.0,
    bool isRequired = false,
  }) async {
    final config = LotExpenseConfig(
      id: 'cfg_exp_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      tamilName: tamilName?.trim(),
      fieldType: fieldType,
      calcType: calcType,
      defaultAmount: defaultAmount,
      isRequired: isRequired,
      isActive: true,
      order: _lotExpenseConfigs.length,
    );
    _lotExpenseConfigs.add(config);
    _notify();
    return config;
  }

  Future<LotExpenseConfig> updateLotExpenseConfig(LotExpenseConfig updated) async {
    final idx = _lotExpenseConfigs.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _lotExpenseConfigs[idx] = updated;
      _notify();
    }
    return updated;
  }

  Future<bool> deleteLotExpenseConfig(String id) async {
    final idx = _lotExpenseConfigs.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _lotExpenseConfigs.removeAt(idx);
      _notify();
      return true;
    }
    return false;
  }

  Future<void> toggleLotExpenseConfig(String id) async {
    final idx = _lotExpenseConfigs.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final current = _lotExpenseConfigs[idx];
      _lotExpenseConfigs[idx] = current.copyWith(isActive: !current.isActive);
      _notify();
    }
  }

  // --- Bills ---
  List<Bill> getBills() => List.unmodifiable(_bills);

  Bill? getBill(String id) {
    try {
      return _bills.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Bill> createCashBill({
    required String lotId,
    String? customerId,
    required String customerName,
    String? customerPhone,
    required DateTime date,
    required double quantity,
    required double weight,
    required double sellRate,
    double labourCharge = 0.0,
    double otherCharges = 0.0,
    double discount = 0.0,
    required double amountReceived,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? paymentReference,
    String? notes,
    List<double>? bagWeights,
    List<BillItem>? items,
    List<BillExtraCharge>? extraCharges,
  }) async {
    final lot = getLot(lotId);
    if (lot == null) throw Exception('Selected lot does not exist');

    final bool hasItems = items != null && items.isNotEmpty;
    if (!hasItems && quantity > lot.remainingQuantity) {
      throw Exception('Requested quantity exceeds available lot quantity');
    }

    final grossAmount = hasItems
        ? items.fold<double>(0.0, (s, it) => s + it.grossAmount)
        : (quantity * sellRate);
    final totalQty = hasItems
        ? items.fold<double>(0.0, (s, it) => s + it.quantity)
        : quantity;
    final totalWt = hasItems
        ? items.fold<double>(0.0, (s, it) => s + it.weight)
        : weight;
    final pName = hasItems
        ? items.map((it) => it.productName).toSet().join(' + ')
        : lot.productName;

    final customChargesSum = extraCharges != null
        ? extraCharges.fold<double>(0.0, (s, c) => s + c.amount)
        : 0.0;
    final totalAmount = grossAmount + labourCharge + otherCharges + customChargesSum - discount;
    final balanceDue = (totalAmount - amountReceived).clamp(0.0, double.infinity);
    final status = balanceDue <= 0 ? BillStatus.paid : BillStatus.partiallyPaid;

    final billNumber = 'CB-2026-$_cashBillSeq';
    _cashBillSeq++;

    final List<BillBagItem> bagItems = (bagWeights != null && bagWeights.isNotEmpty)
        ? [
            for (int i = 0; i < bagWeights.length; i++)
              BillBagItem(
                serialNumber: i + 1,
                weight: bagWeights[i],
                rate: sellRate,
                amount: bagWeights[i] * sellRate,
              ),
          ]
        : (hasItems ? [for (final it in items) ...it.bagItems] : []);

    final bill = Bill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      billNumber: billNumber,
      type: BillType.cash,
      customerId: customerId,
      customerName: customerName.trim(),
      customerPhone: customerPhone?.trim(),
      lotId: lot.id,
      lotNumber: lot.lotNumber,
      productName: pName,
      date: date,
      quantity: totalQty,
      weight: totalWt,
      unit: lot.unit,
      sellRate: sellRate,
      grossAmount: grossAmount,
      labourCharge: labourCharge,
      otherCharges: otherCharges,
      discount: discount,
      totalAmount: totalAmount,
      amountReceived: amountReceived,
      balanceDue: balanceDue,
      status: status,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      notes: notes,
      bagItems: bagItems,
      items: hasItems ? items : const [],
      extraCharges: extraCharges ?? const [],
      createdAt: DateTime.now(),
    );

    // Update lot stock
    if (hasItems) {
      for (final it in items) {
        final itLot = getLot(it.lotId);
        if (itLot != null) _deductLotStock(itLot, it.quantity, it.weight);
      }
    } else {
      _deductLotStock(lot, quantity, weight);
    }
    _bills.insert(0, bill);
    _notify();
    return bill;
  }

  Future<Bill> createLotBasedBill({
    required String lotId,
    required DateTime date,
    BillType type = BillType.cash,
    String? customerId,
    required String customerName,
    String? customerPhone,
    required List<BillBagItem> bagItems,
    double transportFee = 0.0,
    double labourFee = 0.0,
    double mandiFee = 0.0,
    List<BillExtraCharge> extraCharges = const [],
    double discount = 0.0,
    required double amountReceived,
    String? sellerName,
    String? sellerPhone,
    String? village,
    String? lotRefNumber,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? paymentReference,
    String? notes,
  }) async {
    final lot = getLot(lotId);
    if (lot == null) throw Exception('Selected lot does not exist');

    final totalBags = bagItems.length;
    double totalWeight = 0.0;
    double goodsAmount = 0.0;
    for (final bag in bagItems) {
      totalWeight += bag.weight;
      goodsAmount += bag.amount;
    }

    double extraTotal = 0.0;
    for (final ec in extraCharges) {
      extraTotal += ec.amount;
    }

    final totalCharges = transportFee + labourFee + mandiFee + extraTotal;
    final totalAmount = (goodsAmount + totalCharges - discount).clamp(0.0, double.infinity);
    final balanceDue = (totalAmount - amountReceived).clamp(0.0, double.infinity);
    final status = balanceDue <= 0
        ? BillStatus.paid
        : (amountReceived > 0 ? BillStatus.partiallyPaid : BillStatus.unpaid);

    final billSeq = type == BillType.cash ? _cashBillSeq++ : _creditBillSeq++;
    final prefix = type == BillType.cash ? 'CB' : 'CR';
    final billNumber = '$prefix-2026-$billSeq';

    final bill = Bill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      billNumber: billNumber,
      type: type,
      customerId: customerId,
      customerName: customerName.trim().isNotEmpty ? customerName.trim() : 'Counter Cash Buyer',
      customerPhone: customerPhone?.trim(),
      lotId: lot.id,
      lotNumber: lot.lotNumber,
      productName: lot.productName,
      date: date,
      quantity: totalBags.toDouble(),
      weight: totalWeight,
      unit: lot.unit,
      sellRate: totalWeight > 0 ? (goodsAmount / totalWeight) : lot.costRate,
      grossAmount: goodsAmount,
      labourCharge: labourFee,
      transportFee: transportFee,
      mandiFee: mandiFee,
      otherCharges: extraTotal,
      discount: discount,
      totalAmount: totalAmount,
      amountReceived: amountReceived,
      balanceDue: balanceDue,
      status: status,
      bagItems: bagItems,
      extraCharges: extraCharges,
      sellerName: sellerName ?? lot.supplierName,
      sellerPhone: sellerPhone,
      village: village,
      lotRefNumber: lotRefNumber ?? lot.entryNumber,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      notes: notes,
      createdAt: DateTime.now(),
    );

    // Update customer outstanding if credit bill
    if (type == BillType.credit && customerId != null) {
      final customer = getCustomer(customerId);
      if (customer != null) {
        final updatedCustomer = customer.copyWith(
          currentOutstanding: customer.currentOutstanding + balanceDue,
        );
        final cIdx = _customers.indexWhere((c) => c.id == customer.id);
        if (cIdx != -1) _customers[cIdx] = updatedCustomer;
      }
    }

    // Deduct stock from lot
    _deductLotStock(lot, totalBags.toDouble(), totalWeight);
    _bills.insert(0, bill);
    _notify();
    return bill;
  }

  Future<Bill> createCreditBill({
    required String customerId,
    required String lotId,
    required DateTime date,
    required double quantity,
    required double weight,
    required double sellRate,
    double labourCharge = 0.0,
    double otherCharges = 0.0,
    double discount = 0.0,
    double amountReceived = 0.0,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? paymentReference,
    String? notes,
    List<double>? bagWeights,
    List<BillItem>? items,
    List<BillExtraCharge>? extraCharges,
  }) async {
    final customer = getCustomer(customerId);
    if (customer == null) throw Exception('Selected customer does not exist');
    final lot = getLot(lotId);
    if (lot == null) throw Exception('Selected lot does not exist');

    final bool hasItems = items != null && items.isNotEmpty;
    if (!hasItems && quantity > lot.remainingQuantity) {
      throw Exception('Requested quantity exceeds available lot quantity');
    }

    final grossAmount = hasItems
        ? items.fold<double>(0.0, (s, it) => s + it.grossAmount)
        : (quantity * sellRate);
    final totalQty = hasItems
        ? items.fold<double>(0.0, (s, it) => s + it.quantity)
        : quantity;
    final totalWt = hasItems
        ? items.fold<double>(0.0, (s, it) => s + it.weight)
        : weight;
    final pName = hasItems
        ? items.map((it) => it.productName).toSet().join(' + ')
        : lot.productName;

    final customChargesSum = extraCharges != null
        ? extraCharges.fold<double>(0.0, (s, c) => s + c.amount)
        : 0.0;
    final totalAmount = grossAmount + labourCharge + otherCharges + customChargesSum - discount;
    final balanceDue = (totalAmount - amountReceived).clamp(0.0, double.infinity);
    final status = balanceDue <= 0
        ? BillStatus.paid
        : (amountReceived > 0 ? BillStatus.partiallyPaid : BillStatus.unpaid);

    final billNumber = 'CR-2026-$_creditBillSeq';
    _creditBillSeq++;

    final List<BillBagItem> bagItems = (bagWeights != null && bagWeights.isNotEmpty)
        ? [
            for (int i = 0; i < bagWeights.length; i++)
              BillBagItem(
                serialNumber: i + 1,
                weight: bagWeights[i],
                rate: sellRate,
                amount: bagWeights[i] * sellRate,
              ),
          ]
        : (hasItems ? [for (final it in items) ...it.bagItems] : []);

    final bill = Bill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      billNumber: billNumber,
      type: BillType.credit,
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.phone,
      lotId: lot.id,
      lotNumber: lot.lotNumber,
      productName: pName,
      date: date,
      quantity: totalQty,
      weight: totalWt,
      unit: lot.unit,
      sellRate: sellRate,
      grossAmount: grossAmount,
      labourCharge: labourCharge,
      otherCharges: otherCharges,
      discount: discount,
      totalAmount: totalAmount,
      amountReceived: amountReceived,
      balanceDue: balanceDue,
      status: status,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      notes: notes,
      bagItems: bagItems,
      items: hasItems ? items : const [],
      extraCharges: extraCharges ?? const [],
      createdAt: DateTime.now(),
    );

    // Update customer outstanding
    final updatedCustomer = customer.copyWith(
      currentOutstanding: customer.currentOutstanding + balanceDue,
    );
    final cIdx = _customers.indexWhere((c) => c.id == customer.id);
    if (cIdx != -1) _customers[cIdx] = updatedCustomer;

    // Update lot stock
    if (hasItems) {
      for (final it in items) {
        final itLot = getLot(it.lotId);
        if (itLot != null) _deductLotStock(itLot, it.quantity, it.weight);
      }
    } else {
      _deductLotStock(lot, quantity, weight);
    }
    _bills.insert(0, bill);
    _notify();
    return bill;
  }

  void _deductLotStock(Lot lot, double qty, double weight) {
    final newRemainingQty = (lot.remainingQuantity - qty).clamp(0.0, double.infinity);
    final newRemainingWeight = (lot.remainingWeight - weight).clamp(0.0, double.infinity);
    final newStatus = newRemainingQty == 0 ? LotStatus.fullySold : LotStatus.partiallySold;

    final updatedLot = lot.copyWith(
      remainingQuantity: newRemainingQty,
      remainingWeight: newRemainingWeight,
      status: newStatus,
    );

    final lIdx = _lots.indexWhere((l) => l.id == lot.id);
    if (lIdx != -1) _lots[lIdx] = updatedLot;
  }

  Future<void> cancelBill(String billId, String reason) async {
    final bIdx = _bills.indexWhere((b) => b.id == billId);
    if (bIdx == -1) throw Exception('Bill not found');
    final bill = _bills[bIdx];
    if (bill.isCancelled) throw Exception('Bill is already cancelled');

    // Revert lot stock
    if (bill.items.isNotEmpty) {
      for (final it in bill.items) {
        final itLot = getLot(it.lotId);
        if (itLot != null) {
          final restoredQty = itLot.remainingQuantity + it.quantity;
          final restoredWeight = itLot.remainingWeight + it.weight;
          final restoredStatus = restoredQty >= itLot.initialQuantity ? LotStatus.active : LotStatus.partiallySold;
          final updatedLot = itLot.copyWith(
            remainingQuantity: restoredQty,
            remainingWeight: restoredWeight,
            status: restoredStatus,
          );
          final lIdx = _lots.indexWhere((l) => l.id == itLot.id);
          if (lIdx != -1) _lots[lIdx] = updatedLot;
        }
      }
    } else {
      final lot = getLot(bill.lotId);
      if (lot != null) {
        final restoredQty = lot.remainingQuantity + bill.quantity;
        final restoredWeight = lot.remainingWeight + bill.weight;
        final restoredStatus = restoredQty >= lot.initialQuantity ? LotStatus.active : LotStatus.partiallySold;

        final updatedLot = lot.copyWith(
          remainingQuantity: restoredQty,
          remainingWeight: restoredWeight,
          status: restoredStatus,
        );
        final lIdx = _lots.indexWhere((l) => l.id == lot.id);
        if (lIdx != -1) _lots[lIdx] = updatedLot;
      }
    }

    // Revert customer outstanding if credit bill
    if (bill.type == BillType.credit && bill.customerId != null) {
      final customer = getCustomer(bill.customerId!);
      if (customer != null) {
        final newOutstanding = (customer.currentOutstanding - bill.balanceDue).clamp(0.0, double.infinity);
        final cIdx = _customers.indexWhere((c) => c.id == customer.id);
        if (cIdx != -1) {
          _customers[cIdx] = customer.copyWith(currentOutstanding: newOutstanding);
        }
      }
    }

    _bills[bIdx] = bill.copyWith(
      status: BillStatus.cancelled,
      cancellationReason: reason,
      cancelledAt: DateTime.now(),
    );
    _notify();
  }

  Future<void> updateBill(Bill updatedBill) async {
    final bIdx = _bills.indexWhere((b) => b.id == updatedBill.id);
    if (bIdx != -1) {
      _bills[bIdx] = updatedBill;
      _notify();
    }
  }

  // --- Payments / Received Amount ---
  List<Payment> getPayments() => List.unmodifiable(_payments);

  Future<Payment> recordPayment({
    required String customerId,
    required DateTime date,
    required double amount,
    required PaymentMethod method,
    String? referenceNumber,
    String? notes,
    List<PaymentAllocation> allocations = const [],
  }) async {
    final customer = getCustomer(customerId);
    if (customer == null) throw Exception('Customer not found');

    final receiptNumber = 'RCP-2026-$_paymentSeq';
    _paymentSeq++;

    final payment = Payment(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      receiptNumber: receiptNumber,
      customerId: customer.id,
      customerName: customer.name,
      date: date,
      amount: amount,
      method: method,
      referenceNumber: referenceNumber?.trim(),
      notes: notes?.trim(),
      allocations: allocations,
      createdAt: DateTime.now(),
    );

    // Apply allocations to bills
    for (final alloc in allocations) {
      final bIdx = _bills.indexWhere((b) => b.id == alloc.billId);
      if (bIdx != -1) {
        final b = _bills[bIdx];
        final newReceived = b.amountReceived + alloc.allocatedAmount;
        final newBalance = (b.totalAmount - newReceived).clamp(0.0, double.infinity);
        final newStatus = newBalance <= 0 ? BillStatus.paid : BillStatus.partiallyPaid;
        _bills[bIdx] = b.copyWith(
          amountReceived: newReceived,
          balanceDue: newBalance,
          status: newStatus,
        );
      }
    }

    // Update customer outstanding
    final newOutstanding = (customer.currentOutstanding - amount).clamp(0.0, double.infinity);
    final cIdx = _customers.indexWhere((c) => c.id == customer.id);
    if (cIdx != -1) {
      _customers[cIdx] = customer.copyWith(currentOutstanding: newOutstanding);
    }

    _payments.insert(0, payment);
    _notify();
    return payment;
  }

  // --- Expenses ---
  List<Expense> getExpenses() => List.unmodifiable(_expenses);

  Future<Expense> createExpense({
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    ExpensePaymentMethod method = ExpensePaymentMethod.cash,
    String? paidTo,
    String? referenceNumber,
    String? notes,
  }) async {
    final expNumber = 'EXP-2026-$_expenseSeq';
    _expenseSeq++;

    final expense = Expense(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      expenseNumber: expNumber,
      title: title.trim(),
      category: category.trim(),
      amount: amount,
      date: date,
      method: method,
      paidTo: paidTo?.trim(),
      referenceNumber: referenceNumber?.trim(),
      notes: notes?.trim(),
      createdAt: DateTime.now(),
    );

    _expenses.insert(0, expense);
    _notify();
    return expense;
  }

  // --- Customer Ledger ---
  List<CustomerLedgerEntry> getCustomerLedger(String customerId) {
    final customer = getCustomer(customerId);
    if (customer == null) return [];

    final entries = <CustomerLedgerEntry>[];
    double running = customer.openingBalance;

    if (customer.openingBalance > 0) {
      entries.add(CustomerLedgerEntry(
        date: customer.createdAt,
        description: 'Opening Balance',
        refNumber: 'OPEN-BAL',
        debit: customer.openingBalance,
        credit: 0,
        runningBalance: running,
      ));
    }

    // Bills
    final custBills = _bills
        .where((b) => b.customerId == customerId && !b.isCancelled)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final bill in custBills) {
      running += bill.totalAmount;
      entries.add(CustomerLedgerEntry(
        date: bill.date,
        description: 'Credit Sale: ${bill.productName} (${bill.quantity} ${bill.unit})',
        refNumber: bill.billNumber,
        debit: bill.totalAmount,
        credit: 0,
        runningBalance: running,
      ));

      if (bill.amountReceived > 0) {
        running -= bill.amountReceived;
        entries.add(CustomerLedgerEntry(
          date: bill.date,
          description: 'Payment against ${bill.billNumber}',
          refNumber: 'REC-${bill.billNumber}',
          debit: 0,
          credit: bill.amountReceived,
          runningBalance: running,
        ));
      }
    }

    // Direct Payments
    final custPayments = _payments
        .where((p) => p.customerId == customerId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final pay in custPayments) {
      running -= pay.amount;
      entries.add(CustomerLedgerEntry(
        date: pay.date,
        description: 'Payment Received (${pay.method.name.toUpperCase()})',
        refNumber: pay.receiptNumber,
        debit: 0,
        credit: pay.amount,
        runningBalance: running,
      ));
    }

    return entries;
  }

  // --- Supplier Ledger ---
  List<SupplierLedgerEntry> getSupplierLedger(String supplierId) {
    final supplier = getSupplier(supplierId);
    if (supplier == null) return [];

    final entries = <SupplierLedgerEntry>[];
    double running = supplier.openingBalance;

    if (supplier.openingBalance > 0) {
      entries.add(SupplierLedgerEntry(
        date: supplier.createdAt,
        description: 'Opening Balance',
        refNumber: 'OPEN-BAL',
        credit: supplier.openingBalance,
        debit: 0,
        runningBalance: running,
      ));
    }

    final supLots = _lots
        .where((l) => l.supplierId == supplierId && l.status != LotStatus.cancelled)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final lot in supLots) {
      running += lot.totalInitialCost;
      entries.add(SupplierLedgerEntry(
        date: lot.date,
        description: 'Inward Lot: ${lot.productName} (${lot.initialQuantity} ${lot.unit})',
        refNumber: lot.lotNumber,
        credit: lot.totalInitialCost,
        debit: 0,
        runningBalance: running,
      ));
    }

    return entries;
  }

  // --- Stock Summary ---
  List<StockSummaryItem> getStockSummary() {
    final Map<String, List<Lot>> grouped = {};
    for (final lot in _lots) {
      if (lot.status == LotStatus.cancelled) continue;
      grouped.putIfAbsent(lot.productName, () => []).add(lot);
    }

    final summary = <StockSummaryItem>[];
    for (final entry in grouped.entries) {
      final name = entry.key;
      final lots = entry.value;
      double totalInward = 0;
      double remaining = 0;
      String unit = 'Kg';
      int activeCount = 0;

      for (final l in lots) {
        totalInward += l.initialQuantity;
        remaining += l.remainingQuantity;
        unit = l.unit;
        if (l.isAvailable) activeCount++;
      }

      summary.add(StockSummaryItem(
        productName: name,
        totalInwardQuantity: totalInward,
        remainingQuantity: remaining,
        soldQuantity: (totalInward - remaining).clamp(0.0, double.infinity),
        unit: unit,
        activeLotsCount: activeCount,
      ));
    }
    return summary;
  }

  // --- REPORTS MODULE ENGINE ---

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isBetween(DateTime d, DateTime? start, DateTime? end) {
    if (start != null) {
      final s = DateTime(start.year, start.month, start.day);
      if (d.isBefore(s)) return false;
    }
    if (end != null) {
      final e = DateTime(end.year, end.month, end.day, 23, 59, 59);
      if (d.isAfter(e)) return false;
    }
    return true;
  }

  DailySummaryReport getDailySummaryReport(DateTime date) {
    final dayBills = _bills.where((b) => !b.isCancelled && _isSameDay(b.date, date)).toList();
    final dayLots = _lots.where((l) => l.status != LotStatus.cancelled && _isSameDay(l.date, date)).toList();
    final dayPayments = _payments.where((p) => _isSameDay(p.date, date)).toList();
    final dayExpenses = _expenses.where((e) => _isSameDay(e.date, date)).toList();

    // Received Items (Cash collected on bills + Customer payment receipts)
    final receivedItems = <DailyReceivedItem>[];
    for (final b in dayBills) {
      if (b.amountReceived > 0) {
        receivedItems.add(DailyReceivedItem(
          id: 'rec_bill_${b.id}',
          buyerName: b.customerName,
          refNumber: b.billNumber,
          amount: b.amountReceived,
          paymentMode: b.type == BillType.cash ? 'CASH' : 'PARTIAL CREDIT',
          time: b.date,
        ));
      }
    }
    for (final p in dayPayments) {
      receivedItems.add(DailyReceivedItem(
        id: 'rec_pay_${p.id}',
        buyerName: p.customerName,
        refNumber: p.receiptNumber,
        amount: p.amount,
        paymentMode: p.method.name.toUpperCase(),
        time: p.date,
      ));
    }

    // Paid Items (Expenses + Supplier lot inward payments)
    final paidItems = <DailyPaidItem>[];
    for (final e in dayExpenses) {
      paidItems.add(DailyPaidItem(
        id: 'paid_exp_${e.id}',
        sellerName: e.paidTo?.isNotEmpty == true ? e.paidTo! : e.title,
        refNumber: e.expenseNumber,
        amount: e.amount,
        paymentMode: e.method.name.toUpperCase(),
        category: e.category,
        time: e.date,
      ));
    }
    for (final l in dayLots) {
      paidItems.add(DailyPaidItem(
        id: 'paid_lot_${l.id}',
        sellerName: l.supplierName,
        refNumber: l.lotNumber,
        amount: l.totalInitialCost,
        paymentMode: 'INWARD PURCHASE',
        category: 'Goods Purchase',
        time: l.date,
      ));
      if (l.transportCharge > 0) {
        paidItems.add(DailyPaidItem(
          id: 'paid_lot_transp_${l.id}',
          sellerName: '${l.supplierName} (Lot Transport)',
          refNumber: '${l.lotNumber}-TRP',
          amount: l.transportCharge,
          paymentMode: 'CASH / FREIGHT',
          category: 'Transportation',
          time: l.date,
        ));
      }
      if (l.labourCharge > 0) {
        paidItems.add(DailyPaidItem(
          id: 'paid_lot_labour_${l.id}',
          sellerName: '${l.supplierName} (Lot Hamali)',
          refNumber: '${l.lotNumber}-LBR',
          amount: l.labourCharge,
          paymentMode: 'CASH / LABOUR',
          category: 'Labour',
          time: l.date,
        ));
      }
    }
    for (final b in dayBills) {
      if (b.labourCharge > 0) {
        paidItems.add(DailyPaidItem(
          id: 'paid_bill_labour_${b.id}',
          sellerName: '${b.customerName} (Bill Coolie)',
          refNumber: '${b.billNumber}-LBR',
          amount: b.labourCharge,
          paymentMode: 'CASH / HAMALI',
          category: 'Labour',
          time: b.date,
        ));
      }
      if (b.otherCharges > 0) {
        paidItems.add(DailyPaidItem(
          id: 'paid_bill_comm_${b.id}',
          sellerName: '${b.customerName} (Commission / Cess)',
          refNumber: '${b.billNumber}-CMS',
          amount: b.otherCharges,
          paymentMode: 'COMMISSION',
          category: 'Commission',
          time: b.date,
        ));
      }
    }

    final double totalReceived = receivedItems.fold(0.0, (acc, item) => acc + item.amount);
    final double totalPaid = paidItems.fold(0.0, (acc, item) => acc + item.amount);
    final double salesAmount = dayBills.fold(0.0, (acc, b) => acc + b.totalAmount);
    final double purchaseAmount = dayLots.fold(0.0, (acc, l) => acc + l.totalInitialCost);

    // Transportation: Lot transport freight + Transport category expenses
    final double lotTransport = dayLots.fold(0.0, (acc, l) => acc + l.transportCharge);
    final double expTransport = dayExpenses.where((e) => e.category.toLowerCase() == 'transport').fold(0.0, (acc, e) => acc + e.amount);
    final double transportation = lotTransport + expTransport;

    // Total Coolie (Labour): Lot labour + Bill labour + Labour category expenses
    final double lotLabour = dayLots.fold(0.0, (acc, l) => acc + l.labourCharge);
    final double billLabour = dayBills.fold(0.0, (acc, b) => acc + b.labourCharge);
    final double expLabour = dayExpenses.where((e) => e.category.toLowerCase() == 'labour').fold(0.0, (acc, e) => acc + e.amount);
    final double totalCoolie = lotLabour + billLabour + expLabour;

    // Rent
    final double rent = dayExpenses.where((e) => e.category.toLowerCase() == 'rent').fold(0.0, (acc, e) => acc + e.amount);

    // Sales Commission / Handling Fee
    final double salesCommission = dayBills.fold(0.0, (acc, b) => acc + b.otherCharges);

    // Total Operating Expenses for the day
    final double totalExpenses = dayExpenses.fold(0.0, (acc, e) => acc + e.amount);

    return DailySummaryReport(
      date: date,
      totalReceived: totalReceived,
      totalPaid: totalPaid,
      salesAmount: salesAmount,
      salesBillsCount: dayBills.length,
      purchaseAmount: purchaseAmount,
      purchaseLotsCount: dayLots.length,
      transportation: transportation,
      totalCoolie: totalCoolie,
      rent: rent,
      salesCommission: salesCommission,
      totalExpenses: totalExpenses,
      expensesCount: dayExpenses.length,
      receivedItems: receivedItems,
      paidItems: paidItems,
    );
  }

  GrossProfitReport getGrossProfitReport({DateTime? fromDate, DateTime? toDate}) {
    final targetBills = _bills.where((b) => !b.isCancelled && _isBetween(b.date, fromDate, toDate)).toList();

    double totalSales = 0;
    double totalCost = 0;
    final transactions = <TransactionProfitItem>[];
    final Map<String, List<TransactionProfitItem>> byProduct = {};

    for (final b in targetBills) {
      final lot = getLot(b.lotId);
      final costRate = lot?.costRate ?? (b.sellRate * 0.8);
      final salesVal = b.grossAmount;
      final costVal = b.quantity * costRate;
      final profit = salesVal - costVal;

      totalSales += salesVal;
      totalCost += costVal;

      final item = TransactionProfitItem(
        billNumber: b.billNumber,
        date: b.date,
        customerName: b.customerName,
        productName: b.productName,
        quantity: b.quantity,
        unit: b.unit,
        sellRate: b.sellRate,
        costRate: costRate,
        salesValue: salesVal,
        purchaseCost: costVal,
        grossProfit: profit,
      );

      transactions.add(item);
      byProduct.putIfAbsent(b.productName, () => []).add(item);
    }

    final productProfits = <ProductProfitItem>[];
    for (final entry in byProduct.entries) {
      final name = entry.key;
      final items = entry.value;
      double pSales = 0;
      double pCost = 0;
      double pQty = 0;
      String unit = 'Kg';

      for (final t in items) {
        pSales += t.salesValue;
        pCost += t.purchaseCost;
        pQty += t.quantity;
        unit = t.unit;
      }

      final pProfit = pSales - pCost;
      final pMargin = pCost > 0 ? (pProfit / pCost) * 100 : 0.0;

      productProfits.add(ProductProfitItem(
        productName: name,
        quantitySold: pQty,
        unit: unit,
        salesValue: pSales,
        purchaseCost: pCost,
        grossProfit: pProfit,
        profitPercentage: pMargin,
      ));
    }

    final grossProfit = totalSales - totalCost;
    final profitPercentage = totalCost > 0 ? (grossProfit / totalCost) * 100 : 0.0;

    return GrossProfitReport(
      fromDate: fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
      toDate: toDate ?? DateTime.now(),
      totalSalesAmount: totalSales,
      totalPurchaseCost: totalCost,
      grossProfit: grossProfit,
      profitPercentage: profitPercentage,
      productProfits: productProfits,
      transactions: transactions,
    );
  }

  StockReportData getStockReportData({DateTime? fromDate, DateTime? toDate}) {
    final Map<String, List<Lot>> lotsByProduct = {};
    for (final lot in _lots) {
      if (lot.status == LotStatus.cancelled) continue;
      lotsByProduct.putIfAbsent(lot.productName, () => []).add(lot);
    }

    final Map<String, List<Bill>> billsByProduct = {};
    for (final b in _bills) {
      if (b.isCancelled) continue;
      if (!_isBetween(b.date, fromDate, toDate)) continue;
      billsByProduct.putIfAbsent(b.productName, () => []).add(b);
    }

    final products = <StockReportProductItem>[];
    double totalOpen = 0;
    double totalPurchased = 0;
    double totalSold = 0;
    double totalClose = 0;
    double totalValuation = 0;

    for (final entry in lotsByProduct.entries) {
      final name = entry.key;
      final lots = entry.value;
      final bills = billsByProduct[name] ?? [];

      double pInward = 0;
      double pCostSum = 0;
      String unit = 'Kg';
      int activeLots = 0;

      for (final l in lots) {
        if (_isBetween(l.date, fromDate, toDate)) {
          pInward += l.initialQuantity;
          pCostSum += (l.initialQuantity * l.costRate);
        }
        unit = l.unit;
        if (l.isAvailable) activeLots++;
      }

      double pSold = 0;
      for (final b in bills) {
        pSold += b.quantity;
      }

      // Opening stock baseline
      final double pOpen = 0; // Baseline before current inventory records
      final double pClose = (pOpen + pInward - pSold).clamp(0.0, double.infinity);
      final double avgRate = pInward > 0 ? (pCostSum / pInward) : 0;
      final double pValuation = pClose * avgRate;

      totalOpen += pOpen;
      totalPurchased += pInward;
      totalSold += pSold;
      totalClose += pClose;
      totalValuation += pValuation;

      products.add(StockReportProductItem(
        productName: name,
        unit: unit,
        openingStock: pOpen,
        purchasedQuantity: pInward,
        soldQuantity: pSold,
        closingStock: pClose,
        averageRate: avgRate,
        stockValuation: pValuation,
        activeLotsCount: activeLots,
      ));
    }

    // Chronological movements
    final movements = <StockMovementItem>[];
    for (final l in _lots) {
      if (l.status == LotStatus.cancelled) continue;
      if (_isBetween(l.date, fromDate, toDate)) {
        movements.add(StockMovementItem(
          date: l.date,
          refNumber: l.lotNumber,
          type: 'INWARD LOT',
          productName: l.productName,
          quantity: l.initialQuantity,
          unit: l.unit,
          runningStock: l.remainingQuantity,
        ));
      }
    }
    for (final b in _bills) {
      if (b.isCancelled) continue;
      if (_isBetween(b.date, fromDate, toDate)) {
        movements.add(StockMovementItem(
          date: b.date,
          refNumber: b.billNumber,
          type: 'SALES BILL',
          productName: b.productName,
          quantity: b.quantity,
          unit: b.unit,
          runningStock: 0,
        ));
      }
    }
    movements.sort((a, b) => b.date.compareTo(a.date));

    return StockReportData(
      totalOpening: totalOpen,
      totalPurchased: totalPurchased,
      totalSold: totalSold,
      totalClosing: totalClose,
      totalStockValuation: totalValuation,
      products: products,
      movements: movements,
    );
  }

  SalesReportData getSalesReportData({
    DateTime? fromDate,
    DateTime? toDate,
    String? customerId,
    String? productName,
    BillType? type,
  }) {
    final filtered = _bills.where((b) {
      if (b.isCancelled) return false;
      if (!_isBetween(b.date, fromDate, toDate)) return false;
      if (customerId != null && b.customerId != customerId) return false;
      if (productName != null && !b.productName.toLowerCase().contains(productName.toLowerCase())) return false;
      if (type != null && b.type != type) return false;
      return true;
    }).toList();

    double totalSales = 0;
    double totalQty = 0;
    double totalWeight = 0;
    double totalReceived = 0;
    double totalDue = 0;

    final Map<String, List<Bill>> buyerMap = {};
    final Map<String, List<Bill>> cropMap = {};
    final Map<String, List<Bill>> dateMap = {};

    for (final b in filtered) {
      totalSales += b.totalAmount;
      totalQty += b.quantity;
      totalWeight += b.weight;
      totalReceived += b.amountReceived;
      totalDue += b.balanceDue;

      final bKey = b.customerId ?? b.customerName;
      buyerMap.putIfAbsent(bKey, () => []).add(b);
      cropMap.putIfAbsent(b.productName, () => []).add(b);

      final dKey = '${b.date.year}-${b.date.month.toString().padLeft(2, '0')}-${b.date.day.toString().padLeft(2, '0')}';
      dateMap.putIfAbsent(dKey, () => []).add(b);
    }

    final byBuyer = <SalesByBuyerItem>[];
    for (final entry in buyerMap.entries) {
      final bList = entry.value;
      final first = bList.first;
      final bSales = bList.fold(0.0, (acc, b) => acc + b.totalAmount);
      final bRec = bList.fold(0.0, (acc, b) => acc + b.amountReceived);
      final bDue = bList.fold(0.0, (acc, b) => acc + b.balanceDue);

      byBuyer.add(SalesByBuyerItem(
        buyerId: first.customerId ?? entry.key,
        buyerName: first.customerName,
        phone: first.customerPhone ?? '',
        billsCount: bList.length,
        totalSales: bSales,
        amountReceived: bRec,
        balanceDue: bDue,
      ));
    }

    final byCrop = <SalesByCropItem>[];
    for (final entry in cropMap.entries) {
      final name = entry.key;
      final cList = entry.value;
      final cQty = cList.fold(0.0, (acc, b) => acc + b.quantity);
      final cWeight = cList.fold(0.0, (acc, b) => acc + b.weight);
      final cSales = cList.fold(0.0, (acc, b) => acc + b.totalAmount);
      final cAvg = cQty > 0 ? (cSales / cQty) : 0.0;

      byCrop.add(SalesByCropItem(
        cropName: name,
        totalQuantity: cQty,
        totalWeight: cWeight,
        unit: cList.first.unit,
        averageRate: cAvg,
        totalSales: cSales,
      ));
    }

    final byDate = <SalesByDateItem>[];
    for (final entry in dateMap.entries) {
      final dList = entry.value;
      final dCash = dList.where((b) => b.type == BillType.cash).fold(0.0, (acc, b) => acc + b.totalAmount);
      final dCredit = dList.where((b) => b.type == BillType.credit).fold(0.0, (acc, b) => acc + b.totalAmount);

      byDate.add(SalesByDateItem(
        date: dList.first.date,
        billsCount: dList.length,
        cashSales: dCash,
        creditSales: dCredit,
        totalSales: dCash + dCredit,
      ));
    }
    byDate.sort((a, b) => b.date.compareTo(a.date));

    return SalesReportData(
      totalSales: totalSales,
      totalBills: filtered.length,
      totalQuantity: totalQty,
      totalWeight: totalWeight,
      totalReceived: totalReceived,
      totalOutstanding: totalDue,
      byBuyer: byBuyer,
      byCrop: byCrop,
      byDate: byDate,
      bills: filtered,
    );
  }

  PurchaseReportData getPurchaseReportData({
    DateTime? fromDate,
    DateTime? toDate,
    String? supplierId,
    String? productName,
  }) {
    final filtered = _lots.where((l) {
      if (l.status == LotStatus.cancelled) return false;
      if (!_isBetween(l.date, fromDate, toDate)) return false;
      if (supplierId != null && l.supplierId != supplierId) return false;
      if (productName != null && !l.productName.toLowerCase().contains(productName.toLowerCase())) return false;
      return true;
    }).toList();

    double totalCost = 0;
    double totalQty = 0;
    double totalWeight = 0;

    final Map<String, List<Lot>> sellerMap = {};
    final Map<String, List<Lot>> productMap = {};
    final Map<String, List<Lot>> dateMap = {};

    for (final l in filtered) {
      totalCost += l.totalInitialCost;
      totalQty += l.initialQuantity;
      totalWeight += l.initialWeight;

      sellerMap.putIfAbsent(l.supplierId, () => []).add(l);
      productMap.putIfAbsent(l.productName, () => []).add(l);

      final dKey = '${l.date.year}-${l.date.month.toString().padLeft(2, '0')}-${l.date.day.toString().padLeft(2, '0')}';
      dateMap.putIfAbsent(dKey, () => []).add(l);
    }

    final bySeller = <PurchaseBySellerItem>[];
    for (final entry in sellerMap.entries) {
      final sList = entry.value;
      final supplier = getSupplier(entry.key);
      final sCost = sList.fold(0.0, (acc, l) => acc + l.totalInitialCost);

      bySeller.add(PurchaseBySellerItem(
        sellerId: entry.key,
        sellerName: sList.first.supplierName,
        phone: supplier?.phone ?? '',
        lotsCount: sList.length,
        totalPurchase: sCost,
        amountPaid: 0,
        balancePayable: supplier?.currentBalance ?? sCost,
      ));
    }

    final byProduct = <PurchaseByProductItem>[];
    for (final entry in productMap.entries) {
      final name = entry.key;
      final pList = entry.value;
      final pQty = pList.fold(0.0, (acc, l) => acc + l.initialQuantity);
      final pWeight = pList.fold(0.0, (acc, l) => acc + l.initialWeight);
      final pCost = pList.fold(0.0, (acc, l) => acc + l.totalInitialCost);
      final pAvg = pQty > 0 ? (pCost / pQty) : 0.0;

      byProduct.add(PurchaseByProductItem(
        productName: name,
        lotsCount: pList.length,
        totalQuantity: pQty,
        totalWeight: pWeight,
        unit: pList.first.unit,
        averageCostRate: pAvg,
        totalCost: pCost,
      ));
    }

    final byDate = <PurchaseByDateItem>[];
    for (final entry in dateMap.entries) {
      final dList = entry.value;
      final dQty = dList.fold(0.0, (acc, l) => acc + l.initialQuantity);
      final dCost = dList.fold(0.0, (acc, l) => acc + l.totalInitialCost);

      byDate.add(PurchaseByDateItem(
        date: dList.first.date,
        lotsCount: dList.length,
        totalQuantity: dQty,
        totalPurchaseAmount: dCost,
      ));
    }
    byDate.sort((a, b) => b.date.compareTo(a.date));

    return PurchaseReportData(
      totalPurchaseAmount: totalCost,
      totalLots: filtered.length,
      totalQuantity: totalQty,
      totalWeight: totalWeight,
      amountPaid: 0,
      outstandingPayable: totalCost,
      bySeller: bySeller,
      byProduct: byProduct,
      byDate: byDate,
      lots: filtered,
    );
  }

  RmcReportData getRmcReportData({DateTime? fromDate, DateTime? toDate}) {
    final targetBills = _bills.where((b) => !b.isCancelled && _isBetween(b.date, fromDate, toDate)).toList();

    const double rmcRate = 1.0; // 1.0% Mandi Market Committee Cess
    double totalTurnover = 0;
    double totalRmc = 0;

    final transactions = <RmcTransactionItem>[];
    final Map<String, List<RmcTransactionItem>> dateMap = {};

    for (final b in targetBills) {
      final taxable = b.grossAmount;
      final fee = taxable * (rmcRate / 100);

      totalTurnover += taxable;
      totalRmc += fee;

      final item = RmcTransactionItem(
        billNumber: b.billNumber,
        date: b.date,
        partnerName: b.customerName,
        productName: b.productName,
        quantity: b.quantity,
        unit: b.unit,
        taxableAmount: taxable,
        rmcRatePercent: rmcRate,
        rmcAmount: fee,
      );

      transactions.add(item);
      final dKey = '${b.date.year}-${b.date.month.toString().padLeft(2, '0')}-${b.date.day.toString().padLeft(2, '0')}';
      dateMap.putIfAbsent(dKey, () => []).add(item);
    }

    final byDate = <RmcDateItem>[];
    for (final entry in dateMap.entries) {
      final items = entry.value;
      final dTurnover = items.fold(0.0, (acc, it) => acc + it.taxableAmount);
      final dCess = items.fold(0.0, (acc, it) => acc + it.rmcAmount);

      byDate.add(RmcDateItem(
        date: items.first.date,
        transactionsCount: items.length,
        totalTurnover: dTurnover,
        rmcCess: dCess,
      ));
    }
    byDate.sort((a, b) => b.date.compareTo(a.date));

    return RmcReportData(
      totalTaxableTurnover: totalTurnover,
      rmcRatePercent: rmcRate,
      totalRmcFee: totalRmc,
      rmcPaid: 0,
      rmcPending: totalRmc,
      transactions: transactions,
      byDate: byDate,
    );
  }

  // --- Dashboard Summary ---
  DashboardSummary getDashboardSummary() {
    double cashSales = 0;
    double creditSales = 0;

    for (final b in _bills) {
      if (b.isCancelled) continue;
      if (b.type == BillType.cash) {
        cashSales += b.totalAmount;
      } else {
        creditSales += b.totalAmount;
      }
    }

    double received = 0;
    for (final p in _payments) {
      received += p.amount;
    }
    // Also include cash collected directly on cash bills
    for (final b in _bills) {
      if (b.isCancelled) continue;
      if (b.type == BillType.cash) {
        received += b.amountReceived;
      }
    }

    double outstanding = 0;
    for (final c in _customers) {
      outstanding += c.currentOutstanding;
    }

    double totalExp = 0;
    for (final e in _expenses) {
      totalExp += e.amount;
    }

    return DashboardSummary(
      dailyCashSales: cashSales,
      dailyCreditSales: creditSales,
      dailyTotalSales: cashSales + creditSales,
      dailyReceivedAmount: received,
      totalOutstanding: outstanding,
      dailyExpenses: totalExp,
      recentBills: _bills.take(5).toList(),
      recentLots: _lots.take(5).toList(),
      recentPayments: _payments.take(5).toList(),
      recentExpenses: _expenses.take(5).toList(),
    );
  }

  void _seedInitialData() {
    final now = DateTime.now();

    // Suppliers
    _suppliers.addAll([
      Supplier(
        id: 'sup_1',
        name: 'Kaveri Farms & Orchards',
        phone: '9842145670',
        city: 'Coimbatore',
        entryPrefix: 'KF',
        openingBalance: 12500,
        currentBalance: 12500,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Supplier(
        id: 'sup_2',
        name: 'Sri Murugan Agri Traders',
        phone: '9443217890',
        city: 'Pollachi',
        entryPrefix: 'SM',
        openingBalance: 0,
        currentBalance: 0,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Supplier(
        id: 'sup_3',
        name: 'Venkateshwara Vegetable Growers',
        phone: '9894012345',
        city: 'Mettupalayam',
        entryPrefix: 'VVG',
        openingBalance: 34000,
        currentBalance: 34000,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Supplier(
        id: 'sup_tamil',
        name: 'Tamil',
        phone: '9842112345',
        city: 'Salem',
        entryPrefix: 'TA',
        openingBalance: 0,
        currentBalance: 0,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Supplier(
        id: 'sup_tamilselvan',
        name: 'Tamilselvan',
        phone: '9842167890',
        city: 'Erode',
        entryPrefix: 'TAM',
        openingBalance: 0,
        currentBalance: 0,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);

    // Customers
    _customers.addAll([
      Customer(
        id: 'cust_1',
        name: 'Shree Balaji Mart',
        phone: '9840198765',
        city: 'Chennai',
        openingBalance: 45000,
        currentOutstanding: 45000,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Customer(
        id: 'cust_2',
        name: 'Annapoorna Caterers',
        phone: '9789054321',
        city: 'Madurai',
        openingBalance: 18500,
        currentOutstanding: 18500,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      Customer(
        id: 'cust_3',
        name: 'Fresh Supermarket & Daily Needs',
        phone: '9655432109',
        city: 'Salem',
        openingBalance: 8200,
        currentOutstanding: 8200,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ]);

    // Transporters
    _transporters.addAll([
      Transporter(
        id: 'trans_1',
        name: 'Vignesh Express Transport',
        phone: '9843011223',
        vehicleNumber: 'TN 38 AZ 4492',
        notes: 'Eicher 14ft open truck',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Transporter(
        id: 'trans_2',
        name: 'Maruthi Roadlines',
        phone: '9442033445',
        vehicleNumber: 'TN 43 B 8810',
        notes: 'Tata Ace 1.5T',
        createdAt: now.subtract(const Duration(days: 18)),
      ),
    ]);

    // Lots
    _lots.addAll([
      Lot(
        id: 'lot_1',
        lotNumber: 'LOT-2026-101',
        supplierId: 'sup_1',
        supplierName: 'Kaveri Farms & Orchards',
        date: now.subtract(const Duration(days: 1)),
        entryNumber: 'KF-001',
        vehicleNumber: 'TN 38 AZ 4492',
        productName: 'Tomatoes (Hybrid Grade A)',
        goodsCount: 50,
        initialQuantity: 1250,
        remainingQuantity: 650,
        initialWeight: 1250,
        remainingWeight: 650,
        unit: 'Kg',
        costRate: 28,
        labourCharge: 500,
        transportCharge: 1200,
        otherCharges: 100,
        status: LotStatus.partiallySold,
        items: const [
          LotItem(
            id: 'item_lot1_1',
            productId: 'veg_tomato',
            productName: 'Tomatoes (Hybrid Grade A)',
            assetPath: 'assets/products/veg/tomato.png',
            goodsCount: 50,
            quantity: 1250,
            weight: 1250,
            unit: 'Kg',
            costRate: 28,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Lot(
        id: 'lot_2',
        lotNumber: 'LOT-2026-102',
        supplierId: 'sup_2',
        supplierName: 'Sri Murugan Agri Traders',
        date: now,
        entryNumber: 'SM-001',
        vehicleNumber: 'TN 43 B 8810',
        productName: 'Bell Peppers (Capsicum Green)',
        goodsCount: 40,
        initialQuantity: 800,
        remainingQuantity: 800,
        initialWeight: 800,
        remainingWeight: 800,
        unit: 'Kg',
        costRate: 42,
        labourCharge: 400,
        transportCharge: 800,
        otherCharges: 0,
        status: LotStatus.active,
        items: const [
          LotItem(
            id: 'item_lot2_1',
            productId: 'veg_capsicum',
            productName: 'Bell Peppers (Capsicum Green)',
            assetPath: 'assets/products/veg/capsicum.png',
            goodsCount: 40,
            quantity: 800,
            weight: 800,
            unit: 'Kg',
            costRate: 42,
          ),
        ],
        createdAt: now,
      ),
      Lot(
        id: 'lot_3',
        lotNumber: 'LOT-2026-103',
        supplierId: 'sup_3',
        supplierName: 'Venkateshwara Vegetable Growers',
        date: now,
        entryNumber: 'VVG-001',
        vehicleNumber: 'TN 37 C 1209',
        productName: 'Red Onions (Nashik Medium)',
        goodsCount: 60,
        initialQuantity: 3000,
        remainingQuantity: 3000,
        initialWeight: 3000,
        remainingWeight: 3000,
        unit: 'Kg',
        costRate: 31,
        labourCharge: 900,
        transportCharge: 2400,
        otherCharges: 150,
        status: LotStatus.active,
        items: const [
          LotItem(
            id: 'item_lot3_1',
            productId: 'veg_onion',
            productName: 'Red Onions (Nashik Medium)',
            assetPath: 'assets/products/veg/onion.png',
            goodsCount: 60,
            quantity: 3000,
            weight: 3000,
            unit: 'Kg',
            costRate: 31,
          ),
        ],
        createdAt: now,
      ),
    ]);

    // Bills
    _bills.addAll([
      Bill(
        id: 'bill_1',
        billNumber: 'CB-2026-201',
        type: BillType.cash,
        customerName: 'Kannan Retailers',
        customerPhone: '9841238910',
        lotId: 'lot_1',
        lotNumber: 'LOT-2026-101',
        productName: 'Tomatoes (Hybrid Grade A)',
        date: now,
        quantity: 4,
        weight: 200,
        unit: 'Kg',
        sellRate: 36,
        grossAmount: 7200,
        labourCharge: 100,
        otherCharges: 0,
        discount: 100,
        totalAmount: 7200,
        amountReceived: 7200,
        balanceDue: 0,
        status: BillStatus.paid,
        bagItems: const [
          BillBagItem(serialNumber: 1, weight: 52, rate: 36, amount: 1872),
          BillBagItem(serialNumber: 2, weight: 48, rate: 36, amount: 1728),
          BillBagItem(serialNumber: 3, weight: 51, rate: 36, amount: 1836),
          BillBagItem(serialNumber: 4, weight: 49, rate: 36, amount: 1764),
        ],
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Bill(
        id: 'bill_2',
        billNumber: 'CR-2026-301',
        type: BillType.credit,
        customerId: 'cust_1',
        customerName: 'Shree Balaji Mart',
        customerPhone: '9840198765',
        lotId: 'lot_1',
        lotNumber: 'LOT-2026-101',
        productName: 'Tomatoes (Hybrid Grade A)',
        date: now,
        quantity: 8,
        weight: 400,
        unit: 'Kg',
        sellRate: 35,
        grossAmount: 14000,
        labourCharge: 200,
        otherCharges: 0,
        discount: 0,
        totalAmount: 14200,
        amountReceived: 0,
        balanceDue: 14200,
        status: BillStatus.unpaid,
        bagItems: const [
          BillBagItem(serialNumber: 1, weight: 52, rate: 35, amount: 1820),
          BillBagItem(serialNumber: 2, weight: 50, rate: 35, amount: 1750),
          BillBagItem(serialNumber: 3, weight: 49, rate: 35, amount: 1715),
          BillBagItem(serialNumber: 4, weight: 51, rate: 35, amount: 1785),
          BillBagItem(serialNumber: 5, weight: 53, rate: 35, amount: 1855),
          BillBagItem(serialNumber: 6, weight: 48, rate: 35, amount: 1680),
          BillBagItem(serialNumber: 7, weight: 47, rate: 35, amount: 1645),
          BillBagItem(serialNumber: 8, weight: 50, rate: 35, amount: 1750),
        ],
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ]);

    // Update customer 1 outstanding to reflect bill
    _customers[0] = _customers[0].copyWith(
      currentOutstanding: _customers[0].currentOutstanding + 14200,
    );

    // Expenses
    _expenses.addAll([
      Expense(
        id: 'exp_1',
        expenseNumber: 'EXP-2026-501',
        title: 'Mandi Unloading Labour',
        category: 'Labour',
        amount: 850,
        date: now,
        method: ExpensePaymentMethod.cash,
        paidTo: 'Palanisamy & Team',
        notes: 'Morning lorry arrival unloading',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Expense(
        id: 'exp_2',
        expenseNumber: 'EXP-2026-502',
        title: 'Shop Tea & Refreshments',
        category: 'Tea & Refreshments',
        amount: 220,
        date: now,
        method: ExpensePaymentMethod.cash,
        paidTo: 'Murugan Tea Stall',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ]);

    // Products Catalogue Seed
    _products.addAll(defaultProductCatalogue);

    // Seed Initial Daily Tallies
    _dailyTallies.addAll([
      DailyTally(
        id: 'tally_1',
        tallyNumber: 'DT-2026-101',
        date: now,
        openingCash: 15000.0,
        cashSales: 7200.0,
        outstandingReceived: 5000.0,
        otherCashReceived: 0.0,
        gpay1Received: 3500.0,
        gpay2Received: 1200.0,
        labourExpense: 850.0,
        transportExpense: 0.0,
        rentExpense: 0.0,
        utilitiesExpense: 0.0,
        teaRefreshmentsExpense: 220.0,
        otherExpense: 0.0,
        partyPayments: const [
          TallyPartyPayment(
            id: 'tpp_1',
            partyName: 'Kaveri Farms (Farmer)',
            amount: 4500.0,
            mode: TallyPaymentMode.cash,
            reference: 'Evening advance settlement',
          ),
        ],
        bankDeposit: 8000.0,
        otherCashInflow: 0.0,
        otherCashOutflow: 0.0,
        actualCashCounted: 13630.0,
        pettyCashInHand: 500.0,
        notes: 'End of day counter cash tally verified and closed',
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      DailyTally(
        id: 'tally_2',
        tallyNumber: 'DT-2026-100',
        date: now.subtract(const Duration(days: 1)),
        openingCash: 12000.0,
        cashSales: 11400.0,
        outstandingReceived: 4200.0,
        otherCashReceived: 0.0,
        gpay1Received: 4000.0,
        gpay2Received: 0.0,
        labourExpense: 1200.0,
        transportExpense: 400.0,
        rentExpense: 0.0,
        utilitiesExpense: 0.0,
        teaRefreshmentsExpense: 180.0,
        otherExpense: 0.0,
        partyPayments: const [
          TallyPartyPayment(
            id: 'tpp_2',
            partyName: 'Ponnusamy (Supplier)',
            amount: 3000.0,
            mode: TallyPaymentMode.cash,
            reference: 'Direct settlement',
          ),
        ],
        bankDeposit: 6820.0,
        otherCashInflow: 0.0,
        otherCashOutflow: 0.0,
        actualCashCounted: 15000.0,
        pettyCashInHand: 500.0,
        notes: 'Small variance reconciled with counter drawer',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ]);
  }

  // ==================== Products Catalogue ====================
  List<Product> get products => List.unmodifiable(_products);

  List<Product> getProducts({bool activeOnly = true}) {
    if (!activeOnly) return List.unmodifiable(_products);
    return _products.where((p) => p.isActive).toList();
  }

  Product? getProduct(String id) {
    return _products.where((p) => p.id == id).firstOrNull;
  }

  Product? getProductByName(String name) {
    final lower = name.toLowerCase().trim();
    return _products.where((p) => p.name.toLowerCase().trim() == lower).firstOrNull;
  }

  List<Product> getProductsByCategory(ProductCategory category, {bool activeOnly = true}) {
    return _products.where((p) {
      if (p.category != category) return false;
      if (activeOnly && !p.isActive) return false;
      return true;
    }).toList();
  }

  List<Product> searchProducts(String query, {ProductCategory? category, bool activeOnly = true}) {
    final q = query.toLowerCase().trim();
    return _products.where((p) {
      if (category != null && p.category != category) return false;
      if (activeOnly && !p.isActive) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.category.displayName.toLowerCase().contains(q) ||
          (p.description != null && p.description!.toLowerCase().contains(q));
    }).toList();
  }

  void addProduct(Product product) {
    _products.insert(0, product);
    _notify();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      _notify();
    }
  }

  void toggleProductStatus(String id) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        isActive: !_products[index].isActive,
        updatedAt: DateTime.now(),
      );
      _notify();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    _notify();
  }

  void importProducts(List<Product> imported) {
    for (final item in imported) {
      final index = _products.indexWhere((p) => p.id == item.id);
      if (index != -1) {
        _products[index] = item;
      } else {
        _products.add(item);
      }
    }
    _notify();
  }

  // ==========================================
  // DAILY TALLY MODULE METHODS
  // ==========================================
  List<DailyTally> getDailyTallies() {
    return List.unmodifiable(_dailyTallies..sort((a, b) => b.date.compareTo(a.date)));
  }

  DailyTally? getDailyTally(String id) {
    return _dailyTallies.where((t) => t.id == id).firstOrNull;
  }

  DailyTally? getDailyTallyByDate(DateTime date) {
    return _dailyTallies.where((t) =>
        t.date.year == date.year &&
        t.date.month == date.month &&
        t.date.day == date.day).firstOrNull;
  }

  String generateTallyNumber() {
    final num = _tallySeq++;
    return 'DT-2026-$num';
  }

  DailyTally createDailyTally({
    required DateTime date,
    required double openingCash,
    double cashSales = 0.0,
    double outstandingReceived = 0.0,
    double otherCashReceived = 0.0,
    double gpay1Received = 0.0,
    double gpay2Received = 0.0,
    double labourExpense = 0.0,
    double transportExpense = 0.0,
    double rentExpense = 0.0,
    double utilitiesExpense = 0.0,
    double teaRefreshmentsExpense = 0.0,
    double otherExpense = 0.0,
    List<TallyPartyPayment> partyPayments = const [],
    double bankDeposit = 0.0,
    double otherCashInflow = 0.0,
    double otherCashOutflow = 0.0,
    required double actualCashCounted,
    double pettyCashInHand = 0.0,
    String? notes,
  }) {
    final tally = DailyTally(
      id: 'tally_${DateTime.now().millisecondsSinceEpoch}',
      tallyNumber: generateTallyNumber(),
      date: date,
      openingCash: openingCash,
      cashSales: cashSales,
      outstandingReceived: outstandingReceived,
      otherCashReceived: otherCashReceived,
      gpay1Received: gpay1Received,
      gpay2Received: gpay2Received,
      labourExpense: labourExpense,
      transportExpense: transportExpense,
      rentExpense: rentExpense,
      utilitiesExpense: utilitiesExpense,
      teaRefreshmentsExpense: teaRefreshmentsExpense,
      otherExpense: otherExpense,
      partyPayments: partyPayments,
      bankDeposit: bankDeposit,
      otherCashInflow: otherCashInflow,
      otherCashOutflow: otherCashOutflow,
      actualCashCounted: actualCashCounted,
      pettyCashInHand: pettyCashInHand,
      notes: notes,
      createdAt: DateTime.now(),
    );

    _dailyTallies.insert(0, tally);
    _notify();
    return tally;
  }

  void deleteDailyTally(String id) {
    _dailyTallies.removeWhere((t) => t.id == id);
    _notify();
  }
}

final appRepositoryProvider = Provider<AppRepository>((ref) {
  return AppRepository();
});

/// Reactive stream provider listening to repository data changes
final repositoryUpdateStreamProvider = StreamProvider<void>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  return repo.onDataChanged;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getCurrentUser();
});

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getDashboardSummary();
});

final suppliersProvider = Provider<List<Supplier>>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getSuppliers();
});

final customersProvider = Provider<List<Customer>>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getCustomers();
});

final transportersProvider = Provider<List<Transporter>>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getTransporters();
});

final lotsProvider = Provider<List<Lot>>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getLots();
});

final availableLotsProvider = Provider<List<Lot>>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getLots().where((l) => l.isAvailable).toList();
});

final billsProvider = Provider<List<Bill>>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getBills();
});

final paymentsProvider = Provider<List<Payment>>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getPayments();
});

final expensesProvider = Provider<List<Expense>>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getExpenses();
});

final productsProvider = Provider<List<Product>>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.products;
});

final dailyTalliesProvider = Provider<List<DailyTally>>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getDailyTallies();
});

final lotExpenseConfigsProvider = Provider<List<LotExpenseConfig>>((ref) {
  ref.watch(repositoryUpdateStreamProvider);
  final repo = ref.watch(appRepositoryProvider);
  return repo.getLotExpenseConfigs();
});

