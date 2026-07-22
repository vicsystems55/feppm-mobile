import 'package:hive/hive.dart';

import 'auth_session.dart';

class AuthStorage {
  static const _boxName = 'feppm_auth';
  static const _tokenKey = 'access_token';
  static const _userKey = 'user';
  static const _cookieKey = 'refresh_cookie';

  static Future<void> initialize() => Hive.openBox<dynamic>(_boxName);

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  AuthSession? read() {
    final token = _box.get(_tokenKey);
    final rawUser = _box.get(_userKey);
    if (token is! String || rawUser is! Map) return null;

    return AuthSession(
      accessToken: token,
      user: AuthUser.fromJson(Map<String, dynamic>.from(rawUser)),
      refreshCookie: _box.get(_cookieKey) as String?,
    );
  }

  Future<void> save(AuthSession session) async {
    await _box.putAll({
      _tokenKey: session.accessToken,
      _userKey: session.user.toJson(),
      if (session.refreshCookie != null) _cookieKey: session.refreshCookie,
    });
  }

  Future<void> clear() => _box.clear();
}
