import 'package:flutter/material.dart';

class AppColors {
  // Тёмная тема
  static const darkBackground = Color(0xFF121212);
  static const darkCard = Color(0xFF1E1E1E);
  static const darkTextPrimary = Color(0xFFFBFBFB);
  static const darkTextSecondary = Color(0xFFB3B3B3);

  // Светлая тема
  static const lightBackground = Color(0xFFD3D3D3);
  static const lightCard = Color(0xFFEFEFEF);
  static const lightTextPrimary = Color(0xFF212121);
  static const lightTextSecondary = Color(0xFF757575);

  // Общие цвета
  static const accentBlue = Color(0xFF1E88E5);

  // Удобные геттеры
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  }
}