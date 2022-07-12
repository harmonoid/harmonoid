/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;

import 'package:harmonoid/utils/safe_session_storage.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/constants/language.dart';

/// Configuration
/// -------------
///
/// App configuration & settings persistence management for [Harmonoid](https://github.com/harmonoid/harmonoid).
///
class Configuration extends ConfigurationKeys {
  /// [Configuration] object instance.
  static late Configuration instance = Configuration();

  /// [SafeSessionStorage] instance for cache read/write.
  late SafeSessionStorage storage;

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
    instance.storage = SafeSessionStorage(
      path.join(
        await instance.configurationDirectory,
        '.Harmonoid',
        'Configuration.JSON',
      ),
      fallback: _defaultConfiguration,
    );
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
    List<String>? webSearchRecent,
    List<String>? webRecent,
    bool? taskbarIndicator,
    bool? seamlessPlayback,
    bool? jumpToNowPlayingScreenOnPlay,
    bool? automaticMusicLookup,
    bool? dynamicNowPlayingBarColoring,
    String? proxyURL,
    bool? backgroundArtwork,
    bool? modernNowPlayingScreen,
    int? modernNowPlayingScreenCarouselIndex,
    bool? lyricsVisible,
    bool? discordRPC,
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
    if (taskbarIndicator != null) {
      this.taskbarIndicator = taskbarIndicator;
    }
    if (seamlessPlayback != null) {
      this.seamlessPlayback = seamlessPlayback;
    }
    if (jumpToNowPlayingScreenOnPlay != null) {
      this.jumpToNowPlayingScreenOnPlay = jumpToNowPlayingScreenOnPlay;
    }
    if (automaticMusicLookup != null) {
      this.automaticMusicLookup = automaticMusicLookup;
    }
    if (dynamicNowPlayingBarColoring != null) {
      this.dynamicNowPlayingBarColoring = dynamicNowPlayingBarColoring;
    }
    if (proxyURL != null) {
      this.proxyURL = proxyURL;
    }
    if (backgroundArtwork != null) {
      this.backgroundArtwork = backgroundArtwork;
    }
    if (modernNowPlayingScreen != null) {
      this.modernNowPlayingScreen = modernNowPlayingScreen;
    }
    if (modernNowPlayingScreenCarouselIndex != null) {
      this.modernNowPlayingScreenCarouselIndex =
          modernNowPlayingScreenCarouselIndex;
    }
    if (lyricsVisible != null) {
      this.lyricsVisible = lyricsVisible;
    }
    if (discordRPC != null) {
      this.discordRPC = discordRPC;
    }
    await storage.write(
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
        'taskbarIndicator': this.taskbarIndicator,
        'seamlessPlayback': this.seamlessPlayback,
        'jumpToNowPlayingScreenOnPlay': this.jumpToNowPlayingScreenOnPlay,
        'automaticMusicLookup': this.automaticMusicLookup,
        'dynamicNowPlayingBarColoring': this.dynamicNowPlayingBarColoring,
        'proxyURL': this.proxyURL,
        'backgroundArtwork': this.backgroundArtwork,
        'modernNowPlayingScreen': this.modernNowPlayingScreen,
        'modernNowPlayingScreenCarouselIndex':
            this.modernNowPlayingScreenCarouselIndex,
        'lyricsVisible': this.lyricsVisible,
        'discordRPC': this.discordRPC,
      },
    );
  }

  /// Reads various configuration keys & stores in memory.
  ///
  Future<void> read({
    bool retry = true,
  }) async {
    final current = await storage.read();
    // Emblace default values for the keys that not found. Possibly due to app update.
    _defaultConfiguration.keys.forEach(
      (key) {
        if (!current.containsKey(key)) {
          current[key] = _defaultConfiguration[key];
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
    taskbarIndicator = current['taskbarIndicator'];
    seamlessPlayback = current['seamlessPlayback'];
    jumpToNowPlayingScreenOnPlay = current['jumpToNowPlayingScreenOnPlay'];
    automaticMusicLookup = current['automaticMusicLookup'];
    dynamicNowPlayingBarColoring = current['dynamicNowPlayingBarColoring'];
    proxyURL = current['proxyURL'];
    backgroundArtwork = current['backgroundArtwork'];
    modernNowPlayingScreen = current['modernNowPlayingScreen'];
    modernNowPlayingScreenCarouselIndex =
        current['modernNowPlayingScreenCarouselIndex'];
    lyricsVisible = current['lyricsVisible'];
    discordRPC = current['discordRPC'];
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
  late bool taskbarIndicator;
  late bool seamlessPlayback;
  late bool jumpToNowPlayingScreenOnPlay;
  late bool automaticMusicLookup;
  late bool dynamicNowPlayingBarColoring;
  late String? proxyURL;
  late bool backgroundArtwork;
  late bool modernNowPlayingScreen;
  late int modernNowPlayingScreenCarouselIndex;
  late bool lyricsVisible;
  late bool discordRPC;
}

final Map<String, dynamic> _defaultConfiguration = {
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
  'taskbarIndicator': false,
  'seamlessPlayback': false,
  'jumpToNowPlayingScreenOnPlay': isDesktop,
  'automaticMusicLookup': false,
  'dynamicNowPlayingBarColoring': isDesktop,
  'proxyURL': null,
  'backgroundArtwork': true,
  'modernNowPlayingScreen': isDesktop,
  'modernNowPlayingScreenCarouselIndex': 0,
  'lyricsVisible': true,
  'discordRPC': true,
};
