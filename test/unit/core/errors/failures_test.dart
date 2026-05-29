import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/errors/failures.dart';

void main() {
  group('Failure equality', () {
    test('LocalDatabaseFailure equals same message', () {
      expect(
        const LocalDatabaseFailure('db error'),
        equals(const LocalDatabaseFailure('db error')),
      );
    });

    test('LocalDatabaseFailure not equal different message', () {
      expect(
        const LocalDatabaseFailure('a'),
        isNot(equals(const LocalDatabaseFailure('b'))),
      );
    });

    test('ValidationFailure equals same message', () {
      expect(
        const ValidationFailure('invalid'),
        equals(const ValidationFailure('invalid')),
      );
    });

    test('NotFoundFailure equals same message', () {
      expect(
        const NotFoundFailure('missing'),
        equals(const NotFoundFailure('missing')),
      );
    });

    test('NetworkFailure equals same message', () {
      expect(
        const NetworkFailure('timeout'),
        equals(const NetworkFailure('timeout')),
      );
    });

    test('AuthFailure equals same message', () {
      expect(
        const AuthFailure('unauthorized'),
        equals(const AuthFailure('unauthorized')),
      );
    });

    test('different Failure types not equal even with same message', () {
      expect(
        const LocalDatabaseFailure('msg'),
        isNot(equals(const ValidationFailure('msg'))),
      );
    });
  });

  group('Failure hashCode', () {
    test('equal failures have same hashCode', () {
      expect(
        const NetworkFailure('err').hashCode,
        const NetworkFailure('err').hashCode,
      );
    });
  });

  group('Failure message', () {
    test('message is preserved', () {
      expect(const AuthFailure('not allowed').message, 'not allowed');
    });
  });
}
