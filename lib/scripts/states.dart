import 'package:flutter/material.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/constants/constantsupdater.dart';


class States {
  static dynamic musicCollectionCurrentTab = new Album();
  static ThemeMode appTheme = ThemeMode.system;
  static void Function(dynamic musicCollectionCurrentTab) refreshMusicCollection = (dynamic musicCollectionCurrentTab) {};
  static void Function() refreshMusicSearch = () {};
  static void Function(AppTheme appTheme) refreshAppTheme = (appTheme) {
    switch(appTheme) {
      case AppTheme.system: {
        States.appTheme = ThemeMode.system;
      }
      break;
      case AppTheme.light: {
        States.appTheme = ThemeMode.light;
      }
      break;
      case AppTheme.dark: {
        States.appTheme = ThemeMode.dark;
      }
      break;
      }
  };
  static void Function(LanguageRegion languageRegion) refreshLanguage = (LanguageRegion languageRegion) {
    ConstantsUpdater.update(languageRegion.index);
  };
}
