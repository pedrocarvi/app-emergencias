import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/domain.dart';

abstract final class AppColors {
  static const bg = Color(0xFFFBFBFA),
      surface = Colors.white,
      ink = Color(0xFF17181B),
      muted = Color(0xFF6E7076),
      faint = Color(0xFF9A9CA1),
      line = Color(0xFFEAEAE6),
      lineSoft = Color(0xFFEDEDEA),
      lineStrong = Color(0xFFE4E4E0),
      chip = Color(0xFFF2F2EF),
      ok = Color(0xFF1E9E62),
      medical = Color(0xFFD42A2A),
      fire = Color(0xFFE0700F),
      police = Color(0xFF2F4FD8),
      medicalSoft = Color(0xFFFBEDED),
      fireSoft = Color(0xFFFBF2E8),
      policeSoft = Color(0xFFEDEFFC);
}

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.bg,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.ink,
    surface: AppColors.surface,
  ),
  textTheme: GoogleFonts.instrumentSansTextTheme().apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  ),
  dividerColor: AppColors.lineSoft,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.ink),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: const Size.fromHeight(56),
      backgroundColor: AppColors.ink,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      foregroundColor: AppColors.ink,
      side: const BorderSide(color: AppColors.lineStrong),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);

Color incidentColor(IncidentType type) => switch (type) {
  IncidentType.medical => AppColors.medical,
  IncidentType.fire => AppColors.fire,
  IncidentType.police => AppColors.police,
};
