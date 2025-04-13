// ignore_for_file: implementation_imports
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:dynamic_color/src/corepalette_to_colorscheme.dart';
import 'package:dynamic_color/src/dynamic_color_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template theme_notifier}
///
/// ThemeNotifier
/// -------------
/// Implementation to notify widget tree about various theme attributes.
///
/// {@endtemplate}
class ThemeNotifier extends ChangeNotifier {
  static final kDefaultLightColorSchemeM3 = ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4), brightness: Brightness.light);
  static final kDefaultDarkColorSchemeM3 = ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4), brightness: Brightness.dark);
  static const kDefaultLightPrimaryColorM2 = Color(0xFF651FFF);
  static const kDefaultDarkPrimaryColorM2 = Color(0xFF7C4DFF);

  /// Singleton instance.
  static late final ThemeNotifier instance;

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro theme_notifier}
  ThemeNotifier._({
    required this.themeMode,
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
      final accentColor = await DynamicColorPlugin.getAccentColor();
      if (accentColor != null) {
        systemLightColorScheme ??= ColorScheme.fromSeed(seedColor: accentColor, brightness: Brightness.light);
        systemDarkColorScheme = ColorScheme.fromSeed(seedColor: accentColor, brightness: Brightness.dark);
        systemLightColor ??= systemLightColorScheme.primary;
        systemDarkColor ??= systemDarkColorScheme.primary;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    instance = ThemeNotifier._(
      themeMode: themeMode,
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

  ThemeMode themeMode;
  int materialStandard;
  bool systemColorScheme;
  BuildContext? context;
  AnimationDuration animationDuration;

  final Color? systemLightColor;
  final Color? systemDarkColor;
  final ColorScheme? systemLightColorScheme;
  final ColorScheme? systemDarkColorScheme;

  void update({
    BuildContext? context,
    ThemeMode? themeMode,
    int? materialStandard,
    bool? systemColorScheme,
    AnimationDuration? animationDuration,
  }) {
    this.context = context ?? this.context;
    this.themeMode = themeMode ?? this.themeMode;
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
    return kDefaultLightColorSchemeM3;
  }

  ColorScheme get _darkColorScheme {
    if (systemColorScheme) {
      return systemDarkColorScheme ?? kDefaultDarkColorSchemeM3;
    }
    return kDefaultDarkColorSchemeM3;
  }

  Color get _lightColor {
    if (systemColorScheme) {
      return systemLightColor ?? kDefaultLightPrimaryColorM2;
    }
    return kDefaultLightPrimaryColorM2;
  }

  Color get _darkColor {
    if (systemColorScheme) {
      return systemDarkColor ?? kDefaultDarkPrimaryColorM2;
    }
    return kDefaultDarkPrimaryColorM2;
  }
}
