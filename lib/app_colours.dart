import 'package:flutter/material.dart';

/// Call these helpers anywhere you need theme-aware colors.
/// They automatically switch between light and dark mode.
class AppColors {
  static Color bg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color card(BuildContext context) =>
      Theme.of(context).cardColor;

  static Color border(BuildContext context) =>
      Theme.of(context).dividerColor;

  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

  // Fixed colors that don't change with theme
  static const Color blue = Color(0xFF1565C0);
  static const Color blueDark = Color(0xFF0D47A1);
  static const Color blueLight = Color(0xFFE3F2FD);
  static const Color amber = Color(0xFFF9A825);
  static const Color amberLight = Color(0xFFFFF8E1);
  static const Color red = Color(0xFFA32D2D);
  static const Color redLight = Color(0xFFFCEBEB);
  static const Color green = Color(0xFF27500A);
  static const Color greenLight = Color(0xFFEAF3DE);
  static const Color orange = Color(0xFF633806);
  static const Color orangeLight = Color(0xFFFAEEDA);
}