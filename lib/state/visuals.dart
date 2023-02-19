/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
// ignore_for_file: implementation_imports

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dynamic_color/src/dynamic_color_plugin.dart';
import 'package:dynamic_color/src/corepalette_to_colorscheme.dart';

import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/core/configuration.dart';

/// Default color scheme for light theme in Material Design 3.
final defaultLightColorSchemeM3 = ColorScheme.fromSeed(
  seedColor: const Color(0xFF6750A4),
  brightness: Brightness.light,
);

/// Default color scheme for dark theme in Material Design 3.
final defaultDarkColorSchemeM3 = ColorScheme.fromSeed(
  seedColor: const Color(0xFF6750A4),
  brightness: Brightness.dark,
);

/// Default light theme color in Material Design 2.
const kDefaultLightPrimaryColorM2 = Color(0xFF651FFF);

/// Default dark theme color in Material Design 2.
const kDefaultDarkPrimaryColorM2 = Color(0xFF7C4DFF);

/// Visuals
/// -------
///
/// A minimal [ChangeNotifier] which serves the purpose of passing the current application
/// theme down the [Widget] tree trigger redraws whenever theme is changed by the user or
/// system, while automatically updating [SystemChrome] & saving current theme to the
/// application's configuration cache.
///
/// * A single primary [light] or [dark] color is consumed in Material Design 2. It only works if [material3] is set to `false`.
/// * A [lightColorScheme] or [darkColorScheme] is consumed in Material Design 3. It only works if [material3] is set to `true`.
///   System's current [ColorScheme] may be accessed using `package:dynamic_color`.
///
class Visuals extends ChangeNotifier {
  /// Currently used Material Design standard e.g. Material Design 2 or Material Design 3.
  int standard;

  /// Current [ThemeMode] of the application.
  ThemeMode themeMode;

  /// Whether system's current [ColorScheme] should be used or not.
  bool systemColorScheme;

  /// Current [BuildContext] of the application. Assigned at creation of widget tree.
  BuildContext? context;

  /// Animation duration(s) for various animations & transitions inside the application.
  AnimationDuration animationDuration;

  final Color? systemLight;
  final Color? systemDark;
  final ColorScheme? systemLightColorScheme;
  final ColorScheme? systemDarkColorScheme;

  /// Singleton instance of [Visuals]. Must call [initialize].
  static late final Visuals instance;

  /// Prevent calling [initialize] more than once.
  static bool _initialized = false;

  /// Initialize [Visuals] singleton instance.
  static Future<void> initialize({
    required int standard,
    required ThemeMode themeMode,
    required bool systemColorScheme,
    required AnimationDuration animationDuration,
  }) async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    ColorScheme? systemLightColorScheme;
    ColorScheme? systemDarkColorScheme;
    await () async {
      try {
        // Android.
        final corePalette = await DynamicColorPlugin.getCorePalette();
        if (corePalette != null) {
          systemLightColorScheme = corePalette.toColorScheme(
            brightness: Brightness.light,
          );
          systemDarkColorScheme = corePalette.toColorScheme(
            brightness: Brightness.dark,
          );
          return;
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      try {
        // Windows, Linux & macOS.
        final accentColor = await DynamicColorPlugin.getAccentColor();
        if (accentColor != null) {
          systemLightColorScheme = ColorScheme.fromSeed(
            seedColor: accentColor,
            brightness: Brightness.light,
          );
          systemDarkColorScheme = ColorScheme.fromSeed(
            seedColor: accentColor,
            brightness: Brightness.dark,
          );
          return;
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }();

    instance = Visuals._(
      standard: standard,
      themeMode: themeMode,
      systemColorScheme: systemColorScheme,
      animationDuration: animationDuration,
      systemLight: systemLightColorScheme?.primary,
      systemDark: systemDarkColorScheme?.primary,
      systemLightColorScheme: systemLightColorScheme,
      systemDarkColorScheme: systemDarkColorScheme,
    );
  }

  Visuals._({
    required this.standard,
    required this.themeMode,
    required this.systemColorScheme,
    required this.animationDuration,
    required this.systemLight,
    required this.systemDark,
    required this.systemLightColorScheme,
    required this.systemDarkColorScheme,
  });

  Color get light {
    if (systemColorScheme) {
      return systemLight ?? kDefaultLightPrimaryColorM2;
    }
    return kDefaultLightPrimaryColorM2;
  }

  Color get dark {
    if (systemColorScheme) {
      return systemDark ?? kDefaultDarkPrimaryColorM2;
    }
    return kDefaultDarkPrimaryColorM2;
  }

  ColorScheme get lightColorScheme {
    if (systemColorScheme) {
      return systemLightColorScheme ?? defaultLightColorSchemeM3;
    }
    return defaultLightColorSchemeM3;
  }

  ColorScheme get darkColorScheme {
    if (systemColorScheme) {
      return systemDarkColorScheme ?? defaultDarkColorSchemeM3;
    }
    return defaultDarkColorSchemeM3;
  }

  ThemeData get adaptive => themeMode == ThemeMode.light ? theme : darkTheme;

  ThemeData get theme => {
        3: createM3Theme(
          colorScheme: lightColorScheme,
          mode: ThemeMode.light,
          animationDuration: animationDuration,
        ),
        2: createM2Theme(
          color: light,
          mode: ThemeMode.light,
          animationDuration: animationDuration,
        )
      }[standard]!;

  ThemeData get darkTheme => {
        3: createM3Theme(
          colorScheme: darkColorScheme,
          mode: ThemeMode.dark,
          animationDuration: animationDuration,
        ),
        2: createM2Theme(
          color: dark,
          mode: ThemeMode.dark,
          animationDuration: animationDuration,
        )
      }[standard]!;

  Future<void> update({
    ThemeMode? themeMode,
    int? standard,
    BuildContext? context,
    AnimationDuration? animationDuration,
  }) async {
    this.themeMode = themeMode ?? this.themeMode;
    this.standard = standard ?? this.standard;
    this.context = context ?? this.context;
    this.animationDuration = animationDuration ?? this.animationDuration;
    themeMode ??= this.themeMode;
    standard ??= this.standard;
    context ??= this.context;
    animationDuration ??= this.animationDuration;
    if (context != null) {
      if (Platform.isAndroid || Platform.isIOS) {
        final brightness = Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark;
        switch (standard) {
          case 3:
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarBrightness: brightness,
                statusBarIconBrightness: brightness,
                statusBarColor: Colors.transparent,
                // Edge-to-edge effect.
                systemNavigationBarIconBrightness: brightness,
                systemNavigationBarColor:
                    adaptive.navigationBarTheme.backgroundColor,
                systemNavigationBarDividerColor:
                    adaptive.navigationBarTheme.backgroundColor,
              ),
            );
            break;
          case 2:
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarBrightness: brightness,
                statusBarIconBrightness: brightness,
                statusBarColor: Colors.transparent,
                // Always stays black.
                systemNavigationBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.black,
                systemNavigationBarDividerColor: Colors.black,
              ),
            );
            break;
          default:
            throw ArgumentError.value(
              standard,
              'Material Design standard',
              'Only valid values are 2 & 3.',
            );
        }
      }
    } else {
      debugPrint('No [BuildContext] provided.');
    }
    notifyListeners();
    await Configuration.instance.save(
      themeMode: themeMode,
      animationDuration: animationDuration,
    );
  }
}
