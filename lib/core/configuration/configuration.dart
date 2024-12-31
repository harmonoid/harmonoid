import 'dart:ffi';
import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:win32/win32.dart';

import 'package:harmonoid/localization/localization_data.dart';
import 'package:harmonoid/core/configuration/database/constants.dart';
import 'package:harmonoid/core/configuration/database/database.dart';
import 'package:harmonoid/models/playback_state.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';
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

    _desktopNowPlayingBarColorPalette = await db.getBoolean(kKeyDesktopNowPlayingBarColorPalette);
    _desktopNowPlayingCarousel = await db.getInteger(kKeyDesktopNowPlayingCarousel);
    _desktopNowPlayingLyrics = await db.getBoolean(kKeyDesktopNowPlayingLyrics);
    _discordRpc = await db.getBoolean(kKeyDiscordRpc);
    _identifier = await db.getString(kKeyIdentifier);
    _localization = LocalizationData.fromJson(await db.getJson(kKeyLocalization));
    _lrcFromDirectory = await db.getBoolean(kKeyLrcFromDirectory);
    _lyricsViewFocusedFontSize = await db.getDouble(kKeyLyricsViewFocusedFontSize);
    _lyricsViewFocusedLineHeight = await db.getDouble(kKeyLyricsViewFocusedLineHeight);
    _lyricsViewTextAlign = TextAlign.values[(await db.getInteger(kKeyLyricsViewTextAlign))!];
    _lyricsViewUnfocusedFontSize = await db.getDouble(kKeyLyricsViewUnfocusedFontSize);
    _lyricsViewUnfocusedLineHeight = await db.getDouble(kKeyLyricsViewUnfocusedLineHeight);
    _mediaLibraryAddPlaylistToNowPlaying = await db.getBoolean(kKeyMediaLibraryAddPlaylistToNowPlaying);
    _mediaLibraryAlbumGroupingParameters = (await db.getJson(kKeyMediaLibraryAlbumGroupingParameters)).map<AlbumGroupingParameter>((e) => AlbumGroupingParameter.values[e]).toSet();
    _mediaLibraryAlbumSortAscending = await db.getBoolean(kKeyMediaLibraryAlbumSortAscending);
    _mediaLibraryAlbumSortType = AlbumSortType.values[(await db.getInteger(kKeyMediaLibraryAlbumSortType))!];
    _mediaLibraryArtistSortAscending = await db.getBoolean(kKeyMediaLibraryArtistSortAscending);
    _mediaLibraryArtistSortType = ArtistSortType.values[(await db.getInteger(kKeyMediaLibraryArtistSortType))!];
    _mediaLibraryCoverFallback = await db.getBoolean(kKeyMediaLibraryCoverFallback);
    _mediaLibraryDesktopTracksScreenColumnWidths = Map<String, double>.from(await db.getJson(kKeyMediaLibraryDesktopTracksScreenColumnWidths));
    _mediaLibraryDirectories = (await db.getJson(kKeyMediaLibraryDirectories)).map<Directory>((e) => Directory(e)).toSet();
    _mediaLibraryGenreSortAscending = await db.getBoolean(kKeyMediaLibraryGenreSortAscending);
    _mediaLibraryGenreSortType = GenreSortType.values[(await db.getInteger(kKeyMediaLibraryGenreSortType))!];
    _mediaLibraryMinimumFileSize = await db.getInteger(kKeyMediaLibraryMinimumFileSize);
    _mediaLibraryPath = await db.getString(kKeyMediaLibraryPath);
    _mediaLibraryRefreshUponStart = await db.getBoolean(kKeyMediaLibraryRefreshUponStart);
    _mediaLibraryTrackSortAscending = await db.getBoolean(kKeyMediaLibraryTrackSortAscending);
    _mediaLibraryTrackSortType = TrackSortType.values[(await db.getInteger(kKeyMediaLibraryTrackSortType))!];
    _mediaPlayerPlaybackState = PlaybackState.fromJson(await db.getJson(kKeyMediaPlayerPlaybackState));
    _mobileMediaLibraryAlbumGridSpan = await db.getInteger(kKeyMobileMediaLibraryAlbumGridSpan);
    _mobileMediaLibraryArtistGridSpan = await db.getInteger(kKeyMobileMediaLibraryArtistGridSpan);
    _mobileMediaLibraryGenreGridSpan = await db.getInteger(kKeyMobileMediaLibraryGenreGridSpan);
    _mobileNowPlayingRipple = await db.getBoolean(kKeyMobileNowPlayingRipple);
    _mobileNowPlayingVolumeSlider = await db.getBoolean(kKeyMobileNowPlayingVolumeSlider);
    _mpvOptions = Map<String, String>.from(await db.getJson(kKeyMpvOptions));
    _mpvPath = await db.getString(kKeyMpvPath);
    _notificationLyrics = await db.getBoolean(kKeyNotificationLyrics);
    _nowPlayingAudioFormat = await db.getBoolean(kKeyNowPlayingAudioFormat);
    _nowPlayingDisplayUponPlay = await db.getBoolean(kKeyNowPlayingDisplayUponPlay);
    _themeAnimationDuration = AnimationDuration.fromJson(await db.getJson(kKeyThemeAnimationDuration));
    _themeMaterialStandard = await db.getInteger(kKeyThemeMaterialStandard);
    _themeMode = ThemeMode.values[(await db.getInteger(kKeyThemeMode))!];
    _themeSystemColorScheme = await db.getBoolean(kKeyThemeSystemColorScheme);
    _windowsTaskbarProgress = await db.getBoolean(kKeyWindowsTaskbarProgress);
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
        KNOWN_FOLDER_FLAG.KF_FLAG_DEFAULT,
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
    final result = await AndroidStorageController.instance.getStorageDirectories();
    return [path.normalize(result.first.path)];
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
        KNOWN_FOLDER_FLAG.KF_FLAG_DEFAULT,
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
