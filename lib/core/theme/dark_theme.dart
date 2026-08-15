import 'package:flutter/material.dart';

import '../../styles/constantes/app_color.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: AppColors.darkPrimary,
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        secondary: const Color(0xFF83A9F7),
        surface: AppColors.darkSurface,
        error: const Color(0xFFFF8A86),
      ).copyWith(
        primaryContainer: const Color(0xFF204C3E),
        onPrimaryContainer: const Color(0xFFC5F3E1),
        outline: AppColors.darkTextSecondary,
        outlineVariant: AppColors.darkBorder,
      ),
  scaffoldBackgroundColor: AppColors.darkBackground,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
    bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
    bodySmall: TextStyle(color: AppColors.darkTextSecondary),
    titleLarge: TextStyle(color: AppColors.darkTextPrimary),
    titleMedium: TextStyle(color: AppColors.darkTextPrimary),
    titleSmall: TextStyle(color: AppColors.darkTextPrimary),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkTextPrimary,
    elevation: 0,
    centerTitle: true,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkBackground,
      minimumSize: const Size(0, 54),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkBackground,
      minimumSize: const Size(double.infinity, 54),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      elevation: 0,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.darkPrimary,
      minimumSize: const Size(0, 52),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      side: const BorderSide(color: AppColors.darkPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkField,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
    floatingLabelStyle: const TextStyle(
      color: AppColors.darkPrimary,
      fontWeight: FontWeight.w700,
    ),
    prefixIconColor: AppColors.darkPrimary,
    suffixIconColor: AppColors.darkTextSecondary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0xFFFF8A86)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0xFFFF8A86), width: 2),
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.darkBorder),
    ),
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.darkTextPrimary,
    textColor: AppColors.darkTextPrimary,
  ),
  dividerColor: AppColors.darkBorder,
);
