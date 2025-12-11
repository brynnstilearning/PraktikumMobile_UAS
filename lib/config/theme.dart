import 'package:flutter/material.dart';

// File ini berisi definisi tema untuk Light & Dark Mode

class AppColors {
  // Primary Colors
  static const primaryPink = Color(0xFFE94C6F);
  static const primaryPurple = Color(0xFF7C6FE8);
  
  // Accent Colors
  static const accentBlue = Color(0xFF4ECDC4);
  static const accentYellow = Color(0xFFFFD93D);
  static const accentGreen = Color(0xFF6BCB77);
  
  // Light Theme Colors
  static const bgLight = Color(0xFFF8F9FA);
  static const cardLight = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF2D3436);
  static const textLight = Color(0xFF636E72);
  
  // Dark Theme Colors
  static const bgDark = Color(0xFF1A1A1A);
  static const cardDark = Color(0xFF2D2D2D);
  static const textWhite = Color(0xFFFFFFFF);
  static const textGray = Color(0xFFB0B0B0);
}

class AppTheme {

  // 🌞 LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryPink,
    scaffoldBackgroundColor: AppColors.bgLight,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryPink,
      secondary: AppColors.primaryPurple,
      surface: AppColors.cardLight,
      error: Colors.red,
    ),

    // Text Theme (menggunakan default system font)
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textLight,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.cardLight,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(
        color: AppColors.textLight,
        fontSize: 14,
      ),
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.bgLight,
      foregroundColor: AppColors.textDark,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    ),
  );

  // 🌙 DARK THEME
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryPink,
    scaffoldBackgroundColor: AppColors.bgDark,
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryPink,
      secondary: AppColors.primaryPurple,
      surface: AppColors.cardDark,
      error: Colors.red,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textWhite,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textGray,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.cardDark,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(
        color: AppColors.textGray,
        fontSize: 14,
      ),
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.bgDark,
      foregroundColor: AppColors.textWhite,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
    ),
  );
}