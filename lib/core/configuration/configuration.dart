import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:path/path.dart' as path;
import 'package:win32/win32.dart';

import 'package:harmonoid/core/configuration/constants.dart';
import 'package:harmonoid/core/configuration/database.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';

/// {@template configuration}
///
/// Configuration
/// -------------
/// Application's persistent configuration & settings provider.
///
/// {@endtemplate}
class Configuration {
  /// Singleton instance.
  static final Configuration instance = Configuration._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro configuration}
  Configuration._();

  /// Initializes the [instance].
  Future<void> ensureInitialized() async {
    if (initialized) return;
    initialized = true;
    if (Platform.environment['HARMONOID_CACHE_DIR'] == null) {
      // Default directory.
      directory = Directory(path.join(await getDefaultDirectory(), '.Harmonoid'));
    } else {
      // HARMONOID_CACHE_DIR
      directory = Directory(Platform.environment['HARMONOID_CACHE_DIR']!);
    }
    db = Database(directory);
    await refresh();
  }

  /// Directory used to store configuration.
  late Directory directory;

  /// Database used to store configuration.
  late Database db;

  AnimationDuration? _animationDuration;
  bool? _audioFormatDisplay;
  bool? _discordRPC;
  bool? _fallbackAlbumArt;
  LanguageData? _language;
  bool? _launchNowPlayingOnFileOpen;
  bool? _lrcFromDirectory;
  int? _mobileAlbumGridSpanCount;
  int? _mobileArtistGridSpanCount;
  int? _mobileGenreGridSpanCount;
  bool? _mobileNowPlayingRipple;
  bool? _mobileNowPlayingSlider;
  bool? _modernNowPlaying;
  int? _modernNowPlayingCarousel;
  int? _modernNowPlayingHighlightedLyricsSize;
  int? _modernNowPlayingUnhighlightedLyricsSize;
  bool? _modernNowPlayingLyrics;
  Map<String, String>? _mpvOptions;
  String? _mpvPath;
  bool? _musicLibraryAddTracksToPlaylist;
  Set<AlbumGroupingParameter>? _musicLibraryAlbumGroupingParameters;
  bool? _musicLibraryAlbumSortAscending;
  AlbumSortType? _musicLibraryAlbumSortType;
  bool? _musicLibraryArtistSortAscending;
  ArtistSortType? _musicLibraryArtistSortType;
  Set<Directory>? _musicLibraryDirectories;
  bool? _musicLibraryGenreSortAscending;
  GenreSortType? _musicLibraryGenreSortType;
  int? _musicLibraryMinimumFileSize;
  bool? _musicLibraryRefreshOnLaunch;
  int? _musicLibraryTab;
  bool? _musicLibraryTrackSortAscending;
  TrackSortType? _musicLibraryTrackSortType;
  bool? _notificationLyrics;
  bool? _themeDynamicColor;
  int? _themeMaterialVersion;
  ThemeMode? _themeMode;
  bool? _windowsTaskbarProgress;

  AnimationDuration get animationDuration => _animationDuration!;
  bool get audioFormatDisplay => _audioFormatDisplay!;
  bool get discordRPC => _discordRPC!;
  bool get fallbackAlbumArt => _fallbackAlbumArt!;
  LanguageData get language => _language!;
  bool get launchNowPlayingOnFileOpen => _launchNowPlayingOnFileOpen!;
  bool get lrcFromDirectory => _lrcFromDirectory!;
  int get mobileAlbumGridSpanCount => _mobileAlbumGridSpanCount!;
  int get mobileArtistGridSpanCount => _mobileArtistGridSpanCount!;
  int get mobileGenreGridSpanCount => _mobileGenreGridSpanCount!;
  bool get mobileNowPlayingRipple => _mobileNowPlayingRipple!;
  bool get mobileNowPlayingSlider => _mobileNowPlayingSlider!;
  bool get modernNowPlaying => _modernNowPlaying!;
  int get modernNowPlayingCarousel => _modernNowPlayingCarousel!;
  int get modernNowPlayingHighlightedLyricsSize => _modernNowPlayingHighlightedLyricsSize!;
  int get modernNowPlayingUnhighlightedLyricsSize => _modernNowPlayingUnhighlightedLyricsSize!;
  bool get modernNowPlayingLyrics => _modernNowPlayingLyrics!;
  Map<String, String> get mpvOptions => _mpvOptions!;
  String get mpvPath => _mpvPath!;
  bool get musicLibraryAddTracksToPlaylist => _musicLibraryAddTracksToPlaylist!;
  Set<AlbumGroupingParameter> get musicLibraryAlbumGroupingParameters => _musicLibraryAlbumGroupingParameters!;
  bool get musicLibraryAlbumSortAscending => _musicLibraryAlbumSortAscending!;
  AlbumSortType get musicLibraryAlbumSortType => _musicLibraryAlbumSortType!;
  bool get musicLibraryArtistSortAscending => _musicLibraryArtistSortAscending!;
  ArtistSortType get musicLibraryArtistSortType => _musicLibraryArtistSortType!;
  Set<Directory> get musicLibraryDirectories => _musicLibraryDirectories!;
  bool get musicLibraryGenreSortAscending => _musicLibraryGenreSortAscending!;
  GenreSortType get musicLibraryGenreSortType => _musicLibraryGenreSortType!;
  int get musicLibraryMinimumFileSize => _musicLibraryMinimumFileSize!;
  bool get musicLibraryRefreshOnLaunch => _musicLibraryRefreshOnLaunch!;
  int get musicLibraryTab => _musicLibraryTab!;
  bool get musicLibraryTrackSortAscending => _musicLibraryTrackSortAscending!;
  TrackSortType get musicLibraryTrackSortType => _musicLibraryTrackSortType!;
  bool get notificationLyrics => _notificationLyrics!;
  bool get themeDynamicColor => _themeDynamicColor!;
  int get themeMaterialVersion => _themeMaterialVersion!;
  ThemeMode get themeMode => _themeMode!;
  bool get windowsTaskbarProgress => _windowsTaskbarProgress!;

  Future<void> set({
    AnimationDuration? animationDuration,
    bool? audioFormatDisplay,
    bool? discordRPC,
    bool? fallbackAlbumArt,
    LanguageData? language,
    bool? launchNowPlayingOnFileOpen,
    bool? lrcFromDirectory,
    int? mobileAlbumGridSpanCount,
    int? mobileArtistGridSpanCount,
    int? mobileGenreGridSpanCount,
    bool? mobileNowPlayingRipple,
    bool? mobileNowPlayingSlider,
    bool? modernNowPlaying,
    int? modernNowPlayingCarousel,
    int? modernNowPlayingHighlightedLyricsSize,
    int? modernNowPlayingUnhighlightedLyricsSize,
    bool? modernNowPlayingLyrics,
    Map<String, String>? mpvOptions,
    String? mpvPath,
    bool? musicLibraryAddTracksToPlaylist,
    Set<AlbumGroupingParameter>? musicLibraryAlbumGroupingParameters,
    bool? musicLibraryAlbumSortAscending,
    AlbumSortType? musicLibraryAlbumSortType,
    bool? musicLibraryArtistSortAscending,
    ArtistSortType? musicLibraryArtistSortType,
    Set<Directory>? musicLibraryDirectories,
    bool? musicLibraryGenreSortAscending,
    GenreSortType? musicLibraryGenreSortType,
    int? musicLibraryMinimumFileSize,
    bool? musicLibraryRefreshOnLaunch,
    int? musicLibraryTab,
    bool? musicLibraryTrackSortAscending,
    TrackSortType? musicLibraryTrackSortType,
    bool? notificationLyrics,
    bool? themeDynamicColor,
    int? themeMaterialVersion,
    ThemeMode? themeMode,
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
    if (fallbackAlbumArt != null) {
      _fallbackAlbumArt = fallbackAlbumArt;
      await db.setValue(_kKeyFallbackAlbumArt, kTypeBoolean, booleanValue: fallbackAlbumArt);
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
    if (mobileAlbumGridSpanCount != null) {
      _mobileAlbumGridSpanCount = mobileAlbumGridSpanCount;
      await db.setValue(_kKeyMobileAlbumGridSpanCount, kTypeInteger, integerValue: mobileAlbumGridSpanCount);
    }
    if (mobileArtistGridSpanCount != null) {
      _mobileArtistGridSpanCount = mobileArtistGridSpanCount;
      await db.setValue(_kKeyMobileArtistGridSpanCount, kTypeInteger, integerValue: mobileArtistGridSpanCount);
    }
    if (mobileGenreGridSpanCount != null) {
      _mobileGenreGridSpanCount = mobileGenreGridSpanCount;
      await db.setValue(_kKeyMobileGenreGridSpanCount, kTypeInteger, integerValue: mobileGenreGridSpanCount);
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
    if (musicLibraryAddTracksToPlaylist != null) {
      _musicLibraryAddTracksToPlaylist = musicLibraryAddTracksToPlaylist;
      await db.setValue(_kKeyMusicLibraryAddTracksToPlaylist, kTypeBoolean, booleanValue: musicLibraryAddTracksToPlaylist);
    }
    if (musicLibraryAlbumGroupingParameters != null) {
      _musicLibraryAlbumGroupingParameters = musicLibraryAlbumGroupingParameters;
      await db.setValue(_kKeyMusicLibraryAlbumGroupingParameters, kTypeJson, jsonValue: musicLibraryAlbumGroupingParameters.map((e) => e.index).toList());
    }
    if (musicLibraryAlbumSortAscending != null) {
      _musicLibraryAlbumSortAscending = musicLibraryAlbumSortAscending;
      await db.setValue(_kKeyMusicLibraryAlbumSortAscending, kTypeBoolean, booleanValue: musicLibraryAlbumSortAscending);
    }
    if (musicLibraryAlbumSortType != null) {
      _musicLibraryAlbumSortType = musicLibraryAlbumSortType;
      await db.setValue(_kKeyMusicLibraryAlbumSortType, kTypeInteger, integerValue: musicLibraryAlbumSortType.index);
    }
    if (musicLibraryArtistSortAscending != null) {
      _musicLibraryArtistSortAscending = musicLibraryArtistSortAscending;
      await db.setValue(_kKeyMusicLibraryArtistSortAscending, kTypeBoolean, booleanValue: musicLibraryArtistSortAscending);
    }
    if (musicLibraryArtistSortType != null) {
      _musicLibraryArtistSortType = musicLibraryArtistSortType;
      await db.setValue(_kKeyMusicLibraryArtistSortType, kTypeInteger, integerValue: musicLibraryArtistSortType.index);
    }
    if (musicLibraryDirectories != null) {
      _musicLibraryDirectories = musicLibraryDirectories;
      await db.setValue(_kKeyMusicLibraryDirectories, kTypeJson, jsonValue: musicLibraryDirectories.map((e) => e.path).toList());
    }
    if (musicLibraryGenreSortAscending != null) {
      _musicLibraryGenreSortAscending = musicLibraryGenreSortAscending;
      await db.setValue(_kKeyMusicLibraryGenreSortAscending, kTypeBoolean, booleanValue: musicLibraryGenreSortAscending);
    }
    if (musicLibraryGenreSortType != null) {
      _musicLibraryGenreSortType = musicLibraryGenreSortType;
      await db.setValue(_kKeyMusicLibraryGenreSortType, kTypeInteger, integerValue: musicLibraryGenreSortType.index);
    }
    if (musicLibraryMinimumFileSize != null) {
      _musicLibraryMinimumFileSize = musicLibraryMinimumFileSize;
      await db.setValue(_kKeyMusicLibraryMinimumFileSize, kTypeInteger, integerValue: musicLibraryMinimumFileSize);
    }
    if (musicLibraryRefreshOnLaunch != null) {
      _musicLibraryRefreshOnLaunch = musicLibraryRefreshOnLaunch;
      await db.setValue(_kKeyMusicLibraryRefreshOnLaunch, kTypeBoolean, booleanValue: musicLibraryRefreshOnLaunch);
    }
    if (musicLibraryTab != null) {
      _musicLibraryTab = musicLibraryTab;
      await db.setValue(_kKeyMusicLibraryTab, kTypeInteger, integerValue: musicLibraryTab);
    }
    if (musicLibraryTrackSortAscending != null) {
      _musicLibraryTrackSortAscending = musicLibraryTrackSortAscending;
      await db.setValue(_kKeyMusicLibraryTrackSortAscending, kTypeBoolean, booleanValue: musicLibraryTrackSortAscending);
    }
    if (musicLibraryTrackSortType != null) {
      _musicLibraryTrackSortType = musicLibraryTrackSortType;
      await db.setValue(_kKeyMusicLibraryTrackSortType, kTypeInteger, integerValue: musicLibraryTrackSortType.index);
    }
    if (notificationLyrics != null) {
      _notificationLyrics = notificationLyrics;
      await db.setValue(_kKeyNotificationLyrics, kTypeBoolean, booleanValue: notificationLyrics);
    }
    if (themeDynamicColor != null) {
      _themeDynamicColor = themeDynamicColor;
      await db.setValue(_kKeyThemeDynamicColor, kTypeBoolean, booleanValue: themeDynamicColor);
    }
    if (themeMaterialVersion != null) {
      _themeMaterialVersion = themeMaterialVersion;
      await db.setValue(_kKeyThemeMaterialVersion, kTypeInteger, integerValue: themeMaterialVersion);
    }
    if (themeMode != null) {
      _themeMode = themeMode;
      await db.setValue(_kKeyThemeMode, kTypeInteger, integerValue: themeMode.index);
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
      } else if (value is String) {
        await db.setValueIfAbsent(key, kTypeString, stringValue: value);
      } else {
        await db.setValueIfAbsent(key, kTypeJson, jsonValue: value);
      }
    }

    _animationDuration = AnimationDuration.fromJson(await db.getJson(_kKeyAnimationDuration));
    _audioFormatDisplay = await db.getBoolean(_kKeyAudioFormatDisplay);
    _discordRPC = await db.getBoolean(_kKeyDiscordRPC);
    _fallbackAlbumArt = await db.getBoolean(_kKeyFallbackAlbumArt);
    _language = LanguageData.fromJson(await db.getJson(_kKeyLanguage));
    _launchNowPlayingOnFileOpen = await db.getBoolean(_kKeyLaunchNowPlayingOnFileOpen);
    _lrcFromDirectory = await db.getBoolean(_kKeyLRCFromDirectory);
    _mobileAlbumGridSpanCount = await db.getInteger(_kKeyMobileAlbumGridSpanCount);
    _mobileArtistGridSpanCount = await db.getInteger(_kKeyMobileArtistGridSpanCount);
    _mobileGenreGridSpanCount = await db.getInteger(_kKeyMobileGenreGridSpanCount);
    _mobileNowPlayingRipple = await db.getBoolean(_kKeyMobileNowPlayingRipple);
    _mobileNowPlayingSlider = await db.getBoolean(_kKeyMobileNowPlayingSlider);
    _modernNowPlaying = await db.getBoolean(_kKeyModernNowPlaying);
    _modernNowPlayingCarousel = await db.getInteger(_kKeyModernNowPlayingCarousel);
    _modernNowPlayingHighlightedLyricsSize = await db.getInteger(_kKeyModernNowPlayingHighlightedLyricsSize);
    _modernNowPlayingUnhighlightedLyricsSize = await db.getInteger(_kKeyModernNowPlayingUnhighlightedLyricsSize);
    _modernNowPlayingLyrics = await db.getBoolean(_kKeyModernNowPlayingLyrics);
    _mpvOptions = Map<String, String>.from(await db.getJson(_kKeyMpvOptions));
    _mpvPath = await db.getString(_kKeyMpvPath);
    _musicLibraryAddTracksToPlaylist = await db.getBoolean(_kKeyMusicLibraryAddTracksToPlaylist);
    _musicLibraryAlbumGroupingParameters = (await db.getJson(_kKeyMusicLibraryAlbumGroupingParameters)).map((e) => AlbumGroupingParameter.values[e]).toSet();
    _musicLibraryAlbumSortAscending = await db.getBoolean(_kKeyMusicLibraryAlbumSortAscending);
    _musicLibraryAlbumSortType = AlbumSortType.values[(await db.getInteger(_kKeyMusicLibraryAlbumSortType))!];
    _musicLibraryArtistSortAscending = await db.getBoolean(_kKeyMusicLibraryArtistSortAscending);
    _musicLibraryArtistSortType = ArtistSortType.values[(await db.getInteger(_kKeyMusicLibraryArtistSortType))!];
    _musicLibraryDirectories = (await db.getJson(_kKeyMusicLibraryDirectories)).map((e) => Directory(e)).toSet();
    _musicLibraryGenreSortAscending = await db.getBoolean(_kKeyMusicLibraryGenreSortAscending);
    _musicLibraryGenreSortType = GenreSortType.values[(await db.getInteger(_kKeyMusicLibraryGenreSortType))!];
    _musicLibraryMinimumFileSize = await db.getInteger(_kKeyMusicLibraryMinimumFileSize);
    _musicLibraryRefreshOnLaunch = await db.getBoolean(_kKeyMusicLibraryRefreshOnLaunch);
    _musicLibraryTab = await db.getInteger(_kKeyMusicLibraryTab);
    _musicLibraryTrackSortAscending = await db.getBoolean(_kKeyMusicLibraryTrackSortAscending);
    _musicLibraryTrackSortType = TrackSortType.values[(await db.getInteger(_kKeyMusicLibraryTrackSortType))!];
    _notificationLyrics = await db.getBoolean(_kKeyNotificationLyrics);
    _themeDynamicColor = await db.getBoolean(_kKeyThemeDynamicColor);
    _themeMaterialVersion = await db.getInteger(_kKeyThemeMaterialVersion);
    _themeMode = ThemeMode.values[(await db.getInteger(_kKeyThemeMode))!];
    _windowsTaskbarProgress = await db.getBoolean(_kKeyWindowsTaskbarProgress);
  }

  Future<Map<String, dynamic>> getDefaults() async {
    return {
      /* JSON    */ _kKeyAnimationDuration: AnimationDuration(),
      /* Boolean */ _kKeyAudioFormatDisplay: true,
      /* Boolean */ _kKeyDiscordRPC: true,
      /* Boolean */ _kKeyFallbackAlbumArt: false,
      /* JSON    */ _kKeyLanguage: LanguageData(code: 'en-US', name: 'English (United States)', country: 'United States'),
      /* Boolean */ _kKeyLaunchNowPlayingOnFileOpen: isDesktop,
      /* Boolean */ _kKeyLRCFromDirectory: false,
      /* Integer */ _kKeyMobileAlbumGridSpanCount: 2,
      /* Integer */ _kKeyMobileArtistGridSpanCount: 3,
      /* Integer */ _kKeyMobileGenreGridSpanCount: 3,
      /* Boolean */ _kKeyMobileNowPlayingRipple: true,
      /* Boolean */ _kKeyMobileNowPlayingSlider: true,
      /* Boolean */ _kKeyModernNowPlaying: true,
      /* Integer */ _kKeyModernNowPlayingCarousel: 0,
      /* Integer */ _kKeyModernNowPlayingHighlightedLyricsSize: 32,
      /* Integer */ _kKeyModernNowPlayingUnhighlightedLyricsSize: 14,
      /* Boolean */ _kKeyModernNowPlayingLyrics: true,
      /* JSON    */ _kKeyMpvOptions: <String, String>{},
      /* String  */ _kKeyMpvPath: '',
      /* Boolean */ _kKeyMusicLibraryAddTracksToPlaylist: true,
      /* JSON    */ _kKeyMusicLibraryAlbumGroupingParameters: [AlbumGroupingParameter.album.index],
      /* Boolean */ _kKeyMusicLibraryAlbumSortAscending: true,
      /* Integer */ _kKeyMusicLibraryAlbumSortType: AlbumSortType.album.index,
      /* Boolean */ _kKeyMusicLibraryArtistSortAscending: true,
      /* Integer */ _kKeyMusicLibraryArtistSortType: ArtistSortType.artist.index,
      /* JSON    */ _kKeyMusicLibraryDirectories: [await getDefaultMusicLibraryDirectory()],
      /* Boolean */ _kKeyMusicLibraryGenreSortAscending: true,
      /* Integer */ _kKeyMusicLibraryGenreSortType: GenreSortType.genre.index,
      /* Integer */ _kKeyMusicLibraryMinimumFileSize: 0,
      /* Boolean */ _kKeyMusicLibraryRefreshOnLaunch: true,
      /* Integer */ _kKeyMusicLibraryTab: 0,
      /* Boolean */ _kKeyMusicLibraryTrackSortAscending: true,
      /* Integer */ _kKeyMusicLibraryTrackSortType: TrackSortType.title.index,
      /* Boolean */ _kKeyNotificationLyrics: true,
      /* Boolean */ _kKeyThemeDynamicColor: true,
      /* Integer */ _kKeyThemeMaterialVersion: 2,
      /* Integer */ _kKeyThemeMode: ThemeMode.system.index,
      /* Boolean */ _kKeyWindowsTaskbarProgress: false,
    };
  }

  Future<String> getDefaultDirectory() async {
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
      return path.normalize(Platform.environment['HOME']!);
    } else if (Platform.isLinux) {
      return path.normalize(Platform.environment['HOME']!);
    } else if (Platform.isAndroid) {
      final result = await StorageRetriever.instance.cache;
      return result.path;
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  Future<String> getDefaultMusicLibraryDirectory() async {
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
      final result = await StorageRetriever.instance.external;
      return result.path;
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  // ----- Keys -----

  static const _kKeyAnimationDuration = 'ANIMATION_DURATION';
  static const _kKeyAudioFormatDisplay = 'AUDIO_FORMAT_DISPLAY';
  static const _kKeyDiscordRPC = 'DISCORD_RPC';
  static const _kKeyFallbackAlbumArt = 'FALLBACK_ALBUM_ART';
  static const _kKeyLanguage = 'LANGUAGE';
  static const _kKeyLaunchNowPlayingOnFileOpen = 'LAUNCH_NOW_PLAYING_ON_FILE_OPEN';
  static const _kKeyLRCFromDirectory = 'LRC_FROM_DIRECTORY';
  static const _kKeyMobileAlbumGridSpanCount = 'MOBILE_ALBUM_GRID_SPAN_COUNT';
  static const _kKeyMobileArtistGridSpanCount = 'MOBILE_ARTIST_GRID_SPAN_COUNT';
  static const _kKeyMobileGenreGridSpanCount = 'MOBILE_GENRE_GRID_SPAN_COUNT';
  static const _kKeyMobileNowPlayingRipple = 'MOBILE_NOW_PLAYING_RIPPLE';
  static const _kKeyMobileNowPlayingSlider = 'MOBILE_NOW_PLAYING_SLIDER';
  static const _kKeyModernNowPlaying = 'MODERN_NOW_PLAYING';
  static const _kKeyModernNowPlayingCarousel = 'MODERN_NOW_PLAYING_CAROUSEL';
  static const _kKeyModernNowPlayingHighlightedLyricsSize = 'MODERN_NOW_PLAYING_HIGHLIGHTED_LYRICS_SIZE';
  static const _kKeyModernNowPlayingUnhighlightedLyricsSize = 'MODERN_NOW_PLAYING_UNHIGHLIGHTED_LYRICS_SIZE';
  static const _kKeyModernNowPlayingLyrics = 'MODERN_NOW_PLAYING_LYRICS';
  static const _kKeyMpvOptions = 'MPV_OPTIONS';
  static const _kKeyMpvPath = 'MPV_PATH';
  static const _kKeyMusicLibraryAddTracksToPlaylist = 'MUSIC_LIBRARY_ADD_TRACKS_TO_PLAYLIST';
  static const _kKeyMusicLibraryAlbumGroupingParameters = 'MUSIC_LIBRARY_ALBUM_GROUPING_PARAMETERS';
  static const _kKeyMusicLibraryAlbumSortAscending = 'MUSIC_LIBRARY_ALBUM_SORT_ASCENDING';
  static const _kKeyMusicLibraryAlbumSortType = 'MUSIC_LIBRARY_ALBUM_SORT_TYPE';
  static const _kKeyMusicLibraryArtistSortAscending = 'MUSIC_LIBRARY_ARTIST_SORT_ASCENDING';
  static const _kKeyMusicLibraryArtistSortType = 'MUSIC_LIBRARY_ARTIST_SORT_TYPE';
  static const _kKeyMusicLibraryDirectories = 'MUSIC_LIBRARY_DIRECTORIES';
  static const _kKeyMusicLibraryGenreSortAscending = 'MUSIC_LIBRARY_GENRE_SORT_ASCENDING';
  static const _kKeyMusicLibraryGenreSortType = 'MUSIC_LIBRARY_GENRE_SORT_TYPE';
  static const _kKeyMusicLibraryMinimumFileSize = 'MUSIC_LIBRARY_MINIMUM_FILE_SIZE';
  static const _kKeyMusicLibraryRefreshOnLaunch = 'MUSIC_LIBRARY_REFRESH_ON_LAUNCH';
  static const _kKeyMusicLibraryTab = 'MUSIC_LIBRARY_TAB';
  static const _kKeyMusicLibraryTrackSortAscending = 'MUSIC_LIBRARY_TRACK_SORT_ASCENDING';
  static const _kKeyMusicLibraryTrackSortType = 'MUSIC_LIBRARY_TRACK_SORT_TYPE';
  static const _kKeyNotificationLyrics = 'NOTIFICATION_LYRICS';
  static const _kKeyThemeDynamicColor = 'THEME_DYNAMIC_COLOR';
  static const _kKeyThemeMaterialVersion = 'THEME_MATERIAL_VERSION';
  static const _kKeyThemeMode = 'THEME_MODE';
  static const _kKeyWindowsTaskbarProgress = 'WINDOWS_TASKBAR_PROGRESS';
}
