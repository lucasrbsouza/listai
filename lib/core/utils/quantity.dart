import 'package:meta/meta.dart';

@immutable
class Quantity {
  factory Quantity(final double value) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError('Quantity must be finite and > 0: $value');
    }
    final rounded = (value * 1000).round() / 1000;
    return Quantity._(rounded);
  }

  factory Quantity.unit() => Quantity(1.0);
  const Quantity._(this._value);

  final double _value;

  double get value => _value;

  Quantity operator +(final Quantity other) => Quantity(_value + other._value);

  Quantity operator -(final Quantity other) {
    final result = _value - other._value;
    if (result <= 0) {
      throw ArgumentError('Quantity subtraction result must be > 0: $result');
    }
    return Quantity(result);
  }

  Quantity operator *(final num factor) {
    final result = _value * factor;
    if (result <= 0) {
      throw ArgumentError(
        'Quantity multiplication result must be > 0: $result',
      );
    }
    return Quantity(result);
  }

  @override
  bool operator ==(final Object other) =>
      other is Quantity && other._value == _value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value.toString();
}
