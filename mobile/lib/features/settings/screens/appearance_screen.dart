import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_dialog.dart';
import '../widgets/theme_preview_card.dart';

/// Appearance & Themes customization screen providing instant 5-theme switching.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeControllerProvider);

    return Scaffold(
      backgroundColor: currentTheme.background,
      appBar: AppBar(
        title: const Text('Appearance & Themes'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset to Default',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () async {
              await ref.read(themeControllerProvider.notifier).resetToDefault();
              if (context.mounted) {
                AppDialog.showSnackBar(context, 'Reset to Classic default theme');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Informational Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: currentTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: currentTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentTheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.palette_outlined,
                    color: currentTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customize Look & Feel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: currentTheme.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select from 5 professional themes. The entire application updates instantly and persists across restarts.',
                        style: TextStyle(
                          fontSize: 12,
                          color: currentTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Theme List
          ...AppThemeColors.allThemes.map((theme) {
            final isSelected = theme.id == currentTheme.id;
            return ThemePreviewCard(
              theme: theme,
              isSelected: isSelected,
              onSelect: () async {
                if (!isSelected) {
                  await ref.read(themeControllerProvider.notifier).setTheme(theme.id);
                  if (context.mounted) {
                    AppDialog.showSnackBar(
                      context,
                      'Theme updated: ${theme.name}',
                    );
                  }
                }
              },
            );
          }),

          const SizedBox(height: 8),

          // Reset to Default button
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(themeControllerProvider.notifier).resetToDefault();
              if (context.mounted) {
                AppDialog.showSnackBar(context, 'Reset to Classic default theme');
              }
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reset to Classic Default'),
            style: OutlinedButton.styleFrom(
              foregroundColor: currentTheme.textSecondary,
              side: BorderSide(color: currentTheme.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

