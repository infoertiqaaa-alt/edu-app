import 'package:flutter_test/flutter_test.dart';
import 'package:mr/core/utils/json_parsers.dart';
import 'package:mr/core/utils/number_formatter.dart';

void main() {
  group('JsonParsers', () {
    test('parses ints from int, double and string values', () {
      expect(JsonParsers.asInt(2), 2);
      expect(JsonParsers.asInt(2.9), 2);
      expect(JsonParsers.asInt('7'), 7);
      expect(JsonParsers.asInt(' 8 '), 8);
      expect(JsonParsers.asInt(null), isNull);
      expect(JsonParsers.asInt('abc'), isNull);
      expect(JsonParsers.asIntOr('abc', 5), 5);
    });

    test('parses doubles and grouped numeric strings', () {
      expect(JsonParsers.asDouble(2), 2.0);
      expect(JsonParsers.asDouble('2.5'), 2.5);
      expect(JsonParsers.asDouble('1,234.50'), 1234.5);
      expect(JsonParsers.asDouble(''), isNull);
      expect(JsonParsers.asDoubleOr(null, 0), 0);
    });

    test('parses booleans defensively', () {
      expect(JsonParsers.asBool(true), isTrue);
      expect(JsonParsers.asBool(0), isFalse);
      expect(JsonParsers.asBool('yes'), isTrue);
      expect(JsonParsers.asBool('OFF'), isFalse);
      expect(JsonParsers.asBool(null), isNull);
      expect(JsonParsers.asBoolOr('unknown', fallback: true), isTrue);
    });

    test('parses string lists and skips blanks/nulls', () {
      expect(JsonParsers.asStringList(['a', null, ' ', 3]), ['a', '3']);
      expect(JsonParsers.asStringList(null), isEmpty);
      expect(JsonParsers.asStringList({'a': 1}), isEmpty);
    });

    test('parses maps and map lists defensively', () {
      expect(JsonParsers.asMap({'a': 1}), {'a': 1});
      expect(JsonParsers.asMap('nope'), isNull);
      expect(
        JsonParsers.asMapList([
          {'a': 1},
          'bad',
          null,
        ]),
        [
          {'a': 1},
        ],
      );
    });
  });

  group('NumberFormatter', () {
    test('groups thousands and trims trailing decimals', () {
      expect(NumberFormatter.formatNumber(0), '0');
      expect(NumberFormatter.formatNumber(999), '999');
      expect(NumberFormatter.formatNumber(1000), '1,000');
      expect(NumberFormatter.formatNumber(1234567), '1,234,567');
      expect(NumberFormatter.formatNumber(1234.5), '1,234.5');
      expect(NumberFormatter.formatNumber(1234.50), '1,234.5');
      expect(NumberFormatter.formatNumber(-1234.5), '-1,234.5');
    });

    test('formats arbitrary API values without losing non-numeric text', () {
      expect(NumberFormatter.formatDynamic(1500), '1,500');
      expect(NumberFormatter.formatDynamic('1500.25'), '1,500.25');
      expect(NumberFormatter.formatDynamic('١٢٣'), '١٢٣');
      expect(NumberFormatter.formatDynamic(null), '');
    });
  });
}
