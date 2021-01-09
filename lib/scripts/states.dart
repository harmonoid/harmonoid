import 'package:flutter/material.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/constants/constantsupdater.dart';


class States {
  static dynamic musicCollectionCurrentTab = new Album();
  static ThemeMode themeMode = ThemeMode.system;
  static void Function(dynamic musicCollectionCurrentTab) refreshMusicCollection = (dynamic musicCollectionCurrentTab) {};
  static void Function() refreshMusicSearch = () {};
  static void Function(ThemeMode themeMode) refreshThemeMode = (themeMode) {
    States.themeMode = themeMode;
  };
  static void Function(LanguageRegion languageRegion) refreshLanguage = (LanguageRegion languageRegion) {
    ConstantsUpdater.update(languageRegion.index);
  };
}
