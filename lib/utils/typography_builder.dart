import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class TypographyBuilder {
  TypographyBuilder._();

  /// Creates a [Typography] based on the 2021 Material Design specification.
  /// This corresponds to Material Design 3.
  static Typography material2021(ColorScheme colorScheme) {
    final Typography base = _createTypography(
      englishLike2021,
      dense2021,
      tall2021,
    );
    final Color dark = colorScheme.brightness == Brightness.light
        ? colorScheme.onSurface
        : colorScheme.surface;
    final Color light = colorScheme.brightness == Brightness.light
        ? colorScheme.surface
        : colorScheme.onSurface;
    return base.copyWith(
      black: base.black.apply(displayColor: dark, bodyColor: dark, decorationColor: dark),
      white: base.white.apply(displayColor: light, bodyColor: light, decorationColor: light),
    );
  }

  /// Creates a [Typography] based on the 2014 Material Design specification.
  /// This corresponds to Material Design 2.
  static Typography material2014() => _createTypography(englishLike2014, dense2014, tall2014);

  /// Helper for [material2021] and [material2014].
  static Typography _createTypography(
    TextTheme englishLike,
    TextTheme dense,
    TextTheme tall,
  ) {
    TextTheme? black, white;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        black ??= blackCupertino;
        white ??= whiteCupertino;
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        black ??= blackMountainView;
        white ??= whiteMountainView;
        break;
      case TargetPlatform.windows:
        black ??= blackRedmond;
        white ??= whiteRedmond;
        break;
      case TargetPlatform.macOS:
        black ??= blackRedwoodCity;
        white ??= whiteRedwoodCity;
        break;
      case TargetPlatform.linux:
        black ??= blackHelsinki;
        white ??= whiteHelsinki;
        break;
    }
    return Typography(
      platform: defaultTargetPlatform,
      black: black,
      white: white,
      englishLike: englishLike,
      dense: dense,
      tall: tall,
    );
  }

  static const TextTheme blackMountainView = TextTheme(
    displayLarge: TextStyle(debugLabel: 'blackMountainView displayLarge', fontFamily: 'Roboto', color: Colors.black54, decoration: TextDecoration.none),
    displayMedium: TextStyle(debugLabel: 'blackMountainView displayMedium', fontFamily: 'Roboto', color: Colors.black54, decoration: TextDecoration.none),
    displaySmall: TextStyle(debugLabel: 'blackMountainView displaySmall', fontFamily: 'Roboto', color: Colors.black54, decoration: TextDecoration.none),
    headlineLarge: TextStyle(debugLabel: 'blackMountainView headlineLarge', fontFamily: 'Roboto', color: Colors.black54, decoration: TextDecoration.none),
    headlineMedium: TextStyle(debugLabel: 'blackMountainView headlineMedium', fontFamily: 'Roboto', color: Colors.black54, decoration: TextDecoration.none),
    headlineSmall: TextStyle(debugLabel: 'blackMountainView headlineSmall', fontFamily: 'Roboto', color: Colors.black87, decoration: TextDecoration.none),
    titleLarge: TextStyle(debugLabel: 'blackMountainView titleLarge', fontFamily: 'Roboto', color: Colors.black87, decoration: TextDecoration.none),
    titleMedium: TextStyle(debugLabel: 'blackMountainView titleMedium', fontFamily: 'Roboto', color: Colors.black87, decoration: TextDecoration.none),
    titleSmall: TextStyle(debugLabel: 'blackMountainView titleSmall', fontFamily: 'Roboto', color: Colors.black, decoration: TextDecoration.none),
    bodyLarge: TextStyle(debugLabel: 'blackMountainView bodyLarge', fontFamily: 'Roboto', color: Colors.black87, decoration: TextDecoration.none),
    bodyMedium: TextStyle(debugLabel: 'blackMountainView bodyMedium', fontFamily: 'Roboto', color: Colors.black87, decoration: TextDecoration.none),
    bodySmall: TextStyle(debugLabel: 'blackMountainView bodySmall', fontFamily: 'Roboto', color: Colors.black54, decoration: TextDecoration.none),
    labelLarge: TextStyle(debugLabel: 'blackMountainView labelLarge', fontFamily: 'Roboto', color: Colors.black87, decoration: TextDecoration.none),
    labelMedium: TextStyle(debugLabel: 'blackMountainView labelMedium', fontFamily: 'Roboto', color: Colors.black, decoration: TextDecoration.none),
    labelSmall: TextStyle(debugLabel: 'blackMountainView labelSmall', fontFamily: 'Roboto', color: Colors.black, decoration: TextDecoration.none),
  );

  static const TextTheme whiteMountainView = TextTheme(
    displayLarge: TextStyle(debugLabel: 'whiteMountainView displayLarge', fontFamily: 'Roboto', color: Colors.white70, decoration: TextDecoration.none),
    displayMedium: TextStyle(debugLabel: 'whiteMountainView displayMedium', fontFamily: 'Roboto', color: Colors.white70, decoration: TextDecoration.none),
    displaySmall: TextStyle(debugLabel: 'whiteMountainView displaySmall', fontFamily: 'Roboto', color: Colors.white70, decoration: TextDecoration.none),
    headlineLarge: TextStyle(debugLabel: 'whiteMountainView headlineLarge', fontFamily: 'Roboto', color: Colors.white70, decoration: TextDecoration.none),
    headlineMedium: TextStyle(debugLabel: 'whiteMountainView headlineMedium', fontFamily: 'Roboto', color: Colors.white70, decoration: TextDecoration.none),
    headlineSmall: TextStyle(debugLabel: 'whiteMountainView headlineSmall', fontFamily: 'Roboto', color: Colors.white, decoration: TextDecoration.none),
    titleLarge: TextStyle(debugLabel: 'whiteMountainView titleLarge', fontFamily: 'Roboto', color: Colors.white, decoration: TextDecoration.none),
    titleMedium: TextStyle(debugLabel: 'whiteMountainView titleMedium', fontFamily: 'Roboto', color: Colors.white, decoration: TextDecoration.none),
    titleSmall: TextStyle(debugLabel: 'whiteMountainView titleSmall', fontFamily: 'Roboto', color: Colors.white, decoration: TextDecoration.none),
    bodyLarge: TextStyle(debugLabel: 'whiteMountainView bodyLarge', fontFamily: 'Roboto', color: Colors.white, decoration: TextDecoration.none),
    bodyMedium: TextStyle(debugLabel: 'whiteMountainView bodyMedium', fontFamily: 'Roboto', color: Colors.white, decoration: TextDecoration.none),
    bodySmall: TextStyle(debugLabel: 'whiteMountainView bodySmall', fontFamily: 'Roboto', color: Colors.white70, decoration: TextDecoration.none),
    labelLarge: TextStyle(debugLabel: 'whiteMountainView labelLarge', fontFamily: 'Roboto', color: Colors.white, decoration: TextDecoration.none),
    labelMedium: TextStyle(debugLabel: 'whiteMountainView labelMedium', fontFamily: 'Roboto', color: Colors.white, decoration: TextDecoration.none),
    labelSmall: TextStyle(debugLabel: 'whiteMountainView labelSmall', fontFamily: 'Roboto', color: Colors.white, decoration: TextDecoration.none),
  );

  static const TextTheme blackRedmond = TextTheme(
    displayLarge: TextStyle(debugLabel: 'blackRedmond displayLarge', fontFamily: 'Segoe UI', color: Colors.black54, decoration: TextDecoration.none),
    displayMedium: TextStyle(debugLabel: 'blackRedmond displayMedium', fontFamily: 'Segoe UI', color: Colors.black54, decoration: TextDecoration.none),
    displaySmall: TextStyle(debugLabel: 'blackRedmond displaySmall', fontFamily: 'Segoe UI', color: Colors.black54, decoration: TextDecoration.none),
    headlineLarge: TextStyle(debugLabel: 'blackRedmond headlineLarge', fontFamily: 'Segoe UI', color: Colors.black54, decoration: TextDecoration.none),
    headlineMedium: TextStyle(debugLabel: 'blackRedmond headlineMedium', fontFamily: 'Segoe UI', color: Colors.black54, decoration: TextDecoration.none),
    headlineSmall: TextStyle(debugLabel: 'blackRedmond headlineSmall', fontFamily: 'Segoe UI', color: Colors.black87, decoration: TextDecoration.none),
    titleLarge: TextStyle(debugLabel: 'blackRedmond titleLarge', fontFamily: 'Segoe UI', color: Colors.black87, decoration: TextDecoration.none),
    titleMedium: TextStyle(debugLabel: 'blackRedmond titleMedium', fontFamily: 'Segoe UI', color: Colors.black87, decoration: TextDecoration.none),
    titleSmall: TextStyle(debugLabel: 'blackRedmond titleSmall', fontFamily: 'Segoe UI', color: Colors.black, decoration: TextDecoration.none),
    bodyLarge: TextStyle(debugLabel: 'blackRedmond bodyLarge', fontFamily: 'Segoe UI', color: Colors.black87, decoration: TextDecoration.none),
    bodyMedium: TextStyle(debugLabel: 'blackRedmond bodyMedium', fontFamily: 'Segoe UI', color: Colors.black87, decoration: TextDecoration.none),
    bodySmall: TextStyle(debugLabel: 'blackRedmond bodySmall', fontFamily: 'Segoe UI', color: Colors.black54, decoration: TextDecoration.none),
    labelLarge: TextStyle(debugLabel: 'blackRedmond labelLarge', fontFamily: 'Segoe UI', color: Colors.black87, decoration: TextDecoration.none),
    labelMedium: TextStyle(debugLabel: 'blackRedmond labelMedium', fontFamily: 'Segoe UI', color: Colors.black, decoration: TextDecoration.none),
    labelSmall: TextStyle(debugLabel: 'blackRedmond labelSmall', fontFamily: 'Segoe UI', color: Colors.black, decoration: TextDecoration.none),
  );

  static const TextTheme whiteRedmond = TextTheme(
    displayLarge: TextStyle(debugLabel: 'whiteRedmond displayLarge', fontFamily: 'Segoe UI', color: Colors.white70, decoration: TextDecoration.none),
    displayMedium: TextStyle(debugLabel: 'whiteRedmond displayMedium', fontFamily: 'Segoe UI', color: Colors.white70, decoration: TextDecoration.none),
    displaySmall: TextStyle(debugLabel: 'whiteRedmond displaySmall', fontFamily: 'Segoe UI', color: Colors.white70, decoration: TextDecoration.none),
    headlineLarge: TextStyle(debugLabel: 'whiteRedmond headlineLarge', fontFamily: 'Segoe UI', color: Colors.white70, decoration: TextDecoration.none),
    headlineMedium: TextStyle(debugLabel: 'whiteRedmond headlineMedium', fontFamily: 'Segoe UI', color: Colors.white70, decoration: TextDecoration.none),
    headlineSmall: TextStyle(debugLabel: 'whiteRedmond headlineSmall', fontFamily: 'Segoe UI', color: Colors.white, decoration: TextDecoration.none),
    titleLarge: TextStyle(debugLabel: 'whiteRedmond titleLarge', fontFamily: 'Segoe UI', color: Colors.white, decoration: TextDecoration.none),
    titleMedium: TextStyle(debugLabel: 'whiteRedmond titleMedium', fontFamily: 'Segoe UI', color: Colors.white, decoration: TextDecoration.none),
    titleSmall: TextStyle(debugLabel: 'whiteRedmond titleSmall', fontFamily: 'Segoe UI', color: Colors.white, decoration: TextDecoration.none),
    bodyLarge: TextStyle(debugLabel: 'whiteRedmond bodyLarge', fontFamily: 'Segoe UI', color: Colors.white, decoration: TextDecoration.none),
    bodyMedium: TextStyle(debugLabel: 'whiteRedmond bodyMedium', fontFamily: 'Segoe UI', color: Colors.white, decoration: TextDecoration.none),
    bodySmall: TextStyle(debugLabel: 'whiteRedmond bodySmall', fontFamily: 'Segoe UI', color: Colors.white70, decoration: TextDecoration.none),
    labelLarge: TextStyle(debugLabel: 'whiteRedmond labelLarge', fontFamily: 'Segoe UI', color: Colors.white, decoration: TextDecoration.none),
    labelMedium: TextStyle(debugLabel: 'whiteRedmond labelMedium', fontFamily: 'Segoe UI', color: Colors.white, decoration: TextDecoration.none),
    labelSmall: TextStyle(debugLabel: 'whiteRedmond labelSmall', fontFamily: 'Segoe UI', color: Colors.white, decoration: TextDecoration.none),
  );

  static const List<String> _helsinkiFontFallbacks = <String>['Ubuntu', 'Cantarell', 'DejaVu Sans', 'Liberation Sans', 'Arial'];

  static const TextTheme blackHelsinki = TextTheme(
    displayLarge: TextStyle(debugLabel: 'blackHelsinki displayLarge', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black54, decoration: TextDecoration.none),
    displayMedium: TextStyle(debugLabel: 'blackHelsinki displayMedium', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black54, decoration: TextDecoration.none),
    displaySmall: TextStyle(debugLabel: 'blackHelsinki displaySmall', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black54, decoration: TextDecoration.none),
    headlineLarge: TextStyle(debugLabel: 'blackHelsinki headlineLarge', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black54, decoration: TextDecoration.none),
    headlineMedium: TextStyle(debugLabel: 'blackHelsinki headlineMedium', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black54, decoration: TextDecoration.none),
    headlineSmall: TextStyle(debugLabel: 'blackHelsinki headlineSmall', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black87, decoration: TextDecoration.none),
    titleLarge: TextStyle(debugLabel: 'blackHelsinki titleLarge', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black87, decoration: TextDecoration.none),
    titleMedium: TextStyle(debugLabel: 'blackHelsinki titleMedium', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black87, decoration: TextDecoration.none),
    titleSmall: TextStyle(debugLabel: 'blackHelsinki titleSmall', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black, decoration: TextDecoration.none),
    bodyLarge: TextStyle(debugLabel: 'blackHelsinki bodyLarge', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black87, decoration: TextDecoration.none),
    bodyMedium: TextStyle(debugLabel: 'blackHelsinki bodyMedium', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black87, decoration: TextDecoration.none),
    bodySmall: TextStyle(debugLabel: 'blackHelsinki bodySmall', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black54, decoration: TextDecoration.none),
    labelLarge: TextStyle(debugLabel: 'blackHelsinki labelLarge', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black87, decoration: TextDecoration.none),
    labelMedium: TextStyle(debugLabel: 'blackHelsinki labelMedium', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black, decoration: TextDecoration.none),
    labelSmall: TextStyle(debugLabel: 'blackHelsinki labelSmall', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.black, decoration: TextDecoration.none),
  );

  static const TextTheme whiteHelsinki = TextTheme(
    displayLarge: TextStyle(debugLabel: 'whiteHelsinki displayLarge', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white70, decoration: TextDecoration.none),
    displayMedium: TextStyle(debugLabel: 'whiteHelsinki displayMedium', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white70, decoration: TextDecoration.none),
    displaySmall: TextStyle(debugLabel: 'whiteHelsinki displaySmall', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white70, decoration: TextDecoration.none),
    headlineLarge: TextStyle(debugLabel: 'whiteHelsinki headlineLarge', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white70, decoration: TextDecoration.none),
    headlineMedium: TextStyle(debugLabel: 'whiteHelsinki headlineMedium', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white70, decoration: TextDecoration.none),
    headlineSmall: TextStyle(debugLabel: 'whiteHelsinki headlineSmall', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white, decoration: TextDecoration.none),
    titleLarge: TextStyle(debugLabel: 'whiteHelsinki titleLarge', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white, decoration: TextDecoration.none),
    titleMedium: TextStyle(debugLabel: 'whiteHelsinki titleMedium', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white, decoration: TextDecoration.none),
    titleSmall: TextStyle(debugLabel: 'whiteHelsinki titleSmall', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white, decoration: TextDecoration.none),
    bodyLarge: TextStyle(debugLabel: 'whiteHelsinki bodyLarge', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white, decoration: TextDecoration.none),
    bodyMedium: TextStyle(debugLabel: 'whiteHelsinki bodyMedium', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white, decoration: TextDecoration.none),
    bodySmall: TextStyle(debugLabel: 'whiteHelsinki bodySmall', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white70, decoration: TextDecoration.none),
    labelLarge: TextStyle(debugLabel: 'whiteHelsinki labelLarge', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white, decoration: TextDecoration.none),
    labelMedium: TextStyle(debugLabel: 'whiteHelsinki labelMedium', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white, decoration: TextDecoration.none),
    labelSmall: TextStyle(debugLabel: 'whiteHelsinki labelSmall', fontFamily: 'Roboto', fontFamilyFallback: _helsinkiFontFallbacks, color: Colors.white, decoration: TextDecoration.none),
  );

  static const TextTheme blackCupertino = TextTheme(
    displayLarge: TextStyle(debugLabel: 'blackCupertino displayLarge', fontFamily: '.SF UI Display', color: Colors.black54, decoration: TextDecoration.none),
    displayMedium: TextStyle(debugLabel: 'blackCupertino displayMedium', fontFamily: '.SF UI Display', color: Colors.black54, decoration: TextDecoration.none),
    displaySmall: TextStyle(debugLabel: 'blackCupertino displaySmall', fontFamily: '.SF UI Display', color: Colors.black54, decoration: TextDecoration.none),
    headlineLarge: TextStyle(debugLabel: 'blackCupertino headlineLarge', fontFamily: '.SF UI Display', color: Colors.black54, decoration: TextDecoration.none),
    headlineMedium: TextStyle(debugLabel: 'blackCupertino headlineMedium', fontFamily: '.SF UI Display', color: Colors.black54, decoration: TextDecoration.none),
    headlineSmall: TextStyle(debugLabel: 'blackCupertino headlineSmall', fontFamily: '.SF UI Display', color: Colors.black87, decoration: TextDecoration.none),
    titleLarge: TextStyle(debugLabel: 'blackCupertino titleLarge', fontFamily: '.SF UI Display', color: Colors.black87, decoration: TextDecoration.none),
    titleMedium: TextStyle(debugLabel: 'blackCupertino titleMedium', fontFamily: '.SF UI Text', color: Colors.black87, decoration: TextDecoration.none),
    titleSmall: TextStyle(debugLabel: 'blackCupertino titleSmall', fontFamily: '.SF UI Text', color: Colors.black, decoration: TextDecoration.none),
    bodyLarge: TextStyle(debugLabel: 'blackCupertino bodyLarge', fontFamily: '.SF UI Text', color: Colors.black87, decoration: TextDecoration.none),
    bodyMedium: TextStyle(debugLabel: 'blackCupertino bodyMedium', fontFamily: '.SF UI Text', color: Colors.black87, decoration: TextDecoration.none),
    bodySmall: TextStyle(debugLabel: 'blackCupertino bodySmall', fontFamily: '.SF UI Text', color: Colors.black54, decoration: TextDecoration.none),
    labelLarge: TextStyle(debugLabel: 'blackCupertino labelLarge', fontFamily: '.SF UI Text', color: Colors.black87, decoration: TextDecoration.none),
    labelMedium: TextStyle(debugLabel: 'blackCupertino labelMedium', fontFamily: '.SF UI Text', color: Colors.black, decoration: TextDecoration.none),
    labelSmall: TextStyle(debugLabel: 'blackCupertino labelSmall', fontFamily: '.SF UI Text', color: Colors.black, decoration: TextDecoration.none),
  );

  static const TextTheme whiteCupertino = TextTheme(
    displayLarge: TextStyle(debugLabel: 'whiteCupertino displayLarge', fontFamily: '.SF UI Display', color: Colors.white70, decoration: TextDecoration.none),
    displayMedium: TextStyle(debugLabel: 'whiteCupertino displayMedium', fontFamily: '.SF UI Display', color: Colors.white70, decoration: TextDecoration.none),
    displaySmall: TextStyle(debugLabel: 'whiteCupertino displaySmall', fontFamily: '.SF UI Display', color: Colors.white70, decoration: TextDecoration.none),
    headlineLarge: TextStyle(debugLabel: 'whiteCupertino headlineLarge', fontFamily: '.SF UI Display', color: Colors.white70, decoration: TextDecoration.none),
    headlineMedium: TextStyle(debugLabel: 'whiteCupertino headlineMedium', fontFamily: '.SF UI Display', color: Colors.white70, decoration: TextDecoration.none),
    headlineSmall: TextStyle(debugLabel: 'whiteCupertino headlineSmall', fontFamily: '.SF UI Display', color: Colors.white, decoration: TextDecoration.none),
    titleLarge: TextStyle(debugLabel: 'whiteCupertino titleLarge', fontFamily: '.SF UI Display', color: Colors.white, decoration: TextDecoration.none),
    titleMedium: TextStyle(debugLabel: 'whiteCupertino titleMedium', fontFamily: '.SF UI Text', color: Colors.white, decoration: TextDecoration.none),
    titleSmall: TextStyle(debugLabel: 'whiteCupertino titleSmall', fontFamily: '.SF UI Text', color: Colors.white, decoration: TextDecoration.none),
    bodyLarge: TextStyle(debugLabel: 'whiteCupertino bodyLarge', fontFamily: '.SF UI Text', color: Colors.white, decoration: TextDecoration.none),
    bodyMedium: TextStyle(debugLabel: 'whiteCupertino bodyMedium', fontFamily: '.SF UI Text', color: Colors.white, decoration: TextDecoration.none),
    bodySmall: TextStyle(debugLabel: 'whiteCupertino bodySmall', fontFamily: '.SF UI Text', color: Colors.white70, decoration: TextDecoration.none),
    labelLarge: TextStyle(debugLabel: 'whiteCupertino labelLarge', fontFamily: '.SF UI Text', color: Colors.white, decoration: TextDecoration.none),
    labelMedium: TextStyle(debugLabel: 'whiteCupertino labelMedium', fontFamily: '.SF UI Text', color: Colors.white, decoration: TextDecoration.none),
    labelSmall: TextStyle(debugLabel: 'whiteCupertino labelSmall', fontFamily: '.SF UI Text', color: Colors.white, decoration: TextDecoration.none),
  );

  static const TextTheme blackRedwoodCity = TextTheme(
    displayLarge: TextStyle(debugLabel: 'blackRedwoodCity displayLarge', fontFamily: '.AppleSystemUIFont', color: Colors.black54, decoration: TextDecoration.none),
    displayMedium: TextStyle(debugLabel: 'blackRedwoodCity displayMedium', fontFamily: '.AppleSystemUIFont', color: Colors.black54, decoration: TextDecoration.none),
    displaySmall: TextStyle(debugLabel: 'blackRedwoodCity displaySmall', fontFamily: '.AppleSystemUIFont', color: Colors.black54, decoration: TextDecoration.none),
    headlineLarge: TextStyle(debugLabel: 'blackRedwoodCity headlineLarge', fontFamily: '.AppleSystemUIFont', color: Colors.black54, decoration: TextDecoration.none),
    headlineMedium: TextStyle(debugLabel: 'blackRedwoodCity headlineMedium', fontFamily: '.AppleSystemUIFont', color: Colors.black54, decoration: TextDecoration.none),
    headlineSmall: TextStyle(debugLabel: 'blackRedwoodCity headlineSmall', fontFamily: '.AppleSystemUIFont', color: Colors.black87, decoration: TextDecoration.none),
    titleLarge: TextStyle(debugLabel: 'blackRedwoodCity titleLarge', fontFamily: '.AppleSystemUIFont', color: Colors.black87, decoration: TextDecoration.none),
    titleMedium: TextStyle(debugLabel: 'blackRedwoodCity titleMedium', fontFamily: '.AppleSystemUIFont', color: Colors.black87, decoration: TextDecoration.none),
    titleSmall: TextStyle(debugLabel: 'blackRedwoodCity titleSmall', fontFamily: '.AppleSystemUIFont', color: Colors.black, decoration: TextDecoration.none),
    bodyLarge: TextStyle(debugLabel: 'blackRedwoodCity bodyLarge', fontFamily: '.AppleSystemUIFont', color: Colors.black87, decoration: TextDecoration.none),
    bodyMedium: TextStyle(debugLabel: 'blackRedwoodCity bodyMedium', fontFamily: '.AppleSystemUIFont', color: Colors.black87, decoration: TextDecoration.none),
    bodySmall: TextStyle(debugLabel: 'blackRedwoodCity bodySmall', fontFamily: '.AppleSystemUIFont', color: Colors.black54, decoration: TextDecoration.none),
    labelLarge: TextStyle(debugLabel: 'blackRedwoodCity labelLarge', fontFamily: '.AppleSystemUIFont', color: Colors.black87, decoration: TextDecoration.none),
    labelMedium: TextStyle(debugLabel: 'blackRedwoodCity labelMedium', fontFamily: '.AppleSystemUIFont', color: Colors.black, decoration: TextDecoration.none),
    labelSmall: TextStyle(debugLabel: 'blackRedwoodCity labelSmall', fontFamily: '.AppleSystemUIFont', color: Colors.black, decoration: TextDecoration.none),
  );

  static const TextTheme whiteRedwoodCity = TextTheme(
    displayLarge: TextStyle(debugLabel: 'whiteRedwoodCity displayLarge', fontFamily: '.AppleSystemUIFont', color: Colors.white70, decoration: TextDecoration.none),
    displayMedium: TextStyle(debugLabel: 'whiteRedwoodCity displayMedium', fontFamily: '.AppleSystemUIFont', color: Colors.white70, decoration: TextDecoration.none),
    displaySmall: TextStyle(debugLabel: 'whiteRedwoodCity displaySmall', fontFamily: '.AppleSystemUIFont', color: Colors.white70, decoration: TextDecoration.none),
    headlineLarge: TextStyle(debugLabel: 'whiteRedwoodCity headlineLarge', fontFamily: '.AppleSystemUIFont', color: Colors.white70, decoration: TextDecoration.none),
    headlineMedium: TextStyle(debugLabel: 'whiteRedwoodCity headlineMedium', fontFamily: '.AppleSystemUIFont', color: Colors.white70, decoration: TextDecoration.none),
    headlineSmall: TextStyle(debugLabel: 'whiteRedwoodCity headlineSmall', fontFamily: '.AppleSystemUIFont', color: Colors.white, decoration: TextDecoration.none),
    titleLarge: TextStyle(debugLabel: 'whiteRedwoodCity titleLarge', fontFamily: '.AppleSystemUIFont', color: Colors.white, decoration: TextDecoration.none),
    titleMedium: TextStyle(debugLabel: 'whiteRedwoodCity titleMedium', fontFamily: '.AppleSystemUIFont', color: Colors.white, decoration: TextDecoration.none),
    titleSmall: TextStyle(debugLabel: 'whiteRedwoodCity titleSmall', fontFamily: '.AppleSystemUIFont', color: Colors.white, decoration: TextDecoration.none),
    bodyLarge: TextStyle(debugLabel: 'whiteRedwoodCity bodyLarge', fontFamily: '.AppleSystemUIFont', color: Colors.white, decoration: TextDecoration.none),
    bodyMedium: TextStyle(debugLabel: 'whiteRedwoodCity bodyMedium', fontFamily: '.AppleSystemUIFont', color: Colors.white, decoration: TextDecoration.none),
    bodySmall: TextStyle(debugLabel: 'whiteRedwoodCity bodySmall', fontFamily: '.AppleSystemUIFont', color: Colors.white70, decoration: TextDecoration.none),
    labelLarge: TextStyle(debugLabel: 'whiteRedwoodCity labelLarge', fontFamily: '.AppleSystemUIFont', color: Colors.white, decoration: TextDecoration.none),
    labelMedium: TextStyle(debugLabel: 'whiteRedwoodCity labelMedium', fontFamily: '.AppleSystemUIFont', color: Colors.white, decoration: TextDecoration.none),
    labelSmall: TextStyle(debugLabel: 'whiteRedwoodCity labelSmall', fontFamily: '.AppleSystemUIFont', color: Colors.white, decoration: TextDecoration.none),
  );

  static const TextTheme englishLike2014 = TextTheme(
    displayLarge: TextStyle(debugLabel: 'englishLike displayLarge 2014', inherit: false, fontSize: 112.0, fontWeight: FontWeight.w100, textBaseline: TextBaseline.alphabetic),
    displayMedium: TextStyle(debugLabel: 'englishLike displayMedium 2014', inherit: false, fontSize: 56.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    displaySmall: TextStyle(debugLabel: 'englishLike displaySmall 2014', inherit: false, fontSize: 45.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    headlineLarge: TextStyle(debugLabel: 'englishLike headlineLarge 2014', inherit: false, fontSize: 40.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    headlineMedium: TextStyle(debugLabel: 'englishLike headlineMedium 2014', inherit: false, fontSize: 34.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    headlineSmall: TextStyle(debugLabel: 'englishLike headlineSmall 2014', inherit: false, fontSize: 24.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    titleLarge: TextStyle(debugLabel: 'englishLike titleLarge 2014', inherit: false, fontSize: 20.0, fontWeight: FontWeight.w500, textBaseline: TextBaseline.alphabetic),
    titleMedium: TextStyle(debugLabel: 'englishLike titleMedium 2014', inherit: false, fontSize: 16.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    titleSmall: TextStyle(debugLabel: 'englishLike titleSmall 2014', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w500, textBaseline: TextBaseline.alphabetic, letterSpacing: 0.1),
    bodyLarge: TextStyle(debugLabel: 'englishLike bodyLarge 2014', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w500, textBaseline: TextBaseline.alphabetic),
    bodyMedium: TextStyle(debugLabel: 'englishLike bodyMedium 2014', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    bodySmall: TextStyle(debugLabel: 'englishLike bodySmall 2014', inherit: false, fontSize: 12.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    labelLarge: TextStyle(debugLabel: 'englishLike labelLarge 2014', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w500, textBaseline: TextBaseline.alphabetic),
    labelMedium: TextStyle(debugLabel: 'englishLike labelMedium 2014', inherit: false, fontSize: 12.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    labelSmall: TextStyle(debugLabel: 'englishLike labelSmall 2014', inherit: false, fontSize: 10.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic, letterSpacing: 1.5),
  );

  static const TextTheme dense2014 = TextTheme(
    displayLarge: TextStyle(debugLabel: 'dense displayLarge 2014', inherit: false, fontSize: 112.0, fontWeight: FontWeight.w100, textBaseline: TextBaseline.ideographic),
    displayMedium: TextStyle(debugLabel: 'dense displayMedium 2014', inherit: false, fontSize: 56.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.ideographic),
    displaySmall: TextStyle(debugLabel: 'dense displaySmall 2014', inherit: false, fontSize: 45.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.ideographic),
    headlineLarge: TextStyle(debugLabel: 'dense headlineLarge 2014', inherit: false, fontSize: 40.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.ideographic),
    headlineMedium: TextStyle(debugLabel: 'dense headlineMedium 2014', inherit: false, fontSize: 34.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.ideographic),
    headlineSmall: TextStyle(debugLabel: 'dense headlineSmall 2014', inherit: false, fontSize: 24.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.ideographic),
    titleLarge: TextStyle(debugLabel: 'dense titleLarge 2014', inherit: false, fontSize: 21.0, fontWeight: FontWeight.w500, textBaseline: TextBaseline.ideographic),
    titleMedium: TextStyle(debugLabel: 'dense titleMedium 2014', inherit: false, fontSize: 17.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.ideographic),
    titleSmall: TextStyle(debugLabel: 'dense titleSmall 2014', inherit: false, fontSize: 15.0, fontWeight: FontWeight.w500, textBaseline: TextBaseline.ideographic),
    bodyLarge: TextStyle(debugLabel: 'dense bodyLarge 2014', inherit: false, fontSize: 15.0, fontWeight: FontWeight.w500, textBaseline: TextBaseline.ideographic),
    bodyMedium: TextStyle(debugLabel: 'dense bodyMedium 2014', inherit: false, fontSize: 15.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.ideographic),
    bodySmall: TextStyle(debugLabel: 'dense bodySmall 2014', inherit: false, fontSize: 13.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.ideographic),
    labelLarge: TextStyle(debugLabel: 'dense labelLarge 2014', inherit: false, fontSize: 15.0, fontWeight: FontWeight.w500, textBaseline: TextBaseline.ideographic),
    labelMedium: TextStyle(debugLabel: 'dense labelMedium 2014', inherit: false, fontSize: 12.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.ideographic),
    labelSmall: TextStyle(debugLabel: 'dense labelSmall 2014', inherit: false, fontSize: 11.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.ideographic),
  );

  static const TextTheme tall2014 = TextTheme(
    displayLarge: TextStyle(debugLabel: 'tall displayLarge 2014', inherit: false, fontSize: 112.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    displayMedium: TextStyle(debugLabel: 'tall displayMedium 2014', inherit: false, fontSize: 56.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    displaySmall: TextStyle(debugLabel: 'tall displaySmall 2014', inherit: false, fontSize: 45.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    headlineLarge: TextStyle(debugLabel: 'tall headlineLarge 2014', inherit: false, fontSize: 40.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    headlineMedium: TextStyle(debugLabel: 'tall headlineMedium 2014', inherit: false, fontSize: 34.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    headlineSmall: TextStyle(debugLabel: 'tall headlineSmall 2014', inherit: false, fontSize: 24.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    titleLarge: TextStyle(debugLabel: 'tall titleLarge 2014', inherit: false, fontSize: 21.0, fontWeight: FontWeight.w700, textBaseline: TextBaseline.alphabetic),
    titleMedium: TextStyle(debugLabel: 'tall titleMedium 2014', inherit: false, fontSize: 17.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    titleSmall: TextStyle(debugLabel: 'tall titleSmall 2014', inherit: false, fontSize: 15.0, fontWeight: FontWeight.w500, textBaseline: TextBaseline.alphabetic),
    bodyLarge: TextStyle(debugLabel: 'tall bodyLarge 2014', inherit: false, fontSize: 15.0, fontWeight: FontWeight.w700, textBaseline: TextBaseline.alphabetic),
    bodyMedium: TextStyle(debugLabel: 'tall bodyMedium 2014', inherit: false, fontSize: 15.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    bodySmall: TextStyle(debugLabel: 'tall bodySmall 2014', inherit: false, fontSize: 13.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    labelLarge: TextStyle(debugLabel: 'tall labelLarge 2014', inherit: false, fontSize: 15.0, fontWeight: FontWeight.w700, textBaseline: TextBaseline.alphabetic),
    labelMedium: TextStyle(debugLabel: 'tall labelMedium 2014', inherit: false, fontSize: 12.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
    labelSmall: TextStyle(debugLabel: 'tall labelSmall 2014', inherit: false, fontSize: 11.0, fontWeight: FontWeight.w400, textBaseline: TextBaseline.alphabetic),
  );

  static const TextTheme englishLike2021 = TextTheme(
    displayLarge: TextStyle(debugLabel: 'englishLike displayLarge 2021', inherit: false, fontSize: 57.0, fontWeight: FontWeight.w400, letterSpacing: -0.25, height: 1.12, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    displayMedium: TextStyle(debugLabel: 'englishLike displayMedium 2021', inherit: false, fontSize: 45.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.16, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    displaySmall: TextStyle(debugLabel: 'englishLike displaySmall 2021', inherit: false, fontSize: 36.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.22, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    headlineLarge: TextStyle(debugLabel: 'englishLike headlineLarge 2021', inherit: false, fontSize: 32.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.25, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    headlineMedium: TextStyle(debugLabel: 'englishLike headlineMedium 2021', inherit: false, fontSize: 28.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.29, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    headlineSmall: TextStyle(debugLabel: 'englishLike headlineSmall 2021', inherit: false, fontSize: 24.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.33, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    titleLarge: TextStyle(debugLabel: 'englishLike titleLarge 2021', inherit: false, fontSize: 22.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.27, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    titleMedium: TextStyle(debugLabel: 'englishLike titleMedium 2021', inherit: false, fontSize: 16.0, fontWeight: FontWeight.w500, letterSpacing: 0.15, height: 1.50, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    titleSmall: TextStyle(debugLabel: 'englishLike titleSmall 2021', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.43, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    labelLarge: TextStyle(debugLabel: 'englishLike labelLarge 2021', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.43, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    labelMedium: TextStyle(debugLabel: 'englishLike labelMedium 2021', inherit: false, fontSize: 12.0, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.33, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    labelSmall: TextStyle(debugLabel: 'englishLike labelSmall 2021', inherit: false, fontSize: 11.0, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.45, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    bodyLarge: TextStyle(debugLabel: 'englishLike bodyLarge 2021', inherit: false, fontSize: 16.0, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 1.50, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    bodyMedium: TextStyle(debugLabel: 'englishLike bodyMedium 2021', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.43, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    bodySmall: TextStyle(debugLabel: 'englishLike bodySmall 2021', inherit: false, fontSize: 12.0, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.33, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
  );

  static const TextTheme dense2021 = TextTheme(
    displayLarge: TextStyle(debugLabel: 'dense displayLarge 2021', inherit: false, fontSize: 57.0, fontWeight: FontWeight.w400, letterSpacing: -0.25, height: 1.12, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    displayMedium: TextStyle(debugLabel: 'dense displayMedium 2021', inherit: false, fontSize: 45.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.16, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    displaySmall: TextStyle(debugLabel: 'dense displaySmall 2021', inherit: false, fontSize: 36.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.22, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    headlineLarge: TextStyle(debugLabel: 'dense headlineLarge 2021', inherit: false, fontSize: 32.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.25, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    headlineMedium: TextStyle(debugLabel: 'dense headlineMedium 2021', inherit: false, fontSize: 28.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.29, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    headlineSmall: TextStyle(debugLabel: 'dense headlineSmall 2021', inherit: false, fontSize: 24.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.33, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    titleLarge: TextStyle(debugLabel: 'dense titleLarge 2021', inherit: false, fontSize: 22.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.27, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    titleMedium: TextStyle(debugLabel: 'dense titleMedium 2021', inherit: false, fontSize: 16.0, fontWeight: FontWeight.w500, letterSpacing: 0.15, height: 1.50, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    titleSmall: TextStyle(debugLabel: 'dense titleSmall 2021', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.43, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    labelLarge: TextStyle(debugLabel: 'dense labelLarge 2021', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.43, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    labelMedium: TextStyle(debugLabel: 'dense labelMedium 2021', inherit: false, fontSize: 12.0, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.33, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    labelSmall: TextStyle(debugLabel: 'dense labelSmall 2021', inherit: false, fontSize: 11.0, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.45, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    bodyLarge: TextStyle(debugLabel: 'dense bodyLarge 2021', inherit: false, fontSize: 16.0, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 1.50, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    bodyMedium: TextStyle(debugLabel: 'dense bodyMedium 2021', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.43, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
    bodySmall: TextStyle(debugLabel: 'dense bodySmall 2021', inherit: false, fontSize: 12.0, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.33, textBaseline: TextBaseline.ideographic, leadingDistribution: TextLeadingDistribution.even),
  );

  static const TextTheme tall2021 = TextTheme(
    displayLarge: TextStyle(debugLabel: 'tall displayLarge 2021', inherit: false, fontSize: 57.0, fontWeight: FontWeight.w400, letterSpacing: -0.25, height: 1.12, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    displayMedium: TextStyle(debugLabel: 'tall displayMedium 2021', inherit: false, fontSize: 45.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.16, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    displaySmall: TextStyle(debugLabel: 'tall displaySmall 2021', inherit: false, fontSize: 36.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.22, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    headlineLarge: TextStyle(debugLabel: 'tall headlineLarge 2021', inherit: false, fontSize: 32.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.25, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    headlineMedium: TextStyle(debugLabel: 'tall headlineMedium 2021', inherit: false, fontSize: 28.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.29, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    headlineSmall: TextStyle(debugLabel: 'tall headlineSmall 2021', inherit: false, fontSize: 24.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.33, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    titleLarge: TextStyle(debugLabel: 'tall titleLarge 2021', inherit: false, fontSize: 22.0, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.27, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    titleMedium: TextStyle(debugLabel: 'tall titleMedium 2021', inherit: false, fontSize: 16.0, fontWeight: FontWeight.w500, letterSpacing: 0.15, height: 1.50, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    titleSmall: TextStyle(debugLabel: 'tall titleSmall 2021', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.43, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    labelLarge: TextStyle(debugLabel: 'tall labelLarge 2021', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.43, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    labelMedium: TextStyle(debugLabel: 'tall labelMedium 2021', inherit: false, fontSize: 12.0, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.33, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    labelSmall: TextStyle(debugLabel: 'tall labelSmall 2021', inherit: false, fontSize: 11.0, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.45, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    bodyLarge: TextStyle(debugLabel: 'tall bodyLarge 2021', inherit: false, fontSize: 16.0, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 1.50, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    bodyMedium: TextStyle(debugLabel: 'tall bodyMedium 2021', inherit: false, fontSize: 14.0, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.43, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
    bodySmall: TextStyle(debugLabel: 'tall bodySmall 2021', inherit: false, fontSize: 12.0, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.33, textBaseline: TextBaseline.alphabetic, leadingDistribution: TextLeadingDistribution.even),
  );
}
