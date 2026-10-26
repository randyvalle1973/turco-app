import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryClaro = Color(0xFF006A60);
  static const Color primaryContainerClaro = Color(0xFF9EF2E4);
  static const Color secondaryContainerClaro = Color(0xFFCCE8E2);
  static const Color tertiaryClaro = Color(0xFF456179);
  static const Color fondoClaro = Color(0xFFF4FBF9);
  static const Color superficieContainerClaro = Color(0xFFE9EFED);
  static const Color textoClaro = Color(0xFF161D1C);
  static const Color textoSecundarioClaro = Color(0xFF3F4947);
  static const Color bordeClaro = Color(0xFF6F7977);
  static const Color errorClaro = Color(0xFFBA1A1A);

  static const Color primaryOscuro = Color(0xFF53DBC9);
  static const Color primaryContainerOscuro = Color(0xFF005047);
  static const Color secondaryContainerOscuro = Color(0xFF314B47);
  static const Color tertiaryOscuro = Color(0xFFADCAE6);
  static const Color fondoOscuro = Color(0xFF0E1514);
  static const Color superficieContainerOscuro = Color(0xFF1A2120);
  static const Color textoOscuro = Color(0xFFDDE4E2);
  static const Color textoSecundarioOscuro = Color(0xFFBEC9C6);
  static const Color bordeOscuro = Color(0xFF899390);
  static const Color errorOscuro = Color(0xFFFFB4AB);

  static ThemeData get claro {
    final esquema =
        ColorScheme.fromSeed(
          seedColor: primaryClaro,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryClaro,
          onPrimary: Colors.white,
          primaryContainer: primaryContainerClaro,
          onPrimaryContainer: const Color(0xFF00201C),
          secondaryContainer: secondaryContainerClaro,
          tertiary: tertiaryClaro,
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFCDE5FF),
          onTertiaryContainer: const Color(0xFF001D32),
          surface: fondoClaro,
          onSurface: textoClaro,
          surfaceContainer: superficieContainerClaro,
          onSurfaceVariant: textoSecundarioClaro,
          outline: bordeClaro,
          error: errorClaro,
          onError: Colors.white,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: esquema,
      scaffoldBackgroundColor: fondoClaro,
      appBarTheme: const AppBarTheme(
        backgroundColor: fondoClaro,
        foregroundColor: textoClaro,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: superficieContainerClaro,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficieContainerClaro,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bordeClaro),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bordeClaro),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryClaro, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryClaro,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: fondoClaro,
        indicatorColor: primaryContainerClaro,
      ),
    );
  }

  static ThemeData get oscuro {
    final esquema =
        ColorScheme.fromSeed(
          seedColor: primaryOscuro,
          brightness: Brightness.dark,
        ).copyWith(
          primary: primaryOscuro,
          onPrimary: const Color(0xFF003731),
          primaryContainer: primaryContainerOscuro,
          onPrimaryContainer: const Color(0xFF9EF2E4),
          secondaryContainer: secondaryContainerOscuro,
          tertiary: tertiaryOscuro,
          onTertiary: const Color(0xFF001D32),
          tertiaryContainer: const Color(0xFF2D4A62),
          onTertiaryContainer: const Color(0xFFCDE5FF),
          surface: fondoOscuro,
          onSurface: textoOscuro,
          surfaceContainer: superficieContainerOscuro,
          onSurfaceVariant: textoSecundarioOscuro,
          outline: bordeOscuro,
          error: errorOscuro,
          onError: const Color(0xFF690005),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: esquema,
      scaffoldBackgroundColor: fondoOscuro,
      appBarTheme: const AppBarTheme(
        backgroundColor: fondoOscuro,
        foregroundColor: textoOscuro,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: superficieContainerOscuro,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficieContainerOscuro,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bordeOscuro),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bordeOscuro),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOscuro, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOscuro,
          foregroundColor: const Color(0xFF003731),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: fondoOscuro,
        indicatorColor: secondaryContainerOscuro,
      ),
    );
  }
}
