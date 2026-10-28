import 'package:flutter/material.dart';

import 'theme/theme_controller.dart';
import 'router/app_router.dart';

class TurcoApp extends StatelessWidget {
  const TurcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, child) {
        return MaterialApp.router(
          title: 'Turco',

          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00796B),
              brightness: Brightness.light,
              primary: const Color(0xFF00796B),
              secondary: const Color(0xFF80E8D8),
              surface: const Color(0xFFF4F9F7),
            ),
            scaffoldBackgroundColor: const Color(0xFFF4F9F7),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00796B),
              brightness: Brightness.dark,
              primary: const Color(0xFF80E8D8),
              secondary: const Color(0xFF00796B),
              surface: const Color(0xFF202A28),
            ),
            scaffoldBackgroundColor: const Color(0xFF151C1A),
            useMaterial3: true,
          ),

          themeMode: mode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}

void main() {
  runApp(const TurcoApp());
}
