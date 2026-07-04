import 'package:flutter/material.dart';

/// Centralized color palette matching the ELK Business Hub design system.
class AppColors {
  AppColors._();

  static const Color teal = Color(0xFF4BBFB0);
  static const Color tealDark = Color(0xFF2E9E8F);
  static const Color tealLight = Color(0xFFE0F7F5);

  static const Color yellow = Color(0xFFF5C518);
  static const Color yellowLight = Color(0xFFFEF8DC);

  static const Color dark = Color(0xFF1A2332);
  static const Color gray = Color(0xFF6B7280);
  static const Color grayLight = Color(0xFFF4F6F9);

  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E9EF);

  static const Color text = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF5A6474);

  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFFECACA);

  // Gradient stops used across hero/headers
  static const Color gradientNavyStart = Color(0xFF1A2E3D);
  static const Color gradientNavyEnd = Color(0xFF0D3D35);
  static const Color gradientTealStart = Color(0xFF0D3D35);
  static const Color gradientTealEnd = Color(0xFF4BBFB0);
  static const Color gradientDetailStart = Color(0xFF2E7D6B);
  static const Color gradientDetailEnd = Color(0xFF1A2E3D);
  static const Color gradientIndigo = Color(0xFF4F46E5);
  static const Color gradientIndigoSoft = Color(0xFF6366F1);
  static const Color gradientSplashStart = Color(0xFF1A2E3D);
  static const Color gradientSplashEnd = Color(0xFF0D1B26);

  static const Color googleRed = Color(0xFFEA4335);

  static const LinearGradient navyHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientNavyStart, gradientNavyEnd],
  );

  static const LinearGradient tealPromo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientTealStart, gradientTealEnd],
  );

  static const LinearGradient detailHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientDetailStart, gradientDetailEnd],
  );

  static const LinearGradient splashBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientSplashStart, gradientSplashEnd],
  );

  static const LinearGradient indigoHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientNavyStart, gradientIndigo],
  );

  static const LinearGradient providerHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientTealStart, gradientNavyStart],
  );
}
