import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_session.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api/v1',
  );

  final http.Client _client;

  Future<AuthSession> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'password': password,
              'rememberMe': rememberMe,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final payload = _decode(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthException(
          payload['message']?.toString() ?? 'Unable to sign in.',
        );
      }

      final data = Map<String, dynamic>.from(payload['data'] as Map);
      return AuthSession(
        accessToken: data['accessToken'] as String,
        user: AuthUser.fromJson(Map<String, dynamic>.from(data['user'] as Map)),
        refreshCookie: _cookiePair(response.headers['set-cookie']),
      );
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Could not connect to the server. Check your connection and try again.',
      );
    }
  }

  Future<void> logout(AuthSession? session) async {
    try {
      await _client
          .post(
            Uri.parse('$baseUrl/auth/logout'),
            headers: {
              if (session?.accessToken != null)
                'Authorization': 'Bearer ${session!.accessToken}',
              if (session?.refreshCookie != null)
                'Cookie': session!.refreshCookie!,
            },
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Local logout must still succeed if the server is unreachable.
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final value = jsonDecode(response.body);
      return value is Map<String, dynamic> ? value : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String? _cookiePair(String? setCookie) {
    if (setCookie == null || setCookie.isEmpty) return null;
    return setCookie.split(';').first;
  }
}
