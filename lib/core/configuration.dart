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
import 'package:media_library/media_library.dart';
import 'package:safe_session_storage/safe_session_storage.dart';

import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
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
        final cache = await StorageRetriever.instance.cache;
        debugPrint(cache.toString());
        return cache.path;
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
      fallback: await _defaultConfiguration,
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
    Set<Directory>? collectionDirectories,
    LanguageData? language,
    ThemeMode? themeMode,
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
    bool? modernNowPlayingScreen,
    int? modernNowPlayingScreenCarouselIndex,
    bool? lyricsVisible,
    bool? discordRPC,
    double? highlightedLyricsSize,
    double? unhighlightedLyricsSize,
    bool? mobileDenseAlbumTabLayout,
    bool? mobileDenseArtistTabLayout,
    bool? mobileGridArtistTabLayout,
    AlbumsSort? albumsSort,
    TracksSort? tracksSort,
    ArtistsSort? artistsSort,
    GenresSort? genresSort,
    OrderType? albumsOrderType,
    OrderType? tracksOrderType,
    OrderType? artistsOrderType,
    OrderType? genresOrderType,
    int? minimumFileSize,
    int? libraryTab,
    bool? useLRCFromTrackDirectory,
    bool? lookupForFallbackAlbumArt,
    bool? displayAudioFormat,
    bool? mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen,
    bool? mobileEnableNowPlayingScreenRippleEffect,
  }) async {
    if (collectionDirectories != null) {
      this.collectionDirectories = collectionDirectories;
    }
    if (language != null) {
      this.language = language;
    }
    if (themeMode != null) {
      this.themeMode = themeMode;
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
    if (highlightedLyricsSize != null) {
      this.highlightedLyricsSize = highlightedLyricsSize;
    }
    if (unhighlightedLyricsSize != null) {
      this.unhighlightedLyricsSize = unhighlightedLyricsSize;
    }
    if (mobileDenseAlbumTabLayout != null) {
      this.mobileDenseAlbumTabLayout = mobileDenseAlbumTabLayout;
    }
    if (mobileDenseArtistTabLayout != null) {
      this.mobileDenseArtistTabLayout = mobileDenseArtistTabLayout;
    }
    if (mobileGridArtistTabLayout != null) {
      this.mobileGridArtistTabLayout = mobileGridArtistTabLayout;
    }
    if (albumsSort != null) {
      this.albumsSort = albumsSort;
    }
    if (tracksSort != null) {
      this.tracksSort = tracksSort;
    }
    if (artistsSort != null) {
      this.artistsSort = artistsSort;
    }
    if (genresSort != null) {
      this.genresSort = genresSort;
    }
    if (albumsOrderType != null) {
      this.albumsOrderType = albumsOrderType;
    }
    if (tracksOrderType != null) {
      this.tracksOrderType = tracksOrderType;
    }
    if (artistsOrderType != null) {
      this.artistsOrderType = artistsOrderType;
    }
    if (genresOrderType != null) {
      this.genresOrderType = genresOrderType;
    }
    if (minimumFileSize != null) {
      this.minimumFileSize = minimumFileSize;
    }
    if (libraryTab != null) {
      this.libraryTab = libraryTab;
    }
    if (useLRCFromTrackDirectory != null) {
      this.useLRCFromTrackDirectory = useLRCFromTrackDirectory;
    }
    if (lookupForFallbackAlbumArt != null) {
      this.lookupForFallbackAlbumArt = lookupForFallbackAlbumArt;
    }
    if (displayAudioFormat != null) {
      this.displayAudioFormat = displayAudioFormat;
    }
    if (mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen != null) {
      this.mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen =
          mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen;
    }
    if (mobileEnableNowPlayingScreenRippleEffect != null) {
      this.mobileEnableNowPlayingScreenRippleEffect =
          mobileEnableNowPlayingScreenRippleEffect;
    }
    await storage.write(
      {
        'collectionDirectories': this
            .collectionDirectories
            .map((directory) => directory.path)
            .toList()
            .cast<String>(),
        'language': this.language.toJson(),
        'themeMode': this.themeMode.index,
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
        'modernNowPlayingScreen': this.modernNowPlayingScreen,
        'modernNowPlayingScreenCarouselIndex':
            this.modernNowPlayingScreenCarouselIndex,
        'lyricsVisible': this.lyricsVisible,
        'discordRPC': this.discordRPC,
        'highlightedLyricsSize': this.highlightedLyricsSize,
        'unhighlightedLyricsSize': this.unhighlightedLyricsSize,
        'mobileDenseAlbumTabLayout': this.mobileDenseAlbumTabLayout,
        'mobileDenseArtistTabLayout': this.mobileDenseArtistTabLayout,
        'mobileGridArtistTabLayout': this.mobileGridArtistTabLayout,
        'albumsSort': this.albumsSort.index,
        'tracksSort': this.tracksSort.index,
        'artistsSort': this.artistsSort.index,
        'genresSort': this.genresSort.index,
        'albumsOrderType': this.albumsOrderType.index,
        'tracksOrderType': this.tracksOrderType.index,
        'artistsOrderType': this.artistsOrderType.index,
        'genresOrderType': this.genresOrderType.index,
        'minimumFileSize': this.minimumFileSize,
        'libraryTab': this.libraryTab,
        'useLRCFromTrackDirectory': this.useLRCFromTrackDirectory,
        'lookupForFallbackAlbumArt': this.lookupForFallbackAlbumArt,
        'displayAudioFormat': this.displayAudioFormat,
        'mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen':
            this.mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen,
        'mobileEnableNowPlayingScreenRippleEffect':
            this.mobileEnableNowPlayingScreenRippleEffect,
      },
    );
  }

  /// Reads various configuration keys & stores in memory.
  ///
  Future<void> read() async {
    final current = await storage.read();
    final conf = await _defaultConfiguration;
    // Emblace default values for the keys that not found.
    // Most likely due to update in Harmonoid's app version.
    // The Harmonoid's version update likely brought new app keys & fallback to default for those.
    conf.keys.forEach(
      (key) {
        if (!current.containsKey(key)) {
          current[key] = conf[key];
        }
      },
    );
    debugPrint(current.toString());
    // Check for actual keys from the cache.
    collectionDirectories = Set<String>.from(current['collectionDirectories'])
        .map((directory) => Directory(directory))
        .toSet();
    language = LanguageData.fromJson(current['language']);
    themeMode = ThemeMode.values[current['themeMode']];
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
    modernNowPlayingScreen = current['modernNowPlayingScreen'];
    modernNowPlayingScreenCarouselIndex =
        current['modernNowPlayingScreenCarouselIndex'];
    lyricsVisible = current['lyricsVisible'];
    discordRPC = current['discordRPC'];
    highlightedLyricsSize = current['highlightedLyricsSize'];
    unhighlightedLyricsSize = current['unhighlightedLyricsSize'];
    mobileDenseAlbumTabLayout = current['mobileDenseAlbumTabLayout'];
    mobileDenseArtistTabLayout = current['mobileDenseArtistTabLayout'];
    mobileGridArtistTabLayout = current['mobileGridArtistTabLayout'];
    albumsSort = AlbumsSort.values[current['albumsSort']];
    tracksSort = TracksSort.values[current['tracksSort']];
    artistsSort = ArtistsSort.values[current['artistsSort']];
    genresSort = GenresSort.values[current['genresSort']];
    albumsOrderType = OrderType.values[current['albumsOrderType']];
    tracksOrderType = OrderType.values[current['tracksOrderType']];
    artistsOrderType = OrderType.values[current['artistsOrderType']];
    genresOrderType = OrderType.values[current['genresOrderType']];
    minimumFileSize = current['minimumFileSize'];
    libraryTab = current['libraryTab'];
    useLRCFromTrackDirectory = current['useLRCFromTrackDirectory'];
    lookupForFallbackAlbumArt = current['lookupForFallbackAlbumArt'];
    displayAudioFormat = current['displayAudioFormat'];
    mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen =
        current['mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen'];
    mobileEnableNowPlayingScreenRippleEffect =
        current['mobileEnableNowPlayingScreenRippleEffect'];
  }
}

abstract class ConfigurationKeys {
  late Set<Directory> collectionDirectories;
  late Directory cacheDirectory;
  late LanguageData language;
  late ThemeMode themeMode;
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
  late bool modernNowPlayingScreen;
  late int modernNowPlayingScreenCarouselIndex;
  late bool lyricsVisible;
  late bool discordRPC;
  late double highlightedLyricsSize;
  late double unhighlightedLyricsSize;
  late bool mobileDenseAlbumTabLayout;
  late bool mobileDenseArtistTabLayout;
  late bool mobileGridArtistTabLayout;
  late AlbumsSort albumsSort;
  late TracksSort tracksSort;
  late ArtistsSort artistsSort;
  late GenresSort genresSort;
  late OrderType albumsOrderType;
  late OrderType tracksOrderType;
  late OrderType artistsOrderType;
  late OrderType genresOrderType;
  late int minimumFileSize;
  late int libraryTab;
  late bool useLRCFromTrackDirectory;
  late bool lookupForFallbackAlbumArt;
  late bool displayAudioFormat;
  late bool mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen;
  late bool mobileEnableNowPlayingScreenRippleEffect;
}

Future<Map<String, dynamic>> get _defaultConfiguration async => {
      'collectionDirectories': <String>[
        await {
          'windows': () async =>
              path.join(Platform.environment['USERPROFILE']!, 'Music'),
          'linux': () async {
            try {
              final result = await Process.run(
                'xdg-user-dir',
                [
                  'MUSIC',
                ],
              );
              return result.stdout.toString().trim();
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
              return Platform.environment['HOME']!;
            }
          },
          'android': () async {
            final volumes = await StorageRetriever.instance.volumes;
            debugPrint(volumes.toString());
            return volumes.first.path;
          },
        }[Platform.operatingSystem]!(),
      ],
      'language': {
        'code': 'en_US',
        'name': 'English',
        'country': 'United States',
      },
      'themeMode': isDesktop ? 1 : 0,
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
      'modernNowPlayingScreen': isDesktop,
      'modernNowPlayingScreenCarouselIndex': 0,
      'lyricsVisible': true,
      'discordRPC': true,
      'highlightedLyricsSize': 24.0,
      'unhighlightedLyricsSize': 14.0,
      'mobileDenseAlbumTabLayout': false,
      'mobileDenseArtistTabLayout': true,
      'mobileGridArtistTabLayout': true,
      'albumsSort': isDesktop ? 3 : 0,
      'tracksSort': 0,
      'artistsSort': 0,
      'genresSort': 0,
      'albumsOrderType': 0,
      'tracksOrderType': 0,
      'artistsOrderType': 0,
      'genresOrderType': 0,
      'minimumFileSize': 1024 * 1024,
      'libraryTab': isDesktop ? 0 : 2,
      'useLRCFromTrackDirectory': false,
      'lookupForFallbackAlbumArt': false,
      'displayAudioFormat': true,
      'mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen': false,
      'mobileEnableNowPlayingScreenRippleEffect': true,
    };
