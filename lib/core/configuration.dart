/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:media_library/media_library.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/constants/language.dart';

/// Configuration
/// -------------
///
/// Application configuration & settings persistence management for Harmonoid.
///
class Configuration extends ConfigurationKeys {
  /// [Configuration] object instance.
  static final Configuration instance = Configuration();

  /// The dedicated [Directory] for storing cache.
  late final Directory cacheDirectory;

  /// [SafeLocalStorage] instance for cache read/write.
  late final SafeLocalStorage storage;

  Future<String> get operatingSystemCacheDirectory async {
    // Override the cache directory if the `HARMONOID_CACHE_DIR` environment variable is set.
    if (Platform.environment['HARMONOID_CACHE_DIR'] != null) {
      return path.normalize(Platform.environment['HARMONOID_CACHE_DIR']!);
    }
    // Default cache directory for each platform.
    switch (Platform.operatingSystem) {
      case 'windows':
        {
          // `SHGetKnownFolderPath` Win32 API call.
          final rfid = GUIDFromString(FOLDERID_Profile);
          final result = calloc<PWSTR>();
          try {
            final hr = SHGetKnownFolderPath(
              rfid,
              KF_FLAG_DEFAULT,
              NULL,
              result,
            );
            if (FAILED(hr)) {
              throw WindowsException(hr);
            }
            return path.normalize(result.value.toDartString());
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
            // Fallback solution for retrieving the user directory.
            return path.normalize(Platform.environment['USERPROFILE']!);
          } finally {
            calloc.free(rfid);
            calloc.free(result);
          }
        }
      case 'linux':
        {
          return path.normalize(Platform.environment['HOME']!);
        }
      case 'android':
        {
          final cache = await StorageRetriever.instance.cache;
          debugPrint(cache.toString());
          return path.normalize(cache.path);
        }
      default:
        {
          return '';
        }
    }
  }

  /// Initializes the [Configuration] class singleton.
  static Future<void> initialize() async {
    final directory = await instance.operatingSystemCacheDirectory;
    final cacheDirectory = Directory(
      path.join(directory, '.Harmonoid'),
    );
    final storage = SafeLocalStorage(
      path.join(cacheDirectory.path, 'Configuration.JSON'),
      fallback: await _default,
    );
    instance.cacheDirectory = cacheDirectory;
    instance.storage = storage;
    await instance.read();
  }

  Future<void> save({
    Set<Directory>? collectionDirectories,
    LanguageData? language,
    ThemeMode? themeMode,
    bool? automaticAccent,
    bool? notificationLyrics,
    List<String>? collectionSearchRecent,
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
    int? mobileAlbumsGridSize,
    int? mobileArtistsGridSize,
    int? mobileGenresGridSize,
    Set<AlbumHashCodeParameter>? albumHashCodeParameters,
    Map<String, String>? userLibmpvOptions,
    bool? disableAnimations,
    bool? addLibraryToPlaylistWhenPlayingFromTracksTab,
    List<String>? fallbackAlbumArtFileNames,
    bool? androidEnableVolumeBoostFilter,
    AnimationDuration? animationDuration,
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
    if (mobileAlbumsGridSize != null) {
      this.mobileAlbumsGridSize = mobileAlbumsGridSize;
    }
    if (mobileArtistsGridSize != null) {
      this.mobileArtistsGridSize = mobileArtistsGridSize;
    }
    if (mobileGenresGridSize != null) {
      this.mobileGenresGridSize = mobileGenresGridSize;
    }
    if (albumHashCodeParameters != null) {
      this.albumHashCodeParameters = albumHashCodeParameters;
    }
    if (userLibmpvOptions != null) {
      this.userLibmpvOptions = userLibmpvOptions;
    }
    if (disableAnimations != null) {
      this.disableAnimations = disableAnimations;
    }
    if (addLibraryToPlaylistWhenPlayingFromTracksTab != null) {
      this.addLibraryToPlaylistWhenPlayingFromTracksTab =
          addLibraryToPlaylistWhenPlayingFromTracksTab;
    }
    if (fallbackAlbumArtFileNames != null) {
      this.fallbackAlbumArtFileNames = fallbackAlbumArtFileNames;
    }
    if (androidEnableVolumeBoostFilter != null) {
      this.androidEnableVolumeBoostFilter = androidEnableVolumeBoostFilter;
    }
    if (animationDuration != null) {
      this.animationDuration = animationDuration;
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
        'mobileAlbumsGridSize': this.mobileAlbumsGridSize,
        'mobileArtistsGridSize': this.mobileArtistsGridSize,
        'mobileGenresGridSize': this.mobileGenresGridSize,
        'albumHashCodeParameters':
            this.albumHashCodeParameters.map((e) => e.index).toList(),
        'userLibmpvOptions': this.userLibmpvOptions,
        'disableAnimations': this.disableAnimations,
        'addLibraryToPlaylistWhenPlayingFromTracksTab':
            this.addLibraryToPlaylistWhenPlayingFromTracksTab,
        'fallbackAlbumArtFileNames': this.fallbackAlbumArtFileNames,
        'androidEnableVolumeBoostFilter': this.androidEnableVolumeBoostFilter,
        'animationDuration': this.animationDuration.toJson(),
      },
    );
  }

  Future<void> read() async {
    final current = await storage.read();
    final conf = await _default;
    // Emplace default values for the keys that not found. Most likely due to update.
    for (final entry in conf.entries) {
      current[entry.key] ??= entry.value;
    }
    debugPrint(current.toString());
    try {
      // Check for actual keys from the cache.
      collectionDirectories = Set<String>.from(current['collectionDirectories'])
          .map((directory) => Directory(directory))
          .toSet();
      language = LanguageData.fromJson(current['language']);
      themeMode = ThemeMode.values[current['themeMode']];
      automaticAccent = current['automaticAccent'];
      notificationLyrics = current['notificationLyrics'];
      collectionSearchRecent = current['collectionSearchRecent'].cast<String>();
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
      mobileAlbumsGridSize = current['mobileAlbumsGridSize'];
      mobileArtistsGridSize = current['mobileArtistsGridSize'];
      mobileGenresGridSize = current['mobileGenresGridSize'];
      albumHashCodeParameters = Set<AlbumHashCodeParameter>.from(
        current['albumHashCodeParameters'].map(
          (i) => AlbumHashCodeParameter.values[i],
        ),
      );
      userLibmpvOptions =
          Map<String, String>.from(current['userLibmpvOptions']);
      disableAnimations = current['disableAnimations'];
      addLibraryToPlaylistWhenPlayingFromTracksTab =
          current['addLibraryToPlaylistWhenPlayingFromTracksTab'];
      fallbackAlbumArtFileNames =
          current['fallbackAlbumArtFileNames'].cast<String>();
      androidEnableVolumeBoostFilter =
          current['androidEnableVolumeBoostFilter'];
      animationDuration =
          AnimationDuration.fromJson(current['animationDuration']);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  static Future<Map<String, dynamic>> get _default async => {
        'collectionDirectories': <String>[
          await {
            'windows': () async {
              // `SHGetKnownFolderPath` Win32 API call.
              final rfid = GUIDFromString(FOLDERID_Music);
              final result = calloc<PWSTR>();
              try {
                final hr = SHGetKnownFolderPath(
                  rfid,
                  KF_FLAG_DEFAULT,
                  NULL,
                  result,
                );
                if (FAILED(hr)) {
                  throw WindowsException(hr);
                }
                return path.normalize(result.value.toDartString());
              } catch (exception, stacktrace) {
                debugPrint(exception.toString());
                debugPrint(stacktrace.toString());
                // Fallback solution for retrieving the user's music [Directory] using environment variables.
                return path.join(
                  Platform.environment['USERPROFILE']!,
                  'Music',
                );
              } finally {
                calloc.free(rfid);
                calloc.free(result);
              }
            },
            'linux': () async {
              try {
                // Invoke `xdg-user-dir` command.
                final result = await Process.run(
                  'xdg-user-dir',
                  [
                    'MUSIC',
                  ],
                );
                return result.stdout.toString().trim();
              } catch (exception, stacktrace) {
                // Fallback to the user's `HOME` directory.
                debugPrint(exception.toString());
                debugPrint(stacktrace.toString());
                return Platform.environment['HOME']!;
              }
            },
            'android': () async {
              // Native Android implementation on platform channel.
              final volumes = await StorageRetriever.instance.volumes;
              debugPrint(volumes.toString());
              return volumes.first.path;
            },
          }[Platform.operatingSystem]!(),
        ],
        'language': const {
          'code': 'en_US',
          'name': 'English',
          'country': 'United States',
        },
        'themeMode':
            Platform.isWindows || Platform.isLinux || Platform.isMacOS ? 1 : 0,
        'automaticAccent': false,
        'notificationLyrics': true,
        'collectionSearchRecent': const [],
        'webRecent': const [],
        'taskbarIndicator': false,
        'seamlessPlayback': false,
        'jumpToNowPlayingScreenOnPlay':
            Platform.isWindows || Platform.isLinux || Platform.isMacOS,
        'automaticMusicLookup': false,
        'dynamicNowPlayingBarColoring':
            Platform.isWindows || Platform.isLinux || Platform.isMacOS,
        'modernNowPlayingScreen':
            Platform.isWindows || Platform.isLinux || Platform.isMacOS,
        'modernNowPlayingScreenCarouselIndex': 0,
        'lyricsVisible': true,
        'discordRPC': true,
        'highlightedLyricsSize': 38.0,
        'unhighlightedLyricsSize': 14.0,
        'albumsSort':
            Platform.isWindows || Platform.isLinux || Platform.isMacOS ? 3 : 0,
        'tracksSort': 0,
        'artistsSort': 0,
        'genresSort': 0,
        'albumsOrderType': 0,
        'tracksOrderType': 0,
        'artistsOrderType': 0,
        'genresOrderType': 0,
        'minimumFileSize': 1024 * 1024,
        'libraryTab': 0,
        'useLRCFromTrackDirectory': false,
        'lookupForFallbackAlbumArt': false,
        'displayAudioFormat': true,
        'mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen': true,
        'mobileEnableNowPlayingScreenRippleEffect': true,
        'mobileAlbumsGridSize': 2,
        'mobileArtistsGridSize': 3,
        'mobileGenresGridSize': 3,
        'albumHashCodeParameters': const [
          0,
        ],
        'userLibmpvOptions': <String, String>{},
        'disableAnimations': false,
        'addLibraryToPlaylistWhenPlayingFromTracksTab':
            Platform.isAndroid || Platform.isIOS,
        'fallbackAlbumArtFileNames': kDefaultFallbackAlbumArtFileNames,
        'androidEnableVolumeBoostFilter': false,
        'animationDuration': AnimationDuration().toJson(),
      };
}

abstract class ConfigurationKeys {
  late Set<Directory> collectionDirectories;
  late LanguageData language;
  late ThemeMode themeMode;
  late bool automaticAccent;
  late bool notificationLyrics;
  late List<String> collectionSearchRecent;
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
  late int mobileAlbumsGridSize;
  late int mobileArtistsGridSize;
  late int mobileGenresGridSize;
  late Set<AlbumHashCodeParameter> albumHashCodeParameters;
  late Map<String, String> userLibmpvOptions;
  late bool disableAnimations;
  late bool addLibraryToPlaylistWhenPlayingFromTracksTab;
  late List<String> fallbackAlbumArtFileNames;
  late bool androidEnableVolumeBoostFilter;
  late AnimationDuration animationDuration;
}
