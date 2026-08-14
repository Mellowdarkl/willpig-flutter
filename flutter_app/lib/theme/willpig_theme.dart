import 'package:flutter/material.dart';

import 'willpig_colors.dart';

abstract final class WillpigTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: WillpigColors.primarySalmon,
      onPrimary: WillpigColors.inkBlack,
      secondary: WillpigColors.primarySalmon,
      onSecondary: WillpigColors.inkBlack,
      error: WillpigColors.danger,
      onError: Colors.white,
      surface: WillpigColors.surface,
      onSurface: WillpigColors.textDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: WillpigColors.bgOuter,
      appBarTheme: const AppBarTheme(
        toolbarHeight: 75,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: WillpigColors.glassBg,
        foregroundColor: WillpigColors.textDark,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: WillpigColors.primarySalmon,
        ),
      ),
      cardTheme: CardThemeData(
        color: WillpigColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WillpigColors.radiusMd),
          side: const BorderSide(color: WillpigColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: WillpigColors.primarySalmon,
          foregroundColor: WillpigColors.inkBlack,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WillpigColors.textDark,
          side: const BorderSide(color: WillpigColors.textDark),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WillpigColors.bgLight,
        contentPadding: const EdgeInsets.all(12),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: WillpigColors.textMuted,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: WillpigColors.primarySalmon,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WillpigColors.radiusSm),
          borderSide: const BorderSide(color: WillpigColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WillpigColors.radiusSm),
          borderSide: const BorderSide(color: WillpigColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WillpigColors.radiusSm),
          borderSide: const BorderSide(color: WillpigColors.primarySalmon),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: WillpigColors.surface,
        contentTextStyle: const TextStyle(color: WillpigColors.textDark),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WillpigColors.radiusSm),
          side: const BorderSide(color: WillpigColors.border),
        ),
      ),
      dividerColor: WillpigColors.border,
    );
  }
}
