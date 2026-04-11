// lib/features/group_home/quest_card_theme.dart

import 'package:flutter/material.dart';

abstract final class QuestCardTheme {
  // — Shape —
  static const double borderRadius = 14.0;
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 6,
  );
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  // — Elevation / Shadow —
  // Three-layer shadow: tight dark base, mid diffuse, wide ambient.
  // y-axis biased on all three — reads as "lifted off the surface".
  static List<BoxShadow> cardShadow(Color dominantColor) => [
    BoxShadow(
      color: dominantColor.withOpacity(0.18),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: dominantColor.withOpacity(0.10),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  // — Typography —
  static const TextStyle titleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle deadlineStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // — Status accent strip —
  static const double accentStripWidth = 4.0;

  // — Menu button —
  static const double menuButtonSize = 32.0;
  static const double menuIconSize = 18.0;

  // — Animation —
  static const Duration menuPopDuration = Duration(milliseconds: 220);
}
