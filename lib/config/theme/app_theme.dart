import 'package:flutter/material.dart';

class AppColors {
   static const Color bg = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);

  static const Color text = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  static const Color border = Color(0xFFE2E8F0);

  static const Color brand = Color(0xFFEA580C);
  static const Color brandDark = Color(0xFFC2410C);
  static const Color brandSoft = Color(0xFFFFEDD5);

  static const Color onBrand = Colors.white;

  static const Color dark = Color(0xFF0B1220);
  static const Color pill = Color(0xFFF1F5F9);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
}

class AppTheme {
  const AppTheme();

  ThemeData theme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.brand,
      onPrimary: AppColors.onBrand,
      secondary: AppColors.brandDark,
      surface: AppColors.card,
      onSurface: AppColors.text,
      outline: AppColors.border,
      error: AppColors.danger,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bg,
    );

    return baseTheme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.brand,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: AppColors.onBrand,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.onBrand,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.brand,
        textColor: AppColors.text,
        selectedColor: AppColors.brand,
        selectedTileColor: AppColors.brandSoft,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.border,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          color: AppColors.muted,
        ),
        labelStyle: const TextStyle(
          color: AppColors.muted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.brand,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.danger,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.danger,
            width: 2,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.onBrand,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.muted,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand,
          side: const BorderSide(
            color: AppColors.brand,
          ),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.dark,
        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brand,
      ),

      textTheme: baseTheme.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
    );
  }
}
