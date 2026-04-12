// lib/core/theme/app_theme.dart
//
// Single source of truth for the app's visual language.
//
// Flutter's equivalent of a CSS design system:
//   - AppColors    → CSS custom properties (--color-primary, etc.)
//   - AppDimens    → CSS spacing/radius tokens
//   - AppTheme     → ThemeData builder + decoration helpers (like a CSS utility class)
//
// The "hovering tile" look (layered box shadows + rounded rect + surface fill) is
// defined ONCE here in `floatingCard()` and reused everywhere — dialogs, profile
// tiles, forms.  The existing QuestCardTheme in quest_card_theme.dart keeps its
// own constants for quest-specific values (accent strip width, animation duration,
// etc.) but the shadows are intentionally consistent with the ones here.
//
// ─── How to couple with Material theme ────────────────────────────────────────
//
// Pass AppTheme.build() to MaterialApp's `theme:` parameter.
// Material 3's ColorScheme is seeded from AppColors.primary (grass green).
// The secondary (lavender) is injected via .copyWith() after seed generation
// so you get the full M3 tonal palette for free while keeping your accent.
// Widgets like FilledButton, FloatingActionButton, and BottomNavigationBar will
// automatically pick up the seed colors.  The custom decoration (floatingCard,
// shadowedInput) are *outside* Material's system — you use them directly where
// you want the hovering look.

import 'package:flutter/material.dart';

// ─── Color palette ────────────────────────────────────────────────────────────

abstract final class AppColors {
  // Primary — light grass green
  static const Color primary = Color(0xFF78C440);
  static const Color primaryLight = Color(0xFFA8D97A);
  static const Color primaryDark = Color(0xFF4F8F22);

  // Secondary — bright lavender
  static const Color secondary = Color(0xFFAA82E8);
  static const Color secondaryLight = Color(0xFFCDB4F5);
  static const Color secondaryDark = Color(0xFF7B52C0);

  // Neutral surface (matches QuestCardTheme cardColor = colorScheme.surface)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF2F4F0); // very faint green tint
}

// ─── Spacing / shape tokens ───────────────────────────────────────────────────

abstract final class AppDimens {
  // Same border radius as QuestCardTheme.borderRadius — intentional alignment.
  static const double borderRadius = 14.0;
  static const double borderRadiusSmall = 8.0;

  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 6,
  );
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );
  static const EdgeInsets screenPadding = EdgeInsets.all(20);
}

// ─── Design-system helpers ────────────────────────────────────────────────────

abstract final class AppTheme {
  // ── ThemeData ────────────────────────────────────────────────────────────
  //
  // Call AppTheme.build() and pass to MaterialApp(theme: ...).
  // MaterialApp automatically handles light/dark variants if you also supply
  // AppTheme.buildDark() later.
  static ThemeData build() {
    // Generate the full M3 tonal palette from the primary seed, then override
    // the secondary slot with our lavender.
    final base =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          secondary: AppColors.secondary,
          secondaryContainer: AppColors.secondaryLight.withOpacity(0.4),
          onSecondary: Colors.white,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.background,

      // ── Dialog ──────────────────────────────────────────────────────────
      // Gives dialogs the same rounded rect shape as the hovering tiles.
      // elevation: 0 + custom shadow supplied via floatingCard() on the
      // container inside the dialog achieves the same layered-shadow look.
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius),
        ),
        elevation: 4,
      ),

      // ── TextField ───────────────────────────────────────────────────────
      // Filled + rounded, no hard border at rest, primary-colored focus ring.
      // Matches the card surface color so a TextField inside a floatingCard
      // blends in naturally.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.25),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          borderSide: BorderSide(color: base.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          borderSide: BorderSide(color: base.error, width: 2),
        ),
      ),

      // ── ElevatedButton ──────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ── TextButton ──────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: base.onSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: base.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  // ── Decoration helpers ───────────────────────────────────────────────────
  //
  // These are the "CSS utility classes" — call them directly on a Container's
  // `decoration:` property wherever you want the hovering-tile look.

  /// The signature "hovering tile" decoration — three-layer shadow biased on
  /// the y-axis, same formula as QuestCardTheme.cardShadow().
  /// [accentColor] tints the two close shadows; defaults to primary green.
  static BoxDecoration floatingCard({Color? accentColor}) {
    final color = accentColor ?? AppColors.primary;
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.borderRadius),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: color.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Same shape as floatingCard but with a left accent strip color — mirrors the
  /// quest tile visual language for profile fields that have a status/category.
  static BoxDecoration accentCard({required Color accentColor}) {
    return floatingCard(accentColor: accentColor).copyWith(
      border: Border(left: BorderSide(color: accentColor, width: 4)),
    );
  }

  /// Glassy lavender border decoration for dialogs.
  /// Use this via [AppDialog] — a transparent [Dialog] wrapper that applies
  /// this decoration so the border + glow render outside the surface.
  static BoxDecoration dialogDecoration() {
    return BoxDecoration(
      // Slightly frosted surface: not fully opaque so the layered glow bleeds in.
      color: AppColors.surface.withOpacity(0.97),
      borderRadius: BorderRadius.circular(AppDimens.borderRadius),
      border: Border.all(
        color: AppColors.secondary.withOpacity(0.55),
        width: 1.5,
      ),
      boxShadow: [
        // Inner glow — tight lavender halo hugging the edge.
        BoxShadow(
          color: AppColors.secondary.withOpacity(0.25),
          blurRadius: 6,
          spreadRadius: 0,
          offset: Offset.zero,
        ),
        // Mid diffuse lavender glow.
        BoxShadow(
          color: AppColors.secondary.withOpacity(0.12),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
        // Far ambient shadow for depth.
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 40,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }
}
