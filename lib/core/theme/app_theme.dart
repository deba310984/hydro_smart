import 'package:flutter/material.dart';

class AppTheme {
  // Royal Indian Color Palette
  static const Color royalPurple = Color(0xFF4A1A6B);
  static const Color royalGold = Color(0xFFD4AF37);
  static const Color royalMaroon = Color(0xFF6B1A2E);
  static const Color ivoryWhite = Color(0xFFFFFFF0);
  static const Color saffron = Color(0xFFFF9933);
  static const Color peacockBlue = Color(0xFF1E5C6B);
  static const Color lotusWhite = Color(0xFFFDF4E3);

  // Smooth soft colors
  static const Color softPurple = Color(0xFF7B4B94);
  static const Color warmGold = Color(0xFFE8C068);
  static const Color creamWhite = Color(0xFFFFFCF5);

  // Elegant gradient for app bars - smoother transitions
  static LinearGradient get royalGradient => const LinearGradient(
        colors: [
          royalPurple,
          Color(0xFF5E2D82),
          Color(0xFF7B4B94),
          Color(0xFFB88A44),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.35, 0.65, 1.0],
      );

  // Soft gradient for backgrounds
  static LinearGradient get softGradient => LinearGradient(
        colors: [
          royalPurple.withOpacity(0.95),
          softPurple.withOpacity(0.7),
          lotusWhite.withOpacity(0.9),
          lotusWhite,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.25, 0.55, 1.0],
      );

  // Page transition theme - smooth fade
  static PageTransitionsTheme get smoothPageTransitions =>
      const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      );

  // Light theme - Elegant Indian Royal Style
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    pageTransitionsTheme: smoothPageTransitions,
    colorScheme: ColorScheme.fromSeed(
      seedColor: royalPurple,
      brightness: Brightness.light,
      primary: royalPurple,
      secondary: royalGold,
      tertiary: saffron,
      surface: lotusWhite,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: royalPurple,
      foregroundColor: royalGold,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        color: royalGold,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: 0.8,
      ),
      iconTheme: const IconThemeData(color: royalGold),
    ),
    scaffoldBackgroundColor: creamWhite,
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: royalPurple.withOpacity(0.08),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shadowColor: royalPurple.withOpacity(0.25),
        backgroundColor: royalPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.5),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(royalGold.withOpacity(0.15)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: royalPurple,
        side: const BorderSide(color: royalGold, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(royalGold.withOpacity(0.1)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: royalPurple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: royalMaroon, width: 1),
      ),
      labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
          fontSize: 14),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIconColor: softPurple,
      suffixIconColor: Colors.grey.shade500,
      floatingLabelStyle:
          const TextStyle(color: royalPurple, fontWeight: FontWeight.w500),
    ),
    textTheme: TextTheme(
      headlineLarge: const TextStyle(
          color: royalPurple,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          letterSpacing: 0.3),
      headlineMedium: const TextStyle(
          color: royalPurple,
          fontWeight: FontWeight.w600,
          fontSize: 24,
          letterSpacing: 0.2),
      titleLarge: const TextStyle(
          color: royalPurple, fontWeight: FontWeight.w600, fontSize: 20),
      titleMedium: TextStyle(
          color: royalPurple.withOpacity(0.9),
          fontWeight: FontWeight.w500,
          fontSize: 16),
      bodyLarge:
          TextStyle(color: Colors.grey.shade800, fontSize: 16, height: 1.6),
      bodyMedium:
          TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5),
      bodySmall:
          TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: royalPurple,
      foregroundColor: royalGold,
      elevation: 3,
      highlightElevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme:
        DividerThemeData(color: Colors.grey.shade200, thickness: 1, space: 24),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: royalGold,
      circularTrackColor: Color(0xFFF0E6D3),
      linearTrackColor: Color(0xFFF0E6D3),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: royalPurple,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF5F0E8),
      selectedColor: royalPurple.withOpacity(0.15),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: royalPurple,
      brightness: Brightness.dark,
      primary: royalGold,
      secondary: saffron,
      tertiary: peacockBlue,
      surface: Color(0xFF1A1A2E),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF1A1A2E),
      foregroundColor: royalGold,
      titleTextStyle: TextStyle(
          color: royalGold, fontWeight: FontWeight.w600, fontSize: 20),
    ),
    scaffoldBackgroundColor: Color(0xFF0F0F1A),
    cardTheme: CardThemeData(
      elevation: 8,
      color: Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF252538),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: royalGold.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: royalGold, width: 2),
      ),
      labelStyle: TextStyle(color: royalGold.withOpacity(0.8)),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
          color: royalGold, fontWeight: FontWeight.w600, fontSize: 20),
      bodyLarge: TextStyle(color: Colors.grey[300], fontSize: 16),
      bodyMedium: TextStyle(color: Colors.grey[400], fontSize: 14),
    ),
  );
}
