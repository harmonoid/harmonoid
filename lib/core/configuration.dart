import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/constants/language.dart';

// TODO: Migrate this shitty JSON based storage to better alternative like Hive etc.
late Configuration configuration;

abstract class ConfigurationKeys {
  List<Directory>? collectionDirectories;
  Directory? cacheDirectory;
  String? homeAddress;
  LanguageRegion? languageRegion;
  Accent? accent;
  ThemeMode? themeMode;
  CollectionSort? collectionSortType;
  bool? automaticAccent;
  bool? notificationLyrics;
  bool? acrylicEnabled;
  List<String>? collectionSearchRecent;
  List<String>? discoverSearchRecent;
  List<String>? discoverRecent;
}

Map<String, dynamic> DEFAULT_CONFIGURATION = {
  'collectionDirectories': <String>[
    {
      'windows': () => path.join(Platform.environment['USERPROFILE']!, 'Music'),
      'linux': () => path.join(Platform.environment['HOME']!, 'Music'),
      'android': () => '/storage/emulated/0/Music',
    }[Platform.operatingSystem]!(),
  ],
  // TODO: Remove this.
  'homeAddress': '',
  'languageRegion': 0,
  'accent': 0,
  'themeMode': 2,
  'collectionSortType': 0,
  'automaticAccent': false,
  'notificationLyrics': true,
  // TODO: Remove this.
  // TODO: Remove this.
  'acrylicEnabled': true,
  'collectionSearchRecent': [],
  'discoverSearchRecent': [],
  'discoverRecent': [],
};

class Configuration extends ConfigurationKeys {
  late File configurationFile;

  Future<String> get configurationDirectory async {
    switch (Platform.operatingSystem) {
      case 'windows':
        return Platform.environment['USERPROFILE']!;
      case 'linux':
        return Platform.environment['HOME']!;
      case 'android':
        return (await path.getExternalStorageDirectory())!.path;
      default:
        return '';
    }
  }

  static Future<void> init() async {
    configuration = Configuration();
    configuration.configurationFile = File(
      path.join(
        await configuration.configurationDirectory,
        'configuration.JSON',
      ),
    );
    if (!await configuration.configurationFile.exists()) {
      await configuration.configurationFile.create(recursive: true);
      await configuration.configurationFile
          .writeAsString(convert.jsonEncode(DEFAULT_CONFIGURATION));
    }
    await configuration.read();
    configuration.cacheDirectory = Directory(
      path.join(
        await configuration.configurationDirectory,
        '.harmonoid',
      ),
    );
  }

  Future<void> save({
    List<Directory>? collectionDirectories,
    String? homeAddress,
    LanguageRegion? languageRegion,
    Accent? accent,
    ThemeMode? themeMode,
    bool? showOutOfBoxExperience,
    CollectionSort? collectionSortType,
    bool? automaticAccent,
    bool? notificationLyrics,
    bool? acrylicEnabled,
    List<String>? collectionSearchRecent,
    List<String>? discoverSearchRecent,
    List<String>? discoverRecent,
  }) async {
    if (collectionDirectories != null) {
      this.collectionDirectories = collectionDirectories;
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
    if (accent != null) {
      this.accent = accent;
    }
    if (collectionSortType != null) {
      this.collectionSortType = collectionSortType;
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
    if (automaticAccent != null) {
      this.automaticAccent = automaticAccent;
    }
    if (notificationLyrics != null) {
      this.notificationLyrics = notificationLyrics;
    }
    if (acrylicEnabled != null) {
      this.acrylicEnabled = acrylicEnabled;
    }
    await configuration.configurationFile.writeAsString(convert.jsonEncode({
      'collectionDirectories': this
          .collectionDirectories!
          .map((directory) => directory.path)
          .toList()
          .cast<String>(),
      'homeAddress': this.homeAddress,
      'languageRegion': this.languageRegion!.index,
      'accent': accents.indexOf(this.accent),
      'themeMode': this.themeMode!.index,
      'collectionSortType': this.collectionSortType!.index,
      'automaticAccent': this.automaticAccent,
      'notificationLyrics': this.notificationLyrics,
      'acrylicEnabled': this.acrylicEnabled,
      'collectionSearchRecent': this.collectionSearchRecent,
      'discoverSearchRecent': this.discoverSearchRecent,
      'discoverRecent': this.discoverRecent,
    }));
  }

  Future<dynamic> read() async {
    Map<String, dynamic> currentConfiguration =
        convert.jsonDecode(await this.configurationFile.readAsString());
    DEFAULT_CONFIGURATION.keys.forEach((String key) {
      if (!currentConfiguration.containsKey(key)) {
        currentConfiguration[key] = DEFAULT_CONFIGURATION[key];
      }
    });
    this.collectionDirectories = currentConfiguration['collectionDirectories']
        .map((directory) => Directory(directory))
        .toList()
        .cast<Directory>();
    this.homeAddress = currentConfiguration['homeAddress'];
    this.languageRegion =
        LanguageRegion.values[currentConfiguration['languageRegion']];
    this.accent = accents[currentConfiguration['accent']];
    this.themeMode = ThemeMode.values[currentConfiguration['themeMode']];
    this.collectionSortType =
        CollectionSort.values[currentConfiguration['collectionSortType']];
    this.automaticAccent = currentConfiguration['automaticAccent'];
    this.notificationLyrics = currentConfiguration['notificationLyrics'];
    this.acrylicEnabled = currentConfiguration['acrylicEnabled'];
    this.collectionSearchRecent =
        currentConfiguration['collectionSearchRecent'].cast<String>();
    this.discoverSearchRecent =
        currentConfiguration['discoverSearchRecent'].cast<String>();
    this.discoverRecent = currentConfiguration['discoverRecent'].cast<String>();
  }
}
