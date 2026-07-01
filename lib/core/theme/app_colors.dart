import 'package:flutter/material.dart';

/// All app colors in one place, split into light and dark theme groups.
/// Use these instead of hardcoding hex values in widgets.
class AppColors {
  AppColors._(); // prevents creating instances of this class — it's just a container for constants

  // ── Light theme ──────────────────────────────────────────
  static const Color lightPrimary = Color(0xFF0B3D91);      // navy blue — buttons, active icons
  static const Color lightBackground = Color(0xFFF4F8FC);   // page background
  static const Color lightSurface = Color(0xFFFFFFFF);      // cards, app bar
  static const Color lightBorder = Color(0xFFDCE6F2);       // card/input borders
  static const Color lightTextPrimary = Color(0xFF101820);  // main text
  static const Color lightTextSecondary = Color(0xFF5A6570);// subtitles, hints

  // ── Dark theme ───────────────────────────────────────────
  static const Color darkPrimary = Color(0xFF0B3D91);       // same navy blue, used consistently
  static const Color darkBackground = Color(0xFF000000);    // true black background
  static const Color darkSurface = Color(0xFF121212);       // cards, app bar
  static const Color darkBorder = Color(0xFF232323);        // card/input borders
  static const Color darkTextPrimary = Color(0xFFF2F2F2);   // main text
  static const Color darkTextSecondary = Color(0xFF9A9A9A); // subtitles, hints

  // ── Status colors — same in both themes ─────────────────
  static const Color statusPending = Color(0xFFF5B54A);     // amber
  static const Color statusPendingBg = Color(0xFF2E2306);   // amber background chip (dark-friendly)
  static const Color statusApproved = Color(0xFF5FCB8F);    // green
  static const Color statusApprovedBg = Color(0xFF0E2718);  // green background chip
  static const Color statusError = Color(0xFFD8474A);       // red — errors, emergency alerts
}