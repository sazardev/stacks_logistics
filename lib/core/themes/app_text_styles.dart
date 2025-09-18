import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for Stack Logistics app
/// Uses DM Sans for headings and Roboto for body text
class AppTextStyles {
  // Font Families
  static const String headingFontFamily = 'DM Sans';
  static const String bodyFontFamily = 'Roboto';

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Base Text Styles

  // Display Styles (DM Sans)
  static TextStyle displayLarge = GoogleFonts.dmSans(
    fontSize: 32,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle displayMedium = GoogleFonts.dmSans(
    fontSize: 28,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static TextStyle displaySmall = GoogleFonts.dmSans(
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // Headline Styles (DM Sans)
  static TextStyle headlineLarge = GoogleFonts.dmSans(
    fontSize: 22,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = GoogleFonts.dmSans(
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineSmall = GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  // Title Styles (DM Sans)
  static TextStyle titleLarge = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle titleSmall = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  // Body Styles (Roboto)
  static TextStyle bodyLarge = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  // Label Styles (Roboto)
  static TextStyle labelLarge = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMedium = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle labelSmall = GoogleFonts.roboto(
    fontSize: 10,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // Button Styles
  static TextStyle buttonLarge = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: medium,
    height: 1.25,
    letterSpacing: 0.5,
    color: AppColors.buttonText,
  );

  static TextStyle buttonMedium = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: medium,
    height: 1.25,
    letterSpacing: 0.25,
    color: AppColors.buttonText,
  );

  static TextStyle buttonSmall = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: medium,
    height: 1.25,
    letterSpacing: 0.25,
    color: AppColors.buttonText,
  );

  // Caption and Overline
  static TextStyle caption = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static TextStyle overline = GoogleFonts.roboto(
    fontSize: 10,
    fontWeight: medium,
    height: 1.6,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  // Special Purpose Styles

  // App Bar
  static TextStyle appBarTitle = GoogleFonts.dmSans(
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.15,
    color: AppColors.appBarText,
  );

  // Navigation
  static TextStyle navigationLabel = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.navigationBarUnselected,
  );

  static TextStyle navigationLabelSelected = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.navigationBarSelected,
  );

  // Form Fields
  static TextStyle inputText = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle inputLabel = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static TextStyle inputHint = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.5,
    color: AppColors.textDisabled,
  );

  static TextStyle inputError = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.error,
  );

  // Card Content
  static TextStyle cardTitle = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static TextStyle cardSubtitle = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.25,
    color: AppColors.textSecondary,
  );

  // List Items
  static TextStyle listTitle = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: medium,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static TextStyle listSubtitle = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.25,
    color: AppColors.textSecondary,
  );

  // Status and Priority
  static TextStyle statusText = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textOnPrimary,
  );

  // Error Messages
  static TextStyle errorMessage = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.25,
    color: AppColors.error,
  );

  // Success Messages
  static TextStyle successMessage = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.25,
    color: AppColors.success,
  );

  // Utility Methods

  /// Returns a text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Returns a text style with custom font weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Returns a text style with custom font size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Returns a complete TextTheme for the app
  static TextTheme getTextTheme() {
    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }

  /// Returns a dark theme text styles
  static TextTheme getDarkTextTheme() {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: Colors.white),
      displayMedium: displayMedium.copyWith(color: Colors.white),
      displaySmall: displaySmall.copyWith(color: Colors.white),
      headlineLarge: headlineLarge.copyWith(color: Colors.white),
      headlineMedium: headlineMedium.copyWith(color: Colors.white),
      headlineSmall: headlineSmall.copyWith(color: Colors.white),
      titleLarge: titleLarge.copyWith(color: Colors.white),
      titleMedium: titleMedium.copyWith(color: Colors.white),
      titleSmall: titleSmall.copyWith(color: Colors.white),
      bodyLarge: bodyLarge.copyWith(color: Colors.white),
      bodyMedium: bodyMedium.copyWith(color: Colors.white),
      bodySmall: bodySmall.copyWith(color: Colors.white70),
      labelLarge: labelLarge.copyWith(color: Colors.white),
      labelMedium: labelMedium.copyWith(color: Colors.white),
      labelSmall: labelSmall.copyWith(color: Colors.white70),
    );
  }
}
