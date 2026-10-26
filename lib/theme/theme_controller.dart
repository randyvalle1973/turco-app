import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  static void toggle() {
    mode.value = mode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }
}
