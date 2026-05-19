import 'package:meta/meta.dart';

@immutable
abstract class Failure {
  const Failure(this.message);
  final String message;

  @override
  bool operator ==(final Object other) =>
      runtimeType == other.runtimeType &&
      other is Failure &&
      other.message == message;

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

final class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
