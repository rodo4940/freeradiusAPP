import 'package:flutter/material.dart';
import 'package:freeradius_app/app.dart';
import 'package:freeradius_app/providers/auth_provider.dart';

// Win+Control+t to open on top
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthController.init();
  runApp(const MyApp());
}
