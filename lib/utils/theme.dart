/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

ThemeData createTheme({required Color accentColor, ThemeMode? themeMode}) {
  bool isLight = themeMode == ThemeMode.light;
  TextTheme textTheme = TextTheme(
    /// Leading tile widgets text theme.
    headline1: TextStyle(
      color: isLight ? Colors.black : Colors.white,
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
    ),

    /// [CollectionAlbumTile] text theme.
    headline2: TextStyle(
      color: isLight ? Colors.black : Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
    ),
    headline3: TextStyle(
      color: isLight
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
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
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
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
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
    ),
    caption: TextStyle(
      color: isLight
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
    ),
    button: Platform.isLinux
        ? TextStyle(
            color: accentColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          )
        : null,
  );
  return ThemeData(
    chipTheme: Platform.isLinux
        ? ChipThemeData(
            backgroundColor: accentColor,
            disabledColor: accentColor.withOpacity(0.2),
            selectedColor: accentColor,
            secondarySelectedColor: accentColor,
            padding: EdgeInsets.zero,
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            secondaryLabelStyle: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            brightness: Brightness.dark,
          )
        : null,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: accentColor,
      selectionColor: accentColor.withOpacity(0.2),
    ),
    scrollbarTheme: ScrollbarThemeData(
      isAlwaysShown: true,
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
    primaryColorLight: accentColor,
    primaryColor: accentColor,
    primaryColorDark: accentColor,
    scaffoldBackgroundColor: isLight ? Colors.grey.shade100 : Color(0xFF121212),
    toggleableActiveColor: accentColor,
    cardColor: isLight ? Colors.white : Color(0xFF202020),
    backgroundColor: accentColor.withOpacity(0.24),
    dividerColor: isLight ? Colors.black12 : Colors.white24,
    disabledColor: isLight ? Colors.black38 : Colors.white38,
    tabBarTheme: TabBarTheme(
      labelColor: accentColor,
      unselectedLabelColor:
          isLight ? Colors.black54 : Colors.white.withOpacity(0.67),
    ),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 2.0,
      color: isLight ? Colors.white : Color(0xFF242424),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isLight ? Colors.white : Color(0xFF272727),
      systemOverlayStyle:
          isLight ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
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
      color: isLight ? Colors.black54 : Colors.white54,
      size: 24,
    ),
    dialogBackgroundColor: isLight ? Colors.white : Color(0xFF202020),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isLight ? accentColor : Color(0xFF272727),
      selectedItemColor: Colors.white.withOpacity(0.87),
      unselectedItemColor: Colors.white54,
    ),
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: accentColor,
      brightness: isLight ? Brightness.light : Brightness.dark,
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: TextStyle(
        fontSize: 14.0,
        color: isLight ? Colors.white : Colors.black,
      ),
      verticalOffset: Platform.isWindows || Platform.isLinux || Platform.isMacOS
          ? 36.0
          : null,
      preferBelow: Platform.isWindows || Platform.isLinux || Platform.isMacOS
          ? true
          : null,
      waitDuration: Duration(seconds: 1),
    ),
  );
}

const List<Accent?> kAccents = [
  Accent(
    light: Color(0xFF651FFF),
    dark: Color(0xFF7C4DFF),
  ),
  Accent(
    light: Color(0xFFF55A34),
    dark: Color(0xFFF55A34),
  ),
  Accent(
    light: Color(0xFFE53935),
    dark: Color(0xFFE53935),
  ),
  Accent(
    light: Color(0xFF4285F4),
    dark: Color(0xFF82B1FF),
  ),
  Accent(
    light: Color(0xFFF4B400),
    dark: Color(0xFFFFE57F),
  ),
  Accent(
    light: Color(0xFF0F9D58),
    dark: Color(0xFF0F9D58),
  ),
  Accent(
    light: Color(0xFF89CDD0),
    dark: Color(0xFF89CDD0),
  ),
  Accent(
    light: Color(0xFF5B51D8),
    dark: Color(0xFFD1C4E9),
  ),
  Accent(
    light: Color(0xFFF50057),
    dark: Color(0xFFFF80AB),
  ),
  Accent(
    light: Color(0xFF424242),
    dark: Color(0xFF757575),
  ),
];

class Accent {
  final Color light;
  final Color dark;

  const Accent({required this.light, required this.dark});
}
