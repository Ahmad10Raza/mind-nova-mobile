import 'package:intl/intl.dart';

class NumberFormatter {
  /// Formats a double to at most 1 decimal place, dropping the decimal if it's .0
  static String formatMetric(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return NumberFormat("0.0").format(value);
  }
}
