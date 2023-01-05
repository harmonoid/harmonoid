/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

// DO NOT IMPORT ANYTHING FROM `package:harmonoid` IN THIS FILE.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';

final desktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
final mobile = Platform.isAndroid || Platform.isIOS;

ThemeData createMaterial3ThemeModern({
  required ThemeMode mode,
  required Color color,
}) {
  bool light = mode == ThemeMode.light;
  final color = NowPlayingColorPalette.instance.modernColor;
  return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: color,
      brightness: light ? Brightness.light : Brightness.dark,
      fontFamily: "LexendDeca",
      scaffoldBackgroundColor:
          light ? Color.alphaBlend(color.withAlpha(40), Colors.white) : null,
      splashColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.white.withAlpha(10),
      disabledColor: Color.fromARGB(200, 60, 60, 60),
      appBarTheme: AppBarTheme(
          actionsIconTheme: IconThemeData(
              color: light
                  ? Color.fromARGB(200, 40, 40, 40)
                  : Color.fromARGB(200, 233, 233, 233))),
      iconTheme: IconThemeData(
        color: light
            ? Color.fromARGB(200, 40, 40, 40)
            : Color.fromARGB(200, 233, 233, 233),
      ),
      shadowColor: light
          ? Color.fromARGB(180, 100, 100, 100)
          : Color.fromARGB(222, 10, 10, 10),
      dividerTheme: DividerThemeData(
        thickness: 4,
        indent: 0.0,
        endIndent: 0.0,
      ),
      listTileTheme: ListTileThemeData(
          horizontalTitleGap: 4.0,
          selectedColor: light
              ? Color.fromARGB(255, 212, 212, 212)
              : Color.alphaBlend(
                  color.withAlpha(40), Color.fromARGB(255, 55, 55, 55)),
          iconColor: Color.alphaBlend(color.withAlpha(140), Colors.white),
          textColor: Color.alphaBlend(color.withAlpha(140), Colors.white)),
      cardTheme: CardTheme(
        elevation: 12.0,
        color: light
            ? Color.alphaBlend(
                color.withAlpha(40),
                Color.fromARGB(255, 255, 255, 255),
              )
            : Color.alphaBlend(
                color.withAlpha(40),
                Color.fromARGB(255, 35, 35, 35),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 12.0,
        // color: Color.fromARGB(255, 24, 24, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          // color: Colors.white.withOpacity(0.80),
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          // color: Colors.white.withOpacity(0.80),
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
        ),
        // Used as [DataTable]'s column title text-theme.
        titleSmall: TextStyle(
          // color: Colors.white,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        ),
        // Used as [AlertDialog]'s [title] text-theme.
        titleLarge: TextStyle(
          // color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
        displayLarge: TextStyle(
          fontWeight: FontWeight.w700,
          // color: Colors.white.withOpacity(0.80),
          fontSize: 18.0,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.w600,
          // color: Colors.white.withOpacity(0.75),
          fontSize: 16.0,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.w400,
          // color: Colors.white.withOpacity(0.65),
          fontSize: 14.0,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.normal,
          // color: Colors.white.withOpacity(0.75),
          fontSize: 14.0,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.normal,
          // color: Colors.white.withOpacity(0.65),
          fontSize: 14.0,
        ),
      ));
}
