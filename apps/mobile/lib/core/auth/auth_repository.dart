import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/core/auth/session_models.dart';
import 'package:dairycare_mobile/core/errors/app_exception.dart';
import 'package:dairycare_mobile/core/storage/secure_session_store.dart';

final class AuthRepository {
  const AuthRepository({required ApiClient api, required SessionStore store})
    : _api = api,
      _store = store;

  final ApiClient _api;
  final SessionStore _store;

  Future<AuthSession?> restore() async {
    if (await _store.readAccessToken() == null) return null;
    try {
      return _sessionFrom(await _api.getJson('/auth/me'));
    } on AuthenticationException {
      try {
        return await renew();
      } on AppException {
        await _store.clear();
        return null;
      }
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) => _authenticate('/auth/login', {'email': email, 'password': password});

  Future<AuthSession> renew() async {
    final credential = await _store.readRenewalCredential();
    if (credential == null) {
      throw const AuthenticationException('Your session has expired.');
    }
    return _authenticate('/auth/renew', {'renewal_credential': credential});
  }

  Future<AuthSession> switchOrganization(String organizationId) =>
      _contextSwitch('/auth/switch-organization', {
        'organization_id': organizationId,
      });

  Future<AuthSession> switchFarm(String farmId) =>
      _contextSwitch('/auth/switch-farm', {'farm_id': farmId});

  Future<void> logout() async {
    try {
      await _api.postJson('/auth/logout');
    } finally {
      await _store.clear();
    }
  }

  Future<AuthSession> _authenticate(
    String path,
    Map<String, dynamic> request,
  ) async {
    final body = await _api.postJson(path, data: request);
    final data = body['data'] as Map<String, dynamic>;
    await _store.saveTokens(
      accessToken: data['access_token'] as String,
      renewalCredential: data['renewal_credential'] as String,
    );
    return AuthSession.fromJson(data);
  }

  Future<AuthSession> _contextSwitch(
    String path,
    Map<String, dynamic> request,
  ) async {
    final body = await _api.postJson(path, data: request);
    final data = body['data'] as Map<String, dynamic>;
    final accessToken = data['access_token'] as String?;
    final renewal = data['renewal_credential'] as String?;
    if (accessToken != null && renewal != null) {
      await _store.saveTokens(
        accessToken: accessToken,
        renewalCredential: renewal,
      );
    }
    return AuthSession.fromJson(data);
  }

  AuthSession _sessionFrom(Map<String, dynamic> body) =>
      AuthSession.fromJson(body['data'] as Map<String, dynamic>);
}
