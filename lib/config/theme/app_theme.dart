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

/// Semantic colors resolved from the active Material theme.
class AppPalette {
  final Brightness brightness;
  const AppPalette(this.brightness);

  bool get isDark => brightness == Brightness.dark;
  Color get bg => isDark ? const Color(0xFF0B1220) : AppColors.bg;
  Color get card => isDark ? const Color(0xFF151F30) : AppColors.card;
  Color get text => isDark ? const Color(0xFFF1F5F9) : AppColors.text;
  Color get muted => isDark ? const Color(0xFFA6B5CA) : AppColors.muted;
  Color get border => isDark ? const Color(0xFF334155) : AppColors.border;
  Color get brandSoft => isDark ? const Color(0xFF482610) : AppColors.brandSoft;
  Color get pill => isDark ? const Color(0xFF243247) : AppColors.pill;
  Color get successSoft =>
      isDark ? const Color(0xFF14372C) : const Color(0xFFEEF7F0);
  Color get success =>
      isDark ? const Color(0xFF4ADE80) : const Color(0xFF198754);
}

extension AppPaletteContext on BuildContext {
  AppPalette get appColors => AppPalette(Theme.of(this).brightness);
}

class AppTheme {
  const AppTheme();

  ThemeData theme({Brightness brightness = Brightness.light}) {
    final colors = AppPalette(brightness);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.brand,
          onPrimary: AppColors.onBrand,
          secondary: AppColors.brandDark,
          surface: colors.card,
          onSurface: colors.text,
          outline: colors.border,
          error: AppColors.danger,
        );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.bg,
    );

    return baseTheme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.brand,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.onBrand),
        titleTextStyle: TextStyle(
          color: AppColors.onBrand,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: colors.card,
        surfaceTintColor: Colors.transparent,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: AppColors.brand,
        textColor: colors.text,
        selectedColor: AppColors.brand,
        selectedTileColor: colors.brandSoft,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),

      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: TextStyle(color: colors.muted),
        labelStyle: TextStyle(color: colors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.danger, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.onBrand,
          disabledBackgroundColor: colors.border,
          disabledForegroundColor: colors.muted,
          elevation: 0,
          minimumSize: Size(double.infinity, 48),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand,
          side: BorderSide(color: AppColors.brand),
          minimumSize: Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand,
          textStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.dark,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.brand,
      ),

      textTheme: baseTheme.textTheme.apply(
        bodyColor: colors.text,
        displayColor: colors.text,
      ),
    );
  }
}
