import 'package:feppm_mobile/core/auth/auth_controller.dart';
import 'package:feppm_mobile/core/auth/auth_service.dart';
import 'package:feppm_mobile/core/auth/auth_storage.dart';
import 'package:feppm_mobile/features/login/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the FEPPM login form', (tester) async {
    final controller = AuthController(
      service: AuthService(),
      storage: AuthStorage(),
    );
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(authController: controller)),
    );

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
