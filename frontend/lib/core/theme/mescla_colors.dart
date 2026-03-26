// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

class MesclaColors {
  static const background = Color(0xFF0A0A1A);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceStrong = Color(0xFF242438);
  static const border = Color(0xFF2A2A3E);

  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF99A1AF);
  static const textTertiary = Color(0xFF6A7282);

  static const purpleStart = Color(0xFF4F39F6);
  static const purpleEnd = Color(0xFF9810FA);
  static const purpleGlow = Color(0x4D615FFF);
  static const navActive = Color(0xFF7C86FF);
  static const navActiveSurface = Color(0x33615FFF);
  static const navInactive = Color(0xFF6A7282);

  static const success = Color(0xFF05DF72);
  static const successSoft = Color(0x3300C950);
  static const danger = Color(0xFFFF6467);
  static const dangerSoft = Color(0x33FB2C36);

  static const stageExpansion = Color(0xFFC27AFF);
  static const stageExpansionSoft = Color(0x33AD46FF);
  static const stageNew = Color(0xFF51A2FF);
  static const stageNewSoft = Color(0x332B7FFF);
}

class MesclaGradients {
  static const headerFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x334F39F6), Color(0x00000000)],
    stops: [0, 1],
  );

  static const purple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [MesclaColors.purpleStart, MesclaColors.purpleEnd],
  );

  static const purpleHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [MesclaColors.purpleStart, MesclaColors.purpleEnd],
  );

  static const startupCard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [MesclaColors.surface, MesclaColors.surfaceStrong],
  );
}
