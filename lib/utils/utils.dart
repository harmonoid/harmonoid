import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/constants/language.dart';

abstract class Utils {
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
    if (Platform.isAndroid) if (await Permission.storage.isDenied) {
      PermissionStatus storagePermissionState =
          await Permission.storage.request();
      if (!storagePermissionState.isGranted) {
        SystemNavigator.pop(
          animated: true,
        );
      }
    }
  }

  static ThemeData getTheme(
      {required Color accentColor,
      ThemeMode? themeMode,
      TargetPlatform? platform}) {
    bool isLight = themeMode == ThemeMode.light;
    return ThemeData(
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accentColor,
      ),
      platform: platform,
      splashFactory: InkRipple.splashFactory,
      splashColor: Colors.transparent,
      brightness: isLight ? Brightness.light : Brightness.dark,
      primaryColorLight: accentColor,
      primaryColor: accentColor,
      primaryColorDark: accentColor,
      scaffoldBackgroundColor: configuration.acrylicEnabled!
          ? Colors.transparent
          : (isLight ? Colors.white : Color(0xFF121212)),
      accentColor: accentColor,
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
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isLight ? accentColor : Color(0xFF292929),
        selectedItemColor: Colors.white.withOpacity(0.87),
        unselectedItemColor: Colors.white54,
      ),
    );
  }
}
