import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // Keys under which the tokens are stored. Constants avoid typos.
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  // Encrypted storage (Keychain on iOS, Keystore on Android).
  // Better than SharedPreferences, which is plain text.
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Returns null if nothing is saved (user not logged in).
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  // Called after login, register and every token refresh.
  // Both tokens are saved together because the backend issues a new pair each time.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  // Called on logout, or when the refresh fails (session expired).
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
