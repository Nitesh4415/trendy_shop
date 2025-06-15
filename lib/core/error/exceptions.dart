class ServerException implements Exception {}

class CacheException implements Exception {}

class NetworkException implements Exception {}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);
}

// Added specific exceptions for Dio client errors
class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

class OperationCanceledException implements Exception {}
