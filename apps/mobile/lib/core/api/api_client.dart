import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_error_mapper.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

typedef AccessTokenReader = Future<String?> Function();

final class ApiClient {
  ApiClient({
    required EnvironmentConfig config,
    required AccessTokenReader readAccessToken,
    Dio? dio,
    ApiErrorMapper errorMapper = const ApiErrorMapper(),
  }) : _readAccessToken = readAccessToken,
       _errorMapper = errorMapper,
       dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: config.apiBaseUrl.toString(),
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 20),
               headers: const {'Accept': 'application/json'},
             ),
           ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['X-Request-ID'] = const Uuid().v7();
          final token = await _readAccessToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
  final AccessTokenReader _readAccessToken;
  final ApiErrorMapper _errorMapper;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.get<Object>(path, queryParameters: query);
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
        path,
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
      final response = await dio.patch<Object>(path, data: data);
      return _asJson(response.data);
    } catch (error) {
      throw _errorMapper.map(error);
    }
  }

  Future<void> delete(String path) async {
    try {
      await dio.delete<void>(path);
    } catch (error) {
      throw _errorMapper.map(error);
    }
  }

  Map<String, dynamic> _asJson(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const ServerException('The server returned an invalid response.');
  }
}
