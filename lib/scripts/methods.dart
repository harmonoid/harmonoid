
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:harmonoid/language/constants.dart';
import 'package:harmonoid/scripts/collection.dart';


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

  static bool isFileSupported(FileSystemEntity file) {
    if (file is File && SUPPORTED_FILE_TYPES.contains(file.path.split('.').last.toUpperCase())) {
      return true;
    }
    else {
      return false;
    }
  }

  static String mediaTypeToLanguage(MediaType mediaType) {
    if (mediaType is Album)
      return Constants.STRING_ALBUM;
    else if (mediaType is Track)
      return Constants.STRING_TRACK;
    else if (mediaType is Artist)
      return Constants.STRING_ARTIST;
    else if (mediaType is Playlist)
      return Constants.STRING_PLAYLIST;
    else
      return null;
  }

  static Future<void> askStoragePermission() async {
    if (await Permission.storage.isUndetermined || await Permission.storage.isDenied) {
      PermissionStatus storagePermissionState = await Permission.storage.request();
      if (!storagePermissionState.isGranted) {
        SystemNavigator.pop(
          animated: true,
        );
      }
    }
  }

  static ThemeData getThemeData({Color color, ThemeMode themeMode}) {
    bool isLightTheme = themeMode == ThemeMode.light;
    return new ThemeData(
      platform: configuration.enableiOS ? TargetPlatform.iOS: TargetPlatform.android,
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.transparent,
      brightness: isLightTheme ? Brightness.light : Brightness.dark,
      primaryColorLight: color,
      primaryColor: color,
      primaryColorDark: color,
      scaffoldBackgroundColor: isLightTheme ? Colors.grey[100] : Color(0xFF121212),
      cursorColor: color,
      accentColor: color,
      textSelectionHandleColor: color,
      toggleableActiveColor: color,
      cardColor: isLightTheme ? Colors.white : Color(0xFF1C1C1C),
      backgroundColor: color.withOpacity(0.24),
      dividerColor: isLightTheme ? Colors.black12 : Colors.white24,
      disabledColor: isLightTheme ? Colors.black38 : Colors.white38,
      tabBarTheme: TabBarTheme(
        labelColor: color,
        unselectedLabelColor: isLightTheme ? Colors.black54 : Colors.white.withOpacity(0.67),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 2.0,
        color: isLightTheme ? Colors.white : Color(0xFF242424),
      ),
      appBarTheme: AppBarTheme(
        color: isLightTheme ? Colors.white : Color(0xFF1C1C1C),
        brightness: isLightTheme ? Brightness.light : Brightness.dark,
        elevation: 4.0,
        iconTheme: IconThemeData(
          color: isLightTheme ? Colors.black54 : Colors.white.withOpacity(0.87),
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: isLightTheme ? Colors.black54 : Colors.white.withOpacity(0.87),
          size: 24,
        ),
      ),
      iconTheme: IconThemeData(
        color: isLightTheme ? Colors.black54 : Colors.white.withOpacity(0.87),
        size: 24,
      ),
      bottomNavigationBarTheme: new BottomNavigationBarThemeData(
        backgroundColor: isLightTheme ? color : Color(0xFF1F1F1F),
        selectedItemColor: Colors.white.withOpacity(0.87),
        unselectedItemColor: Colors.white54,
      ),
      primaryTextTheme: new TextTheme(
        headline1: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 18,
        ),
        headline2: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 16,
        ),
        headline3: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black54 : Colors.white.withOpacity(0.54),
          fontSize: 16,
        ),
        headline4: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 14,
        ),
        headline5: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black54 : Colors.white.withOpacity(0.54),
          fontSize: 14,
        ),
        headline6: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 18,
        ),
      ),
      textTheme: new TextTheme(
        headline1: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 18,
        ),
        headline2: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 16,
        ),
        headline3: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black54 : Colors.white.withOpacity(0.54),
          fontSize: 16,
        ),
        headline4: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 14,
        ),
        headline5: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black54 : Colors.white.withOpacity(0.54),
          fontSize: 14,
        ),
        headline6: TextStyle(
          fontWeight: FontWeight.normal,
          color: isLightTheme ? Colors.black87 : Colors.white.withOpacity(0.87),
          fontSize: 18,
        ),
      ),
    );
  }
}
