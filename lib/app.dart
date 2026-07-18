import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

class FeppmApp extends StatelessWidget {
  const FeppmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FEPPM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DashboardScreen(),
    );
  }
}
