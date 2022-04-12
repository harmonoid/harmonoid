/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;

import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/file_system.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:ytm_client/ytm_client.dart';

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
    if (!await instance.file.exists_()) {
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
    ytm_request_authority = instance.proxyURL == "" ? null : instance.proxyURL;
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
    List<String>? webSearchRecent,
    List<String>? webRecent,
    bool? showTrackProgressOnTaskbar,
    bool? automaticallyAddOtherSongsFromCollectionToNowPlaying,
    bool? automaticallyShowNowPlayingScreenAfterPlaying,
    bool? automaticallyRefreshCollectionOnFreshStart,
    bool? changeNowPlayingBarColorBasedOnPlayingMusic,
    String? proxyURL,
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
    if (webSearchRecent != null) {
      this.webSearchRecent = webSearchRecent;
    }
    if (webRecent != null) {
      this.webRecent = webRecent;
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
    if (automaticallyRefreshCollectionOnFreshStart != null) {
      this.automaticallyRefreshCollectionOnFreshStart =
          automaticallyRefreshCollectionOnFreshStart;
    }
    if (changeNowPlayingBarColorBasedOnPlayingMusic != null) {
      this.changeNowPlayingBarColorBasedOnPlayingMusic =
          changeNowPlayingBarColorBasedOnPlayingMusic;
    }
    if (proxyURL != null) {
      this.proxyURL = proxyURL;
    }
    await file.writeAsString(
      const convert.JsonEncoder.withIndent('  ').convert(
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
          'webSearchRecent': this.webSearchRecent,
          'webRecent': this.webRecent,
          'showTrackProgressOnTaskbar': this.showTrackProgressOnTaskbar,
          'automaticallyAddOtherSongsFromCollectionToNowPlaying':
              this.automaticallyAddOtherSongsFromCollectionToNowPlaying,
          'automaticallyShowNowPlayingScreenAfterPlaying':
              this.automaticallyShowNowPlayingScreenAfterPlaying,
          'automaticallyRefreshCollectionOnFreshStart':
              this.automaticallyRefreshCollectionOnFreshStart,
          'changeNowPlayingBarColorBasedOnPlayingMusic':
              this.changeNowPlayingBarColorBasedOnPlayingMusic,
          'proxyURL': this.proxyURL,
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
      webSearchRecent = current['webSearchRecent'].cast<String>();
      webRecent = current['webRecent'].cast<String>();
      showTrackProgressOnTaskbar = current['showTrackProgressOnTaskbar'];
      automaticallyAddOtherSongsFromCollectionToNowPlaying =
          current['automaticallyAddOtherSongsFromCollectionToNowPlaying'];
      automaticallyShowNowPlayingScreenAfterPlaying =
          current['automaticallyShowNowPlayingScreenAfterPlaying'];
      automaticallyRefreshCollectionOnFreshStart =
          current['automaticallyRefreshCollectionOnFreshStart'];
      changeNowPlayingBarColorBasedOnPlayingMusic =
          current['changeNowPlayingBarColorBasedOnPlayingMusic'];
      proxyURL = current["proxyURL"];
    } catch (exception) {
      if (!retry) throw exception;
      if (!await file.exists_()) {
        await file.create(recursive: true);
      }
      await file.writeAsString(
        const convert.JsonEncoder.withIndent('  ')
            .convert(defaultConfiguration),
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
  late List<String> webSearchRecent;
  late List<String> webRecent;
  late bool showTrackProgressOnTaskbar;
  late bool automaticallyAddOtherSongsFromCollectionToNowPlaying;
  late bool automaticallyShowNowPlayingScreenAfterPlaying;
  late bool automaticallyRefreshCollectionOnFreshStart;
  late bool changeNowPlayingBarColorBasedOnPlayingMusic;
  late String proxyURL;
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
  'webSearchRecent': [],
  'webRecent': [],
  'showTrackProgressOnTaskbar': false,
  'automaticallyAddOtherSongsFromCollectionToNowPlaying': false,
  'automaticallyShowNowPlayingScreenAfterPlaying': true,
  'automaticallyRefreshCollectionOnFreshStart': false,
  'changeNowPlayingBarColorBasedOnPlayingMusic': true,
  'proxyURL': '',
};
