import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dio/dio.dart';

final class ApiErrorMapper {
  const ApiErrorMapper();

  AppException map(Object error) {
    if (error is AppException) return error;
    if (error is! DioException) {
      return const ServerException('An unexpected error occurred.');
    }

    final response = error.response;
    final payload = response?.data;
    final errorBody = payload is Map<String, dynamic>
        ? payload['error'] as Map<String, dynamic>?
        : null;
    final code = errorBody?['code'] as String?;
    final message =
        errorBody?['message'] as String? ??
        (response == null
            ? 'Unable to reach the server.'
            : 'The request could not be completed.');
    final status = response?.statusCode;

    if (status == null) return NetworkException(message, code: code);
    if (status == 408 || status == 425 || status == 429 || status >= 500) {
      return TransientServerException(message, code: code);
    }
    if (status == 401) return AuthenticationException(message, code: code);
    if (status == 403) return AuthorizationException(message, code: code);
    if (status == 409 || status == 412) {
      return ConflictException(message, code: code);
    }
    if (status == 422) {
      return ValidationException(
        message,
        code: code,
        fieldErrors: _fieldErrors(errorBody?['fields']),
      );
    }
    return ServerException(message, code: code);
  }

  Map<String, List<String>> _fieldErrors(Object? raw) {
    if (raw is! Map<String, dynamic>) return const {};
    return raw.map((field, value) {
      final entries = value is List ? value : [value];
      return MapEntry(
        field,
        entries
            .map(
              (entry) => entry is Map<String, dynamic>
                  ? entry['message']?.toString() ?? 'Invalid value.'
                  : entry.toString(),
            )
            .toList(growable: false),
      );
    });
  }
}
