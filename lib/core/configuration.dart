/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///

import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;

import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';

/// Configuration
/// -------------
///
/// App configuration & settings persistence management for [Harmonoid](https://github.com/harmonoid/harmonoid).
///
class Configuration extends ConfigurationKeys {
  /// [Configuration] object instance.
  static late Configuration instance = Configuration();

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
    instance.file = File(
      path.join(
        await instance.configurationDirectory,
        '.Harmonoid',
        'Configuration.JSON',
      ),
    );
    if (!await instance.file.exists()) {
      await instance.file.create(recursive: true);
      await instance.file.writeAsString(
        convert.JsonEncoder.withIndent('  ').convert(defaultConfiguration),
      );
    }
    await instance.read();
    instance.cacheDirectory = Directory(
      path.join(
        await instance.configurationDirectory,
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
    CollectionOrder? collectionOrderType,
    CollectionSort? collectionSortType,
    bool? automaticAccent,
    bool? notificationLyrics,
    List<String>? collectionSearchRecent,
    List<String>? discoverSearchRecent,
    List<String>? discoverRecent,
    bool? showTrackProgressOnTaskbar,
    bool? automaticallyAddOtherSongsFromCollectionToNowPlaying,
    bool? automaticallyShowNowPlayingScreenAfterPlaying,
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
    if (collectionOrderType != null) {
      this.collectionOrderType = collectionOrderType;
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
    if (showTrackProgressOnTaskbar != null) {
      this.showTrackProgressOnTaskbar = showTrackProgressOnTaskbar;
    }
    if (automaticallyAddOtherSongsFromCollectionToNowPlaying != null) {
      this.automaticallyAddOtherSongsFromCollectionToNowPlaying =
          automaticallyAddOtherSongsFromCollectionToNowPlaying;
    }
    if (automaticallyShowNowPlayingScreenAfterPlaying != null) {
      this.automaticallyShowNowPlayingScreenAfterPlaying =
          automaticallyShowNowPlayingScreenAfterPlaying;
    }
    await file.writeAsString(
      convert.JsonEncoder.withIndent('  ').convert(
        {
          'collectionDirectories': this
              .collectionDirectories
              .map((directory) => directory.path)
              .toList()
              .cast<String>(),
          'languageRegion': this.languageRegion.index,
          'accent': kAccents.indexOf(this.accent),
          'themeMode': this.themeMode.index,
          'collectionSortType': this.collectionSortType.index,
          'collectionOrderType': this.collectionOrderType.index,
          'automaticAccent': this.automaticAccent,
          'notificationLyrics': this.notificationLyrics,
          'collectionSearchRecent': this.collectionSearchRecent,
          'discoverSearchRecent': this.discoverSearchRecent,
          'discoverRecent': this.discoverRecent,
          'showTrackProgressOnTaskbar': this.showTrackProgressOnTaskbar,
          'automaticallyAddOtherSongsFromCollectionToNowPlaying':
              this.automaticallyAddOtherSongsFromCollectionToNowPlaying,
          'automaticallyShowNowPlayingScreenAfterPlaying':
              this.automaticallyShowNowPlayingScreenAfterPlaying,
        },
      ),
    );
  }

  /// Reads various configuration keys & stores in memory.
  ///
  Future<void> read({
    bool retry = true,
  }) async {
    try {
      Map<String, dynamic> current =
          convert.jsonDecode(await file.readAsString());
      // Emblace default values for the keys that not found. Possibly due to app update.
      defaultConfiguration.keys.forEach(
        (String key) {
          if (!current.containsKey(key)) {
            current[key] = defaultConfiguration[key];
          }
        },
      );
      // Check for actual keys from the cache.
      collectionDirectories = current['collectionDirectories']
          .map((directory) => Directory(directory))
          .toList()
          .cast<Directory>();
      languageRegion = LanguageRegion.values[current['languageRegion']];
      accent = kAccents[current['accent']];
      themeMode = ThemeMode.values[current['themeMode']];
      collectionSortType = CollectionSort.values[current['collectionSortType']];
      collectionOrderType =
          CollectionOrder.values[current['collectionOrderType']];
      automaticAccent = current['automaticAccent'];
      notificationLyrics = current['notificationLyrics'];
      collectionSearchRecent = current['collectionSearchRecent'].cast<String>();
      discoverSearchRecent = current['discoverSearchRecent'].cast<String>();
      discoverRecent = current['discoverRecent'].cast<String>();
      showTrackProgressOnTaskbar = current['showTrackProgressOnTaskbar'];
      automaticallyAddOtherSongsFromCollectionToNowPlaying =
          current['automaticallyAddOtherSongsFromCollectionToNowPlaying'];
      automaticallyShowNowPlayingScreenAfterPlaying =
          current['automaticallyShowNowPlayingScreenAfterPlaying'];
    } catch (exception) {
      if (!retry) throw exception;
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      await file.writeAsString(
        convert.JsonEncoder.withIndent('  ').convert(defaultConfiguration),
      );
      read(retry: false);
    }
  }
}

abstract class ConfigurationKeys {
  late List<Directory> collectionDirectories;
  late Directory cacheDirectory;
  late LanguageRegion languageRegion;
  late Accent accent;
  late ThemeMode themeMode;
  late CollectionSort collectionSortType;
  late CollectionOrder collectionOrderType;
  late bool automaticAccent;
  late bool notificationLyrics;
  late List<String> collectionSearchRecent;
  late List<String> discoverSearchRecent;
  late List<String> discoverRecent;
  late bool showTrackProgressOnTaskbar;
  late bool automaticallyAddOtherSongsFromCollectionToNowPlaying;
  late bool automaticallyShowNowPlayingScreenAfterPlaying;
}

final Map<String, dynamic> defaultConfiguration = {
  'collectionDirectories': <String>[
    {
      'windows': () => path.join(Platform.environment['USERPROFILE']!, 'Music'),
      'linux': () =>
          Process.runSync('xdg-user-dir', ['MUSIC']).stdout.toString().trim(),
      'android': () => '/storage/emulated/0/Music',
    }[Platform.operatingSystem]!(),
  ],
  'languageRegion': 0,
  'accent': 0,
  'themeMode': isMobile ? 0 : 1,
  'collectionSortType': isMobile ? 1 : 3,
  'collectionOrderType': isMobile ? 1 : 0,
  'automaticAccent': false,
  'notificationLyrics': true,
  'collectionSearchRecent': [],
  'discoverSearchRecent': [],
  'discoverRecent': [],
  'showTrackProgressOnTaskbar': false,
  'automaticallyAddOtherSongsFromCollectionToNowPlaying': false,
  'automaticallyShowNowPlayingScreenAfterPlaying': true,
};
