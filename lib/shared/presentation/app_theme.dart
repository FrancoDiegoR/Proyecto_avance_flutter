import 'package:flutter/material.dart';

/// Mismos colores que la app Android y la web (styles.css).
class AppColors {
  static const blue = Color(0xFF066CBB);
  static const orange = Color(0xFFE6501F);
  static const green = Color(0xFF1A8A54);
  static const red = Color(0xFFD64545);
  static const amber = Color(0xFFB76E00);
  static const grey = Color(0xFF64748B);
  static const background = Color(0xFFF2F8FD);
  static const line = Color(0xFFDFE8F1);
  static const muted = Color(0xFF6E7B88);
}

ThemeData buildAppTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue, primary: AppColors.blue),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.background, surfaceTintColor: Colors.transparent),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
    );

/// Color segun el estado: verde seguro, naranja advertencia, rojo critico.
Color statusColor(String status) {
  switch (status.toLowerCase().replaceAll(' ', '')) {
    case 'safe':
    case 'online':
    case 'resolved':
      return AppColors.green;
    case 'warning':
    case 'high':
    case 'active':
      return AppColors.orange;
    case 'critical':
      return AppColors.red;
    default:
      return AppColors.blue;
  }
}
