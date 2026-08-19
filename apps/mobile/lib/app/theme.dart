import 'package:flutter/material.dart';

abstract final class AppColors {
  /// The single non-semantic accent used throughout DairyCare.
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF60A5FA);
  static const sidebarDark = Color(0xFF111827);
  static const backgroundLight = Color(0xFFF8FAFC);
  static const surfaceWhite = Color(0xFFFFFFFF);

  // Backwards-compatible aliases. Screens should use the theme color scheme.
  static const adminBlue = primary;
  static const cardPurple = primary;
  static const cardLightBlue = primary;
  static const cardPink = primary;
  static const cardOrange = primary;
  static const cardDeepPurple = primary;
  static const cardGreen = primary;
  static const cardTeal = primary;
  static const cardYellow = primary;

  static const textDark = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
}

abstract final class DairyCareTheme {
  static ThemeData get light => _theme(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: AppColors.surfaceWhite,
      surfaceContainerHighest: const Color(0xFFF1F5F9),
    ),
  );

  static ThemeData get dark => _theme(
    ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      surface: const Color(0xFF0F172A),
      surfaceContainerHighest: const Color(0xFF1E293B),
    ),
  );

  static ThemeData _theme(ColorScheme colors) {
    final dark = colors.brightness == Brightness.dark;
    final outline = dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final cardColor = dark ? const Color(0xFF1E293B) : Colors.white;
    final fieldColor = dark ? const Color(0xFF1E293B) : Colors.white;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      brightness: colors.brightness,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF0F172A)
          : AppColors.backgroundLight,
    );
    final textTheme = base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.5),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cardColor,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colors.primary),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: rounded.copyWith(side: BorderSide(color: outline)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        prefixIconColor: colors.onSurfaceVariant,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: rounded,
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: rounded,
          side: BorderSide(color: outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: rounded,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colors.primaryContainer.withValues(
          alpha: dark ? 0.22 : 0.45,
        ),
        selectedColor: colors.primaryContainer,
        labelStyle: textTheme.labelMedium?.copyWith(color: colors.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.28)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: cardColor,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarDark,
        indicatorColor: colors.primary,
        selectedIconTheme: const IconThemeData(color: Colors.white),
        unselectedIconTheme: const IconThemeData(color: Colors.white70),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: Colors.white,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: Colors.white70,
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 24),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: rounded,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(colors.primaryContainer),
        headingTextStyle: textTheme.titleSmall?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 12,
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.primaryContainer,
      ),
    );
  }
}
