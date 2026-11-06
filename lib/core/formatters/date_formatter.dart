import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _shortDate = DateFormat('dd MMM yyyy');
  static final DateFormat _displayDate = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _numericDate = DateFormat('dd/MM/yyyy');
  static final DateFormat _dayMonth = DateFormat('dd MMM');

  static String format(DateTime date) => _shortDate.format(date);
  static String formatWithTime(DateTime date) => _displayDate.format(date);
  static String formatNumeric(DateTime date) => _numericDate.format(date);
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);
}
