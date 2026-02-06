import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _brandPrimary = Color(0xFF0F1B33);
  static const Color _brandSecondary = Color(0xFF3772FF);
  static const Color _brandAccent = Color(0xFF00C38A);
  static const Color _lightBackground = Colors.white;
  static const Color _lightSurface = Colors.white;
  static const Color _lightBorder = Color(0xFFE3E7EF);

  static const Color _darkBackground = Color(0xFF080E1D);
  static const Color _darkSurface = Color(0xFF11192A);
  static const Color _darkSurfaceAlt = Color(0xFF1D253A);
  static const Color _darkBorder = Color(0xFF2B3451);
  static const Color _darkSecondary = Color(0xFF8AA6FF);
  static const Color _darkAccent = Color(0xFF2AC7F2);

  static TextTheme _textTheme(TextTheme base, Color color) {
    TextTheme resolvedTheme = base;
    try {
      resolvedTheme = GoogleFonts.plusJakartaSansTextTheme(base);
    } catch (error, stackTrace) {
      debugPrint(
        'google_fonts failed to load PlusJakartaSans; falling back to defaults: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    return resolvedTheme.apply(
      displayColor: color,
      bodyColor: color,
    );
  }

  static ThemeData light() {
    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _brandPrimary,
      onPrimary: Colors.white,
      secondary: _brandSecondary,
      onSecondary: Colors.white,
      tertiary: _brandAccent,
      onTertiary: Colors.white,
      background: _lightBackground,
      onBackground: _brandPrimary,
      surface: _lightSurface,
      onSurface: _brandPrimary,
      error: Colors.red.shade700,
      onError: Colors.white,
    );

    final TextTheme textTheme =
        _textTheme(Typography.blackMountainView, colorScheme.onBackground);

    final ButtonStyle elevatedStyle = ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );

    final ButtonStyle outlinedStyle = OutlinedButton.styleFrom(
      foregroundColor: colorScheme.primary,
      side: BorderSide(color: colorScheme.primary.withOpacity(0.6)),
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.primary),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _lightBorder),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: _lightBorder,
        thickness: 1,
      ),
      iconTheme: IconThemeData(color: colorScheme.primary),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedStyle),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: textTheme.labelMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightSurface,
        labelStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _lightBorder),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _darkAccent,
      onPrimary: _darkBackground,
      secondary: _darkSecondary,
      onSecondary: Colors.white,
      tertiary: _darkAccent,
      onTertiary: _darkBackground,
      background: _darkBackground,
      onBackground: Colors.white,
      surface: _darkSurface,
      onSurface: Colors.white,
      error: Colors.red.shade400,
      onError: Colors.white,
    );

    final TextTheme textTheme =
        _textTheme(Typography.whiteMountainView, colorScheme.onBackground);

    final ButtonStyle elevatedStyle = ElevatedButton.styleFrom(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );

    final ButtonStyle outlinedStyle = OutlinedButton.styleFrom(
      foregroundColor: Colors.white70,
      side: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.12),
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkSurfaceAlt,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: Colors.white60,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedStyle),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
        ),
        labelStyle: textTheme.labelMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white12,
        labelStyle: textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white12),
        ),
      ),
    );
  }
}
