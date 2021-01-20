import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;

import 'package:harmonoid/constants/constants.dart';


extension ThemeModeExtension on ThemeMode {
  String get data {
    String data;
    switch(this) {
      case ThemeMode.system: data = Constants.STRING_THEME_MODE_SYSTEM ; break;
      case ThemeMode.light:  data = Constants.STRING_THEME_MODE_LIGHT  ; break;
      case ThemeMode.dark:   data = Constants.STRING_THEME_MODE_DARK   ; break;
    }
    return data;
  }
}


Configuration configuration;


enum Configurations {
  version,
  languageRegion,
  themeMode,
  accentColor,
  homeAddress,
  collectionStartTab,
  collectionDirectoryType,
  collectionSearchRecents,
  discoverSearchRecents,
  discoverRecentID,
}


class Configuration {
  File configurationFile;
  Map<dynamic, dynamic> configurationMap;

  Configuration(Directory cacheDirectory) {
    if (!cacheDirectory.existsSync()) cacheDirectory.createSync(recursive: true);
    this.configurationFile = File(path.join(cacheDirectory.path, 'appConfiguration.json'));
  }

  static Future<void> init({Directory cacheDirectory}) async {
    configuration = new Configuration(cacheDirectory);
    if (!await configuration.configurationFile.exists()) {
      await configuration.configurationFile.writeAsString(await rootBundle.loadString('assets/initialAppConfiguration.json'));
    }
  }

  Future<dynamic> get(Configurations configurationType, {bool refresh = true}) async {
    if (refresh || this.configurationMap == null) {
      this.configurationMap = jsonDecode(await this.configurationFile.readAsString());
    }
    if (!this.configurationMap.containsKey(configurationType.toString().split('.').last)) {
      await this.set(configurationType, jsonDecode(await rootBundle.loadString('assets/initialAppConfiguration.json'))[configuration.toString().split('.').last]);
    }
    return this.configurationMap[configurationType.toString().split('.').last];
  }

  Future<void> set(Configurations configurationType, dynamic value, {bool save = true}) async {
    this.configurationMap[configurationType.toString().split('.').last] = value;
    if (save) {
      await this.configurationFile.writeAsString(JsonEncoder.withIndent('    ').convert(this.configurationMap));
    }
  }
}
