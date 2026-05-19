import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/quantity.dart';

void main() {
  group('Quantity construction', () {
    test('stores value', () {
      expect(Quantity(1.5).value, closeTo(1.5, 0.001));
    });

    test('unit() returns 1.0', () {
      expect(Quantity.unit().value, closeTo(1.0, 0.001));
    });

    test('zero throws ArgumentError', () {
      expect(() => Quantity(0), throwsArgumentError);
    });

    test('negative throws ArgumentError', () {
      expect(() => Quantity(-1.0), throwsArgumentError);
    });

    test('NaN throws ArgumentError', () {
      expect(() => Quantity(double.nan), throwsArgumentError);
    });

    test('positive infinity throws ArgumentError', () {
      expect(() => Quantity(double.infinity), throwsArgumentError);
    });

    test('negative infinity throws ArgumentError', () {
      expect(() => Quantity(double.negativeInfinity), throwsArgumentError);
    });

    test('rounds to 3 decimal places', () {
      expect(Quantity(1.5678).value, closeTo(1.568, 0.0001));
    });
  });

  group('Quantity arithmetic', () {
    test('addition', () {
      expect((Quantity(1.5) + Quantity(2.5)).value, closeTo(4.0, 0.001));
    });

    test('subtraction valid', () {
      expect((Quantity(3.0) - Quantity(1.0)).value, closeTo(2.0, 0.001));
    });

    test('subtraction resulting in zero or negative throws', () {
      expect(() => Quantity(1.0) - Quantity(1.0), throwsArgumentError);
      expect(() => Quantity(1.0) - Quantity(2.0), throwsArgumentError);
    });

    test('multiplication by num', () {
      expect((Quantity(2.0) * 3).value, closeTo(6.0, 0.001));
    });

    test('multiplication by double', () {
      expect((Quantity(2.0) * 1.5).value, closeTo(3.0, 0.001));
    });
  });

  group('Quantity equality', () {
    test('structural equality', () {
      expect(Quantity(1.5), equals(Quantity(1.5)));
    });

    test('inequality', () {
      expect(Quantity(1.5), isNot(equals(Quantity(2.0))));
    });

    test('equal values have same hashCode', () {
      expect(Quantity(1.5).hashCode, Quantity(1.5).hashCode);
    });
  });
}
