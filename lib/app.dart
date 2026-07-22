import 'package:flutter/material.dart';

import 'core/auth/auth_controller.dart';
import 'core/auth/auth_service.dart';
import 'core/auth/auth_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/login/presentation/login_screen.dart';

class FeppmApp extends StatefulWidget {
  const FeppmApp({super.key});

  @override
  State<FeppmApp> createState() => _FeppmAppState();
}

class _FeppmAppState extends State<FeppmApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(
      service: AuthService(),
      storage: AuthStorage(),
    )..restoreSession();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,
      builder: (context, _) => MaterialApp(
        title: 'Mazilu Fe-PPM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: _authController.isAuthenticated
            ? DashboardScreen(
                userName: _authController.user?.displayName,
                userEmail: _authController.user?.email,
                accessToken: _authController.accessToken ?? '',
                onLogout: _authController.logout,
              )
            : LoginScreen(authController: _authController),
      ),
    );
  }
}
