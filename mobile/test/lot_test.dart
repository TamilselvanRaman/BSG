import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bsg_mobile/data/repositories/app_repository.dart';
import 'package:bsg_mobile/features/lots/create_lot_screen.dart';
import 'package:bsg_mobile/features/lots/lots_list_screen.dart';
import 'package:bsg_mobile/features/lots/widgets/step_progress_indicator.dart';

void main() {
  group('Lot Management & Repository Tests', () {
    test('AppRepository createLot, updateLot, and deleteLot operations', () async {
      final repo = AppRepository();
      final initialCount = repo.getLots().length;

      // Create Lot
      final newLot = await repo.createLot(
        supplierId: 'sup_test',
        supplierName: 'Test Farmer Orchard',
        date: DateTime.now(),
        entryNumber: 'ENT-9999',
        vehicleNumber: 'TN 99 ZZ 1234',
        productName: 'Shimla Royal Apple',
        goodsCount: 50,
        quantity: 2500,
        weight: 2500,
        unit: 'Kg',
        costRate: 85.0,
        labourCharge: 200,
        transportCharge: 1500,
      );

      expect(repo.getLots().length, initialCount + 1);
      expect(newLot.productName, 'Shimla Royal Apple');
      expect(newLot.isAvailable, true);
      expect(newLot.goodsCount, 50);
      expect(newLot.totalInitialCost, (2500 * 85.0) + 200 + 1500);

      // Update Lot
      final updated = newLot.copyWith(costRate: 90.0);
      await repo.updateLot(updated);
      final fetched = repo.getLot(newLot.id);
      expect(fetched?.costRate, 90.0);

      // Delete Lot
      final deleted = await repo.deleteLot(newLot.id);
      expect(deleted, true);
      expect(repo.getLots().length, initialCount);
      expect(repo.getLot(newLot.id), isNull);
    });

    test('Supplier fixed prefix and sequence auto-increment (Tamil TA-001/002 vs Tamilselvan TAM-001)', () async {
      final repo = AppRepository();

      // 1. Verify pre-seeded Tamil & Tamilselvan suppliers
      expect(repo.getOrGenerateSupplierPrefix('sup_tamil'), 'TA');
      expect(repo.getNextEntryNumberForSupplier('sup_tamil'), 'TA-001');

      expect(repo.getOrGenerateSupplierPrefix('sup_tamilselvan'), 'TAM');
      expect(repo.getNextEntryNumberForSupplier('sup_tamilselvan'), 'TAM-001');

      // Create a lot for Tamil with TA-001
      await repo.createLot(
        supplierId: 'sup_tamil',
        supplierName: 'Tamil',
        date: DateTime.now(),
        entryNumber: 'TA-001',
        productName: 'Tomatoes',
        goodsCount: 10,
        quantity: 500,
        weight: 500,
        costRate: 30,
      );

      // Next time for Tamil: fixed prefix TA remains, number increments to TA-002
      expect(repo.getNextEntryNumberForSupplier('sup_tamil'), 'TA-002');
      expect(repo.getOrGenerateSupplierPrefix('sup_tamil'), 'TA');

      // 2. Test dynamically added suppliers: "Kumar" vs "Kumaresan"
      final supplierKumar = await repo.addSupplier(name: 'Kumar', phone: '9842100011');
      final prefixKumar = repo.getOrGenerateSupplierPrefix(supplierKumar.id);
      expect(prefixKumar, 'KU');

      final entry1Kumar = repo.getNextEntryNumberForSupplier(supplierKumar.id);
      expect(entry1Kumar, 'KU-001');

      await repo.createLot(
        supplierId: supplierKumar.id,
        supplierName: supplierKumar.name,
        date: DateTime.now(),
        entryNumber: entry1Kumar,
        productName: 'Onions',
        goodsCount: 15,
        quantity: 600,
        weight: 600,
        costRate: 20,
      );

      // Next lot for Kumar: KU-002
      expect(repo.getNextEntryNumberForSupplier(supplierKumar.id), 'KU-002');
      expect(repo.getOrGenerateSupplierPrefix(supplierKumar.id), 'KU');

      // 3. Another user "Kumaresan" arrives: KU is already taken, so it takes 3 letters: KUM
      final supplierKumaresan = await repo.addSupplier(name: 'Kumaresan', phone: '9842100022');
      final prefixKumaresan = repo.getOrGenerateSupplierPrefix(supplierKumaresan.id);
      expect(prefixKumaresan, 'KUM');

      final entry1Kumaresan = repo.getNextEntryNumberForSupplier(supplierKumaresan.id);
      expect(entry1Kumaresan, 'KUM-001');

      await repo.createLot(
        supplierId: supplierKumaresan.id,
        supplierName: supplierKumaresan.name,
        date: DateTime.now(),
        entryNumber: entry1Kumaresan,
        productName: 'Carrots',
        goodsCount: 25,
        quantity: 1200,
        weight: 1200,
        costRate: 40,
      );

      // Next lot for Kumaresan: KUM-002
      expect(repo.getNextEntryNumberForSupplier(supplierKumaresan.id), 'KUM-002');
      expect(repo.getOrGenerateSupplierPrefix(supplierKumaresan.id), 'KUM');
    });
  });

  group('Create Lot Flow Widget Tests', () {
    testWidgets('StepProgressIndicator displays 3 steps and progress', (tester) async {
      int tappedStep = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StepProgressIndicator(
              currentStep: 0,
              totalSteps: 3,
              stepTitles: const [
                'Crop & Supplier',
                'Bags & Pricing',
                'Charges & Review',
              ],
              onStepTapped: (index) => tappedStep = index,
            ),
          ),
        ),
      );

      expect(find.text('STEP 1 OF 3'), findsOneWidget);
      expect(find.text('Crop & Supplier'), findsWidgets);
      expect(find.text('33%'), findsOneWidget);
      expect(tappedStep, -1);
    });

    testWidgets('CreateLotScreen renders initial 3-step consolidated flow', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateLotScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Create New Lot'), findsOneWidget);
      expect(find.text('STEP 1 OF 3'), findsOneWidget);
      expect(find.text('Next: Bags & Weight'), findsOneWidget);
    });

    testWidgets('LotsListScreen renders lot inventory, search, and filter chips', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LotsListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lot Inventory & Procurement'), findsOneWidget);
      expect(find.text('Active Lots In Stock'), findsOneWidget);
      expect(find.text('All Lots (3)'), findsOneWidget);
    });
  });
}
