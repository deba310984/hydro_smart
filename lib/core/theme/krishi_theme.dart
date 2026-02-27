import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Digital Krishi - Professional Indian Agriculture Theme
/// A high-end "Modern Earth" palette designed for AgTech applications
class KrishiTheme {
  // ═══════════════════════════════════════════════════════════════════
  // MODERN EARTH COLOR PALETTE
  // ═══════════════════════════════════════════════════════════════════

  /// Deep Paddy Green - Primary brand color
  static const Color primaryGreen = Color(0xFF2E7D32);

  /// Terracotta/Clay - Secondary warm accent
  static const Color terracotta = Color(0xFFD87D4A);

  /// Parchment White - Premium surface color
  static const Color parchment = Color(0xFFF9F7F2);

  /// Rich Earth Brown - Text and grounding elements
  static const Color earthBrown = Color(0xFF5D4037);

  /// Fresh Lime - Charts and highlights
  static const Color freshLime = Color(0xFF8BC34A);

  /// Golden Wheat - Success states and accents
  static const Color goldenWheat = Color(0xFFFFB300);

  /// Deep Soil - Dark backgrounds
  static const Color deepSoil = Color(0xFF1B2631);

  /// Monsoon Sky - Info and neutral states
  static const Color monsoonSky = Color(0xFF546E7A);

  /// Alert Red - Error states
  static const Color alertRed = Color(0xFFD32F2F);

  // ═══════════════════════════════════════════════════════════════════
  // PREMIUM GRADIENTS
  // ═══════════════════════════════════════════════════════════════════

  /// Primary gradient for headers and hero sections
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [
          Color(0xFF1B5E20),
          primaryGreen,
          Color(0xFF43A047),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      );

  /// Chart gradient for data visualization
  static LinearGradient get chartGradient => const LinearGradient(
        colors: [
          primaryGreen,
          Color(0xFF66BB6A),
          freshLime,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  /// Terracotta warm gradient for CTAs
  static LinearGradient get warmGradient => const LinearGradient(
        colors: [
          Color(0xFFC66837),
          terracotta,
          Color(0xFFE8A87C),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Glass overlay gradient
  static LinearGradient get glassGradient => LinearGradient(
        colors: [
          Colors.white.withOpacity(0.25),
          Colors.white.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ═══════════════════════════════════════════════════════════════════
  // PREMIUM BOX SHADOWS (5% Green Tint)
  // ═══════════════════════════════════════════════════════════════════

  /// Large elevated shadow for cards
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primaryGreen.withOpacity(0.05),
          offset: const Offset(0, 10),
          blurRadius: 20,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
      ];

  /// Subtle shadow for inputs and small elements
  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: primaryGreen.withOpacity(0.04),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];

  /// Elevated shadow for pressed/active states
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: primaryGreen.withOpacity(0.08),
          offset: const Offset(0, 12),
          blurRadius: 24,
          spreadRadius: 2,
        ),
      ];

  // ═══════════════════════════════════════════════════════════════════
  // TYPOGRAPHY SYSTEM
  // ═══════════════════════════════════════════════════════════════════

  /// Get Montserrat for headers (geometric, modern)
  static TextStyle get headerFont => GoogleFonts.montserrat();

  /// Get Hind for body text (optimized for Hindi/English bilingual)
  static TextStyle get bodyFont => GoogleFonts.hind();

  /// Display Large - Hero text
  static TextStyle get displayLarge => GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: deepSoil,
        letterSpacing: -0.5,
        height: 1.2,
      );

  /// Display Medium - Section headers
  static TextStyle get displayMedium => GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: deepSoil,
        letterSpacing: -0.3,
        height: 1.3,
      );

  /// Headline Small - Subsection headers
  static TextStyle get headlineSmall => GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: deepSoil,
        letterSpacing: -0.2,
        height: 1.35,
      );

  /// Title Large - Card headers
  static TextStyle get titleLarge => GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryGreen,
        height: 1.4,
      );

  /// Title Medium - Subtitles
  static TextStyle get titleMedium => GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: earthBrown,
        height: 1.4,
      );

  /// Body Large - Primary content
  static TextStyle get bodyLarge => GoogleFonts.hind(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: earthBrown,
        height: 1.6,
      );

  /// Body Medium - Secondary content
  static TextStyle get bodyMedium => GoogleFonts.hind(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: monsoonSky,
        height: 1.5,
      );

  /// Body Small - Captions and labels
  static TextStyle get bodySmall => GoogleFonts.hind(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: monsoonSky,
        height: 1.4,
      );

  /// Label - Buttons and badges
  static TextStyle get labelStyle => GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // ═══════════════════════════════════════════════════════════════════
  // BORDER RADIUS SYSTEM
  // ═══════════════════════════════════════════════════════════════════

  static const double radiusSmall = 12.0;
  static const double radiusMedium = 18.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;

  // ═══════════════════════════════════════════════════════════════════
  // SPACING SYSTEM
  // ═══════════════════════════════════════════════════════════════════

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ═══════════════════════════════════════════════════════════════════
  // HAPTIC FEEDBACK
  // ═══════════════════════════════════════════════════════════════════

  static void lightHaptic() => HapticFeedback.lightImpact();
  static void mediumHaptic() => HapticFeedback.mediumImpact();
  static void selectionHaptic() => HapticFeedback.selectionClick();

  // ═══════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.light,
          primary: primaryGreen,
          secondary: terracotta,
          tertiary: freshLime,
          surface: parchment,
          error: alertRed,
        ),
        scaffoldBackgroundColor: parchment,

        // App Bar
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        // Card Theme - Premium styling
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),

        // Elevated Button - Stadium border with gradient feel
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: const StadiumBorder(),
            textStyle: labelStyle,
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              Colors.white.withOpacity(0.15),
            ),
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryGreen,
            side: const BorderSide(color: primaryGreen, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: const StadiumBorder(),
            textStyle: labelStyle,
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: const StadiumBorder(),
            textStyle: labelStyle.copyWith(color: primaryGreen),
          ),
        ),

        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: primaryGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: alertRed, width: 1),
          ),
          labelStyle: bodyMedium,
          hintStyle: bodyMedium.copyWith(color: Colors.grey.shade400),
          prefixIconColor: primaryGreen,
          suffixIconColor: monsoonSky,
          floatingLabelStyle: labelStyle.copyWith(color: primaryGreen),
        ),

        // Text Theme
        textTheme: TextTheme(
          displayLarge: displayLarge,
          displayMedium: displayMedium,
          titleLarge: titleLarge,
          titleMedium: titleMedium,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelLarge: labelStyle,
        ),

        // FAB
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: terracotta,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),

        // Divider
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade200,
          thickness: 1,
          space: spacingL,
        ),

        // Progress Indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryGreen,
          circularTrackColor: Color(0xFFE8F5E9),
          linearTrackColor: Color(0xFFE8F5E9),
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: deepSoil,
          contentTextStyle: bodyMedium.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          elevation: 6,
        ),

        // Bottom Sheet
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(radiusXLarge),
            ),
          ),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          elevation: 16,
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFE8F5E9),
          selectedColor: primaryGreen.withOpacity(0.2),
          labelStyle: bodySmall.copyWith(fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
        ),

        // Page transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      );

  // ═══════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.dark,
          primary: freshLime,
          secondary: terracotta,
          tertiary: goldenWheat,
          surface: deepSoil,
          error: alertRed,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1B14),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: deepSoil,
          foregroundColor: freshLime,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: freshLime,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF1E3A2F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: displayLarge.copyWith(color: Colors.white),
          displayMedium: displayMedium.copyWith(color: Colors.white),
          titleLarge: titleLarge.copyWith(color: freshLime),
          titleMedium: titleMedium.copyWith(color: Colors.grey.shade300),
          bodyLarge: bodyLarge.copyWith(color: Colors.grey.shade200),
          bodyMedium: bodyMedium.copyWith(color: Colors.grey.shade400),
          bodySmall: bodySmall.copyWith(color: Colors.grey.shade500),
        ),
      );
}
