enum AppLanguage {
  english(code: 'en', displayName: 'English', nativeName: 'English'),
  tamil(code: 'ta', displayName: 'Tamil', nativeName: 'தமிழ்'),
  hindi(code: 'hi', displayName: 'Hindi', nativeName: 'हिन्दी');

  final String code;
  final String displayName;
  final String nativeName;

  const AppLanguage({
    required this.code,
    required this.displayName,
    required this.nativeName,
  });

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}
