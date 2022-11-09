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

ThemeData createTheme({
  required Color color,
  required ThemeMode themeMode,
}) {
  final light = themeMode == ThemeMode.light;
  final TextTheme theme;
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    theme = TextTheme(
      /// Leading tile widgets text theme.
      displayLarge: TextStyle(
        color: light ? Colors.black : Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),

      /// [AlbumTile] text theme.
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

      /// [ListTile] text theme.
      /// [ListTile.title]'s text theme must be overrided to headlineMedium, if it does not contain subtitle.
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
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(color),
        overlayColor: MaterialStateProperty.all(
          color.withOpacity(0.05),
        ),
        textStyle: (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            ? MaterialStateProperty.all(
                TextStyle(
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  fontFamily: Platform.isLinux ? 'Inter' : null,
                ),
              )
            : null,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.disabled)
              ? light
                  ? Colors.black12
                  : Colors.white24
              : color;
        }),
        textStyle: (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            ? MaterialStateProperty.all(
                TextStyle(
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
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
    splashFactory: Platform.isWindows || Platform.isMacOS || Platform.isLinux
        ? InkRipple.splashFactory
        : InkSparkle.splashFactory,
    highlightColor: Platform.isWindows || Platform.isMacOS || Platform.isLinux
        ? null
        : Colors.transparent,
    primaryColorLight: color,
    primaryColor: color,
    primaryColorDark: color,
    scaffoldBackgroundColor: light ? Colors.white : Colors.black,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: light ? Color(0xFF202020) : Colors.white,
      actionTextColor: color,
      contentTextStyle: theme.headlineMedium?.copyWith(
        color: light ? Colors.white : Colors.black,
      ),
    ),
    cardColor: light ? Colors.white : Color(0xFF222222),
    dividerColor: light ? Colors.black12 : Colors.white24,
    disabledColor: light ? Colors.black38 : Colors.white38,
    tabBarTheme: TabBarTheme(
      labelColor: color,
      unselectedLabelColor:
          light ? Colors.black54 : Colors.white.withOpacity(0.67),
    ),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 2.0,
      color: light ? Colors.white : Color(0xFF292929),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Platform.isAndroid || Platform.isIOS
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
    textTheme: theme,
    primaryTextTheme: theme,
    tooltipTheme: TooltipThemeData(
      textStyle: Platform.isWindows || Platform.isLinux || Platform.isMacOS
          ? TextStyle(
              fontSize: 12.0,
              color: light ? Colors.white : Colors.black,
            )
          : null,
      decoration: BoxDecoration(
        color: light ? Colors.black : Colors.white,
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
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return color;
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return color;
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return color;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return color;
        }
        return null;
      }),
    ),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(
          secondary: color,
          brightness: light ? Brightness.light : Brightness.dark,
        )
        .copyWith(background: color.withOpacity(0.24)),
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
