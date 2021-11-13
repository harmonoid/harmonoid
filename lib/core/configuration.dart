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
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/constants/language.dart';

/// Configuration
/// -------------
///
/// App configuration & settings persistence management.
///
class Configuration extends ConfigurationKeys {
  /// Configuration storage [File] to hold serialized JSON document.
  late File file;

  /// Returns equivalent directory on various platforms to save configuration file.
  /// Not working on iOS or macOS yet.
  ///
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

  /// Initializes the [Configuration] class.
  ///
  /// Called before the [runApp] & fills the configuration keys.
  /// Generates from scratch if no configuration is found.
  ///
  static Future<void> initialize() async {
    configuration = Configuration();
    configuration.file = File(
      path.join(
        await configuration.configurationDirectory,
        '.Harmonoid',
        'Configuration.JSON',
      ),
    );
    if (!await configuration.file.exists()) {
      await configuration.file.create(recursive: true);
      await configuration.file.writeAsString(
        convert.JsonEncoder.withIndent('  ').convert(default_configuration),
      );
    }
    await configuration.read();
    configuration.cacheDirectory = Directory(
      path.join(
        await configuration.configurationDirectory,
        '.Harmonoid',
      ),
    );
  }

  /// Updates a particular key in the Harmonoid's configuration.
  ///
  Future<void> save({
    List<Directory>? collectionDirectories,
    LanguageRegion? languageRegion,
    Accent? accent,
    ThemeMode? themeMode,
    CollectionSort? collectionSortType,
    bool? automaticAccent,
    bool? notificationLyrics,
    bool? acrylicEnabled,
    List<String>? collectionSearchRecent,
    List<String>? discoverSearchRecent,
    List<String>? discoverRecent,
    bool? enable125Scaling,
  }) async {
    if (collectionDirectories != null) {
      this.collectionDirectories = collectionDirectories;
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
    if (discoverRecent != null) {
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
    if (enable125Scaling != null) {
      this.enable125Scaling = enable125Scaling;
    }
    await configuration.file.writeAsString(
      convert.JsonEncoder.withIndent('  ').convert(
        {
          'collectionDirectories': this
              .collectionDirectories!
              .map((directory) => directory.path)
              .toList()
              .cast<String>(),
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
          'enable125Scaling': this.enable125Scaling,
        },
      ),
    );
  }

  /// Reads various configuration keys & stores in memory.
  ///
  Future<dynamic> read() async {
    Map<String, dynamic> current =
        convert.jsonDecode(await this.file.readAsString());
    // Emblace default values for the keys that not found. Possibly due to app update.
    default_configuration.keys.forEach(
      (String key) {
        if (!current.containsKey(key)) {
          current[key] = default_configuration[key];
        }
      },
    );
    // Check for actual keys from the cache.
    this.collectionDirectories = current['collectionDirectories']
        .map((directory) => Directory(directory))
        .toList()
        .cast<Directory>();
    this.languageRegion = LanguageRegion.values[current['languageRegion']];
    this.accent = accents[current['accent']];
    this.themeMode = ThemeMode.values[current['themeMode']];
    this.collectionSortType =
        CollectionSort.values[current['collectionSortType']];
    this.automaticAccent = current['automaticAccent'];
    this.notificationLyrics = current['notificationLyrics'];
    this.acrylicEnabled = current['acrylicEnabled'];
    this.collectionSearchRecent =
        current['collectionSearchRecent'].cast<String>();
    this.discoverSearchRecent = current['discoverSearchRecent'].cast<String>();
    this.discoverRecent = current['discoverRecent'].cast<String>();
    this.enable125Scaling = current['enable125Scaling'] ??
        default_configuration['enable125Scaling'];
  }
}

abstract class ConfigurationKeys {
  List<Directory>? collectionDirectories;
  Directory? cacheDirectory;
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
  bool? enable125Scaling;
}

// ignore: non_constant_identifier_names
Map<String, dynamic> default_configuration = {
  'collectionDirectories': <String>[
    {
      'windows': () => path.join(Platform.environment['USERPROFILE']!, 'Music'),
      'linux': () =>
          Process.runSync('xdg-user-dir', ['MUSIC']).stdout.toString(),
      'android': () => '/storage/emulated/0/Music',
    }[Platform.operatingSystem]!(),
  ],
  'languageRegion': 0,
  'accent': 0,
  'themeMode': 1,
  'collectionSortType': 0,
  'automaticAccent': false,
  'notificationLyrics': true,
  'acrylicEnabled': Platform.isWindows,
  'collectionSearchRecent': [],
  'discoverSearchRecent': [],
  'discoverRecent': ['XfEMj-z3TtA'],
  'enable125Scaling': false,
};

/// Late initialized configuration object instance.
late Configuration configuration;
