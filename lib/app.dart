import 'package:flutter/material.dart';
import './theme/app_theme.dart';
import 'package:freeradius_app/providers/auth_provider.dart';
import 'package:freeradius_app/providers/theme_controller.dart';
import 'package:freeradius_app/screens/dashboard_screen.dart';
import 'package:freeradius_app/screens/database_screen.dart';
import 'package:freeradius_app/screens/login_screen.dart';
import 'package:freeradius_app/screens/nas_screen.dart';
import 'package:freeradius_app/screens/plans_screen.dart';
import 'package:freeradius_app/screens/pppoe_users_screen.dart';
import 'package:freeradius_app/screens/radius_status_screen.dart';
import 'package:freeradius_app/screens/user_guide_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (_, themeMode, __) {
        final initialRoute =
            AuthController.state.value.isAuthenticated ? '/home' : '/login';
        return MaterialApp(
          // debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          title: 'FreeRadius App',
          initialRoute: initialRoute,
          routes: {
            '/login': (_) => const Login(),
            '/home': (_) => const Dashboard(),
            '/pppoe_users': (_) => const PppoeUsers(),
            '/nas': (_) => const Nas(),
            '/plans': (_) => const Plans(),
            '/database': (_) => const Database(),
            '/radius_status': (_) => const RadiusStatus(),
            '/user_guide': (_) => const UserGuide(),
          },
        );
      },
    );
  }
}
