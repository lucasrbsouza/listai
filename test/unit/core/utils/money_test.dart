import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';

void main() {
  group('Money construction', () {
    test('fromCents stores cents', () {
      expect(Money.fromCents(1234).cents, 1234);
    });

    test('fromReais converts to cents', () {
      expect(Money.fromReais(12.34).cents, 1234);
    });

    test('zero() has 0 cents', () {
      expect(const Money.zero().cents, 0);
    });

    test('fromCents negative throws ArgumentError', () {
      expect(() => Money.fromCents(-1), throwsArgumentError);
    });

    test('fromReais negative throws ArgumentError', () {
      expect(() => Money.fromReais(-0.01), throwsArgumentError);
    });

    test('fromReais zero is valid', () {
      expect(Money.fromReais(0).cents, 0);
    });
  });

  group('Money arithmetic', () {
    test('addition is correct', () {
      expect((Money.fromCents(100) + Money.fromCents(50)).cents, 150);
    });

    test('subtraction is correct', () {
      expect((Money.fromCents(100) - Money.fromCents(30)).cents, 70);
    });

    test('subtraction resulting in negative throws', () {
      expect(
        () => Money.fromCents(50) - Money.fromCents(100),
        throwsArgumentError,
      );
    });

    test('multiply by int', () {
      expect((Money.fromCents(100) * 3).cents, 300);
    });

    test('multiply by double', () {
      expect((Money.fromCents(100) * 1.5).cents, 150);
    });

    test('multiply by zero gives zero', () {
      expect((Money.fromCents(500) * 0).cents, 0);
    });

    test('no precision loss in sum of cents', () {
      final total =
          Money.fromCents(1) + Money.fromCents(1) + Money.fromCents(1);
      expect(total.cents, 3);
    });
  });

  group('Money comparisons', () {
    test('greater than', () {
      expect(Money.fromCents(100) > Money.fromCents(50), isTrue);
    });

    test('less than', () {
      expect(Money.fromCents(50) < Money.fromCents(100), isTrue);
    });

    test('greater than or equal', () {
      expect(Money.fromCents(100) >= Money.fromCents(100), isTrue);
    });

    test('less than or equal', () {
      expect(Money.fromCents(99) <= Money.fromCents(100), isTrue);
    });
  });

  group('Money equality', () {
    test('structural equality', () {
      expect(Money.fromCents(100), equals(Money.fromCents(100)));
    });

    test('inequality', () {
      expect(Money.fromCents(100), isNot(equals(Money.fromCents(101))));
    });

    test('equal values have same hashCode', () {
      expect(Money.fromCents(999).hashCode, Money.fromCents(999).hashCode);
    });
  });

  group('Money format', () {
    test('format contains integer and decimal parts', () {
      final formatted = Money.fromCents(1234).format();
      expect(formatted, contains('12'));
      expect(formatted, contains('34'));
    });

    test('format en-US uses dot as decimal separator', () {
      final formatted = Money.fromCents(
        1234,
      ).format(locale: 'en-US', symbol: r'$');
      expect(formatted, contains('.'));
    });

    test('format includes currency symbol', () {
      expect(Money.fromCents(100).format(), contains('R\$'));
    });

    test('format custom symbol', () {
      expect(
        Money.fromCents(100).format(locale: 'en-US', symbol: r'$'),
        contains(r'$'),
      );
    });
  });

  group('Money large values', () {
    test('handles up to R\$ 10,000,000 without overflow', () {
      final m = Money.fromReais(10000000.00);
      expect(m.cents, 1000000000);
    });
  });
}
