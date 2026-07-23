import 'package:dairycare_mobile/core/api/api_error_mapper.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps API validation envelope to typed field errors', () {
    final request = RequestOptions(path: '/farms');
    final error = DioException(
      requestOptions: request,
      response: Response<Object>(
        requestOptions: request,
        statusCode: 422,
        data: {
          'error': {
            'code': 'VALIDATION_FAILED',
            'message': 'The request could not be processed.',
            'fields': {
              'name': [
                {'code': 'required', 'message': 'Name is required.'},
              ],
            },
          },
        },
      ),
    );

    final mapped = const ApiErrorMapper().map(error);
    expect(mapped, isA<ValidationException>());
    expect(mapped.code, 'VALIDATION_FAILED');
    expect(mapped.fieldErrors['name'], ['Name is required.']);
  });

  test('maps connection failure to network exception', () {
    final mapped = const ApiErrorMapper().map(
      DioException(requestOptions: RequestOptions(path: '/auth/me')),
    );
    expect(mapped, isA<NetworkException>());
  });

  test('maps retryable HTTP response to transient exception', () {
    final request = RequestOptions(path: '/sync');
    final mapped = const ApiErrorMapper().map(
      DioException(
        requestOptions: request,
        response: Response<Object>(
          requestOptions: request,
          statusCode: 503,
          data: {
            'error': {'code': 'SERVICE_UNAVAILABLE'},
          },
        ),
      ),
    );
    expect(mapped, isA<TransientServerException>());
    expect(mapped.code, 'SERVICE_UNAVAILABLE');
  });
}
