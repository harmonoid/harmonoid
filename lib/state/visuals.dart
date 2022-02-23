/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/core/configuration.dart';

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
  Accent accent;
  ThemeMode themeMode;

  Visuals({
    required this.accent,
    required this.themeMode,
    required this.context,
  }) {
    update(context: context);
  }

  void update({
    Accent? accent,
    ThemeMode? themeMode,
    TargetPlatform? platform,
    BuildContext? context,
  }) {
    this.accent = accent ?? this.accent;
    this.themeMode = themeMode ?? this.themeMode;
    if (isMobile && context != null) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white12
              : Colors.black12,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
        ),
      );
    }
    this.notifyListeners();
    Configuration.instance.save(
      accent: this.accent,
      themeMode: this.themeMode,
    );
  }

  ThemeData get theme => createTheme(
        color: this.accent.light,
        themeMode: ThemeMode.light,
      );

  ThemeData get darkTheme => createTheme(
        color: this.accent.dark,
        themeMode: ThemeMode.dark,
      );
}
