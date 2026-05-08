import 'package:flutter/material.dart';

class AppColors {
  static const Color bg = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color brand = Color(
    0xFFEA580C,
  ); //color naranja para el sistema de diseño
  static const Color dark = Color(0xFF0B1220);
  static const Color pill = Color(0xFFF1F5F9);
}

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0});
  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light, //basado en el bg
      //configuraacion de colores principales
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        primary: AppColors.brand,
        surface: AppColors.card,
        background: AppColors.bg,
        onBackground: AppColors.text,
        onSurface: AppColors.text,
        outline: AppColors.border,
      ),
      //personalizacion de componentes
      scaffoldBackgroundColor: AppColors.bg,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.brand,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      //estilos para los inputs (usando los colores definidios de borde y texto )
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brand, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.muted),
      ),

      //estilo para botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
