import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_language.dart';
import 'app_strings.dart';

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => AppLanguage.english;

  void setLanguage(AppLanguage language) {
    state = language;
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

final translationProvider = Provider.family<String, String>((ref, key) {
  final lang = ref.watch(languageProvider);
  return AppStrings.tr(key, lang);
});

extension WidgetRefTr on WidgetRef {
  String tr(String key) {
    final lang = watch(languageProvider);
    return AppStrings.tr(key, lang);
  }
}
