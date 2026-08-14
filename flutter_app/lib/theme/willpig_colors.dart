import 'package:flutter/material.dart';

/// Paleta alineada con `willpig_studio/public/css/modules/variables.css`.
abstract final class WillpigColors {
  static const primarySalmon = Color(
    0xFFE6A17E,
  ); // Peach accent color from website
  static const primarySalmonDark = Color(0xFFB56A49);
  static const primarySalmonMuted = Color(0xFF8B5E4A);
  static const inkBlack = Color(0xFF0F0F0F);
  static const brandPink = Color(0xFFFFBDCC);

  static const bgOuter = Color(0xFF121212); // Deep dark charcoal background
  static const bgLight = Color(0xFF1E1E1E); // Slightly lighter dark background
  static const surface = Color(0xFF181818); // Surface cards / containers
  static const surfaceVariant = Color(
    0xFF262626,
  ); // Interactive elements background

  static const textDark = Color(0xFFFFFFFF); // Primary text is white
  static const textMuted = Color(0xFFA0A0A0); // Secondary text is soft grey

  static const success = Color(0xFF4CAF50);
  static const danger = Color(0xFFFF5C5C);

  static const border = Color(0x1EFFFFFF); // Semi-transparent white border
  static const glassBg = Color(0xFA121212); // App Bar dark background
  static const tabActiveBg = Color(0x3DFFCCAA);

  static const radiusXs = 4.0;
  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;

  static const storyCardWidth = 180.0;
  static const storyCardGap = 20.0;

  static const salmonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarySalmon, Color(0xFFFFBDCC)],
  );

  static List<BoxShadow> get shadowSoft => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
