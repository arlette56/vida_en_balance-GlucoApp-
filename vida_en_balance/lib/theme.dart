import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFFDFCF7);
  static const forest = Color(0xFF3B6B2A);
  static const forestDark = Color(0xFF263A1B);
  static const sage = Color(0xFF9DB27A);
  static const sageSoft = Color(0xFFEAF0DD);
  static const sageLine = Color(0xFFD3DBC1);
  static const ink = Color(0xFF2B2F26);
  static const muted = Color(0xFF6B7062);
  static const amber = Color(0xFFB8741A);
  static const amberSoft = Color(0xFFFBEFC9);
  static const danger = Color(0xFFC0392B);
  static const dangerSoft = Color(0xFFFBE9E7);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: GoogleFonts.loraTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.forest
            : AppColors.sageLine,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}

/// Tipografía manuscrita usada en títulos de marca («Glucosa Registrada»).
TextStyle scriptStyle(double size, {Color color = AppColors.forest}) =>
    GoogleFonts.dancingScript(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
    );
