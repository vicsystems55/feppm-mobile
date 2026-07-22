import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'auth_session.dart';
import 'auth_storage.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthService service, required AuthStorage storage})
    : _service = service,
      _storage = storage;

  final AuthService _service;
  final AuthStorage _storage;
  AuthSession? _session;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthUser? get user => _session?.user;

  void restoreSession() {
    _session = _storage.read();
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _service.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      if (rememberMe) {
        await _storage.save(_session!);
      } else {
        await _storage.clear();
      }
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    final session = _session;
    _session = null;
    _errorMessage = null;
    await _storage.clear();
    notifyListeners();
    await _service.logout(session);
  }
}
