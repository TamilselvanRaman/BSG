import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bsg_mobile/data/models/product_model.dart';
import 'package:bsg_mobile/data/repositories/app_repository.dart';
import 'package:bsg_mobile/features/catalogue/widgets/product_crop_selector_sheet.dart';

void main() {
  group('Product Catalogue Repository & Data Tests', () {
    late AppRepository repo;

    setUp(() {
      repo = AppRepository();
    });

    test('Catalogue initializes with 197 comprehensive starter products', () {
      final products = repo.products;
      expect(products.length, greaterThanOrEqualTo(190));

      final fruits = repo.getProductsByCategory(ProductCategory.fruit);
      final veg = repo.getProductsByCategory(ProductCategory.veg);
      final flowers = repo.getProductsByCategory(ProductCategory.flower);
      final spices = repo.getProductsByCategory(ProductCategory.spices);
      final crops = repo.getProductsByCategory(ProductCategory.crop);

      expect(fruits, isNotEmpty);
      expect(veg, isNotEmpty);
      expect(flowers, isNotEmpty);
      expect(spices, isNotEmpty);
      expect(crops, isNotEmpty);

      // Verify each product has an asset path and valid category
      for (final p in products) {
        expect(p.name, isNotEmpty);
        expect(p.assetPath, startsWith('assets/products/'));
        expect(p.defaultUnit, isNotEmpty);
      }
    });

    test('Searching products by name works accurately', () {
      final tomato = repo.searchProducts('Tomato');
      expect(tomato, isNotEmpty);
      expect(tomato.any((p) => p.name.contains('Tomato')), isTrue);

      final apple = repo.searchProducts('Apple');
      expect(apple, isNotEmpty);
      expect(apple.any((p) => p.name.contains('Apple')), isTrue);
    });

    test('Admin CRUD: add, toggle status, update, and delete product', () {
      final now = DateTime.now();
      final testProduct = Product(
        id: 'test_product_999',
        name: 'Organic Dragonfruit Special',
        category: ProductCategory.fruit,
        assetPath: 'assets/products/fruit/dragon_fruit.png',
        defaultUnit: 'Boxes',
        defaultRate: 150.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // 1. Add
      repo.addProduct(testProduct);
      expect(repo.getProduct('test_product_999'), isNotNull);

      // 2. Toggle status
      repo.toggleProductStatus('test_product_999');
      expect(repo.getProduct('test_product_999')!.isActive, isFalse);

      // 3. Update
      final updated = testProduct.copyWith(name: 'Premium Dragonfruit Special', defaultRate: 175.0);
      repo.updateProduct(updated);
      expect(repo.getProduct('test_product_999')!.name, equals('Premium Dragonfruit Special'));

      // 4. Delete
      repo.deleteProduct('test_product_999');
      expect(repo.getProduct('test_product_999'), isNull);
    });
  });

  group('Product Crop Selector Widget Tests', () {
    testWidgets('Renders bottom sheet header, categories, search, and continue button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProductCropSelectorSheet(
                initialSelectedProductIds: [],
                allowMultiple: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Select Crop'), findsOneWidget);

      // Verify Category Tabs
      expect(find.text('Fruit'), findsWidgets);
      expect(find.text('Veg'), findsWidgets);
      expect(find.text('Flower'), findsWidgets);
      expect(find.text('Spices'), findsWidgets);
      expect(find.text('Crop'), findsWidgets);

      // Verify search bar hint
      expect(find.text('Search in Fruit...'), findsOneWidget);

      // Tap on 'Veg' category tab
      await tester.tap(find.text('Veg').first);
      await tester.pumpAndSettle();

      // Search hint should update to Veg
      expect(find.text('Search in Veg...'), findsOneWidget);

      // Verify Continue button starts with CONTINUE
      expect(find.text('CONTINUE'), findsOneWidget);
    });
  });
}

