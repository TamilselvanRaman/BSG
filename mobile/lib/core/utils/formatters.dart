import 'package:intl/intl.dart';

/// Formatter utilities for currency (INR), dates, and quantities.
class AppFormatters {
  AppFormatters._();

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inrNoDecimalsFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final NumberFormat _numberFormat = NumberFormat('#,##,##0', 'en_IN');

  /// Formats raw number with commas: e.g. "24,000"
  static String number(num amount) {
    return _numberFormat.format(amount);
  }

  /// Formats amount in INR: e.g. ₹12,450.00
  static String currency(num amount, {bool showDecimals = true}) {
    if (showDecimals) {
      return _inrFormat.format(amount);
    }
    return _inrNoDecimalsFormat.format(amount);
  }

  /// Formats date: e.g. 09 Nov 2026
  static String date(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Formats time: e.g. 05:30 PM
  static String time(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Formats date and time: e.g. 09 Nov 2026, 05:30 PM
  static String dateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Formats quantity with unit: e.g. "45.5 Bags", "120 Kgs"
  static String quantity(num qty, String unit) {
    if (qty == qty.roundToDouble()) {
      return '${qty.toInt()} $unit';
    }
    return '${qty.toStringAsFixed(2)} $unit';
  }
}

