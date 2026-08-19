import 'dart:convert';
import 'dart:typed_data';

import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('relative feature paths retain the configured api v1 prefix', () async {
    late Uri requestedUri;
    final api = ApiClient(
      config: EnvironmentConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: Uri.parse('http://192.168.1.47:8001/api/v1'),
      ),
      readAccessToken: () async => 'test-token',
    );
    api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestedUri = options.uri;
          handler.resolve(
            Response<Object>(
              requestOptions: options,
              statusCode: 200,
              data: {'data': <Object>[]},
            ),
          );
        },
      ),
    );

    await api.getJson('/animals');

    expect(requestedUri.toString(), 'http://192.168.1.47:8001/api/v1/animals');
  });

  test(
    'already-prefixed paths are normalized without duplicating api v1',
    () async {
      late Uri requestedUri;
      final api = ApiClient(
        config: EnvironmentConfig(
          environment: AppEnvironment.development,
          apiBaseUrl: Uri.parse('https://api.example.test/api/v1'),
        ),
        readAccessToken: () async => null,
      );
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedUri = options.uri;
            handler.resolve(
              Response<Object>(
                requestOptions: options,
                statusCode: 200,
                data: {'data': <Object>[]},
              ),
            );
          },
        ),
      );

      await api.getJson('/api/v1/inventory');

      expect(
        requestedUri.toString(),
        'https://api.example.test/api/v1/inventory',
      );
    },
  );

  test('expired data request renews the session and retries once', () async {
    var storedAccessToken = 'expired-token';
    var storedRenewalCredential = 'renewal-one';
    var animalAttempts = 0;
    final dio = Dio();
    final api = ApiClient(
      config: EnvironmentConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: Uri.parse('https://api.example.test/api/v1'),
      ),
      readAccessToken: () async => storedAccessToken,
      readRenewalCredential: () async => storedRenewalCredential,
      saveTokens: ({required accessToken, required renewalCredential}) async {
        storedAccessToken = accessToken;
        storedRenewalCredential = renewalCredential;
      },
      dio: dio,
    );
    dio.httpClientAdapter = _RenewalAdapter(
      onAnimalRequest: () => animalAttempts++,
    );

    await api.getJson('/animals');

    expect(animalAttempts, 2);
    expect(storedAccessToken, 'fresh-token');
    expect(storedRenewalCredential, 'renewal-two');
  });
}

final class _RenewalAdapter implements HttpClientAdapter {
  _RenewalAdapter({required this.onAnimalRequest});

  final void Function() onAnimalRequest;
  var _animalAttempts = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/auth/renew') {
      return ResponseBody.fromString(
        jsonEncode({
          'data': {
            'access_token': 'fresh-token',
            'renewal_credential': 'renewal-two',
          },
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    _animalAttempts++;
    onAnimalRequest();
    return ResponseBody.fromString(
      jsonEncode(
        _animalAttempts == 1
            ? {
                'error': {'code': 'UNAUTHENTICATED'},
              }
            : {'data': <Object>[]},
      ),
      _animalAttempts == 1 ? 401 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
