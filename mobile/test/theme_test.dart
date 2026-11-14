import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bsg_mobile/core/theme/theme_extension.dart';
import 'package:bsg_mobile/features/settings/screens/appearance_screen.dart';
import 'package:bsg_mobile/features/settings/widgets/theme_preview_card.dart';

void main() {
  group('5-Theme Customization System - Color Token & Model Tests', () {
    test('Theme 01 - Classic matches exact specification', () {
      const theme = AppThemeColors.classic;
      expect(theme.id, 'classic');
      expect(theme.background, const Color(0xFFF5F6F1));
      expect(theme.surface, const Color(0xFFFFFFFF));
      expect(theme.primary, const Color(0xFF252525));
      expect(theme.secondary, const Color(0xFF777777));
      expect(theme.accent, const Color(0xFFE9EBE5));
      expect(theme.border, const Color(0xFFE2E3DE));
      expect(theme.success, const Color(0xFF287A52));
      expect(theme.error, const Color(0xFFD32F2F));
      expect(theme.isDark, false);
    });

    test('Theme 02 - Fresh Green White matches exact specification', () {
      const theme = AppThemeColors.green;
      expect(theme.id, 'green');
      expect(theme.background, const Color(0xFFF1F7F2));
      expect(theme.surface, const Color(0xFFFFFFFF));
      expect(theme.primary, const Color(0xFF159B45));
      expect(theme.secondary, const Color(0xFF66756A));
      expect(theme.accent, const Color(0xFFD9F1DF));
      expect(theme.border, const Color(0xFFDCE8DF));
      expect(theme.text, const Color(0xFF26352B));
      expect(theme.success, const Color(0xFF159B45));
      expect(theme.error, const Color(0xFFD32F2F));
      expect(theme.isDark, false);
    });

    test('Theme 03 - Executive Navy Blue matches exact specification', () {
      const theme = AppThemeColors.navy;
      expect(theme.id, 'navy');
      expect(theme.background, const Color(0xFF0B1220));
      expect(theme.surface, const Color(0xFF14243B));
      expect(theme.primary, const Color(0xFF2563EB));
      expect(theme.secondary, const Color(0xFF9CAFC8));
      expect(theme.accent, const Color(0xFF1E3554));
      expect(theme.border, const Color(0xFF263B59));
      expect(theme.text, const Color(0xFFF5F7FB));
      expect(theme.success, const Color(0xFF22C55E));
      expect(theme.error, const Color(0xFFEF4444));
      expect(theme.isDark, true);
    });

    test('Theme 04 - Royal Burgundy Ivory matches exact specification', () {
      const theme = AppThemeColors.burgundy;
      expect(theme.id, 'burgundy');
      expect(theme.background, const Color(0xFFFFF9F5));
      expect(theme.surface, const Color(0xFFFFFFFF));
      expect(theme.primary, const Color(0xFF8B1538));
      expect(theme.secondary, const Color(0xFF77717A));
      expect(theme.accent, const Color(0xFFF4E2E5));
      expect(theme.border, const Color(0xFFEAE3E3));
      expect(theme.text, const Color(0xFF282329));
      expect(theme.success, const Color(0xFF287A52));
      expect(theme.error, const Color(0xFFC62828));
      expect(theme.isDark, false);
    });

    test('Theme 05 - Midnight Dark matches exact specification', () {
      const theme = AppThemeColors.midnight;
      expect(theme.id, 'midnight');
      expect(theme.background, const Color(0xFF101214));
      expect(theme.surface, const Color(0xFF1C2226));
      expect(theme.primary, const Color(0xFFF59E0B));
      expect(theme.secondary, const Color(0xFFA5ADB3));
      expect(theme.accent, const Color(0xFF30383D));
      expect(theme.border, const Color(0xFF353D42));
      expect(theme.text, const Color(0xFFF5F5F5));
      expect(theme.success, const Color(0xFF22C55E));
      expect(theme.error, const Color(0xFFEF4444));
      expect(theme.isDark, true);
    });

    test('All 5 themes can be resolved from ID', () {
      expect(AppThemeColors.fromId('classic').id, 'classic');
      expect(AppThemeColors.fromId('green').id, 'green');
      expect(AppThemeColors.fromId('navy').id, 'navy');
      expect(AppThemeColors.fromId('burgundy').id, 'burgundy');
      expect(AppThemeColors.fromId('midnight').id, 'midnight');
      expect(AppThemeColors.fromId('invalid').id, 'classic');
    });
  });

  group('Appearance & Themes Screen Widget Tests', () {
    testWidgets('Renders all 5 theme preview cards and switches theme', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppearanceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Appearance & Themes'), findsOneWidget);

      // Verify all 5 themes are listed
      expect(find.byType(ThemePreviewCard), findsNWidgets(5));
      expect(find.text('THEME 01'), findsOneWidget);
      expect(find.text('THEME 02'), findsOneWidget);
      expect(find.text('THEME 03'), findsOneWidget);
      expect(find.text('THEME 04'), findsOneWidget);
      expect(find.text('THEME 05'), findsOneWidget);

      // Verify Reset button
      expect(find.text('Reset to Classic Default'), findsOneWidget);

      // Tap Theme 02 (Fresh Green)
      await tester.tap(find.text('THEME 02'));
      await tester.pumpAndSettle();
    });
  });
}

