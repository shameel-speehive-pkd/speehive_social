import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class AIServiceFailure extends Failure {
  const AIServiceFailure({required super.message, super.statusCode});
}

class ToolExecutionFailure extends Failure {
  const ToolExecutionFailure({required super.message, super.statusCode});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.statusCode = 401});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message}) : super(statusCode: null);
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
