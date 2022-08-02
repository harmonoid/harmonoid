/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData createTheme({
  required Color color,
  required ThemeMode themeMode,
}) {
  bool isLight = themeMode == ThemeMode.light;
  late TextTheme textTheme;
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    textTheme = TextTheme(
      /// Leading tile widgets text theme.
      headline1: TextStyle(
        color: isLight ? Colors.black : Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),

      /// [AlbumTile] text theme.
      headline2: TextStyle(
        color: isLight ? Colors.black : Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      ),
      headline3: TextStyle(
        color: isLight
            ? Colors.black.withOpacity(0.87)
            : Colors.white.withOpacity(0.87),
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      headline4: TextStyle(
        color: isLight ? Colors.black : Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      headline5: TextStyle(
        color: isLight
            ? Colors.black.withOpacity(0.87)
            : Colors.white.withOpacity(0.87),
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
      ),

      /// [ListTile] text theme.
      /// [ListTile.title]'s text theme must be overrided to headline4, if it does not contain subtitle.
      subtitle1: TextStyle(
        color: isLight ? Colors.black : Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      ),
      bodyText2: TextStyle(
        color: isLight
            ? Colors.black.withOpacity(0.87)
            : Colors.white.withOpacity(0.87),
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      caption: TextStyle(
        color: isLight
            ? Colors.black.withOpacity(0.87)
            : Colors.white.withOpacity(0.87),
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
    );
  } else {
    textTheme = TextTheme(
      headline1: TextStyle(
        fontWeight: FontWeight.normal,
        color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
        fontSize: 18.0,
      ),
      headline2: TextStyle(
        fontWeight: FontWeight.normal,
        color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
        fontSize: 16.0,
      ),
      headline3: TextStyle(
        fontWeight: FontWeight.normal,
        color: isLight ? Colors.black54 : Colors.white.withOpacity(0.54),
        fontSize: 14.0,
      ),
      headline4: TextStyle(
        fontWeight: FontWeight.normal,
        color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
        fontSize: 14.0,
      ),
      headline5: TextStyle(
        fontWeight: FontWeight.normal,
        color: isLight ? Colors.black54 : Colors.white.withOpacity(0.54),
        fontSize: 14.0,
      ),
      headline6: TextStyle(
        fontWeight: FontWeight.normal,
        color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
        fontSize: 18.0,
      ),
    );
  }
  return ThemeData(
    // ignore: deprecated_member_use
    androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
    // Explicitly using [ChipThemeData] on Linux since it seems to be falling back to Ubuntu's font family.
    chipTheme: Platform.isLinux
        ? ChipThemeData(
            backgroundColor: color,
            disabledColor: color.withOpacity(0.2),
            selectedColor: color,
            secondarySelectedColor: color,
            padding: EdgeInsets.zero,
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              fontFamily: 'Inter',
            ),
            secondaryLabelStyle: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              fontFamily: 'Inter',
            ),
            brightness: Brightness.dark,
          )
        : null,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: color,
      selectionHandleColor: color,
      selectionColor: color.withOpacity(0.2),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: MaterialStateProperty.all(true),
      thickness: MaterialStateProperty.all(8.0),
      trackBorderColor:
          MaterialStateProperty.all(isLight ? Colors.black12 : Colors.white24),
      trackColor:
          MaterialStateProperty.all(isLight ? Colors.black12 : Colors.white24),
      crossAxisMargin: 0.0,
      radius: Radius.zero,
      minThumbLength: 96.0,
      thumbColor: MaterialStateProperty.resolveWith(
        (states) {
          if ([
            MaterialState.hovered,
            MaterialState.dragged,
            MaterialState.focused,
            MaterialState.pressed,
          ].fold(false, (val, el) => val || states.contains(el))) {
            return isLight ? Colors.black54 : Colors.white54;
          } else {
            return isLight ? Colors.black26 : Colors.white24;
          }
        },
      ),
    ),
    splashFactory: InkRipple.splashFactory,
    primaryColorLight: color,
    primaryColor: color,
    primaryColorDark: color,
    scaffoldBackgroundColor: isLight ? Colors.grey.shade100 : Color(0xFF121212),
    toggleableActiveColor: color,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isLight ? Color(0xFF202020) : Colors.white,
      actionTextColor: color,
      contentTextStyle: textTheme.headline4?.copyWith(
        color: isLight ? Colors.white : Colors.black,
      ),
    ),
    cardColor: isLight ? Colors.white : Color(0xFF222222),
    backgroundColor: color.withOpacity(0.24),
    dividerColor: isLight ? Colors.black12 : Colors.white24,
    disabledColor: isLight ? Colors.black38 : Colors.white38,
    tabBarTheme: TabBarTheme(
      labelColor: color,
      unselectedLabelColor:
          isLight ? Colors.black54 : Colors.white.withOpacity(0.67),
    ),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 2.0,
      color: isLight ? Colors.white : Color(0xFF292929),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Platform.isAndroid || Platform.isIOS
          ? isLight
              ? Colors.white
              : Color(0xFF202020)
          : isLight
              ? Colors.white
              : Color(0xFF272727),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: isLight ? Colors.white12 : Colors.black12,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      ),
      elevation: 4.0,
      iconTheme: IconThemeData(
        color: isLight ? Colors.black54 : Colors.white54,
        size: 24.0,
      ),
      actionsIconTheme: IconThemeData(
        color: isLight ? Colors.black54 : Colors.white54,
        size: 24.0,
      ),
    ),
    iconTheme: IconThemeData(
      color: isLight ? Color(0xFF757575) : Color(0xFF8A8A8A),
      size: 24,
    ),
    dialogBackgroundColor: isLight ? Colors.white : Color(0xFF202020),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isLight ? color : Color(0xFF272727),
      selectedItemColor: Colors.white.withOpacity(0.87),
      unselectedItemColor: Colors.white54,
    ),
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: color,
      brightness: isLight ? Brightness.light : Brightness.dark,
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: Platform.isWindows || Platform.isLinux || Platform.isMacOS
          ? TextStyle(
              fontSize: 12.0,
              color: isLight ? Colors.white : Colors.black,
            )
          : null,
      decoration: BoxDecoration(
        color: isLight ? Colors.black : Colors.white,
        borderRadius: Platform.isAndroid || Platform.isIOS
            ? BorderRadius.circular(16.0)
            : BorderRadius.circular(4.0),
      ),
      height: Platform.isAndroid || Platform.isIOS ? 32.0 : null,
      verticalOffset: Platform.isWindows || Platform.isLinux || Platform.isMacOS
          ? 36.0
          : null,
      preferBelow: Platform.isWindows || Platform.isLinux || Platform.isMacOS
          ? true
          : null,
      waitDuration: Duration(seconds: 1),
    ),
    fontFamily: Platform.isLinux ? 'Inter' : null,
  );
}

const kAccents = [
  Accent(Color(0xFF6200EA), Color(0xFF7C4DFF)),
  Accent(Color(0xFFF55A34), Color(0xFFF55A34)),
  Accent(Color(0xFFE53935), Color(0xFFE53935)),
  Accent(Color(0xFF4285F4), Color(0xFF82B1FF)),
  Accent(Color(0xFFF4B400), Color(0xFFFFE57F)),
  Accent(Color(0xFF0F9D58), Color(0xFF0F9D58)),
  Accent(Color(0xFF89CDD0), Color(0xFF89CDD0)),
  Accent(Color(0xFF5B51D8), Color(0xFFD1C4E9)),
  Accent(Color(0xFFF50057), Color(0xFFFF80AB)),
  Accent(Color(0xFF424242), Color(0xFF757575)),
];

class Accent {
  final Color light;
  final Color dark;

  const Accent(this.light, this.dark);
}
