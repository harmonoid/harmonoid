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
    await () async {
      try {
        final corePalette = await DynamicColorPlugin.getCorePalette();
        if (corePalette != null) {
          systemLightColorScheme = corePalette.toColorScheme(brightness: Brightness.light);
          systemDarkColorScheme = corePalette.toColorScheme(brightness: Brightness.dark);
          systemLightColor = systemLightColorScheme?.primary;
          systemDarkColor = systemDarkColorScheme?.primary;
          return;
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      try {
        final accentColor = await DynamicColorPlugin.getAccentColor();
        if (accentColor != null) {
          systemLightColorScheme = ColorScheme.fromSeed(seedColor: accentColor, brightness: Brightness.light);
          systemDarkColorScheme = ColorScheme.fromSeed(seedColor: accentColor, brightness: Brightness.dark);
          systemLightColor = systemLightColorScheme?.primary;
          systemDarkColor = systemDarkColorScheme?.primary;
          return;
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }();

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

  ThemeData get theme => {
        3: createM3Theme(
          context: context!,
          lightColorScheme: _lightColorScheme,
          darkColorScheme: _darkColorScheme,
          mode: ThemeMode.light,
          animationDuration: animationDuration,
        ),
        2: createM2Theme(
          context: context!,
          color: _lightColor,
          mode: ThemeMode.light,
          animationDuration: animationDuration,
        )
      }[materialStandard]!;

  ThemeData get darkTheme => {
        3: createM3Theme(
          context: context!,
          lightColorScheme: _lightColorScheme,
          darkColorScheme: _darkColorScheme,
          mode: ThemeMode.dark,
          animationDuration: animationDuration,
        ),
        2: createM2Theme(
          context: context!,
          color: _darkColor,
          mode: ThemeMode.dark,
          animationDuration: animationDuration,
        )
      }[materialStandard]!;

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

    const statusBarColor = Colors.transparent;
    final statusBarBrightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      _ => Brightness.light,
    };
    final statusBarIconBrightness = switch (themeMode) {
      ThemeMode.light => Brightness.dark,
      ThemeMode.dark => Brightness.light,
      _ => Brightness.dark,
    };
    final systemNavigationBarColor = switch (materialStandard) {
      2 => Colors.black,
      _ => Colors.transparent,
    };
    final systemNavigationBarDividerColor = switch (materialStandard) {
      2 => Colors.black,
      _ => Colors.transparent,
    };
    final systemNavigationBarIconBrightness = switch ((materialStandard, themeMode)) {
      (2, _) => Brightness.light,
      (3, ThemeMode.light) => Brightness.dark,
      (3, ThemeMode.dark) => Brightness.light,
      _ => Brightness.light,
    };

    final style = SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarBrightness: statusBarBrightness,
      statusBarIconBrightness: statusBarIconBrightness,
      systemNavigationBarColor: systemNavigationBarColor,
      systemNavigationBarDividerColor: systemNavigationBarDividerColor,
      systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    );
    SystemChrome.setSystemUIOverlayStyle(style);

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

  /// Default light theme color scheme in Material Design 3.
  static final kDefaultLightColorSchemeM3 = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: Brightness.light,
  );

  /// Default dark theme color scheme in Material Design 3.
  static final kDefaultDarkColorSchemeM3 = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: Brightness.dark,
  );

  /// Default light theme color in Material Design 2.
  static const kDefaultLightPrimaryColorM2 = Color(0xFF651FFF);

  /// Default dark theme color in Material Design 2.
  static const kDefaultDarkPrimaryColorM2 = Color(0xFF7C4DFF);
}
