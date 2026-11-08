/// Safe, centralized JSON value conversions.
///
/// Backend values are typed inconsistently (`2`, `"2"`, `2.0`). Parsing them
/// through this class avoids unsafe casts and `TypeError`s in model factories.
class JsonParsers {
  JsonParsers._();

  static int? asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    if (value is bool) return value ? 1 : 0;
    return null;
  }

  static int asIntOr(dynamic value, int fallback) => asInt(value) ?? fallback;

  static double? asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.trim().replaceAll(',', '');
      if (normalized.isEmpty) return null;
      return double.tryParse(normalized);
    }
    return null;
  }

  static double asDoubleOr(dynamic value, double fallback) =>
      asDouble(value) ?? fallback;

  static num? asNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) {
      final normalized = value.trim().replaceAll(',', '');
      if (normalized.isEmpty) return null;
      return num.tryParse(normalized);
    }
    return null;
  }

  static num asNumOr(dynamic value, num fallback) => asNum(value) ?? fallback;

  static String asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value;
    return value.toString();
  }

  /// Returns `null` for blank strings, useful for optional text fields.
  static String? asNullableString(dynamic value) {
    final text = asString(value).trim();
    return text.isEmpty ? null : text;
  }

  static bool? asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
        case 'yes':
        case 'on':
          return true;
        case 'false':
        case '0':
        case 'no':
        case 'off':
          return false;
      }
    }
    return null;
  }

  static bool asBoolOr(dynamic value, {required bool fallback}) =>
      asBool(value) ?? fallback;

  static List<String> asStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .where((item) => item != null)
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);
  }

  static Map<String, dynamic>? asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static List<Map<String, dynamic>> asMapList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }
}
