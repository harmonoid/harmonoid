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

  /// [SafeLocalStorage] instance for cache read/write.
  late SafeLocalStorage storage;

  /// Returns equivalent directory on various platforms to save application specific data & other cache.
  ///
  Future<String> get configurationDirectory async {
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
            return Platform.environment['USERPROFILE']!;
          } finally {
            calloc.free(rfid);
            calloc.free(result);
          }
        }
      case 'linux':
        {
          return Platform.environment['HOME']!;
        }
      case 'android':
        {
          final cache = await StorageRetriever.instance.cache;
          debugPrint(cache.toString());
          return cache.path;
        }
      default:
        {
          return '';
        }
    }
  }

  /// Initializes the [Configuration] class.
  ///
  /// Called before the [runApp] & fills the configuration keys.
  /// Generates from scratch if no configuration is found.
  ///
  static Future<void> initialize() async {
    instance.storage = SafeLocalStorage(
      path.join(
        await instance.configurationDirectory,
        '.Harmonoid',
        'Configuration.JSON',
      ),
      fallback: await _getDefaultApplicationConfiguration(),
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
    ThemeMode? themeModeModern,
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
    double? trackThumbnailSizeinList,
    double? trackListTileHeight,
    double? albumThumbnailSizeinList,
    double? albumListTileHeight,
    double? queueSheetMinHeight,
    double? queueSheetMaxHeight,
    double? nowPlayingImageContainerHeight,
    double? borderRadiusMultiplier,
    double? fontScaleFactor,
    String? dateTimeFormat,
    bool? hourFormat12,
    String? trackTileFirstRowFirstItem,
    String? trackTileFirstRowSecondItem,
    String? trackTileFirstRowThirdItem,
    String? trackTileSecondRowFirstItem,
    String? trackTileSecondRowSecondItem,
    String? trackTileSecondRowThirdItem,
    bool? trackTileDisplayThirdItemInRows,
    bool? trackTileDisplayThirdRow,
    String? trackTileThirdRowFirstItem,
    String? trackTileThirdRowSecondItem,
    String? trackTileThirdRowThirdItem,
    String? trackTileRightFirstItem,
    String? trackTileRightSecondItem,
    String? trackTileSeparator,
    int? searchResultsPlayMode,
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
    bool? isModernLayout,
    bool? stickyMiniplayer,
    bool? enableVolumeFadeOnPlayPause,
    bool? displayTrackNumberinAlbumPage,
    bool? albumCardTopRightDate,
    bool? forceSquaredTrackThumbnail,
    bool? forceSquaredAlbumThumbnail,
    bool? useAlbumStaggeredGridView,
    bool? enableBlurEffect,
    bool? enableGlowEffect,
    bool? mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen,
    bool? mobileEnableNowPlayingScreenRippleEffect,
    int? mobileAlbumsGridSize,
    int? mobileArtistsGridSize,
    int? mobileGenresGridSize,
    Set<AlbumHashCodeParameter>? albumHashCodeParameters,
    Map<String, String>? userLibmpvOptions,
    bool? disableAnimations,
    bool? addLibraryToPlaylistWhenPlayingFromTracksTab,
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
    if (themeModeModern != null) {
      this.themeModeModern = themeModeModern;
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
    if (trackThumbnailSizeinList != null) {
      this.trackThumbnailSizeinList = trackThumbnailSizeinList;
    }
    if (trackListTileHeight != null) {
      this.trackListTileHeight = trackListTileHeight;
    }

    if (albumThumbnailSizeinList != null) {
      this.albumThumbnailSizeinList = albumThumbnailSizeinList;
    }
    if (albumListTileHeight != null) {
      this.albumListTileHeight = albumListTileHeight;
    }
    if (queueSheetMinHeight != null) {
      this.queueSheetMinHeight = queueSheetMinHeight;
    }
    if (queueSheetMaxHeight != null) {
      this.queueSheetMaxHeight = queueSheetMaxHeight;
    }
    if (nowPlayingImageContainerHeight != null) {
      this.nowPlayingImageContainerHeight = nowPlayingImageContainerHeight;
    }
    if (borderRadiusMultiplier != null) {
      this.borderRadiusMultiplier = borderRadiusMultiplier;
    }
    if (fontScaleFactor != null) {
      this.fontScaleFactor = fontScaleFactor;
    }
    if (dateTimeFormat != null) {
      this.dateTimeFormat = dateTimeFormat;
    }
    if (hourFormat12 != null) {
      this.hourFormat12 = hourFormat12;
    }
    if (trackTileFirstRowFirstItem != null) {
      this.trackTileFirstRowFirstItem = trackTileFirstRowFirstItem;
    }
    if (trackTileFirstRowSecondItem != null) {
      this.trackTileFirstRowSecondItem = trackTileFirstRowSecondItem;
    }
    if (trackTileFirstRowThirdItem != null) {
      this.trackTileFirstRowThirdItem = trackTileFirstRowThirdItem;
    }
    if (trackTileSecondRowFirstItem != null) {
      this.trackTileSecondRowFirstItem = trackTileSecondRowFirstItem;
    }
    if (trackTileSecondRowSecondItem != null) {
      this.trackTileSecondRowSecondItem = trackTileSecondRowSecondItem;
    }
    if (trackTileSecondRowThirdItem != null) {
      this.trackTileSecondRowThirdItem = trackTileSecondRowThirdItem;
    }
    if (trackTileDisplayThirdItemInRows != null) {
      this.trackTileDisplayThirdItemInRows = trackTileDisplayThirdItemInRows;
    }
    if (trackTileDisplayThirdRow != null) {
      this.trackTileDisplayThirdRow = trackTileDisplayThirdRow;
    }
    if (trackTileThirdRowFirstItem != null) {
      this.trackTileThirdRowFirstItem = trackTileThirdRowFirstItem;
    }
    if (trackTileThirdRowSecondItem != null) {
      this.trackTileThirdRowSecondItem = trackTileThirdRowSecondItem;
    }
    if (trackTileThirdRowThirdItem != null) {
      this.trackTileThirdRowThirdItem = trackTileThirdRowThirdItem;
    }
    if (trackTileRightFirstItem != null) {
      this.trackTileRightFirstItem = trackTileRightFirstItem;
    }
    if (trackTileRightSecondItem != null) {
      this.trackTileRightSecondItem = trackTileRightSecondItem;
    }
    if (trackTileSeparator != null) {
      this.trackTileSeparator = trackTileSeparator;
    }
    if (searchResultsPlayMode != null) {
      this.searchResultsPlayMode = searchResultsPlayMode;
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
    if (isModernLayout != null) {
      this.isModernLayout = isModernLayout;
    }
    if (stickyMiniplayer != null) {
      this.stickyMiniplayer = stickyMiniplayer;
    }
    if (enableVolumeFadeOnPlayPause != null) {
      this.enableVolumeFadeOnPlayPause = enableVolumeFadeOnPlayPause;
    }
    if (displayTrackNumberinAlbumPage != null) {
      this.displayTrackNumberinAlbumPage = displayTrackNumberinAlbumPage;
    }
    if (albumCardTopRightDate != null) {
      this.albumCardTopRightDate = albumCardTopRightDate;
    }
    if (forceSquaredTrackThumbnail != null) {
      this.forceSquaredTrackThumbnail = forceSquaredTrackThumbnail;
    }
    if (forceSquaredAlbumThumbnail != null) {
      this.forceSquaredAlbumThumbnail = forceSquaredAlbumThumbnail;
    }
    if (useAlbumStaggeredGridView != null) {
      this.useAlbumStaggeredGridView = useAlbumStaggeredGridView;
    }
    if (enableBlurEffect != null) {
      this.enableBlurEffect = enableBlurEffect;
    }
    if (enableGlowEffect != null) {
      this.enableGlowEffect = enableGlowEffect;
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
    await storage.write(
      {
        'collectionDirectories': this
            .collectionDirectories
            .map((directory) => directory.path)
            .toList()
            .cast<String>(),
        'language': this.language.toJson(),
        'themeMode': this.themeMode.index,
        'themeModeModern': this.themeModeModern.index,
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
        'trackThumbnailSizeinList': this.trackThumbnailSizeinList,
        'trackListTileHeight': this.trackListTileHeight,
        'albumThumbnailSizeinList': this.albumThumbnailSizeinList,
        'albumListTileHeight': this.albumListTileHeight,
        'queueSheetMinHeight': this.queueSheetMinHeight,
        'queueSheetMaxHeight': this.queueSheetMaxHeight,
        'nowPlayingImageContainerHeight': this.nowPlayingImageContainerHeight,
        'borderRadiusMultiplier': this.borderRadiusMultiplier,
        'fontScaleFactor': this.fontScaleFactor,
        'dateTimeFormat': this.dateTimeFormat,
        'hourFormat12': this.hourFormat12,
        'trackTileFirstRowFirstItem': this.trackTileFirstRowFirstItem,
        'trackTileFirstRowSecondItem': this.trackTileFirstRowSecondItem,
        'trackTileFirstRowThirdItem': this.trackTileFirstRowThirdItem,
        'trackTileSecondRowFirstItem': this.trackTileSecondRowFirstItem,
        'trackTileSecondRowSecondItem': this.trackTileSecondRowSecondItem,
        'trackTileSecondRowThirdItem': this.trackTileSecondRowThirdItem,
        'trackTileDisplayThirdItemInRows': this.trackTileDisplayThirdItemInRows,
        'trackTileDisplayThirdRow': this.trackTileDisplayThirdRow,
        'trackTileThirdRowFirstItem': this.trackTileThirdRowFirstItem,
        'trackTileThirdRowSecondItem': this.trackTileThirdRowSecondItem,
        'trackTileThirdRowThirdItem': this.trackTileThirdRowThirdItem,
        'trackTileRightFirstItem': this.trackTileRightFirstItem,
        'trackTileRightSecondItem': this.trackTileRightSecondItem,
        'trackTileSeparator': this.trackTileSeparator,
        'searchResultsPlayMode': this.searchResultsPlayMode,
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
        'isModernLayout': this.isModernLayout,
        'stickyMiniplayer': this.stickyMiniplayer,
        'enableVolumeFadeOnPlayPause': this.enableVolumeFadeOnPlayPause,
        'displayTrackNumberinAlbumPage': this.displayTrackNumberinAlbumPage,
        'albumCardTopRightDate': this.albumCardTopRightDate,
        'forceSquaredTrackThumbnail': this.forceSquaredTrackThumbnail,
        'forceSquaredAlbumThumbnail': this.forceSquaredAlbumThumbnail,
        'useAlbumStaggeredGridView': this.useAlbumStaggeredGridView,
        'enableBlurEffect': this.enableBlurEffect,
        'enableGlowEffect': this.enableGlowEffect,
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
      },
    );
  }

  /// Reads various configuration keys & stores in memory.
  ///
  Future<void> read() async {
    final current = await storage.read();
    final conf = await _getDefaultApplicationConfiguration();
    // Emplace default values for the keys that not found.
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
    themeModeModern = ThemeMode.values[current['themeModeModern']];
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
    trackThumbnailSizeinList = current['trackThumbnailSizeinList'];
    trackListTileHeight = current['trackListTileHeight'];
    albumThumbnailSizeinList = current['albumThumbnailSizeinList'];
    albumListTileHeight = current['albumListTileHeight'];
    queueSheetMinHeight = current['queueSheetMinHeight'];
    queueSheetMaxHeight = current['queueSheetMaxHeight'];
    nowPlayingImageContainerHeight = current['nowPlayingImageContainerHeight'];
    borderRadiusMultiplier = current['borderRadiusMultiplier'];
    fontScaleFactor = current['fontScaleFactor'];
    dateTimeFormat = current['dateTimeFormat'];
    hourFormat12 = current['hourFormat12'];
    trackTileFirstRowFirstItem = current['trackTileFirstRowFirstItem'];
    trackTileFirstRowSecondItem = current['trackTileFirstRowSecondItem'];
    trackTileFirstRowThirdItem = current['trackTileFirstRowThirdItem'];
    trackTileSecondRowFirstItem = current['trackTileSecondRowFirstItem'];
    trackTileSecondRowSecondItem = current['trackTileSecondRowSecondItem'];
    trackTileSecondRowThirdItem = current['trackTileSecondRowThirdItem'];
    trackTileDisplayThirdItemInRows =
        current['trackTileDisplayThirdItemInRows'];
    trackTileDisplayThirdRow = current['trackTileDisplayThirdRow'];
    trackTileThirdRowFirstItem = current['trackTileThirdRowFirstItem'];
    trackTileThirdRowSecondItem = current['trackTileThirdRowSecondItem'];
    trackTileThirdRowThirdItem = current['trackTileThirdRowThirdItem'];
    trackTileRightFirstItem = current['trackTileRightFirstItem'];
    trackTileRightSecondItem = current['trackTileRightSecondItem'];
    trackTileSeparator = current['trackTileSeparator'];
    searchResultsPlayMode = current['searchResultsPlayMode'];
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
    isModernLayout = current['isModernLayout'];
    stickyMiniplayer = current['stickyMiniplayer'];
    enableVolumeFadeOnPlayPause = current['enableVolumeFadeOnPlayPause'];
    displayTrackNumberinAlbumPage = current['displayTrackNumberinAlbumPage'];
    albumCardTopRightDate = current['albumCardTopRightDate'];
    forceSquaredTrackThumbnail = current['forceSquaredTrackThumbnail'];
    forceSquaredAlbumThumbnail = current['forceSquaredAlbumThumbnail'];
    useAlbumStaggeredGridView = current['useAlbumStaggeredGridView'];
    enableBlurEffect = current['enableBlurEffect'];
    enableGlowEffect = current['enableGlowEffect'];
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
    userLibmpvOptions = Map<String, String>.from(current['userLibmpvOptions']);
    disableAnimations = current['disableAnimations'];
    addLibraryToPlaylistWhenPlayingFromTracksTab =
        current['addLibraryToPlaylistWhenPlayingFromTracksTab'];
  }

  static Future<Map<String, dynamic>>
      _getDefaultApplicationConfiguration() async => {
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
            'themeMode': isDesktop ? 1 : 0,
            'themeModeModern': isDesktop ? 1 : 0,
            'automaticAccent': false,
            'notificationLyrics': true,
            'collectionSearchRecent': const [],
            'webSearchRecent': const [],
            'webRecent': const [],
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
            'trackThumbnailSizeinList': 70.0,
            'trackListTileHeight': 70.0,
            'albumThumbnailSizeinList': 90.0,
            'albumListTileHeight': 90.0,
            'queueSheetMinHeight': 25.0,
            'queueSheetMaxHeight': 500.0,
            'nowPlayingImageContainerHeight': 400.0,
            'borderRadiusMultiplier': 1.0,
            'fontScaleFactor': 1.0,
            'dateTimeFormat': 'MMM yyyy',
            'hourFormat12': true,
            'trackTileFirstRowFirstItem': 'trackName',
            'trackTileFirstRowSecondItem': 'none',
            'trackTileFirstRowThirdItem': 'none',
            'trackTileSecondRowFirstItem': 'artistNames',
            'trackTileSecondRowSecondItem': 'albumName',
            'trackTileSecondRowThirdItem': 'none',
            'trackTileDisplayThirdItemInRows': false,
            'trackTileDisplayThirdRow': false,
            'trackTileThirdRowFirstItem': 'none',
            'trackTileThirdRowSecondItem': 'none',
            'trackTileThirdRowThirdItem': 'none',
            'trackTileRightFirstItem': 'duration',
            'trackTileRightSecondItem': 'none',
            'trackTileSeparator': '•',
            'searchResultsPlayMode': 1,
            'albumsSort': isDesktop ? 3 : 0,
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
            'isModernLayout': false,
            'stickyMiniplayer': false,
            'enableVolumeFadeOnPlayPause': true,
            'displayTrackNumberinAlbumPage': true,
            'albumCardTopRightDate': true,
            'forceSquaredTrackThumbnail': false,
            'forceSquaredAlbumThumbnail': false,
            'useAlbumStaggeredGridView': false,
            'enableBlurEffect': true,
            'enableGlowEffect': true,
            'mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen': true,
            'mobileEnableNowPlayingScreenRippleEffect': true,
            'mobileAlbumsGridSize': 2,
            'mobileArtistsGridSize': 3,
            'mobileGenresGridSize': 3,
            'albumHashCodeParameters': const [
              0,
              1,
              2,
            ],
            'userLibmpvOptions': <String, String>{},
            'disableAnimations': false,
            'addLibraryToPlaylistWhenPlayingFromTracksTab': true,
          };
}

abstract class ConfigurationKeys {
  late Set<Directory> collectionDirectories;
  late Directory cacheDirectory;
  late LanguageData language;
  late ThemeMode themeMode;
  late ThemeMode themeModeModern;
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
  late double trackThumbnailSizeinList;
  late double trackListTileHeight;
  late double albumThumbnailSizeinList;
  late double albumListTileHeight;
  late double queueSheetMinHeight;
  late double queueSheetMaxHeight;
  late double nowPlayingImageContainerHeight;
  late double borderRadiusMultiplier;
  late double fontScaleFactor;
  late String dateTimeFormat;
  late bool hourFormat12;
  late String trackTileFirstRowFirstItem;
  late String trackTileFirstRowSecondItem;
  late String trackTileFirstRowThirdItem;
  late String trackTileSecondRowFirstItem;
  late String trackTileSecondRowSecondItem;
  late String trackTileSecondRowThirdItem;
  late bool trackTileDisplayThirdItemInRows;
  late bool trackTileDisplayThirdRow;
  late String trackTileThirdRowFirstItem;
  late String trackTileThirdRowSecondItem;
  late String trackTileThirdRowThirdItem;
  late String trackTileRightFirstItem;
  late String trackTileRightSecondItem;
  late String trackTileSeparator;
  late int searchResultsPlayMode;
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
  late bool isModernLayout;
  late bool stickyMiniplayer;
  late bool enableVolumeFadeOnPlayPause;
  late bool displayTrackNumberinAlbumPage;
  late bool albumCardTopRightDate;
  late bool forceSquaredTrackThumbnail;
  late bool forceSquaredAlbumThumbnail;
  late bool useAlbumStaggeredGridView;
  late bool enableBlurEffect;
  late bool enableGlowEffect;
  late bool mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen;
  late bool mobileEnableNowPlayingScreenRippleEffect;
  late int mobileAlbumsGridSize;
  late int mobileArtistsGridSize;
  late int mobileGenresGridSize;
  late Set<AlbumHashCodeParameter> albumHashCodeParameters;
  late Map<String, String> userLibmpvOptions;
  late bool disableAnimations;
  late bool addLibraryToPlaylistWhenPlayingFromTracksTab;
}
