import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'dev/widget_showcase_screen.dart';
import 'features/landing/presentation/landingscreen.dart';
import 'features/Auth/presentation/loginscreen.dart';
import 'features/Auth/presentation/registration_step2_screen.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Vault',
      theme: AppTheme.light,
      home: const LandingScreen(),
      // home: const SignupStep2Screen(),
    );
  }
}
