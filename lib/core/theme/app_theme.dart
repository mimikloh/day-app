import 'package:flutter/material.dart';
import 'package:day_app/core/theme/app_colors.dart';

class AppTheme {
  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    fontFamily: 'Ubuntu',
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.accentBlue,
      surface: AppColors.darkCard,
      background: AppColors.darkBackground,
    ),
  );

  static final light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    fontFamily: 'Ubuntu',
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.accentBlue,
      surface: AppColors.lightCard,
      background: AppColors.lightBackground,
    ),
  );
}