sealed class AppException implements Exception {
  const AppException(this.message, {this.code, this.fieldErrors = const {}});

  final String message;
  final String? code;
  final Map<String, List<String>> fieldErrors;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

final class TransientServerException extends AppException {
  const TransientServerException(super.message, {super.code});
}

final class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.code});
}

final class AuthorizationException extends AppException {
  const AuthorizationException(super.message, {super.code});
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.fieldErrors});
}

final class ConflictException extends AppException {
  const ConflictException(super.message, {super.code});
}

final class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}
