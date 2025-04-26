import 'dart:ffi';
import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:lastfm/lastfm.dart';
import 'package:media_library/media_library.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:win32/win32.dart';

import 'package:harmonoid/core/configuration/database/constants.dart';
import 'package:harmonoid/core/configuration/database/database.dart';
import 'package:harmonoid/localization/localization_data.dart';
import 'package:harmonoid/mappers/media_player_state.dart';
import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playback_state.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/macos_storage_controller.dart';

part 'configuration.g.dart';

/// {@template configuration}
///
/// Configuration
/// -------------
/// Implementation to retrieve & save persistent configuration & settings.
///
/// {@endtemplate}
class Configuration extends ConfigurationBase {
  /// Singleton instance.
  static late final Configuration instance;

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro configuration}
  Configuration._(Directory directory) : super(directory: directory, db: Database(directory));

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
      } else if (value is double) {
        await db.setValueIfAbsent(key, kTypeDouble, doubleValue: value);
      } else if (value is String) {
        await db.setValueIfAbsent(key, kTypeString, stringValue: value);
      } else {
        await db.setValueIfAbsent(key, kTypeJson, jsonValue: value);
      }
    }

    _apiBaseUrl = await _read<String, String>(kKeyApiBaseUrl, defaults);
    _desktopNowPlayingBarColorPalette = await _read<bool, bool>(kKeyDesktopNowPlayingBarColorPalette, defaults);
    _desktopNowPlayingCarousel = await _read<int, int>(kKeyDesktopNowPlayingCarousel, defaults);
    _desktopNowPlayingLyrics = await _read<bool, bool>(kKeyDesktopNowPlayingLyrics, defaults);
    _discordRpc = await _read<bool, bool>(kKeyDiscordRpc, defaults);
    _identifier = await _read<String, String>(kKeyIdentifier, defaults);
    _lastfmSession = await _read<dynamic, Session>(kKeyLastfmSession, defaults, (value) => Session.fromJson(value));
    _localization = await _read<dynamic, LocalizationData>(kKeyLocalization, defaults, (value) => LocalizationData.fromJson(value));
    _lrcFromDirectory = await _read<bool, bool>(kKeyLrcFromDirectory, defaults);
    _lyricsViewFocusedFontSize = await _read<double, double>(kKeyLyricsViewFocusedFontSize, defaults);
    _lyricsViewFocusedLineHeight = await _read<double, double>(kKeyLyricsViewFocusedLineHeight, defaults);
    _lyricsViewTextAlign = await _read<int, TextAlign>(kKeyLyricsViewTextAlign, defaults, (value) => TextAlign.values[value]);
    _lyricsViewUnfocusedFontSize = await _read<double, double>(kKeyLyricsViewUnfocusedFontSize, defaults);
    _lyricsViewUnfocusedLineHeight = await _read<double, double>(kKeyLyricsViewUnfocusedLineHeight, defaults);
    _mediaLibraryAddPlaylistToNowPlaying = await _read<bool, bool>(kKeyMediaLibraryAddPlaylistToNowPlaying, defaults);
    _mediaLibraryAlbumGroupingParameters = await _read<dynamic, Set<AlbumGroupingParameter>>(kKeyMediaLibraryAlbumGroupingParameters, defaults, (value) => value.map<AlbumGroupingParameter>((e) => AlbumGroupingParameter.values[e]).toSet());
    _mediaLibraryAlbumSortAscending = await _read<bool, bool>(kKeyMediaLibraryAlbumSortAscending, defaults);
    _mediaLibraryAlbumSortType = await _read<int, AlbumSortType>(kKeyMediaLibraryAlbumSortType, defaults, (value) => AlbumSortType.values[value]);
    _mediaLibraryArtistSortAscending = await _read<bool, bool>(kKeyMediaLibraryArtistSortAscending, defaults);
    _mediaLibraryArtistSortType = await _read<int, ArtistSortType>(kKeyMediaLibraryArtistSortType, defaults, (value) => ArtistSortType.values[value]);
    _mediaLibraryCoverFallback = await _read<bool, bool>(kKeyMediaLibraryCoverFallback, defaults);
    _mediaLibraryDesktopTracksScreenColumnWidths = await _read<dynamic, Map<String, double>>(kKeyMediaLibraryDesktopTracksScreenColumnWidths, defaults, (value) => Map<String, double>.from(value));
    _mediaLibraryDirectories = await _read<dynamic, Set<Directory>>(kKeyMediaLibraryDirectories, defaults, (value) => value.map<Directory>((e) => Directory(e)).toSet());
    _mediaLibraryGenreSortAscending = await _read<bool, bool>(kKeyMediaLibraryGenreSortAscending, defaults);
    _mediaLibraryGenreSortType = await _read<int, GenreSortType>(kKeyMediaLibraryGenreSortType, defaults, (value) => GenreSortType.values[value]);
    _mediaLibraryMinimumFileSize = await _read<int, int>(kKeyMediaLibraryMinimumFileSize, defaults);
    _mediaLibraryPath = await _read<String, String>(kKeyMediaLibraryPath, defaults);
    _mediaLibraryRefreshUponStart = await _read<bool, bool>(kKeyMediaLibraryRefreshUponStart, defaults);
    _mediaLibraryTrackSortAscending = await _read<bool, bool>(kKeyMediaLibraryTrackSortAscending, defaults);
    _mediaLibraryTrackSortType = await _read<int, TrackSortType>(kKeyMediaLibraryTrackSortType, defaults, (value) => TrackSortType.values[value]);
    _mediaPlayerPlaybackState = await _read<dynamic, PlaybackState>(kKeyMediaPlayerPlaybackState, defaults, (value) => PlaybackState.fromJson(value));
    _mobileMediaLibraryAlbumGridSpan = await _read<int, int>(kKeyMobileMediaLibraryAlbumGridSpan, defaults);
    _mobileMediaLibraryArtistGridSpan = await _read<int, int>(kKeyMobileMediaLibraryArtistGridSpan, defaults);
    _mobileMediaLibraryGenreGridSpan = await _read<int, int>(kKeyMobileMediaLibraryGenreGridSpan, defaults);
    _mobileNowPlayingRipple = await _read<bool, bool>(kKeyMobileNowPlayingRipple, defaults);
    _mobileNowPlayingVolumeSlider = await _read<bool, bool>(kKeyMobileNowPlayingVolumeSlider, defaults);
    _mpvOptions = await _read<dynamic, Map<String, String>>(kKeyMpvOptions, defaults, (value) => Map<String, String>.from(value));
    _mpvPath = await _read<String, String>(kKeyMpvPath, defaults);
    _notificationLyrics = await _read<bool, bool>(kKeyNotificationLyrics, defaults);
    _nowPlayingAudioFormat = await _read<bool, bool>(kKeyNowPlayingAudioFormat, defaults);
    _nowPlayingDisplayUponPlay = await _read<bool, bool>(kKeyNowPlayingDisplayUponPlay, defaults);
    _themeAnimationDuration = await _read<dynamic, AnimationDuration>(kKeyThemeAnimationDuration, defaults, (value) => AnimationDuration.fromJson(value));
    _themeMaterialStandard = await _read<int, int>(kKeyThemeMaterialStandard, defaults);
    _themeMode = await _read<int, ThemeMode>(kKeyThemeMode, defaults, (value) => ThemeMode.values[value]);
    _themeSystemColorScheme = await _read<bool, bool>(kKeyThemeSystemColorScheme, defaults);
    _updateCheckVersion = await _read<String, String>(kKeyUpdateCheckVersion, defaults);
    _windowsTaskbarProgress = await _read<bool, bool>(kKeyWindowsTaskbarProgress, defaults);
  }

  Future<O> _read<I, O>(String key, Map<String, dynamic> defaults, [O Function(I)? map]) async {
    if (I == O) {
      map ??= (value) => value as O;
    } else if (map == null) {
      throw ArgumentError();
    }
    try {
      final I i = await switch (I) {
        const (bool) => db.getBoolean(key),
        const (int) => db.getInteger(key),
        const (double) => await db.getDouble(key),
        const (String) => await db.getString(key),
        _ => await db.getJson(key),
      };
      return map(i);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      return defaults[key];
    }
  }
}

/// Returns the default directory to save the application data.
Future<String> getDefaultDirectory() async {
  if (Platform.isAndroid) {
    final result = await AndroidStorageController.instance.getCacheDirectory();
    return path.normalize(result.path);
  } else if (Platform.isLinux) {
    final result = Platform.environment['HOME'];
    return path.normalize(result!);
  } else if (Platform.isMacOS) {
    final result = await path.getApplicationSupportDirectory();
    return path.normalize(result.path);
  } else if (Platform.isWindows) {
    String? value;

    final rfid = GUIDFromString(FOLDERID_Profile);
    final result = calloc<PWSTR>();
    try {
      final hr = SHGetKnownFolderPath(
        rfid,
        KF_FLAG_DEFAULT,
        NULL,
        result,
      );
      if (SUCCEEDED(hr)) {
        value ??= path.normalize(result.value.toDartString());
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    } finally {
      calloc.free(rfid);
      calloc.free(result);
    }

    try {
      final result = Platform.environment['USERPROFILE'];
      if (result != null) {
        value ??= path.normalize(result);
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    return value!;
  }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}

/// Returns the default directories to scan the media files.
Future<List<String>> getDefaultMediaLibraryDirectories() async {
  if (Platform.isAndroid) {
    final result = await AndroidStorageController.instance.getDefaultMediaLibraryDirectory();
    return [path.normalize(result.path)];
  } else if (Platform.isLinux) {
    String? value;

    try {
      final result = await Process.run('xdg-user-dir', ['MUSIC']);
      if (result.exitCode == 0) {
        value ??= path.normalize(result.stdout.toString().trim());
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    try {
      final result = Platform.environment['XDG_MUSIC_DIR'];
      if (result != null) {
        value ??= path.normalize(result);
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    try {
      final result = Platform.environment['HOME'];
      if (result != null) {
        value ??= path.join(path.normalize(result), 'Music');
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    return [value!];
  } else if (Platform.isMacOS) {
    final result = await MacOSStorageController.instance.getDefaultMediaLibraryDirectory();
    return [if (result != null) result.path];
  } else if (Platform.isWindows) {
    String? value;

    final rfid = GUIDFromString(FOLDERID_Music);
    final result = calloc<PWSTR>();

    try {
      final hr = SHGetKnownFolderPath(
        rfid,
        KF_FLAG_DEFAULT,
        NULL,
        result,
      );
      if (SUCCEEDED(hr)) {
        value ??= path.normalize(result.value.toDartString());
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    } finally {
      calloc.free(rfid);
      calloc.free(result);
    }

    try {
      final result = Platform.environment['USERPROFILE'];
      if (result != null) {
        value ??= path.join(path.normalize(result), 'Music');
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    return [value!];
  }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}

extension on Set<AlbumGroupingParameter> {
  List<int> toJson() => map((e) => e.index).toList();
}

extension on Set<Directory> {
  List<String> toJson() => map((e) => e.path).toList();
}
