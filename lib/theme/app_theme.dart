import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core palette ──────────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF050510);
  static const Color bgCard = Color(0xFF0F0F1E);
  static const Color bgElevated = Color(0xFF181830);
  static const Color surface = Color(0xFF222244);

  // Accent gradient endpoints
  static const Color accentStart = Color(0xFF6C63FF);
  static const Color accentMid = Color(0xFFAB47BC);
  static const Color accentEnd = Color(0xFFE040FB);

  // Semantic
  static const Color operatorColor = Color(0xFF00E5FF);
  static const Color functionColor = Color(0xFF64FFDA);
  static const Color deleteColor = Color(0xFFFF5252);
  static const Color warningColor = Color(0xFFFFD740);
  static const Color successColor = Color(0xFF69F0AE);

  // Equals button
  static const Color equalsGradientStart = Color(0xFF6C63FF);
  static const Color equalsGradientEnd = Color(0xFFE040FB);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textDim = Color(0xFF555570);

  // ── Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentStart, accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6E40), Color(0xFFFFD740)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coolGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF64FFDA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF050510), Color(0xFF0A0A1C), Color(0xFF050510)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Typography (static final — allocated once, not per frame) ─────────
  static final TextStyle displayLarge = GoogleFonts.spaceGrotesk(
    fontSize: 56,
    fontWeight: FontWeight.w300,
    color: textPrimary,
    letterSpacing: -2,
    height: 1.1,
  );

  static final TextStyle displayMedium = GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    letterSpacing: -1,
  );

  static final TextStyle expressionStyle = GoogleFonts.jetBrainsMono(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static final TextStyle historyStyle = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: textDim,
  );

  static final TextStyle buttonText = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static final TextStyle buttonTextSmall = GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static final TextStyle operatorText = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: operatorColor,
  );

  static final TextStyle functionText = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: functionColor,
  );

  static final TextStyle labelStyle = GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textDim,
    letterSpacing: 1.5,
  );

  // ── Shadows ───────────────────────────────────────────────────────────
  static final List<BoxShadow> glowShadow = [
    BoxShadow(
      color: accentStart.withValues(alpha: 0.2),
      blurRadius: 24,
      spreadRadius: 2,
    ),
  ];

  static final List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  // ── Border radius ─────────────────────────────────────────────────────
  static const double radiusSmall = 12;
  static const double radiusMedium = 18;
  static const double radiusLarge = 24;
  static const double radiusXL = 32;
}
