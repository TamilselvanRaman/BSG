import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bsg_mobile/features/bills/bill_details_screen.dart';

void main() {
  group('Bill Details Mandi Weighment Table Widget Tests', () {
    testWidgets('BillDetailsScreen renders Mandi Goods & Weighment Table with all requested columns', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BillDetailsScreen(billId: 'bill_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen loaded
      expect(find.text('CB-2026-201'), findsWidgets);

      // Verify Goods & Weighment Table title
      expect(find.text('GOODS & WEIGHMENT TABLE'), findsOneWidget);

      // Verify Paper slip column headers
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Lot Num'), findsOneWidget);
      expect(find.text('Quantity Total Bag'), findsOneWidget);
      expect(find.text('Each Bags Weight (Kg)'), findsOneWidget);
      expect(find.text('Total Weight'), findsOneWidget);
      expect(find.text('Rate / Bag (₹)'), findsOneWidget);
      expect(find.text('Amount (₹)'), findsOneWidget);

      // Verify Individual Bag breakdown section
      expect(find.textContaining('Each Bags Weight Breakdown'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('52 kg'), findsWidgets);
    });
  });
}
