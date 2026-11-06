import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String format(num amount, {bool showDecimals = false}) {
    if (showDecimals || amount % 1 != 0) {
      return _inrWithDecimals.format(amount);
    }
    return _inrFormat.format(amount);
  }

  static String formatCompact(num amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)} k';
    }
    return format(amount);
  }
}
