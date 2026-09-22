import 'package:flutter/material.dart';

import 'appcolors.dart';

class AppTheme {
  static const _lightCanvas = Color(0xffF9F7FB);
  static const _darkCanvas = Color(0xff10191E);
  static const _darkSurface = Color(0xff1A282E);
  static const _darkMuted = Color(0xff243840);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? _darkSurface : Colors.white;
    final onSurface = dark ? const Color(0xffE8F2F3) : const Color(0xff1B282C);
    final outline = dark ? const Color(0xff42565E) : const Color(0xffD8E2E5);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: Appcolors.Primary,
          brightness: brightness,
        ).copyWith(
          primary: Appcolors.Primary,
          onPrimary: Colors.white,
          surface: surface,
          onSurface: onSurface,
          onSurfaceVariant: dark
              ? const Color(0xffAFC2C6)
              : const Color(0xff607277),
          outline: outline,
          outlineVariant: outline,
          surfaceContainerLow: dark
              ? const Color(0xff1F3037)
              : const Color(0xffF2FAFA),
          surfaceContainer: dark ? _darkMuted : const Color(0xffEEF8F8),
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? _darkCanvas : _lightCanvas,
      cardColor: surface,
      canvasColor: dark ? _darkCanvas : _lightCanvas,
      dividerColor: outline,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(borderSide: BorderSide(color: outline)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: outline),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline),
      popupMenuTheme: PopupMenuThemeData(color: surface),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark
            ? const Color(0xff30454C)
            : const Color(0xff26383E),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}

extension AppThemePalette on BuildContext {
  Color get appCanvas => Theme.of(this).scaffoldBackgroundColor;
  Color get appSurface => Theme.of(this).colorScheme.surface;
  Color get appMutedSurface => Theme.of(this).colorScheme.surfaceContainer;
  Color get appSoftSurface => Theme.of(this).colorScheme.surfaceContainerLow;
  Color get appText => Theme.of(this).colorScheme.onSurface;
  Color get appSecondaryText => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get appOutline => Theme.of(this).colorScheme.outlineVariant;
  Color get appOnPrimary => Theme.of(this).colorScheme.onPrimary;
}
