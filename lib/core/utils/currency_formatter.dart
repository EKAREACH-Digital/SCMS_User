class CurrencyFormatter {
  static String formatKHR(double amount) {
    final intAmount = amount.toInt();
    return '៛${_addThousandSeparators(intAmount.toString())}';
  }

  static String formatUSD(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  static String khrToUsd(double khr, {double rate = 4000.0}) {
    return formatUSD(khr / rate);
  }

  static String usdToKhr(double usd, {double rate = 4000.0}) {
    return formatKHR(usd * rate);
  }

  static String _addThousandSeparators(String value) {
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final remaining = value.length - i;
      if (i > 0 && remaining % 3 == 0) buffer.write(',');
      buffer.write(value[i]);
    }
    return buffer.toString();
  }
}
