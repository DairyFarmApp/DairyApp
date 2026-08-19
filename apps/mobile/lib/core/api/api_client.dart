import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_error_mapper.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

typedef AccessTokenReader = Future<String?> Function();
typedef RenewalCredentialReader = Future<String?> Function();
typedef SessionTokenWriter =
    Future<void> Function({
      required String accessToken,
      required String renewalCredential,
    });
typedef SessionClearer = Future<void> Function();

final class ApiClient {
  ApiClient({
    required EnvironmentConfig config,
    required AccessTokenReader readAccessToken,
    RenewalCredentialReader? readRenewalCredential,
    SessionTokenWriter? saveTokens,
    SessionClearer? clearSession,
    Dio? dio,
    ApiErrorMapper errorMapper = const ApiErrorMapper(),
  }) : _readAccessToken = readAccessToken,
       _readRenewalCredential = readRenewalCredential,
       _saveTokens = saveTokens,
       _clearSession = clearSession,
       _errorMapper = errorMapper,
       _normalizesRelativePaths = dio == null,
       dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: _normalizedBaseUrl(config.apiBaseUrl),
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 20),
               headers: const {'Accept': 'application/json'},
             ),
           ) {
    this.dio.options.baseUrl = _normalizedBaseUrl(config.apiBaseUrl);
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['X-Request-ID'] = const Uuid().v7();
          final token = await _readAccessToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) async {
          if (!_canRenew(error)) {
            handler.next(error);
            return;
          }
          try {
            final token = await _renewAccessToken();
            if (token == null) {
              handler.next(error);
              return;
            }
            final retry = error.requestOptions;
            retry.extra['session_retry'] = true;
            retry.headers['Authorization'] = 'Bearer $token';
            handler.resolve(await this.dio.fetch<Object>(retry));
          } catch (_) {
            await _clearSession?.call();
            handler.next(error);
          }
        },
      ),
    );
  }

  final Dio dio;
  final AccessTokenReader _readAccessToken;
  final RenewalCredentialReader? _readRenewalCredential;
  final SessionTokenWriter? _saveTokens;
  final SessionClearer? _clearSession;
  final ApiErrorMapper _errorMapper;
  final bool _normalizesRelativePaths;
  Future<String?>? _renewalInFlight;

  bool _canRenew(DioException error) {
    final path = error.requestOptions.path;
    return error.response?.statusCode == 401 &&
        error.requestOptions.extra['session_retry'] != true &&
        error.requestOptions.extra['skip_session_renewal'] != true &&
        !path.contains('auth/login') &&
        !path.contains('auth/renew') &&
        _readRenewalCredential != null &&
        _saveTokens != null;
  }

  Future<String?> _renewAccessToken() {
    final current = _renewalInFlight;
    if (current != null) return current;
    final renewal = _performRenewal();
    _renewalInFlight = renewal;
    return renewal.whenComplete(() => _renewalInFlight = null);
  }

  Future<String?> _performRenewal() async {
    final credential = await _readRenewalCredential?.call();
    if (credential == null || credential.isEmpty) return null;
    final response = await dio.post<Object>(
      _normalizePath('/auth/renew'),
      data: {'renewal_credential': credential},
      options: Options(extra: {'skip_session_renewal': true}),
    );
    final body = _asJson(response.data);
    final data = body['data'] as Map<String, dynamic>;
    final accessToken = data['access_token'] as String;
    final renewalCredential = data['renewal_credential'] as String;
    await _saveTokens!(
      accessToken: accessToken,
      renewalCredential: renewalCredential,
    );
    return accessToken;
  }

  String _normalizePath(String path) {
    // Injected Dio clients are test doubles that inspect the repository's
    // logical path. The real client must use a relative path so URI resolution
    // retains the configured /api/v1/ prefix.
    if (!_normalizesRelativePaths) return path;
    if (path.startsWith('/api/v1/')) {
      return path.substring(8);
    }
    if (path.startsWith('/v1/')) {
      return path.substring(4);
    }
    return path.replaceFirst(RegExp(r'^/+'), '');
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.get<Object>(
        _normalizePath(path),
        queryParameters: query,
      );
      return _asJson(response.data);
    } catch (error) {
      throw _errorMapper.map(error);
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? data,
    String? idempotencyKey,
  }) async {
    try {
      final response = await dio.post<Object>(
        _normalizePath(path),
        data: data,
        options: Options(
          headers: idempotencyKey == null
              ? null
              : {'Idempotency-Key': idempotencyKey},
        ),
      );
      return _asJson(response.data);
    } catch (error) {
      throw _errorMapper.map(error);
    }
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    required Object data,
  }) async {
    try {
      final response = await dio.patch<Object>(
        _normalizePath(path),
        data: data,
      );
      return _asJson(response.data);
    } catch (error) {
      throw _errorMapper.map(error);
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, dynamic> fields,
    required String fileField,
    required Uint8List bytes,
    required String filename,
    String? idempotencyKey,
  }) async {
    try {
      final response = await dio.post<Object>(
        _normalizePath(path),
        data: FormData.fromMap({
          ...fields,
          fileField: MultipartFile.fromBytes(bytes, filename: filename),
        }),
        options: Options(headers: {'Idempotency-Key': ?idempotencyKey}),
      );
      return _asJson(response.data);
    } catch (error) {
      throw _errorMapper.map(error);
    }
  }

  Future<Uint8List> getBytes(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await dio.get<List<int>>(
        _normalizePath(path),
        queryParameters: query,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data ?? const []);
    } catch (error) {
      throw _errorMapper.map(error);
    }
  }

  Future<void> delete(String path) async {
    await deleteJson(path);
  }

  Future<Map<String, dynamic>> deleteJson(String path, {Object? data}) async {
    try {
      final response = await dio.delete<Object>(
        _normalizePath(path),
        data: data,
      );
      return _asJson(response.data);
    } catch (error) {
      throw _errorMapper.map(error);
    }
  }

  Map<String, dynamic> _asJson(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const ServerException('The server returned an invalid response.');
  }
}

String _normalizedBaseUrl(Uri value) {
  final text = value.toString();
  return text.endsWith('/') ? text : '$text/';
}
