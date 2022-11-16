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
import 'package:flutter/services.dart';

final desktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
final mobile = Platform.isAndroid || Platform.isIOS;

ThemeData createTheme({
  required Color color,
  required ThemeMode mode,
}) {
  bool light = mode == ThemeMode.light;
  TextTheme theme;
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    theme = TextTheme(
      // Leading tile widgets text theme.
      displayLarge: TextStyle(
        color: light ? Colors.black : Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
      // [AlbumTile] text theme.
      displayMedium: TextStyle(
        color: light ? Colors.black : Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: TextStyle(
        color: light
            ? Colors.black.withOpacity(0.87)
            : Colors.white.withOpacity(0.87),
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      headlineMedium: TextStyle(
        color: light ? Colors.black : Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      headlineSmall: TextStyle(
        color: light
            ? Colors.black.withOpacity(0.87)
            : Colors.white.withOpacity(0.87),
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
      ),
      // [ListTile] text theme.
      // [ListTile.title]'s text theme must be overrided to [headlineMedium], if it does not contain subtitle.
      titleMedium: TextStyle(
        color: light ? Colors.black : Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        color: light
            ? Colors.black.withOpacity(0.87)
            : Colors.white.withOpacity(0.87),
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: light
            ? Colors.black.withOpacity(0.87)
            : Colors.white.withOpacity(0.87),
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      // Used as [DataTable]'s column title text-theme.
      titleSmall: TextStyle(
        color: light ? Colors.black : Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      ),
      // Used as [AlertDialog]'s [title] text-theme.
      titleLarge: TextStyle(
        color: light ? Colors.black : Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      ),
    );
  } else {
    theme = TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.normal,
        color: light ? Colors.black87 : Colors.white.withOpacity(0.87),
        fontSize: 18.0,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.normal,
        color: light ? Colors.black87 : Colors.white.withOpacity(0.87),
        fontSize: 16.0,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.normal,
        color: light ? Colors.black54 : Colors.white70,
        fontSize: 14.0,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.normal,
        color: light ? Colors.black87 : Colors.white.withOpacity(0.87),
        fontSize: 14.0,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.normal,
        color: light ? Colors.black54 : Colors.white70,
        fontSize: 14.0,
      ),
    );
  }
  // Enforce `Inter` font family on Linux machines.
  theme = theme.apply(fontFamily: Platform.isLinux ? 'Inter' : null);
  return ThemeData(
    // Enforce `Inter` font family on Linux machines.
    fontFamily: Platform.isLinux ? 'Inter' : null,
    colorScheme: ColorScheme(
      brightness: light ? Brightness.light : Brightness.dark,
      primary: color,
      onPrimary: color.computeLuminance() > 0.7 ? Colors.black : Colors.white,
      secondary: color,
      onSecondary: color.computeLuminance() > 0.7 ? Colors.black : Colors.white,
      error: Colors.red.shade800,
      onError: Colors.white,
      background: light ? Colors.white : Colors.black,
      onBackground: desktop
          ? (light ? Colors.black : Colors.white)
          : (light
              ? Colors.black.withOpacity(0.87)
              : Colors.white.withOpacity(0.87)),
      surface: Colors.transparent,
      onSurface: desktop
          ? (light ? Colors.black : Colors.white)
          : (light
              ? Colors.black.withOpacity(0.87)
              : Colors.white.withOpacity(0.87)),
    ),
    textTheme: theme,
    primaryTextTheme: theme,
    // Breaks [FloatingActionButton.extended].
    // floatingActionButtonTheme: FloatingActionButtonThemeData(
    //   shape: CircleBorder(),
    // ),
    // ignore: deprecated_member_use
    androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
    textButtonTheme: desktop
        ? TextButtonThemeData(
            style: ButtonStyle(
              textStyle: MaterialStatePropertyAll(
                TextStyle(
                  letterSpacing: Platform.isLinux ? 0.8 : 1.6,
                  fontWeight: FontWeight.w600,
                  // Enforce `Inter` font family on Linux machines.
                  fontFamily: Platform.isLinux ? 'Inter' : null,
                ),
              ),
            ),
          )
        : null,
    elevatedButtonTheme: desktop
        ? ElevatedButtonThemeData(
            style: ButtonStyle(
              textStyle: MaterialStatePropertyAll(
                TextStyle(
                  letterSpacing: Platform.isLinux ? 0.8 : 1.6,
                  fontWeight: FontWeight.w600,
                  // Enforce `Inter` font family on Linux machines.
                  fontFamily: Platform.isLinux ? 'Inter' : null,
                ),
              ),
            ),
          )
        : null,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: light ? Colors.white : Color(0xFF202020),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: desktop
          ? light
              ? Colors.black
              : Colors.white
          : color,
      selectionHandleColor: color,
      selectionColor: color.withOpacity(0.2),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: MaterialStateProperty.all(true),
      thickness: MaterialStateProperty.all(8.0),
      trackBorderColor:
          MaterialStateProperty.all(light ? Colors.black12 : Colors.white24),
      trackColor:
          MaterialStateProperty.all(light ? Colors.black12 : Colors.white24),
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
            return light ? Colors.black54 : Colors.white54;
          } else {
            return light ? Colors.black26 : Colors.white24;
          }
        },
      ),
    ),
    splashFactory: desktop ? InkRipple.splashFactory : InkSparkle.splashFactory,
    highlightColor: desktop ? null : Colors.transparent,
    primaryColorLight: color,
    primaryColor: color,
    primaryColorDark: color,
    scaffoldBackgroundColor: light ? Colors.white : Colors.black,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: light ? Color(0xFF202020) : Colors.white,
      actionTextColor: color,
      contentTextStyle: theme.headlineMedium?.copyWith(
        color: light ? Colors.white : Colors.black,
        // Enforce `Inter` font family on Linux machines.
        fontFamily: Platform.isLinux ? 'Inter' : null,
      ),
    ),
    disabledColor: light
        ? Color.lerp(Colors.white, Colors.black, 0.38)
        : Color.lerp(Colors.black, Colors.white, 0.38),
    tabBarTheme: TabBarTheme(
      labelColor: color,
      unselectedLabelColor:
          light ? Colors.black54 : Colors.white.withOpacity(0.67),
    ),
    dividerTheme: DividerThemeData(
      color: light ? Colors.black12 : Colors.white24,
      thickness: 1.0,
      indent: 0.0,
      endIndent: 0.0,
    ),
    cardTheme: CardTheme(
      elevation: 4.0,
      color: light ? Colors.white : Color(0xFF222222),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    // Legacy.
    cardColor: light ? Colors.white : Color(0xFF222222),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 4.0,
      color: light ? Colors.white : Color(0xFF282828),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: mobile
          ? light
              ? Colors.white
              : Color(0xFF202020)
          : light
              ? Colors.white
              : Color(0xFF272727),
      foregroundColor: light ? Colors.black87 : Colors.white.withOpacity(0.87),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: light ? Colors.white12 : Colors.black12,
        statusBarIconBrightness: light ? Brightness.dark : Brightness.light,
      ),
      elevation: 4.0,
      iconTheme: IconThemeData(
        color: light
            ? Color.lerp(Colors.white, Colors.black, 0.70)
            : Color.lerp(Colors.black, Colors.white, 1.0),
        size: 24.0,
      ),
      actionsIconTheme: IconThemeData(
        color: light
            ? Color.lerp(Colors.white, Colors.black, 0.70)
            : Color.lerp(Colors.black, Colors.white, 1.0),
        size: 24.0,
      ),
    ),
    iconTheme: IconThemeData(
      color: light
          ? Color.lerp(Colors.white, Colors.black, 0.54)
          : Color.lerp(Colors.black, Colors.white, 0.54),
      size: 24.0,
    ),
    dialogBackgroundColor: light ? Colors.white : Color(0xFF202020),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: light ? color : Color(0xFF272727),
      selectedItemColor: Colors.white.withOpacity(0.87),
      unselectedItemColor: Colors.white54,
    ),
    tooltipTheme: desktop
        ? TooltipThemeData(
            textStyle: TextStyle(
              fontSize: 12.0,
              color: light ? Colors.white : Colors.black,
              // Enforce `Inter` font family on Linux machines.
              fontFamily: Platform.isLinux ? 'Inter' : null,
            ),
            decoration: BoxDecoration(
              color: light ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
            height: null,
            verticalOffset: 36.0,
            preferBelow: true,
            waitDuration: const Duration(seconds: 1),
          )
        : null,
    extensions: {
      IconColors(
        Color.lerp(Colors.white, Colors.black, 0.54),
        Color.lerp(Colors.black, Colors.white, 0.54),
        Color.lerp(Colors.white, Colors.black, 0.70),
        Color.lerp(Colors.black, Colors.white, 1.0),
        Color.lerp(Colors.white, Colors.black, 0.70),
        Color.lerp(Colors.black, Colors.white, 1.0),
      ),
    },
  );
}

class IconColors extends ThemeExtension<IconColors> {
  final Color? lightIconColor;
  final Color? darkIconColor;
  final Color? appBarLightIconColor;
  final Color? appBarDarkIconColor;
  final Color? appBarActionLightIconColor;
  final Color? appBarActionDarkIconColor;

  IconColors(
    this.lightIconColor,
    this.darkIconColor,
    this.appBarLightIconColor,
    this.appBarDarkIconColor,
    this.appBarActionLightIconColor,
    this.appBarActionDarkIconColor,
  );

  @override
  ThemeExtension<IconColors> copyWith({
    Color? lightIconColor,
    Color? darkIconColor,
    Color? appBarLightIconColor,
    Color? appBarDarkIconColor,
    Color? appBarActionLightIconColor,
    Color? appBarActionDarkIconColor,
  }) {
    return IconColors(
      lightIconColor ?? this.lightIconColor,
      darkIconColor ?? this.darkIconColor,
      appBarLightIconColor ?? this.appBarLightIconColor,
      appBarDarkIconColor ?? this.appBarDarkIconColor,
      appBarActionLightIconColor ?? this.appBarActionLightIconColor,
      appBarActionDarkIconColor ?? this.appBarActionDarkIconColor,
    );
  }

  @override
  ThemeExtension<IconColors> lerp(ThemeExtension<IconColors>? other, double t) {
    if (other is! IconColors) {
      return this;
    }
    return IconColors(
      Color.lerp(
        lightIconColor,
        other.lightIconColor,
        t,
      ),
      Color.lerp(
        darkIconColor,
        other.darkIconColor,
        t,
      ),
      Color.lerp(
        appBarLightIconColor,
        other.appBarLightIconColor,
        t,
      ),
      Color.lerp(
        appBarDarkIconColor,
        other.appBarDarkIconColor,
        t,
      ),
      Color.lerp(
        appBarActionLightIconColor,
        other.appBarActionLightIconColor,
        t,
      ),
      Color.lerp(
        appBarActionDarkIconColor,
        other.appBarActionDarkIconColor,
        t,
      ),
    );
  }
}
