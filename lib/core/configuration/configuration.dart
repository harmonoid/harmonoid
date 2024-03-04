import 'dart:ffi';
import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:path/path.dart' as path;
import 'package:win32/win32.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration/database/constants.dart';
import 'package:harmonoid/core/configuration/database/database.dart';
import 'package:harmonoid/models/playback_state.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';

/// {@template configuration}
///
/// Configuration
/// -------------
/// Implementation to retrieve & save persistent configuration & settings.
///
/// {@endtemplate}
class Configuration {
  /// Singleton instance.
  static late final Configuration instance;

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro configuration}
  Configuration._(this.directory) : db = Database(directory);

  /// Initializes the [instance].
  static Future<void> ensureInitialized() async {
    if (initialized) return;
    initialized = true;
    final Directory directory;
    if (Platform.environment['HARMONOID_CACHE_DIR'] == null) {
      // Default directory.
      directory = Directory(path.join(await getDefaultDirectory(), '.Harmonoid'));
    } else {
      // HARMONOID_CACHE_DIR
      directory = Directory(Platform.environment['HARMONOID_CACHE_DIR']!);
    }
    if (!await directory.exists_()) {
      await directory.create_();
    }
    instance = Configuration._(directory);
    await instance.refresh();
  }

  /// Directory used to store configuration.
  final Directory directory;

  /// Database used to store configuration.
  final Database db;

  AnimationDuration get animationDuration => _animationDuration!;
  bool get audioFormatDisplay => _audioFormatDisplay!;
  bool get discordRPC => _discordRPC!;
  LanguageData get language => _language!;
  bool get launchNowPlayingOnFileOpen => _launchNowPlayingOnFileOpen!;
  bool get lrcFromDirectory => _lrcFromDirectory!;
  bool get mediaLibraryAddTracksToPlaylist => _mediaLibraryAddTracksToPlaylist!;
  Set<AlbumGroupingParameter> get mediaLibraryAlbumGroupingParameters => _mediaLibraryAlbumGroupingParameters!;
  bool get mediaLibraryAlbumSortAscending => _mediaLibraryAlbumSortAscending!;
  AlbumSortType get mediaLibraryAlbumSortType => _mediaLibraryAlbumSortType!;
  bool get mediaLibraryArtistSortAscending => _mediaLibraryArtistSortAscending!;
  ArtistSortType get mediaLibraryArtistSortType => _mediaLibraryArtistSortType!;
  bool get mediaLibraryCoverFallback => _mediaLibraryCoverFallback!;
  Map<String, double> get mediaLibraryDesktopTracksScreenColumnWidths => _mediaLibraryDesktopTracksScreenColumnWidths!;
  Set<Directory> get mediaLibraryDirectories => _mediaLibraryDirectories!;
  bool get mediaLibraryGenreSortAscending => _mediaLibraryGenreSortAscending!;
  GenreSortType get mediaLibraryGenreSortType => _mediaLibraryGenreSortType!;
  int get mediaLibraryMinimumFileSize => _mediaLibraryMinimumFileSize!;
  String get mediaLibraryPath => _mediaLibraryPath!;
  bool get mediaLibraryRefreshOnLaunch => _mediaLibraryRefreshOnLaunch!;
  bool get mediaLibraryTrackSortAscending => _mediaLibraryTrackSortAscending!;
  TrackSortType get mediaLibraryTrackSortType => _mediaLibraryTrackSortType!;
  int get mobileAlbumGridSpan => _mobileAlbumGridSpan!;
  int get mobileArtistGridSpan => _mobileArtistGridSpan!;
  int get mobileGenreGridSpan => _mobileGenreGridSpan!;
  bool get mobileNowPlayingRipple => _mobileNowPlayingRipple!;
  bool get mobileNowPlayingSlider => _mobileNowPlayingSlider!;
  bool get modernNowPlaying => _modernNowPlaying!;
  int get modernNowPlayingCarousel => _modernNowPlayingCarousel!;
  int get modernNowPlayingHighlightedLyricsSize => _modernNowPlayingHighlightedLyricsSize!;
  bool get modernNowPlayingLyrics => _modernNowPlayingLyrics!;
  int get modernNowPlayingUnhighlightedLyricsSize => _modernNowPlayingUnhighlightedLyricsSize!;
  Map<String, String> get mpvOptions => _mpvOptions!;
  String? get mpvPath => _mpvPath;
  bool get notificationLyrics => _notificationLyrics!;
  bool get nowPlayingBarColorPalette => _nowPlayingBarColorPalette!;
  PlaybackState get playbackState => _playbackState!;
  int get themeMaterialVersion => _themeMaterialVersion!;
  ThemeMode get themeMode => _themeMode!;
  bool get themeSystemColorScheme => _themeSystemColorScheme!;
  bool get windowsTaskbarProgress => _windowsTaskbarProgress!;

  Future<void> set({
    AnimationDuration? animationDuration,
    bool? audioFormatDisplay,
    bool? discordRPC,
    LanguageData? language,
    bool? launchNowPlayingOnFileOpen,
    bool? lrcFromDirectory,
    bool? mediaLibraryAddTracksToPlaylist,
    Set<AlbumGroupingParameter>? mediaLibraryAlbumGroupingParameters,
    bool? mediaLibraryAlbumSortAscending,
    AlbumSortType? mediaLibraryAlbumSortType,
    bool? mediaLibraryArtistSortAscending,
    ArtistSortType? mediaLibraryArtistSortType,
    bool? mediaLibraryCoverFallback,
    Map<String, double>? mediaLibraryDesktopTracksScreenColumnWidths,
    Set<Directory>? mediaLibraryDirectories,
    bool? mediaLibraryGenreSortAscending,
    GenreSortType? mediaLibraryGenreSortType,
    int? mediaLibraryMinimumFileSize,
    String? mediaLibraryPath,
    bool? mediaLibraryRefreshOnLaunch,
    bool? mediaLibraryTrackSortAscending,
    TrackSortType? mediaLibraryTrackSortType,
    int? mobileAlbumGridSpan,
    int? mobileArtistGridSpan,
    int? mobileGenreGridSpan,
    bool? mobileNowPlayingRipple,
    bool? mobileNowPlayingSlider,
    bool? modernNowPlaying,
    int? modernNowPlayingCarousel,
    int? modernNowPlayingHighlightedLyricsSize,
    int? modernNowPlayingUnhighlightedLyricsSize,
    bool? modernNowPlayingLyrics,
    Map<String, String>? mpvOptions,
    String? mpvPath,
    bool? notificationLyrics,
    PlaybackState? playbackState,
    int? themeMaterialVersion,
    ThemeMode? themeMode,
    bool? themeSystemColorScheme,
    bool? windowsTaskbarProgress,
  }) async {
    if (animationDuration != null) {
      _animationDuration = animationDuration;
      await db.setValue(_kKeyAnimationDuration, kTypeJson, jsonValue: animationDuration);
    }
    if (audioFormatDisplay != null) {
      _audioFormatDisplay = audioFormatDisplay;
      await db.setValue(_kKeyAudioFormatDisplay, kTypeBoolean, booleanValue: audioFormatDisplay);
    }
    if (discordRPC != null) {
      _discordRPC = discordRPC;
      await db.setValue(_kKeyDiscordRPC, kTypeBoolean, booleanValue: discordRPC);
    }
    if (language != null) {
      _language = language;
      await db.setValue(_kKeyLanguage, kTypeJson, jsonValue: language);
    }
    if (launchNowPlayingOnFileOpen != null) {
      _launchNowPlayingOnFileOpen = launchNowPlayingOnFileOpen;
      await db.setValue(_kKeyLaunchNowPlayingOnFileOpen, kTypeBoolean, booleanValue: launchNowPlayingOnFileOpen);
    }
    if (lrcFromDirectory != null) {
      _lrcFromDirectory = lrcFromDirectory;
      await db.setValue(_kKeyLRCFromDirectory, kTypeBoolean, booleanValue: lrcFromDirectory);
    }
    if (mediaLibraryAddTracksToPlaylist != null) {
      _mediaLibraryAddTracksToPlaylist = mediaLibraryAddTracksToPlaylist;
      await db.setValue(_kKeyMediaLibraryAddTracksToPlaylist, kTypeBoolean, booleanValue: mediaLibraryAddTracksToPlaylist);
    }
    if (mediaLibraryAlbumGroupingParameters != null) {
      _mediaLibraryAlbumGroupingParameters = mediaLibraryAlbumGroupingParameters;
      await db.setValue(_kKeyMediaLibraryAlbumGroupingParameters, kTypeJson, jsonValue: mediaLibraryAlbumGroupingParameters.map((e) => e.index).toList());
    }
    if (mediaLibraryAlbumSortAscending != null) {
      _mediaLibraryAlbumSortAscending = mediaLibraryAlbumSortAscending;
      await db.setValue(_kKeyMediaLibraryAlbumSortAscending, kTypeBoolean, booleanValue: mediaLibraryAlbumSortAscending);
    }
    if (mediaLibraryAlbumSortType != null) {
      _mediaLibraryAlbumSortType = mediaLibraryAlbumSortType;
      await db.setValue(_kKeyMediaLibraryAlbumSortType, kTypeInteger, integerValue: mediaLibraryAlbumSortType.index);
    }
    if (mediaLibraryArtistSortAscending != null) {
      _mediaLibraryArtistSortAscending = mediaLibraryArtistSortAscending;
      await db.setValue(_kKeyMediaLibraryArtistSortAscending, kTypeBoolean, booleanValue: mediaLibraryArtistSortAscending);
    }
    if (mediaLibraryArtistSortType != null) {
      _mediaLibraryArtistSortType = mediaLibraryArtistSortType;
      await db.setValue(_kKeyMediaLibraryArtistSortType, kTypeInteger, integerValue: mediaLibraryArtistSortType.index);
    }
    if (mediaLibraryCoverFallback != null) {
      _mediaLibraryCoverFallback = mediaLibraryCoverFallback;
      await db.setValue(_kKeyMediaLibraryCoverFallback, kTypeBoolean, booleanValue: mediaLibraryCoverFallback);
    }
    if (mediaLibraryDesktopTracksScreenColumnWidths != null) {
      _mediaLibraryDesktopTracksScreenColumnWidths = mediaLibraryDesktopTracksScreenColumnWidths;
      await db.setValue(_kKeyMediaLibraryDesktopTracksScreenColumnWidths, kTypeJson, jsonValue: mediaLibraryDesktopTracksScreenColumnWidths);
    }
    if (mediaLibraryDirectories != null) {
      _mediaLibraryDirectories = mediaLibraryDirectories;
      await db.setValue(_kKeyMediaLibraryDirectories, kTypeJson, jsonValue: mediaLibraryDirectories.map((e) => e.path).toList());
    }
    if (mediaLibraryGenreSortAscending != null) {
      _mediaLibraryGenreSortAscending = mediaLibraryGenreSortAscending;
      await db.setValue(_kKeyMediaLibraryGenreSortAscending, kTypeBoolean, booleanValue: mediaLibraryGenreSortAscending);
    }
    if (mediaLibraryGenreSortType != null) {
      _mediaLibraryGenreSortType = mediaLibraryGenreSortType;
      await db.setValue(_kKeyMediaLibraryGenreSortType, kTypeInteger, integerValue: mediaLibraryGenreSortType.index);
    }
    if (mediaLibraryMinimumFileSize != null) {
      _mediaLibraryMinimumFileSize = mediaLibraryMinimumFileSize;
      await db.setValue(_kKeyMediaLibraryMinimumFileSize, kTypeInteger, integerValue: mediaLibraryMinimumFileSize);
    }
    if (mediaLibraryPath != null) {
      _mediaLibraryPath = mediaLibraryPath;
      await db.setValue(_kKeyMediaLibraryPath, kTypeString, stringValue: mediaLibraryPath);
    }
    if (mediaLibraryRefreshOnLaunch != null) {
      _mediaLibraryRefreshOnLaunch = mediaLibraryRefreshOnLaunch;
      await db.setValue(_kKeyMediaLibraryRefreshOnLaunch, kTypeBoolean, booleanValue: mediaLibraryRefreshOnLaunch);
    }
    if (mediaLibraryTrackSortAscending != null) {
      _mediaLibraryTrackSortAscending = mediaLibraryTrackSortAscending;
      await db.setValue(_kKeyMediaLibraryTrackSortAscending, kTypeBoolean, booleanValue: mediaLibraryTrackSortAscending);
    }
    if (mediaLibraryTrackSortType != null) {
      _mediaLibraryTrackSortType = mediaLibraryTrackSortType;
      await db.setValue(_kKeyMediaLibraryTrackSortType, kTypeInteger, integerValue: mediaLibraryTrackSortType.index);
    }
    if (mobileAlbumGridSpan != null) {
      _mobileAlbumGridSpan = mobileAlbumGridSpan;
      await db.setValue(_kKeyMobileAlbumGridSpan, kTypeInteger, integerValue: mobileAlbumGridSpan);
    }
    if (mobileArtistGridSpan != null) {
      _mobileArtistGridSpan = mobileArtistGridSpan;
      await db.setValue(_kKeyMobileArtistGridSpan, kTypeInteger, integerValue: mobileArtistGridSpan);
    }
    if (mobileGenreGridSpan != null) {
      _mobileGenreGridSpan = mobileGenreGridSpan;
      await db.setValue(_kKeyMobileGenreGridSpan, kTypeInteger, integerValue: mobileGenreGridSpan);
    }
    if (mobileNowPlayingRipple != null) {
      _mobileNowPlayingRipple = mobileNowPlayingRipple;
      await db.setValue(_kKeyMobileNowPlayingRipple, kTypeBoolean, booleanValue: mobileNowPlayingRipple);
    }
    if (mobileNowPlayingSlider != null) {
      _mobileNowPlayingSlider = mobileNowPlayingSlider;
      await db.setValue(_kKeyMobileNowPlayingSlider, kTypeBoolean, booleanValue: mobileNowPlayingSlider);
    }
    if (modernNowPlaying != null) {
      _modernNowPlaying = modernNowPlaying;
      await db.setValue(_kKeyModernNowPlaying, kTypeBoolean, booleanValue: modernNowPlaying);
    }
    if (modernNowPlayingCarousel != null) {
      _modernNowPlayingCarousel = modernNowPlayingCarousel;
      await db.setValue(_kKeyModernNowPlayingCarousel, kTypeInteger, integerValue: modernNowPlayingCarousel);
    }
    if (modernNowPlayingHighlightedLyricsSize != null) {
      _modernNowPlayingHighlightedLyricsSize = modernNowPlayingHighlightedLyricsSize;
      await db.setValue(_kKeyModernNowPlayingHighlightedLyricsSize, kTypeInteger, integerValue: modernNowPlayingHighlightedLyricsSize);
    }
    if (modernNowPlayingUnhighlightedLyricsSize != null) {
      _modernNowPlayingUnhighlightedLyricsSize = modernNowPlayingUnhighlightedLyricsSize;
      await db.setValue(_kKeyModernNowPlayingUnhighlightedLyricsSize, kTypeInteger, integerValue: modernNowPlayingUnhighlightedLyricsSize);
    }
    if (modernNowPlayingLyrics != null) {
      _modernNowPlayingLyrics = modernNowPlayingLyrics;
      await db.setValue(_kKeyModernNowPlayingLyrics, kTypeBoolean, booleanValue: modernNowPlayingLyrics);
    }
    if (mpvOptions != null) {
      _mpvOptions = mpvOptions;
      await db.setValue(_kKeyMpvOptions, kTypeJson, jsonValue: mpvOptions);
    }
    if (mpvPath != null) {
      _mpvPath = mpvPath;
      await db.setValue(_kKeyMpvPath, kTypeString, stringValue: mpvPath);
    }
    if (notificationLyrics != null) {
      _notificationLyrics = notificationLyrics;
      await db.setValue(_kKeyNotificationLyrics, kTypeBoolean, booleanValue: notificationLyrics);
    }
    if (playbackState != null) {
      _playbackState = playbackState;
      await db.setValue(_kKeyPlaybackState, kTypeJson, jsonValue: playbackState);
    }
    if (themeMaterialVersion != null) {
      _themeMaterialVersion = themeMaterialVersion;
      await db.setValue(_kKeyThemeMaterialVersion, kTypeInteger, integerValue: themeMaterialVersion);
    }
    if (themeMode != null) {
      _themeMode = themeMode;
      await db.setValue(_kKeyThemeMode, kTypeInteger, integerValue: themeMode.index);
    }
    if (themeSystemColorScheme != null) {
      _themeSystemColorScheme = themeSystemColorScheme;
      await db.setValue(_kKeyThemeSystemColorScheme, kTypeBoolean, booleanValue: themeSystemColorScheme);
    }
    if (windowsTaskbarProgress != null) {
      _windowsTaskbarProgress = windowsTaskbarProgress;
      await db.setValue(_kKeyWindowsTaskbarProgress, kTypeBoolean, booleanValue: windowsTaskbarProgress);
    }
  }

  Future<void> refresh() async {
    // Insert default values if any key is absent.
    final defaults = await getDefaults();
    for (final entry in defaults.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is bool) {
        await db.setValueIfAbsent(key, kTypeBoolean, booleanValue: value);
      } else if (value is int) {
        await db.setValueIfAbsent(key, kTypeInteger, integerValue: value);
      } else if (value is String || value == null) {
        await db.setValueIfAbsent(key, kTypeString, stringValue: value);
      } else {
        await db.setValueIfAbsent(key, kTypeJson, jsonValue: value);
      }
    }

    _animationDuration = AnimationDuration.fromJson(await db.getJson(_kKeyAnimationDuration));
    _audioFormatDisplay = await db.getBoolean(_kKeyAudioFormatDisplay);
    _discordRPC = await db.getBoolean(_kKeyDiscordRPC);
    _language = LanguageData.fromJson(await db.getJson(_kKeyLanguage));
    _launchNowPlayingOnFileOpen = await db.getBoolean(_kKeyLaunchNowPlayingOnFileOpen);
    _lrcFromDirectory = await db.getBoolean(_kKeyLRCFromDirectory);
    _mediaLibraryAddTracksToPlaylist = await db.getBoolean(_kKeyMediaLibraryAddTracksToPlaylist);
    _mediaLibraryAlbumGroupingParameters = (await db.getJson(_kKeyMediaLibraryAlbumGroupingParameters)).map<AlbumGroupingParameter>((e) => AlbumGroupingParameter.values[e]).toSet();
    _mediaLibraryAlbumSortAscending = await db.getBoolean(_kKeyMediaLibraryAlbumSortAscending);
    _mediaLibraryAlbumSortType = AlbumSortType.values[(await db.getInteger(_kKeyMediaLibraryAlbumSortType))!];
    _mediaLibraryArtistSortAscending = await db.getBoolean(_kKeyMediaLibraryArtistSortAscending);
    _mediaLibraryArtistSortType = ArtistSortType.values[(await db.getInteger(_kKeyMediaLibraryArtistSortType))!];
    _mediaLibraryCoverFallback = await db.getBoolean(_kKeyMediaLibraryCoverFallback);
    _mediaLibraryDesktopTracksScreenColumnWidths = Map<String, double>.from(await db.getJson(_kKeyMediaLibraryDesktopTracksScreenColumnWidths));
    _mediaLibraryDirectories = (await db.getJson(_kKeyMediaLibraryDirectories)).map<Directory>((e) => Directory(e)).toSet();
    _mediaLibraryGenreSortAscending = await db.getBoolean(_kKeyMediaLibraryGenreSortAscending);
    _mediaLibraryGenreSortType = GenreSortType.values[(await db.getInteger(_kKeyMediaLibraryGenreSortType))!];
    _mediaLibraryMinimumFileSize = await db.getInteger(_kKeyMediaLibraryMinimumFileSize);
    _mediaLibraryPath = await db.getString(_kKeyMediaLibraryPath);
    _mediaLibraryRefreshOnLaunch = await db.getBoolean(_kKeyMediaLibraryRefreshOnLaunch);
    _mediaLibraryTrackSortAscending = await db.getBoolean(_kKeyMediaLibraryTrackSortAscending);
    _mediaLibraryTrackSortType = TrackSortType.values[(await db.getInteger(_kKeyMediaLibraryTrackSortType))!];
    _mobileAlbumGridSpan = await db.getInteger(_kKeyMobileAlbumGridSpan);
    _mobileArtistGridSpan = await db.getInteger(_kKeyMobileArtistGridSpan);
    _mobileGenreGridSpan = await db.getInteger(_kKeyMobileGenreGridSpan);
    _mobileNowPlayingRipple = await db.getBoolean(_kKeyMobileNowPlayingRipple);
    _mobileNowPlayingSlider = await db.getBoolean(_kKeyMobileNowPlayingSlider);
    _modernNowPlaying = await db.getBoolean(_kKeyModernNowPlaying);
    _modernNowPlayingCarousel = await db.getInteger(_kKeyModernNowPlayingCarousel);
    _modernNowPlayingHighlightedLyricsSize = await db.getInteger(_kKeyModernNowPlayingHighlightedLyricsSize);
    _modernNowPlayingUnhighlightedLyricsSize = await db.getInteger(_kKeyModernNowPlayingUnhighlightedLyricsSize);
    _modernNowPlayingLyrics = await db.getBoolean(_kKeyModernNowPlayingLyrics);
    _mpvOptions = Map<String, String>.from(await db.getJson(_kKeyMpvOptions));
    _mpvPath = await db.getString(_kKeyMpvPath);
    _notificationLyrics = await db.getBoolean(_kKeyNotificationLyrics);
    _nowPlayingBarColorPalette = await db.getBoolean(_kKeyNowPlayingBarColorPalette);
    _playbackState = PlaybackState.fromJson(await db.getJson(_kKeyPlaybackState));
    _themeMaterialVersion = await db.getInteger(_kKeyThemeMaterialVersion);
    _themeMode = ThemeMode.values[(await db.getInteger(_kKeyThemeMode))!];
    _themeSystemColorScheme = await db.getBoolean(_kKeyThemeSystemColorScheme);
    _windowsTaskbarProgress = await db.getBoolean(_kKeyWindowsTaskbarProgress);
  }

  AnimationDuration? _animationDuration;
  bool? _audioFormatDisplay;
  bool? _discordRPC;
  LanguageData? _language;
  bool? _launchNowPlayingOnFileOpen;
  bool? _lrcFromDirectory;
  bool? _mediaLibraryAddTracksToPlaylist;
  Set<AlbumGroupingParameter>? _mediaLibraryAlbumGroupingParameters;
  bool? _mediaLibraryAlbumSortAscending;
  AlbumSortType? _mediaLibraryAlbumSortType;
  bool? _mediaLibraryArtistSortAscending;
  ArtistSortType? _mediaLibraryArtistSortType;
  bool? _mediaLibraryCoverFallback;
  Map<String, double>? _mediaLibraryDesktopTracksScreenColumnWidths;
  Set<Directory>? _mediaLibraryDirectories;
  bool? _mediaLibraryGenreSortAscending;
  GenreSortType? _mediaLibraryGenreSortType;
  int? _mediaLibraryMinimumFileSize;
  String? _mediaLibraryPath;
  bool? _mediaLibraryRefreshOnLaunch;
  bool? _mediaLibraryTrackSortAscending;
  TrackSortType? _mediaLibraryTrackSortType;
  int? _mobileAlbumGridSpan;
  int? _mobileArtistGridSpan;
  int? _mobileGenreGridSpan;
  bool? _mobileNowPlayingRipple;
  bool? _mobileNowPlayingSlider;
  bool? _modernNowPlaying;
  int? _modernNowPlayingCarousel;
  int? _modernNowPlayingHighlightedLyricsSize;
  bool? _modernNowPlayingLyrics;
  int? _modernNowPlayingUnhighlightedLyricsSize;
  Map<String, String>? _mpvOptions;
  String? _mpvPath;
  bool? _notificationLyrics;
  bool? _nowPlayingBarColorPalette;
  PlaybackState? _playbackState;
  int? _themeMaterialVersion;
  ThemeMode? _themeMode;
  bool? _themeSystemColorScheme;
  bool? _windowsTaskbarProgress;

  static Future<Map<String, dynamic>> getDefaults() async {
    return {
      /* JSON    */ _kKeyAnimationDuration: const AnimationDuration(),
      /* Boolean */ _kKeyAudioFormatDisplay: true,
      /* Boolean */ _kKeyDiscordRPC: true,
      /* JSON    */ _kKeyLanguage: const LanguageData(code: 'en_US', name: 'English (United States)', country: 'United States'),
      /* Boolean */ _kKeyLaunchNowPlayingOnFileOpen: isDesktop,
      /* Boolean */ _kKeyLRCFromDirectory: false,
      /* Boolean */ _kKeyMediaLibraryAddTracksToPlaylist: true,
      /* JSON    */ _kKeyMediaLibraryAlbumGroupingParameters: [AlbumGroupingParameter.album.index],
      /* Boolean */ _kKeyMediaLibraryAlbumSortAscending: true,
      /* Integer */ _kKeyMediaLibraryAlbumSortType: isDesktop ? AlbumSortType.albumArtist.index : AlbumSortType.album.index,
      /* Boolean */ _kKeyMediaLibraryArtistSortAscending: true,
      /* Integer */ _kKeyMediaLibraryArtistSortType: ArtistSortType.artist.index,
      /* Boolean */ _kKeyMediaLibraryCoverFallback: false,
      /* JSON    */ _kKeyMediaLibraryDesktopTracksScreenColumnWidths: <String, double>{},
      /* JSON    */ _kKeyMediaLibraryDirectories: [await getDefaultMediaLibraryDirectory()],
      /* Boolean */ _kKeyMediaLibraryGenreSortAscending: true,
      /* Integer */ _kKeyMediaLibraryGenreSortType: GenreSortType.genre.index,
      /* Integer */ _kKeyMediaLibraryMinimumFileSize: 0,
      /* Integer */ _kKeyMediaLibraryPath: kAlbumsPath,
      /* Boolean */ _kKeyMediaLibraryRefreshOnLaunch: true,
      /* Boolean */ _kKeyMediaLibraryTrackSortAscending: true,
      /* Integer */ _kKeyMediaLibraryTrackSortType: TrackSortType.title.index,
      /* Integer */ _kKeyMobileAlbumGridSpan: 2,
      /* Integer */ _kKeyMobileArtistGridSpan: 3,
      /* Integer */ _kKeyMobileGenreGridSpan: 3,
      /* Boolean */ _kKeyMobileNowPlayingRipple: true,
      /* Boolean */ _kKeyMobileNowPlayingSlider: true,
      /* Boolean */ _kKeyModernNowPlaying: true,
      /* Integer */ _kKeyModernNowPlayingCarousel: 0,
      /* Integer */ _kKeyModernNowPlayingHighlightedLyricsSize: 32,
      /* Boolean */ _kKeyModernNowPlayingLyrics: true,
      /* Integer */ _kKeyModernNowPlayingUnhighlightedLyricsSize: 14,
      /* JSON    */ _kKeyMpvOptions: <String, String>{},
      /* String  */ _kKeyMpvPath: null,
      /* Boolean */ _kKeyNotificationLyrics: true,
      /* Boolean */ _kKeyNowPlayingBarColorPalette: true,
      /* JSON    */ _kKeyPlaybackState: PlaybackState.defaults(),
      /* Integer */ _kKeyThemeMaterialVersion: isDesktop ? 2 : 3,
      /* Integer */ _kKeyThemeMode: ThemeMode.system.index,
      /* Boolean */ _kKeyThemeSystemColorScheme: true,
      /* Boolean */ _kKeyWindowsTaskbarProgress: false,
    };
  }

  static Future<String> getDefaultDirectory() async {
    if (Platform.isWindows) {
      // SHGetKnownFolderPath Win32 API call.
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
        // Fallback.
        return path.normalize(Platform.environment['USERPROFILE']!);
      } finally {
        calloc.free(rfid);
        calloc.free(result);
      }
    } else if (Platform.isMacOS) {
      // TODO:
    } else if (Platform.isLinux) {
      return path.normalize(Platform.environment['HOME']!);
    } else if (Platform.isAndroid) {
      final result = await AndroidStorageController.instance.cache;
      return result.path;
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  static Future<String> getDefaultMediaLibraryDirectory() async {
    if (Platform.isWindows) {
      // SHGetKnownFolderPath Win32 API call.
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
        // Fallback.
        return path.normalize(path.join(Platform.environment['USERPROFILE']!, 'Music'));
      } finally {
        calloc.free(rfid);
        calloc.free(result);
      }
    } else if (Platform.isMacOS) {
      // TODO:
    } else if (Platform.isLinux) {
      try {
        // Invoke xdg-user-dir command.
        final result = await Process.run('xdg-user-dir', ['MUSIC']);
        if (result.exitCode != 0) {
          throw Exception('xdg-user-dir command failed with exit code ${result.exitCode}');
        }
        return path.normalize(result.stdout.toString().trim());
      } catch (exception, stacktrace) {
        // Fallback.
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
        return path.join(path.normalize(Platform.environment['HOME']!), 'Music');
      }
    } else if (Platform.isAndroid) {
      final result = await AndroidStorageController.instance.external;
      return result.first.path;
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  // ----- Keys -----

  static const _kKeyAnimationDuration = 'ANIMATION_DURATION';
  static const _kKeyAudioFormatDisplay = 'AUDIO_FORMAT_DISPLAY';
  static const _kKeyDiscordRPC = 'DISCORD_RPC';
  static const _kKeyLanguage = 'LANGUAGE';
  static const _kKeyLaunchNowPlayingOnFileOpen = 'LAUNCH_NOW_PLAYING_ON_FILE_OPEN';
  static const _kKeyLRCFromDirectory = 'LRC_FROM_DIRECTORY';
  static const _kKeyMediaLibraryAddTracksToPlaylist = 'MEDIA_LIBRARY_ADD_TRACKS_TO_PLAYLIST';
  static const _kKeyMediaLibraryAlbumGroupingParameters = 'MEDIA_LIBRARY_ALBUM_GROUPING_PARAMETERS';
  static const _kKeyMediaLibraryAlbumSortAscending = 'MEDIA_LIBRARY_ALBUM_SORT_ASCENDING';
  static const _kKeyMediaLibraryAlbumSortType = 'MEDIA_LIBRARY_ALBUM_SORT_TYPE';
  static const _kKeyMediaLibraryArtistSortAscending = 'MEDIA_LIBRARY_ARTIST_SORT_ASCENDING';
  static const _kKeyMediaLibraryArtistSortType = 'MEDIA_LIBRARY_ARTIST_SORT_TYPE';
  static const _kKeyMediaLibraryCoverFallback = 'MEDIA_LIBRARY_COVER_FALLBACK';
  static const _kKeyMediaLibraryDesktopTracksScreenColumnWidths = 'MEDIA_LIBRARY_DESKTOP_TRACKS_SCREEN_COLUMN_WIDTHS';
  static const _kKeyMediaLibraryDirectories = 'MEDIA_LIBRARY_DIRECTORIES';
  static const _kKeyMediaLibraryGenreSortAscending = 'MEDIA_LIBRARY_GENRE_SORT_ASCENDING';
  static const _kKeyMediaLibraryGenreSortType = 'MEDIA_LIBRARY_GENRE_SORT_TYPE';
  static const _kKeyMediaLibraryMinimumFileSize = 'MEDIA_LIBRARY_MINIMUM_FILE_SIZE';
  static const _kKeyMediaLibraryPath = 'MEDIA_LIBRARY_PATH';
  static const _kKeyMediaLibraryRefreshOnLaunch = 'MEDIA_LIBRARY_REFRESH_ON_LAUNCH';
  static const _kKeyMediaLibraryTrackSortAscending = 'MEDIA_LIBRARY_TRACK_SORT_ASCENDING';
  static const _kKeyMediaLibraryTrackSortType = 'MEDIA_LIBRARY_TRACK_SORT_TYPE';
  static const _kKeyMobileAlbumGridSpan = 'MOBILE_ALBUM_GRID_SPAN';
  static const _kKeyMobileArtistGridSpan = 'MOBILE_ARTIST_GRID_SPAN';
  static const _kKeyMobileGenreGridSpan = 'MOBILE_GENRE_GRID_SPAN';
  static const _kKeyMobileNowPlayingRipple = 'MOBILE_NOW_PLAYING_RIPPLE';
  static const _kKeyMobileNowPlayingSlider = 'MOBILE_NOW_PLAYING_SLIDER';
  static const _kKeyModernNowPlaying = 'MODERN_NOW_PLAYING';
  static const _kKeyModernNowPlayingCarousel = 'MODERN_NOW_PLAYING_CAROUSEL';
  static const _kKeyModernNowPlayingHighlightedLyricsSize = 'MODERN_NOW_PLAYING_HIGHLIGHTED_LYRICS_SIZE';
  static const _kKeyModernNowPlayingLyrics = 'MODERN_NOW_PLAYING_LYRICS';
  static const _kKeyModernNowPlayingUnhighlightedLyricsSize = 'MODERN_NOW_PLAYING_UNHIGHLIGHTED_LYRICS_SIZE';
  static const _kKeyMpvOptions = 'MPV_OPTIONS';
  static const _kKeyMpvPath = 'MPV_PATH';
  static const _kKeyNotificationLyrics = 'NOTIFICATION_LYRICS';
  static const _kKeyNowPlayingBarColorPalette = 'NOW_PLAYING_COLOR_PALETTE';
  static const _kKeyPlaybackState = 'PLAYBACK_STATE';
  static const _kKeyThemeMaterialVersion = 'THEME_MATERIAL_VERSION';
  static const _kKeyThemeMode = 'THEME_MODE';
  static const _kKeyThemeSystemColorScheme = 'THEME_SYSTEM_COLOR_SCHEME';
  static const _kKeyWindowsTaskbarProgress = 'WINDOWS_TASKBAR_PROGRESS';
}
