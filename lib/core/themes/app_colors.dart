import 'package:flutter/material.dart';

/// Application color palette following the Stack Logistics design system
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF42A5F5); // Blue
  static const Color primaryLight = Color(0xFF90CAF9); // Light Blue
  static const Color primaryDark = Color(0xFF1976D2); // Dark Blue

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6F00); // Orange
  static const Color secondaryLight = Color(0xFFFFB74D); // Light Orange
  static const Color secondaryDark = Color(0xFFE65100); // Dark Orange

  // Accent Colors
  static const Color accent = Color(0xFFFFCA28); // Yellow
  static const Color accentLight = Color(0xFFFFF176); // Light Yellow
  static const Color accentDark = Color(0xFFFBC02D); // Dark Yellow

  // Background Colors
  static const Color background = Color(0xFFF5F5F5); // Light Grey
  static const Color backgroundLight = Color(0xFFFAFAFA); // Very Light Grey
  static const Color backgroundDark = Color(0xFFEEEEEE); // Medium Light Grey

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF8F9FA); // Off White
  static const Color surfaceTint = Color(0xFFE3F2FD); // Light Blue Tint

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Dark Grey
  static const Color textSecondary = Color(0xFF757575); // Grey
  static const Color textDisabled = Color(0xFFBDBDBD); // Light Grey
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White
  static const Color textOnSecondary = Color(0xFFFFFFFF); // White
  static const Color textOnSurface = Color(0xFF212121); // Dark Grey

  // Icon Colors
  static const Color icon = Color(0xFF616161); // Grey
  static const Color iconLight = Color(0xFF9E9E9E); // Light Grey
  static const Color iconDisabled = Color(0xFFBDBDBD); // Light Grey
  static const Color iconOnPrimary = Color(0xFFFFFFFF); // White

  // State Colors
  static const Color error = Color(0xFFD32F2F); // Red
  static const Color errorLight = Color(0xFFEF5350); // Light Red
  static const Color errorDark = Color(0xFFC62828); // Dark Red

  static const Color success = Color(0xFF388E3C); // Green
  static const Color successLight = Color(0xFF66BB6A); // Light Green
  static const Color successDark = Color(0xFF2E7D32); // Dark Green

  static const Color warning = Color(0xFFFBC02D); // Amber
  static const Color warningLight = Color(0xFFFFE082); // Light Amber
  static const Color warningDark = Color(0xFFF9A825); // Dark Amber

  static const Color info = Color(0xFF1976D2); // Blue
  static const Color infoLight = Color(0xFF42A5F5); // Light Blue
  static const Color infoDark = Color(0xFF1565C0); // Dark Blue

  // UI Element Colors
  static const Color divider = Color(0xFFE0E0E0); // Light Grey
  static const Color border = Color(0xFFE0E0E0); // Light Grey
  static const Color shadow = Color(0x1A000000); // Black with 10% opacity
  static const Color overlay = Color(0x66000000); // Black with 40% opacity

  // Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color buttonTextDisabled = Color(0xFF9E9E9E);

  // Card Colors
  static const Color card = surface;
  static const Color cardElevated = surface;
  static const Color cardOutlined = surface;
  static const Color cardBorder = border;

  // Navigation Colors
  static const Color navigationBar = surface;
  static const Color navigationBarSelected = primary;
  static const Color navigationBarUnselected = Color(0xFFBDBDBD);
  static const Color appBar = primary;
  static const Color appBarText = textOnPrimary;

  // Form Colors
  static const Color inputFill = Color(0xFFF8F9FA);
  static const Color inputBorder = border;
  static const Color inputFocused = primary;
  static const Color inputError = error;
  static const Color inputDisabled = Color(0xFFF5F5F5);

  // Status Colors for Containers
  static const Color statusLoading = Color(0xFF42A5F5); // Blue
  static const Color statusInTransit = Color(0xFFFF9800); // Orange
  static const Color statusDelivered = success; // Green
  static const Color statusDelayed = warning; // Amber
  static const Color statusDamaged = error; // Red
  static const Color statusLost = Color(0xFF9C27B0); // Purple

  // Priority Colors
  static const Color priorityLow = Color(0xFF4CAF50); // Green
  static const Color priorityMedium = Color(0xFFFF9800); // Orange
  static const Color priorityHigh = Color(0xFFFF5722); // Deep Orange
  static const Color priorityCritical = Color(0xFFD32F2F); // Red

  // Gradient Colors
  static const List<Color> primaryGradient = [primary, primaryDark];
  static const List<Color> secondaryGradient = [secondary, secondaryDark];
  static const List<Color> accentGradient = [accent, accentDark];

  // Chart Colors
  static const List<Color> chartColors = [
    primary,
    secondary,
    success,
    warning,
    error,
    info,
    Color(0xFF9C27B0), // Purple
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF795548), // Brown
    Color(0xFF009688), // Teal
  ];

  // Utility Methods

  /// Returns a color with the specified opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Returns a color based on container status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'loading':
        return statusLoading;
      case 'in_transit':
        return statusInTransit;
      case 'delivered':
        return statusDelivered;
      case 'delayed':
        return statusDelayed;
      case 'damaged':
        return statusDamaged;
      case 'lost':
        return statusLost;
      default:
        return textSecondary;
    }
  }

  /// Returns a color based on priority level
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return priorityLow;
      case 'medium':
        return priorityMedium;
      case 'high':
        return priorityHigh;
      case 'critical':
        return priorityCritical;
      default:
        return textSecondary;
    }
  }

  /// Returns a color scheme for the given brightness
  static ColorScheme getColorScheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const ColorScheme.light(
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: secondary,
        onSecondary: textOnSecondary,
        surface: surface,
        onSurface: textOnSurface,
        background: background,
        onBackground: textPrimary,
        error: error,
        onError: textOnPrimary,
      );
    } else {
      return ColorScheme.dark(
        primary: primaryLight,
        onPrimary: textPrimary,
        secondary: secondaryLight,
        onSecondary: textPrimary,
        surface: const Color(0xFF121212),
        onSurface: Colors.white,
        background: Colors.black,
        onBackground: Colors.white,
        error: errorLight,
        onError: Colors.white,
      );
    }
  }
}
