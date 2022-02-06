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
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'package:harmonoid/interface/settings/settings.dart';

ThemeData getTheme({required Color accentColor, ThemeMode? themeMode}) {
  bool isLight = themeMode == ThemeMode.light;
  TextTheme textTheme = TextTheme(
    // Leading tile widgets text theme.
    headline1: TextStyle(
      color: isLight ? Colors.black : Colors.white,
      fontSize: 16.0,
      fontWeight: FontWeights.thick(isLight),
    ),
    // AlbumTile text theme.
    headline2: TextStyle(
      color: isLight ? Colors.black : Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeights.thick(isLight),
    ),
    headline3: TextStyle(
      color: isLight
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      fontSize: 14.0,
      fontWeight: FontWeights.thin(isLight),
    ),
    headline4: TextStyle(
      color: isLight ? Colors.black : Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeights.thin(isLight),
    ),
    headline5: TextStyle(
      color: isLight
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      fontSize: 12.0,
      fontWeight: FontWeights.thin(isLight),
    ),
    // ListTile text theme.
    // [ListTile.title]'s text theme must be overrided to headline4, if it does not contain subtitle.
    subtitle1: TextStyle(
      color: isLight ? Colors.black : Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeights.thick(isLight),
    ),
    bodyText2: TextStyle(
      color: isLight
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      fontSize: 14.0,
      fontWeight: FontWeights.thin(isLight),
    ),
    caption: TextStyle(
      color: isLight
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      fontSize: 14.0,
      fontWeight: FontWeights.thin(isLight),
    ),
  );
  return ThemeData(
    fontFamily: Platform.isLinux ? 'Roboto' : null,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: accentColor,
      selectionColor: accentColor.withOpacity(0.2),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: MaterialStateProperty.all(8.0),
      thumbColor: MaterialStateProperty.all(
        isLight ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
      ),
    ),
    splashFactory: InkRipple.splashFactory,
    splashColor: Colors.transparent,
    primaryColorLight: accentColor,
    primaryColor: accentColor,
    primaryColorDark: accentColor,
    scaffoldBackgroundColor: isLight ? Colors.white : Color(0xFF121212),
    toggleableActiveColor: accentColor,
    cardColor: isLight
        ? Colors.black.withOpacity(0.04)
        : Colors.white.withOpacity(0.04),
    backgroundColor: accentColor.withOpacity(0.24),
    dividerColor: isLight ? Colors.black12 : Colors.white24,
    disabledColor: isLight ? Colors.black38 : Colors.white38,
    tabBarTheme: TabBarTheme(
      labelColor: accentColor,
      unselectedLabelColor:
          isLight ? Colors.black54 : Colors.white.withOpacity(0.67),
    ),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 0.0,
      color: isLight ? Colors.white : Color(0xFF242424),
    ),
    appBarTheme: AppBarTheme(
      color: isLight ? Colors.white : Color(0xFF292929),
      systemOverlayStyle:
          isLight ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      elevation: 4.0,
      iconTheme: IconThemeData(
        color: isLight ? Colors.black54 : Colors.white.withOpacity(0.87),
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: isLight ? Colors.black54 : Colors.white.withOpacity(0.87),
        size: 24,
      ),
    ),
    iconTheme: IconThemeData(
      color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
      size: 24,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isLight ? accentColor : Color(0xFF292929),
      selectedItemColor: Colors.white.withOpacity(0.87),
      unselectedItemColor: Colors.white54,
    ),
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: accentColor,
      brightness: isLight ? Brightness.light : Brightness.dark,
    ),
  );
}

class FontWeights {
  static FontWeight thick(bool isLight) {
    if (Platform.isLinux) {
      return FontWeight.w400;
    }
    return FontWeight.w600;
  }

  static FontWeight thin(bool isLight) {
    if (Platform.isLinux) {
      return isLight
          ? FontWeight.normal
          : FontWeight.lerp(FontWeight.w400, FontWeight.w300, 0.8)!;
    }
    return FontWeight.normal;
  }
}

class ExceptionApp extends StatelessWidget {
  final Object exception;
  final StackTrace stacktrace;
  ExceptionApp({Key? key, required this.exception, required this.stacktrace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: getTheme(
        accentColor: Colors.deepPurpleAccent.shade200,
        themeMode: ThemeMode.dark,
      ),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: Column(
          children: [
            DesktopTitleBar(),
            Container(
              height: 56.0,
              color: Colors.white.withOpacity(0.10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24.0,
                  ),
                  Text(
                    'Exception',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                children: [
                  SettingsTile(
                    title: 'Exception occured',
                    subtitle: 'Something wrong has happened.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exception.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeights.thin(false),
                          ),
                        ),
                        Text(
                          stacktrace.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeights.thin(false),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ],
              ),
            ),
            ButtonBar(
              children: [
                MaterialButton(
                  onPressed: () => UrlLauncher.launch(
                      'https://github.com/alexmercerind/harmonoid/issues'),
                  child: Text(
                    'REPORT',
                    style: TextStyle(
                      color: Colors.deepPurpleAccent.shade200,
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: SystemNavigator.pop,
                  child: Text(
                    'EXIT',
                    style: TextStyle(
                      color: Colors.deepPurpleAccent.shade200,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
