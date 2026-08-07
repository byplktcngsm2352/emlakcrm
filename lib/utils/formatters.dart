import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount, [String symbol = '₺']) {
    final String formatted = NumberFormat.decimalPattern('tr_TR').format(amount.toInt());
    return '$symbol$formatted';
  }

  static String formatCompactCurrency(double amount, [String symbol = '₺']) {
    if (amount >= 1000000000) {
      return '$symbol${(amount / 1000000000).toStringAsFixed(2)} Mlrd';
    } else if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)} Milyon';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(0)} Bin';
    }
    return '$symbol${amount.toInt()}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }
}
