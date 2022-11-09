/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/rendering.dart';
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
class Visuals extends ChangeNotifier {
  BuildContext context;
  Color light;
  Color dark;
  ThemeMode themeMode;

  Visuals({
    this.light = kPrimaryLightColor,
    this.dark = kPrimaryDarkColor,
    required this.themeMode,
    required this.context,
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
    this.light = light ?? this.light;
    this.dark = dark ?? this.dark;
    this.themeMode = themeMode ?? this.themeMode;
    if (isMobile && context != null) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black12
              : Colors.white12,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
        ),
      );
    }
    this.notifyListeners();
    await Configuration.instance.save(themeMode: this.themeMode);
  }

  ThemeData get theme => createTheme(
        color: light,
        mode: ThemeMode.light,
      );

  ThemeData get darkTheme => createTheme(
        color: dark,
        mode: ThemeMode.dark,
      );
}
