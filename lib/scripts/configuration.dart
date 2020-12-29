import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;

import 'package:harmonoid/constants/constants.dart';


enum AppTheme {
  system,
  light,
  dark,
}


extension AppThemeExtension on AppTheme {
  String get data {
    String data;
    switch(this) {
      case AppTheme.system: data = Constants.STRING_APP_THEME_SYSTEM ; break;
      case AppTheme.light:  data = Constants.STRING_APP_THEME_LIGHT  ; break;
      case AppTheme.dark:   data = Constants.STRING_APP_THEME_DARK   ; break;
    }
    return data;
  }
}


enum LanguageRegion {
  enUs,
  ruRu, /* Credits: https://github.com/raitonoberu/             */
  slSi, /* Credits: https://github.com/mytja/                   */
  ptBr, /* Credits: https://github.com/bdlukaa/                 */
  hiIn, /* Credits: https://github.com/alexmercerind/           */
  deDe, /* Credits: https://github.com/MickLesk/                */
}


extension LanguageRegionExtension on LanguageRegion {
  List<String> get data {
    List<String> data;
    switch(this) {
      case LanguageRegion.enUs: data = ['English'        , 'United States'    ]; break;
      case LanguageRegion.ruRu: data = ['Русский'        , 'Россия'           ]; break;
      case LanguageRegion.slSi: data = ['Slovenija'      , 'Slovenščina'      ]; break;
      case LanguageRegion.ptBr: data = ['Português'      , 'Brasil'           ]; break;
      case LanguageRegion.hiIn: data = ['हिंदी'            , 'भारत'              ]; break;
      case LanguageRegion.deDe: data = ['Deutsche'       , 'Deutschland'      ]; break;
    }
    return data;
  }
}


Configuration configuration;


enum ConfigurationType {
  version,
  languageRegion,
  appTheme,
  accentColor,
  homeUri,
  collectionStartTab,
  collectionDirectoryType,
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

  Future<dynamic> getConfiguration(ConfigurationType configurationType, {bool refresh = true}) async {
    if (refresh || this.configurationMap == null) {
      this.configurationMap = jsonDecode(await this.configurationFile.readAsString());
    }
    if (!this.configurationMap.containsKey(configurationType.toString().split('.').last)) {
      await this.setConfiguration(configurationType, jsonDecode(await rootBundle.loadString('assets/initialAppConfiguration.json'))[configuration.toString().split('.').last]);
    }
    return this.configurationMap[configurationType.toString().split('.').last];
  }

  Future<void> setConfiguration(ConfigurationType configurationType, dynamic value, {bool save = true}) async {
    this.configurationMap[configurationType.toString().split('.').last] = value;
    if (save) {
      await this.configurationFile.writeAsString(JsonEncoder.withIndent('    ').convert(this.configurationMap));
    }
  }
}
