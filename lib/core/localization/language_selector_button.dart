import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import 'app_language.dart';
import 'language_provider.dart';

class LanguageSelectorButton extends ConsumerWidget {
  final bool compact;

  const LanguageSelectorButton({super.key, this.compact = true});

  static void showLanguageSheet(BuildContext context, WidgetRef ref) {
    final currentLang = ref.read(languageProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.translate_rounded, color: AppColors.primaryGreen, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Select Language / மொழி / भाषा',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Change application display language across all screens.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ...AppLanguage.values.map((lang) {
                  final isSelected = lang == currentLang;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.lightGreenSurface : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryGreen.withValues(alpha: 0.15) : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          lang.code.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: isSelected ? AppColors.primaryGreenDark : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      title: Text(
                        lang.nativeName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 15,
                          color: isSelected ? AppColors.primaryGreenDark : const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        lang.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? AppColors.primaryGreen : const Color(0xFF64748B),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 22)
                          : null,
                      onTap: () {
                        ref.read(languageProvider.notifier).setLanguage(lang);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Language changed to ${lang.displayName} (${lang.nativeName})'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return InkWell(
      onTap: () => showLanguageSheet(context, ref),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.lightGreenSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.g_translate_rounded, size: 16, color: AppColors.primaryGreen),
            const SizedBox(width: 5),
            Text(
              currentLang.nativeName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreenDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
