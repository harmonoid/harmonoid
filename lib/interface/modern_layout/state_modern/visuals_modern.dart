/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/interface/modern_layout/utils_modern/material3theme_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/theme_modern.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/core/configuration.dart';

/// Default light theme color.
const kPrimaryLightColor = Color(0xFF6200EA);

/// Default dark theme color.
const kPrimaryDarkColor = Color(0xFF7C4DFF);

/// Visuals
/// -------
///
/// Minimal [ChangeNotifier] which serves the purpose of passing the current
/// app theme down the [Widget] tree & trigger UI updates whenever theme is
/// changed, while automatically updating [SystemChrome] & saving current
/// theme to the [Configuration].
///
class VisualsModern extends ChangeNotifier {
  BuildContext? context;
  Color light;
  Color dark;
  ThemeMode? themeMode;
  List<Color>? colorPalette;
  Color? color;
  VisualsModern({
    this.light = kPrimaryLightColor,
    this.dark = kPrimaryDarkColor,
    this.themeMode,
    this.context,
    this.colorPalette,
    this.color,
  }) {
    update(context: context);
  }

  void update({
    Color? light,
    Color? dark,
    ThemeMode? themeMode,
    TargetPlatform? platform,
    BuildContext? context,
  }) async {
    final colorDelightened =
        color ?? NowPlayingColorPalette.instance.modernColor;
    this.light = colorDelightened;
    this.dark = colorDelightened;

    this.themeMode = themeMode ?? this.themeMode;

    this.notifyListeners();
    await Configuration.instance.save(themeModeModern: this.themeMode);
  }

  ThemeData get theme => createThemeModern(
        color: light,
        mode: ThemeMode.light,
      );

  ThemeData get darkTheme => createThemeModern(
        color: dark,
        mode: ThemeMode.dark,
      );

  // ThemeData get dynamicLightTheme => ThemeData(
  //       useMaterial3: true,
  //       colorSchemeSeed: Colors.blue,
  //       brightness: Brightness.light,
  //       fontFamily: "LexendDeca",
  //     );
  // ThemeData get dynamicDarkTheme => ThemeData(
  //       useMaterial3: true,
  //       colorSchemeSeed: Colors.red,
  //       brightness: Brightness.dark,
  //       fontFamily: "LexendDeca",
  //     );
  ThemeData get dynamicLightTheme =>
      createMaterial3ThemeModern(mode: ThemeMode.light, color: light);
  ThemeData get dynamicDarkTheme =>
      createMaterial3ThemeModern(mode: ThemeMode.dark, color: dark);
}
