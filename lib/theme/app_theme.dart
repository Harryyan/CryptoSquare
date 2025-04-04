import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFF03A9F4);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color subtitleColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color tagBackgroundColor = Color(0xFFEEF2F6);
  static const Color tagTextColor = Color(0xFF6E8098);

  static const Color darkPrimaryColor = Color(0xFF1565C0);
  static const Color darkSecondaryColor = Color(0xFF1976D2);
  static const Color darkAccentColor = Color(0xFF0288D1);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkTextColor = Color(0xFFEEEEEE);
  static const Color darkSubtitleColor = Color(0xFFBDBDBD);
  static const Color darkDividerColor = Color(0xFF424242);
  static const Color darkTagBackgroundColor = Color(0xFF2C3440);
  static const Color darkTagTextColor = Color(0xFFB0BEC5);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: subtitleColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
      bodySmall: TextStyle(color: subtitleColor, fontSize: 12),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextColor),
      titleTextStyle: TextStyle(
        color: darkTextColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: darkPrimaryColor,
      unselectedLabelColor: darkSubtitleColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: darkTextColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: darkTextColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: darkTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: darkTextColor, fontSize: 16),
      bodyMedium: TextStyle(color: darkTextColor, fontSize: 14),
      bodySmall: TextStyle(color: darkSubtitleColor, fontSize: 12),
    ),
    colorScheme: ColorScheme.dark(primary: darkPrimaryColor),
  );
}
