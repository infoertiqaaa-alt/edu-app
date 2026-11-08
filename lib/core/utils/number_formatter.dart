/// Locale-independent, defensive number formatting for API values.
///
/// The backend does not currently send a currency code for financial totals,
/// therefore no currency symbol is invented here. Only grouping and decimal
/// formatting are applied.
class NumberFormatter {
  NumberFormatter._();

  static String formatNumber(num value, {int maxFractionDigits = 2}) {
    final negative = value < 0;
    final absolute = value.abs();

    final fixed = absolute.toStringAsFixed(maxFractionDigits);
    final parts = fixed.split('.');
    final integerPart = _groupDigits(parts.first);
    final fractionPart = parts.length > 1 ? parts[1] : '';

    final trimmedFraction = fractionPart.replaceFirst(RegExp(r'0+$'), '');
    final formatted = trimmedFraction.isEmpty
        ? integerPart
        : '$integerPart.$trimmedFraction';

    return negative ? '-$formatted' : formatted;
  }

  /// Formats an arbitrary API value. Returns the original text when it cannot
  /// be interpreted as a number, so no information is silently lost.
  static String formatDynamic(dynamic value) {
    if (value == null) return '';
    if (value is num) return formatNumber(value);

    final text = value.toString().trim();
    if (text.isEmpty) return '';

    final numeric = num.tryParse(text.replaceAll(',', ''));
    if (numeric != null) return formatNumber(numeric);

    return text;
  }

  static String _groupDigits(String digits) {
    if (digits.length <= 3) return digits;

    final buffer = StringBuffer();
    final firstGroupLength = digits.length % 3;
    var index = 0;

    if (firstGroupLength > 0) {
      buffer.write(digits.substring(0, firstGroupLength));
      index = firstGroupLength;
    }

    while (index < digits.length) {
      if (buffer.isNotEmpty) buffer.write(',');
      buffer.write(digits.substring(index, index + 3));
      index += 3;
    }

    return buffer.toString();
  }
}
