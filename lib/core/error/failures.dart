import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.properties = const []]);
  final List<Object> properties; // Changed from List to List<Object>

  @override
  List<Object> get props => properties;
}

class ServerFailure extends Failure {
  final String? message;
  const ServerFailure({this.message});
  @override
  List<Object> get props => [message ?? ''];
}

class CacheFailure extends Failure {}

class NetworkFailure extends Failure {}

class AuthFailure extends Failure {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object> get props => [message];
}

class PaymentFailure extends Failure {
  final String message;
  const PaymentFailure(this.message);
  @override
  List<Object> get props => [message];
}

class BadRequestFailure extends Failure {
  final String message;
  const BadRequestFailure(this.message);
  @override
  List<Object> get props => [message];
}

class UnauthorizedFailure extends Failure {
  final String message;
  const UnauthorizedFailure(this.message);
  @override
  List<Object> get props => [message];
}

class ForbiddenFailure extends Failure {
  final String message;
  const ForbiddenFailure(this.message);
  @override
  List<Object> get props => [message];
}

class NotFoundFailure extends Failure {
  final String message;
  const NotFoundFailure(this.message);
  @override
  List<Object> get props => [message];
}

class OperationCanceledFailure extends Failure {}
