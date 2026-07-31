import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color.fromARGB(255, 43, 120, 92);
  static const primaryDark = Color(0xFF267A61);
  static const primaryLight = Color(0xFFDDF4EB);

  static const background = Color(0xFFFAFAF7);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF26332F);
  static const textSecondary = Color(0xFF687772);
  static const border = Color(0xFFDDE5E1);

  static const adoption = Color(0xFFF2A65A);
  static const forum = Color(0xFF5B8DEF);
  static const badge = Color(0xFF8B72D0);
  static const success = Color(0xFF43A86B);
  static const warning = Color(0xFFF4C95D);
  static const critical = Color(0xFFD9534F);

  // Variantes equivalentes con contraste adecuado para modo oscuro.
  static const darkBackground = Color(0xFF111815);
  static const darkSurface = Color(0xFF19231F);
  static const darkField = Color(0xFF202D28);
  static const darkDisabledField = Color(0xFF17201C);
  static const darkPrimary = Color(0xFF267A61);
  static const darkTextPrimary = Color(0xFFE8F1ED);
  static const darkTextSecondary = Color(0xFFA9B9B3);
  static const darkBorder = Color(0xFF33443D);

  // Alias usados por componentes existentes.
  static const secondary = forum;
}
