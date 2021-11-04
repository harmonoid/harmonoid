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
import 'package:harmonoid/utils/widgets.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/interface/harmonoid.dart';

abstract class Utils {
  static Future<void> handleYouTubeFailure() async {
    showDialog(
      context: key.currentState!.overlay!.context,
      builder: (context) => FractionallyScaledWidget(
        child: AlertDialog(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(
            'Could not fetch the YouTube audio stream.',
            style: Theme.of(context).textTheme.headline1,
          ),
          content: Text(
            'Please report the issue on the repository. Possibly something changed on YouTube\'s website.\nLet\'s play your local music till then.',
            style: Theme.of(context).textTheme.headline3,
          ),
          actions: [
            MaterialButton(
              textColor: Theme.of(context).primaryColor,
              onPressed: Navigator.of(context).pop,
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
    nowPlaying.isBuffering = false;
  }

  static Future<void> handleInvalidLink() async {
    showDialog(
      context: key.currentState!.overlay!.context,
      builder: (context) => FractionallyScaledWidget(
        child: AlertDialog(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(
            'Invalid link.',
            style: Theme.of(context).textTheme.headline1,
          ),
          content: Text(
            'Please give us correct link to the media.\nIf you think this is a false result, please report at the repository.',
            style: Theme.of(context).textTheme.headline3,
          ),
          actions: [
            MaterialButton(
              textColor: Theme.of(context).primaryColor,
              onPressed: Navigator.of(context).pop,
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  static ThemeData getTheme(
      {required Color accentColor, ThemeMode? themeMode}) {
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
      button: Platform.isLinux
          ? TextStyle(
              color: accentColor,
              fontSize: 14.0,
              fontWeight: FontWeights.thick(isLight),
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
                fontFamily: Platform.isLinux ? 'Roboto' : null,
                fontWeight: FontWeights.thin(isLight),
              ),
              secondaryLabelStyle: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontFamily: Platform.isLinux ? 'Roboto' : null,
                fontWeight: FontWeights.thin(isLight),
              ),
              brightness: Brightness.dark,
            )
          : null,
      fontFamily: Platform.isLinux ? 'Roboto' : null,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accentColor,
        selectionColor: accentColor.withOpacity(0.2),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: MaterialStateProperty.all(8.0),
        thumbColor: MaterialStateProperty.all(
          isLight
              ? Colors.black.withOpacity(0.4)
              : Colors.white.withOpacity(0.4),
        ),
        isAlwaysShown: Platform.isWindows || Platform.isLinux,
      ),
      splashFactory: InkRipple.splashFactory,
      splashColor: Platform.isAndroid ? null : Colors.transparent,
      primaryColorLight: accentColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(accentColor),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          shadowColor: MaterialStateProperty.all(accentColor),
          elevation: MaterialStateProperty.all(8.0),
        ),
      ),
      primaryColor: accentColor,
      primaryColorDark: accentColor,
      scaffoldBackgroundColor: configuration.acrylicEnabled!
          ? Colors.transparent
          : (isLight ? Colors.white : Color(0xFF202020)),
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
        color: isLight ? Colors.white : Color(0xFF292929),
        systemOverlayStyle:
            isLight ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        elevation: 4.0,
        iconTheme: IconThemeData(
          color: isLight ? Colors.black : Colors.white,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: isLight ? Colors.black : Colors.white,
          size: 24,
        ),
      ),
      iconTheme: IconThemeData(
        color: isLight ? Colors.black : Colors.white,
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

  static bool isPresentInCollectionDirectories(Track track) {
    bool isPresent = false;
    for (Directory directory in configuration.collectionDirectories!) {
      if (directory.path.startsWith(track.filePath!)) {
        isPresent = true;
        break;
      }
    }
    return isPresent;
  }
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
