import 'package:meta/meta.dart';

@immutable
class Money {
  factory Money.fromCents(final int cents) {
    if (cents < 0) throw ArgumentError('Money cannot be negative: $cents');
    return Money._(cents);
  }

  factory Money.fromReais(final double reais) {
    if (reais < 0) throw ArgumentError('Money cannot be negative: $reais');
    return Money._((reais * 100).round());
  }

  const Money.zero() : _cents = 0;
  const Money._(this._cents);

  final int _cents;

  int get cents => _cents;
  double get reais => _cents / 100.0;

  Money operator +(final Money other) => Money._(_cents + other._cents);

  Money operator -(final Money other) {
    final result = _cents - other._cents;
    if (result < 0) throw ArgumentError('Money subtraction result is negative');
    return Money._(result);
  }

  Money operator *(final num factor) {
    if (factor < 0) throw ArgumentError('Factor cannot be negative: $factor');
    return Money._((_cents * factor).round());
  }

  bool operator >(final Money other) => _cents > other._cents;
  bool operator <(final Money other) => _cents < other._cents;
  bool operator >=(final Money other) => _cents >= other._cents;
  bool operator <=(final Money other) => _cents <= other._cents;

  @override
  bool operator ==(final Object other) =>
      other is Money && other._cents == _cents;

  @override
  int get hashCode => _cents.hashCode;

  String format({final String locale = 'pt-BR', final String symbol = 'R\$'}) {
    final intPart = _cents ~/ 100;
    final fracPart = _cents % 100;
    final fracStr = fracPart.toString().padLeft(2, '0');
    final thousands = _formatThousands(intPart, locale);
    final decimal = (locale == 'pt-BR' || locale == 'es-ES') ? ',' : '.';
    return '$symbol $thousands$decimal$fracStr';
  }

  static String _formatThousands(final int value, final String locale) {
    final str = value.toString();
    final sep = (locale == 'pt-BR' || locale == 'es-ES') ? '.' : ',';
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(sep);
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  String toString() => format();
}
