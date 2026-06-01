import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF0a0a1a);
  static const backgroundSecondary = Color(0xFF12122a);

  static const lightBackground = Color(0xFFF1F5F9);
  static const lightBackgroundSecondary = Color(0xFFF8FAFC);
  static const lightCardBackground = Color(0xFFFFFFFF);
  static const lightCardBorder = Color(0xFFCBD5E1);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF475569);
  static const lightTextTertiary = Color(0xFF64748B);
  static const lightInputBackground = Color(0xFFF8FAFC);
  static const lightInputBorder = Color(0xFFCBD5E1);
  static const lightIconButtonBackground = Color(0xFFF1F5F9);
  static const lightIconButtonBorder = Color(0xFFCBD5E1);
  static const lightBottomNavBackground = Color(0xFFFFFFFF);
  static const lightBottomNavBorder = Color(0xFFE2E8F0);

  static const primary = Color(0xFF6366f1);
  static const primaryLight = Color(0xFF818cf8);
  static const primaryDark = Color(0xFF4f46e5);

  static const accent = Color(0xFF8b5cf6);
  static const accentLight = Color(0xFFa78bfa);

  static const success = Color(0xFF10b981);
  static const successDark = Color(0xFF059669);

  static const error = Color(0xFFef4444);
  static const errorDark = Color(0xFFdc2626);

  static const warning = Color(0xFFf59e0b);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF94a3b8);
  static const textTertiary = Color(0xFF64748b);

  static const cardBackground = Color.fromRGBO(255, 255, 255, 0.03);
  static const cardBorder = Color.fromRGBO(255, 255, 255, 0.08);
  static const cardHover = Color.fromRGBO(255, 255, 255, 0.06);

  static const inputBackground = Color.fromRGBO(255, 255, 255, 0.05);
  static const inputBorder = Color.fromRGBO(255, 255, 255, 0.1);

  static const iconButtonBackground = Color.fromRGBO(255, 255, 255, 0.05);
  static const iconButtonBorder = Color.fromRGBO(255, 255, 255, 0.1);

  static const bottomNavBackground = Color.fromRGBO(10, 10, 26, 0.95);

  static const lightCardShadow = Color.fromRGBO(0, 0, 0, 0.08);
  static const lightCardShadowHover = Color.fromRGBO(0, 0, 0, 0.12);
}

class AppTypography {
  AppTypography._();

  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.backgroundSecondary,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppTypography.headlineMedium,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textTertiary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bottomNavBackground,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.cardBorder,
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.lightBackgroundSecondary,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      titleTextStyle: AppTypography.headlineMedium,
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightCardBackground,
      elevation: 2,
      shadowColor: AppColors.lightCardShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightInputBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightInputBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
      hintStyle: const TextStyle(color: AppColors.lightTextTertiary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBottomNavBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.lightTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightCardBorder,
      thickness: 1,
      space: 1,
    ),
  );
}
