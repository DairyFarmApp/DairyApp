import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SessionStore {
  Future<String?> readAccessToken();
  Future<String?> readRenewalCredential();
  Future<void> saveTokens({
    required String accessToken,
    required String renewalCredential,
  });
  Future<void> clear();
}

final class SecureSessionStore implements SessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'session.access_token';
  static const _renewalKey = 'session.renewal_credential';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> readRenewalCredential() => _storage.read(key: _renewalKey);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String renewalCredential,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _renewalKey, value: renewalCredential);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _renewalKey);
  }
}
