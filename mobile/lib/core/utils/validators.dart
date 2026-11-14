/// Standard form field validators
class AppValidators {
  AppValidators._();

  static String? required(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String message = 'Enter a valid positive number']) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return message;
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, [String message = 'Enter a valid number (0 or more)']) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return message;
    }
    return null;
  }
}

