// ignore_for_file: implementation_imports
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:dynamic_color/src/corepalette_to_colorscheme.dart';
import 'package:dynamic_color/src/dynamic_color_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/state/theme/models/theme_accent_color.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';
import 'package:harmonoid/utils/platform_utils.dart';

/// {@template theme_notifier}
///
/// ThemeNotifier
/// -------------
/// Implementation to notify widget tree about various theme attributes.
///
/// {@endtemplate}
class ThemeNotifier extends ChangeNotifier {
  static const ThemeAccentColor kDefaultAccentColorM2 = ThemeAccentColor(light: 0xFF651FFF, dark: 0xFF8A5CFF);
  static const ThemeAccentColor kDefaultAccentColorM3 = ThemeAccentColor(light: 0xFF6750A4, dark: 0xFF6750A4);

  static final ColorScheme kDefaultLightColorSchemeM3 = ColorScheme.fromSeed(seedColor: Color(kDefaultAccentColorM3.light), brightness: Brightness.light);
  static final ColorScheme kDefaultDarkColorSchemeM3 = ColorScheme.fromSeed(seedColor: Color(kDefaultAccentColorM3.dark), brightness: Brightness.dark);

  static const List<ThemeAccentColor> kColorsM2 = [
    kDefaultAccentColorM2,
    ThemeAccentColor(light: 0xFFFF1744, dark: 0xFFFF5252),
    ThemeAccentColor(light: 0xFFF50057, dark: 0xFFFF4081),
    ThemeAccentColor(light: 0xFFD500F9, dark: 0xFFE040FB),
    ThemeAccentColor(light: 0xFF3D5AFE, dark: 0xFF536DFE),
    ThemeAccentColor(light: 0xFF00B0FF, dark: 0xFF40C4FF),
    ThemeAccentColor(light: 0xFF00E5FF, dark: 0xFF18FFFF),
    ThemeAccentColor(light: 0xFF1DE9B6, dark: 0xFF64FFDA),
    ThemeAccentColor(light: 0xFF00E676, dark: 0xFF69F0AE),
    ThemeAccentColor(light: 0xFF76FF03, dark: 0xFFB2FF59),
    ThemeAccentColor(light: 0xFFFFC400, dark: 0xFFFFD740),
    ThemeAccentColor(light: 0xFFFF9100, dark: 0xFFFFAB40),
    ThemeAccentColor(light: 0xFFFF3D00, dark: 0xFFFF6E40),
    ThemeAccentColor(light: 0xFF795548, dark: 0xFF795548),
    ThemeAccentColor(light: 0xFF607D8B, dark: 0xFF607D8B),
  ];

  static const List<ThemeAccentColor> kColorsM3 = [
    kDefaultAccentColorM3,
    ThemeAccentColor(light: 0xFF0061A4, dark: 0xFF0061A4),
    ThemeAccentColor(light: 0xFF006874, dark: 0xFF006874),
    ThemeAccentColor(light: 0xFF006A60, dark: 0xFF006A60),
    ThemeAccentColor(light: 0xFF4C662B, dark: 0xFF4C662B),
    ThemeAccentColor(light: 0xFF5D5F00, dark: 0xFF5D5F00),
    ThemeAccentColor(light: 0xFF7A5900, dark: 0xFF7A5900),
    ThemeAccentColor(light: 0xFF8F4C00, dark: 0xFF8F4C00),
    ThemeAccentColor(light: 0xFFB3261E, dark: 0xFFB3261E),
    ThemeAccentColor(light: 0xFF984061, dark: 0xFF984061),
    ThemeAccentColor(light: 0xFF7D5260, dark: 0xFF7D5260),
  ];

  /// Singleton instance.
  static late final ThemeNotifier instance;

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro theme_notifier}
  ThemeNotifier._({
    required this.themeMode,
    required this.accentColor,
    required this.materialStandard,
    required this.systemColorScheme,
    required this.animationDuration,
    required this.systemLightColorScheme,
    required this.systemDarkColorScheme,
    required this.systemLightColor,
    required this.systemDarkColor,
  });

  /// Initializes the [instance].
  static Future<void> ensureInitialized({
    required ThemeMode themeMode,
    required ThemeAccentColor accentColor,
    required int materialStandard,
    required bool systemColorScheme,
    required AnimationDuration animationDuration,
  }) async {
    if (initialized) return;
    initialized = true;

    ColorScheme? systemLightColorScheme;
    ColorScheme? systemDarkColorScheme;
    Color? systemLightColor;
    Color? systemDarkColor;

    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      if (corePalette != null) {
        systemLightColorScheme ??= corePalette.toColorScheme(brightness: Brightness.light);
        systemDarkColorScheme ??= corePalette.toColorScheme(brightness: Brightness.dark);
        systemLightColor ??= systemLightColorScheme.primary;
        systemDarkColor ??= systemDarkColorScheme.primary;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    try {
      final accentColor = await PlatformUtils.instance.getSystemAccentColor() ?? await DynamicColorPlugin.getAccentColor();
      if (accentColor != null) {
        systemLightColorScheme ??= ColorScheme.fromSeed(seedColor: accentColor, brightness: Brightness.light);
        systemDarkColorScheme ??= ColorScheme.fromSeed(seedColor: accentColor, brightness: Brightness.dark);
        systemLightColor ??= systemLightColorScheme.primary;
        systemDarkColor ??= systemDarkColorScheme.primary;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    instance = ThemeNotifier._(
      themeMode: themeMode,
      accentColor: accentColor,
      materialStandard: materialStandard,
      systemColorScheme: systemColorScheme,
      animationDuration: animationDuration,
      systemLightColorScheme: systemLightColorScheme,
      systemDarkColorScheme: systemDarkColorScheme,
      systemLightColor: systemLightColor,
      systemDarkColor: systemDarkColor,
    );
  }

  static SystemUiOverlayStyle getSystemUiOverlayStyle(int materialStandard, ThemeMode themeMode) {
    if (themeMode == ThemeMode.system) {
      themeMode = switch (WidgetsBinding.instance.platformDispatcher.platformBrightness) {
        Brightness.light => ThemeMode.light,
        Brightness.dark => ThemeMode.dark,
      };
    }

    const statusBarColor = Colors.transparent;
    final statusBarBrightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      _ => throw UnimplementedError(),
    };
    final statusBarIconBrightness = switch (themeMode) {
      ThemeMode.light => Brightness.dark,
      ThemeMode.dark => Brightness.light,
      _ => throw UnimplementedError(),
    };

    if (AndroidStorageController.instance.version <= 29) {
      materialStandard = 2;
      themeMode = ThemeMode.dark;
    }

    final systemNavigationBarColor = switch (materialStandard) {
      3 => Colors.transparent,
      2 => Colors.black,
      _ => throw UnimplementedError(),
    };
    final systemNavigationBarDividerColor = systemNavigationBarColor;
    final systemNavigationBarIconBrightness = switch ((materialStandard, themeMode)) {
      (3, ThemeMode.light) => Brightness.dark,
      (3, ThemeMode.dark) => Brightness.light,
      (2, _) => Brightness.light,
      _ => throw UnimplementedError(),
    };

    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarBrightness: statusBarBrightness,
      statusBarIconBrightness: statusBarIconBrightness,
      systemNavigationBarColor: systemNavigationBarColor,
      systemNavigationBarDividerColor: systemNavigationBarDividerColor,
      systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    );
  }

  ThemeData get theme => switch (materialStandard) {
    3 => createM3Theme(
      context: context!,
      lightColorScheme: _lightColorScheme,
      darkColorScheme: _darkColorScheme,
      mode: ThemeMode.light,
      animationDuration: animationDuration,
    ),
    2 => createM2Theme(
      context: context!,
      color: _lightColor,
      mode: ThemeMode.light,
      animationDuration: animationDuration,
    ),
    _ => throw UnimplementedError(),
  };

  ThemeData get darkTheme => switch (materialStandard) {
    3 => createM3Theme(
      context: context!,
      lightColorScheme: _lightColorScheme,
      darkColorScheme: _darkColorScheme,
      mode: ThemeMode.dark,
      animationDuration: animationDuration,
    ),
    2 => createM2Theme(
      context: context!,
      color: _darkColor,
      mode: ThemeMode.dark,
      animationDuration: animationDuration,
    ),
    _ => throw UnimplementedError(),
  };

  BuildContext? context;
  ThemeMode themeMode;
  ThemeAccentColor accentColor;
  int materialStandard;
  bool systemColorScheme;
  AnimationDuration animationDuration;

  final Color? systemLightColor;
  final Color? systemDarkColor;
  final ColorScheme? systemLightColorScheme;
  final ColorScheme? systemDarkColorScheme;

  void update({
    BuildContext? context,
    ThemeMode? themeMode,
    ThemeAccentColor? accentColor,
    int? materialStandard,
    bool? systemColorScheme,
    AnimationDuration? animationDuration,
  }) {
    this.context = context ?? this.context;
    this.themeMode = themeMode ?? this.themeMode;
    this.accentColor = accentColor ?? this.accentColor;
    this.materialStandard = materialStandard ?? this.materialStandard;
    this.systemColorScheme = systemColorScheme ?? this.systemColorScheme;
    this.animationDuration = animationDuration ?? this.animationDuration;
    context ??= this.context;
    themeMode ??= this.themeMode;
    materialStandard ??= this.materialStandard;
    systemColorScheme ??= this.systemColorScheme;
    animationDuration ??= this.animationDuration;

    SystemChrome.setSystemUIOverlayStyle(getSystemUiOverlayStyle(materialStandard, themeMode));

    notifyListeners();
  }

  ColorScheme get _lightColorScheme {
    if (systemColorScheme) {
      return systemLightColorScheme ?? kDefaultLightColorSchemeM3;
    }
    return ColorScheme.fromSeed(seedColor: Color(accentColor.light), brightness: Brightness.light);
  }

  ColorScheme get _darkColorScheme {
    if (systemColorScheme) {
      return systemDarkColorScheme ?? kDefaultDarkColorSchemeM3;
    }
    return ColorScheme.fromSeed(seedColor: Color(accentColor.dark), brightness: Brightness.dark);
  }

  Color get _lightColor {
    if (systemColorScheme) {
      return systemLightColor ?? Color(kDefaultAccentColorM2.light);
    }
    return Color(accentColor.light);
  }

  Color get _darkColor {
    if (systemColorScheme) {
      return systemDarkColor ?? Color(kDefaultAccentColorM2.dark);
    }
    return Color(accentColor.dark);
  }
}
