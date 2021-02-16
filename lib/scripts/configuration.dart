import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:harmonoid/language/language.dart';
import 'package:path/path.dart' as path;


Configuration configuration;


const Map<String, dynamic> DEFAULT_CONFIGURATION = {
  'version': '0.0.3+1',
  'homeAddress': 'harmonoid2.herokuapp.com',
  'languageRegion': 0,
  'themeMode': 0,
  'accentColor': 0,
  'showOutOfBoxExperience': true,
  'collectionSearchRecent': [],
  'discoverSearchRecent': [],
  'discoverRecent': []
};


const JsonEncoder JSON_ENCODER = JsonEncoder.withIndent('    ');

/* TODO: Implement accentColor */
class Configuration {
  String version;
  String homeAddress;
  LanguageRegion languageRegion;
  ThemeMode themeMode;
  Color accentColor;
  bool showOutOfBoxExperience;
  List<dynamic> collectionSearchRecent;
  List<dynamic> discoverSearchRecent;
  List<dynamic> discoverRecent;

  File configurationFile;

  static Future<void> init({Directory cacheDirectory}) async {
    configuration = new Configuration();
    configuration.configurationFile = File(path.join(cacheDirectory.path, 'configuration.json'));
    if (!await configuration.configurationFile.exists()) {
      await configuration.configurationFile.writeAsString(JSON_ENCODER.convert(DEFAULT_CONFIGURATION));
    }
    await configuration._refresh();
  }

  Future<void> save({
    String version,
    String homeAddress,
    LanguageRegion languageRegion,
    ThemeMode themeMode,
    Color accentColor,
    bool showOutOfBoxExperience,
    List<dynamic> collectionSearchRecent,
    List<dynamic> discoverSearchRecent,
    List<dynamic> discoverRecent,
    }) async {
    if (version != null) {
      this.version = version;
    }
    if (homeAddress != null) {
      this.homeAddress = homeAddress;
    }
    if (languageRegion != null) {
      this.languageRegion = languageRegion;
    }
    if (themeMode != null) {
      this.themeMode = themeMode;
    }
    if (accentColor != null) {
      this.accentColor = accentColor;
    }
    if (showOutOfBoxExperience != null) {
      this.showOutOfBoxExperience = showOutOfBoxExperience;
    }
    if (collectionSearchRecent != null) {
      this.collectionSearchRecent = collectionSearchRecent;
    }
    if (discoverSearchRecent != null) {
      this.discoverSearchRecent = discoverSearchRecent;
    }
    if (collectionSearchRecent != null) {
      this.discoverRecent = discoverRecent;
    }
    await configuration.configurationFile.writeAsString(JSON_ENCODER.convert({
      'version': this.version,
      'homeAddress': this.homeAddress,
      'languageRegion': this.languageRegion.index,
      'themeMode': this.themeMode.index,
      'accentColor': this.accentColor,
      'showOutOfBoxExperience': this.showOutOfBoxExperience,
      'collectionSearchRecent': this.collectionSearchRecent,
      'discoverSearchRecent': this.discoverSearchRecent,
      'discoverRecent': this.discoverRecent,
    }));
  }

  Future<dynamic> _refresh() async {
    Map<String, dynamic> configurationMap = jsonDecode(await this.configurationFile.readAsString());
    this.version = configurationMap['version'];
    this.homeAddress = configurationMap['homeAddress'];
    this.languageRegion = LanguageRegion.values[configurationMap['languageRegion']];
    this.themeMode = ThemeMode.values[configurationMap['themeMode']];
    this.showOutOfBoxExperience = configurationMap['showOutOfBoxExperience'];
    this.collectionSearchRecent = configurationMap['collectionSearchRecent'];
    this.discoverSearchRecent = configurationMap['discoverSearchRecent'];
    this.discoverRecent = configurationMap['discoverRecent'];
  }
}
