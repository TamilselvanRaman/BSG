import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buyer_seller_goods_management/app/app.dart';

void main() {
  testWidgets('App launches with BSG Goods Management title and splash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GoodsManagementApp(),
      ),
    );

    // Initial frame shows splash
    expect(find.text('BSG'), findsOneWidget);
    expect(find.text('Buyer & Seller Goods Management'), findsOneWidget);

    // Let the splash timer expire and settle into Dashboard
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Dashboard header should now be present
    expect(find.text('BSG Agro Goods Mandi'), findsOneWidget);
    expect(find.text("Today's Sales"), findsOneWidget);
    expect(find.text('Initial Payments'), findsOneWidget);
  });
}
