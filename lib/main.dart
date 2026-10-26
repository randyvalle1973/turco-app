import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() {
  runApp(const TurcoApp());
}

class TurcoApp extends StatelessWidget {
  const TurcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, modo, child) {
        return MaterialApp.router(
          title: 'Turco',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          themeMode: modo,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
