import 'package:flutter/material.dart';
import 'package:freeradius_app/screens/dashboard.dart';
import 'package:freeradius_app/screens/database.dart';
import 'package:freeradius_app/screens/nas.dart';
import 'package:freeradius_app/screens/pppoe_users.dart';
import 'package:freeradius_app/screens/radius_status.dart';
import 'package:freeradius_app/screens/user_guide.dart';

// Win+Ctrol+t to open on top
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeRadius App',
      initialRoute: '/home',
      routes: {
        '/home': (context) => const Dashboard(),
        '/pppoe_users': (context) => const PppoeUsers(),
        '/nas': (context) => const Nas(),
        '/database': (context) => const Database(),
        '/radius_status': (context) => const RadiusStatus(),
        '/user_guide': (context) => const UserGuide(),
      },
    );
  }
}
