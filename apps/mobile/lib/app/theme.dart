import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand colors
  static const adminBlue = Color(0xFF4C51BF); // App Bar Blue
  static const sidebarDark = Color(0xFF2C3248); // Sidebar Dark Blue
  static const backgroundLight = Color(0xFFF3F4F6); // App background
  static const surfaceWhite = Color(0xFFFFFFFF);

  // Card vibrant colors
  static const cardPurple = Color(0xFF5A4FCF);
  static const cardLightBlue = Color(0xFF42A5F5);
  static const cardPink = Color(0xFFEC407A);
  static const cardOrange = Color(0xFFFF9800);
  static const cardDeepPurple = Color(0xFF6A1B9A);
  static const cardGreen = Color(0xFF26A69A);
  static const cardTeal = Color(0xFF26C6DA);
  static const cardYellow = Color(0xFFFFCA28);

  // Text
  static const textDark = Color(0xFF1F2937);
  static const textMuted = Color(0xFF6B7280);
}

abstract final class DairyCareTheme {
  static ThemeData get light => _theme(
    ColorScheme.fromSeed(
      seedColor: AppColors.adminBlue,
      brightness: Brightness.light,
      primary: AppColors.adminBlue,
      surface: AppColors.backgroundLight,
      surfaceContainerHighest: Colors.white,
    ),
  );

  static ThemeData get dark => _theme(
    ColorScheme.fromSeed(
      seedColor: AppColors.cardLightBlue,
      brightness: Brightness.dark,
      surface: const Color(0xFF111827),
      surfaceContainerHighest: const Color(0xFF1F2937),
    ),
  );

  static ThemeData _theme(ColorScheme colors) {
    final dark = colors.brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      brightness: colors.brightness,
      scaffoldBackgroundColor: colors.surface,
    );
    final textTheme = base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
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

    final outline = dark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: AppColors.adminBlue,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        margin: EdgeInsets.zero,
        color: dark ? colors.surfaceContainerHighest : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF374151) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        prefixIconColor: dark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          backgroundColor: AppColors.adminBlue,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          side: BorderSide(color: outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: outline),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 8,
        backgroundColor: AppColors.sidebarDark,
        indicatorColor: AppColors.adminBlue,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium?.copyWith(color: Colors.white70)),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const IconThemeData(color: Colors.white);
          return const IconThemeData(color: Colors.white70);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarDark,
        indicatorColor: AppColors.adminBlue,
        selectedIconTheme: const IconThemeData(color: Colors.white),
        unselectedIconTheme: const IconThemeData(color: Colors.white70),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: Colors.white,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: Colors.white70,
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(AppColors.adminBlue),
        headingTextStyle: textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: dark ? colors.surfaceContainerHighest : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.primaryContainer,
      ),
    );
  }
}
