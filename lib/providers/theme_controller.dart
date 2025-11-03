import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  static void toggle(Brightness platformBrightness) {
    final nextMode = isDarkMode(themeMode.value, platformBrightness)
        ? ThemeMode.light
        : ThemeMode.dark;
    themeMode.value = nextMode;
  }

  static bool isDarkMode(ThemeMode mode, Brightness platformBrightness) {
    switch (mode) {
      case ThemeMode.system:
        return platformBrightness == Brightness.dark;
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
    }
  }
}
