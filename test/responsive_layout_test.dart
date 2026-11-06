import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buyer_seller_goods_management/app/app.dart';
import 'package:buyer_seller_goods_management/core/responsive/breakpoints.dart';
import 'package:buyer_seller_goods_management/core/widgets/mandi_bottom_navbar.dart';

void main() {
  group('Responsive Breakpoints Unit Tests', () {
    testWidgets('Breakpoint helpers detect mobile correctly', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.isMobile, isTrue);
              expect(context.isTablet, isFalse);
              expect(context.isDesktop, isFalse);
              expect(context.isTabletOrDesktop, isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Breakpoint helpers detect tablet correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.isMobile, isFalse);
              expect(context.isTablet, isTrue);
              expect(context.isDesktop, isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Breakpoint helpers detect desktop correctly', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.isMobile, isFalse);
              expect(context.isTablet, isFalse);
              expect(context.isDesktop, isTrue);
              expect(context.isTabletOrDesktop, isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('Multi-Device Surface Size Rendering Tests', () {
    testWidgets('App renders on small compact mobile phone (360x640) without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: GoodsManagementApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(MandiBottomNavBar), findsOneWidget);
    });

    testWidgets('App renders on tablet display (768x1024) with NavigationRail', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: GoodsManagementApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(NavigationRail), findsOneWidget);
    });

    testWidgets('App renders on desktop widescreen (1440x900) with extended NavigationRail', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: GoodsManagementApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('BSG'), findsWidgets);
    });
  });
}
