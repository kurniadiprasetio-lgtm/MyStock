class FormatUtils {
  FormatUtils._();

  static String currency(double amount, {bool showSymbol = true}) {
    final symbol = showSymbol ? 'Rp ' : '';
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$symbol$formatted';
  }

  static String currencyShort(double amount) {
    if (amount >= 1000000000) {
      // 1 milyar = 1 Mrd (Indonesian abbreviation)
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}Mrd';
    } else if (amount >= 1000000) {
      // 1 juta = 1 Jt
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    } else if (amount >= 1000) {
      // 1 ribu = 1 Rb
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}Rb';
    }
    return currency(amount);
  }

  static String date(DateTime date, {String format = 'dd MMM yyyy'}) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _monthShort(date.month);
    final year = date.year.toString();
    return '$day $month $year';
  }

  static String dateShort(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _monthShort(date.month);
    return '$day $month';
  }

  static String _monthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  static String percentage(double value, {bool showSign = false}) {
    String result = '${value.toStringAsFixed(1)}%';
    if (showSign && value > 0) {
      result = '+$result';
    }
    return result;
  }

  static String bepProgress(double covered, double total) {
    if (total == 0) return '0%';
    final progress = (covered / total * 100).clamp(0.0, 100.0);
    return '${progress.toStringAsFixed(0)}%';
  }
}
