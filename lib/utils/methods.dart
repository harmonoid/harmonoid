
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/constants/language.dart';


abstract class Methods {

  static int binaryIndexOf(List<dynamic> collectionList, List<dynamic> keywordList) {
    int indexOfKeywordList = -1;
    for (int index = 0; index < collectionList.length; index++) {
      List<dynamic> object = collectionList[index];
      if (object[0] == keywordList[0] && object[1] == keywordList[1]) {
        indexOfKeywordList = index;
        break;
      }
    }
    return indexOfKeywordList;
  }

  static bool binaryContains(List<dynamic> collectionList, List<dynamic> keywordList) => binaryIndexOf(collectionList, keywordList) != -1 ? true : false;

  static bool isFileSupported(FileSystemEntity? file) {
    if (file is File && SUPPORTED_FILE_TYPES.contains(file.path.split('.').last.toUpperCase())) {
      return true;
    }
    else {
      return false;
    }
  }

  static String? mediaTypeToLanguage(MediaType mediaType) {
    if (mediaType is Album)
      return language!.STRING_ALBUM;
    else if (mediaType is Track)
      return language!.STRING_TRACK;
    else if (mediaType is Artist)
      return language!.STRING_ARTIST;
    else if (mediaType is Playlist)
      return language!.STRING_PLAYLIST;
    else
      return null;
  }

  static Future<void> askStoragePermission() async {
    if (Platform.isAndroid)
      if (await Permission.storage.isDenied) {
        PermissionStatus storagePermissionState = await Permission.storage.request();
        if (!storagePermissionState.isGranted) {
          SystemNavigator.pop(
            animated: true,
          );
        }
      }
  }

  static ThemeData getTheme({required Color accentColor, ThemeMode? themeMode, TargetPlatform? platform}) {
    bool isLight = themeMode == ThemeMode.light;
    return new ThemeData(
      platform: platform,
      splashFactory: InkRipple.splashFactory,
      splashColor: isLight ? Colors.black12 : Colors.white12,
      highlightColor: Colors.transparent,
      brightness: isLight ? Brightness.light : Brightness.dark,
      primaryColorLight: accentColor,
      primaryColor: accentColor,
      primaryColorDark: accentColor,
      scaffoldBackgroundColor: isLight ? Colors.grey[100] : Color(0xFF121212),
      accentColor: accentColor,
      toggleableActiveColor: accentColor,
      cardColor: isLight ? Colors.white : Color(0xFF1F1F1F),
      backgroundColor: accentColor.withOpacity(0.24),
      dividerColor: isLight ? Colors.black12 : Colors.white24,
      disabledColor: isLight ? Colors.black38 : Colors.white38,
      tabBarTheme: TabBarTheme(
        labelColor: accentColor,
        unselectedLabelColor: isLight ? Colors.black54 : Colors.white.withOpacity(0.67),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 2.0,
        color: isLight ? Colors.white : Color(0xFF242424),
      ),
      appBarTheme: AppBarTheme(
        color: isLight ? Colors.white : Color(0xFF292929),
        brightness: isLight ? Brightness.light : Brightness.dark,
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
        color: isLight ? Colors.black54 : Colors.white.withOpacity(0.87),
        size: 24,
      ),
      bottomNavigationBarTheme: new BottomNavigationBarThemeData(
        backgroundColor: isLight ? accentColor : Color(0xFF292929),
        selectedItemColor: Colors.white.withOpacity(0.87),
        unselectedItemColor: Colors.white54,
      ),
      primaryTextTheme: new TextTheme(
        headline1: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 18,
        ),
        headline2: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 16,
        ),
        headline3: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black54 : Colors.white.withOpacity(0.54),
          fontSize: 16,
        ),
        headline4: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 14,
        ),
        headline5: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black54 : Colors.white.withOpacity(0.54),
          fontSize: 14,
        ),
        headline6: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 18,
        ),
      ),
      textTheme: new TextTheme(
        headline1: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 18,
        ),
        headline2: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 16,
        ),
        headline3: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black54 : Colors.white.withOpacity(0.54),
          fontSize: 16,
        ),
        headline4: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 14,
        ),
        headline5: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black54 : Colors.white.withOpacity(0.54),
          fontSize: 14,
        ),
        headline6: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLight ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 18,
        ),
      ),
    );
  }
}
