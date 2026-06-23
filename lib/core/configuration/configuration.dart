import 'dart:ffi';
import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
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
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/media_player_state.dart';
import 'package:harmonoid/models/language.dart';
import 'package:harmonoid/models/media_library_tab.dart';
import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playback_state.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/darwin_storage_controller.dart';

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
    if (Platform.environment['HARMONOID_CACHE_DIRECTORY'] == null) {
      // Default directory.
      const directoryName = '.Harmonoid';
      final defaultDirectory = Directory(path.join(await getDefaultDirectory(), directoryName));
      final legacyDefaultDirectory = Directory(path.join(await getLegacyDefaultDirectory(), directoryName));
      directory = await legacyDefaultDirectory.exists_() ? legacyDefaultDirectory : defaultDirectory;
    } else {
      // HARMONOID_CACHE_DIRECTORY
      directory = Directory(Platform.environment['HARMONOID_CACHE_DIRECTORY']!);
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

    _apiBaseUrl = await read<String, String>(kKeyApiBaseUrl, defaults);
    _desktopMediaLibraryFoldersScreenColumnWidths = await read<dynamic, List<double>>(kKeyDesktopMediaLibraryFoldersScreenColumnWidths, defaults, (value) => List<double>.from(value));
    _desktopMediaLibraryTracksScreenColumnWidths = await read<dynamic, List<double>>(kKeyDesktopMediaLibraryTracksScreenColumnWidths, defaults, (value) => List<double>.from(value));
    _desktopNowPlayingBarColorPalette = await read<bool, bool>(kKeyDesktopNowPlayingBarColorPalette, defaults);
    _desktopNowPlayingCarousel = await read<int, int>(kKeyDesktopNowPlayingCarousel, defaults);
    _desktopNowPlayingLyrics = await read<bool, bool>(kKeyDesktopNowPlayingLyrics, defaults);
    _discordRpc = await read<bool, bool>(kKeyDiscordRpc, defaults);
    _identifier = await read<String, String>(kKeyIdentifier, defaults);
    _lastfmSession = await read<dynamic, Session>(kKeyLastfmSession, defaults, (value) => Session.fromJson(value));
    _localization = await read<dynamic, LocalizationData>(kKeyLocalization, defaults, (value) => LocalizationData.fromJson(value));
    _lrcFromDirectory = await read<bool, bool>(kKeyLrcFromDirectory, defaults);
    _lyricsViewFocusedFontSize = await read<double, double>(kKeyLyricsViewFocusedFontSize, defaults);
    _lyricsViewFocusedLineHeight = await read<double, double>(kKeyLyricsViewFocusedLineHeight, defaults);
    _lyricsViewFontFamily = await read<String, String>(kKeyLyricsViewFontFamily, defaults);
    _lyricsViewTextAlign = await read<int, TextAlign>(kKeyLyricsViewTextAlign, defaults, (value) => TextAlign.values[value]);
    _lyricsViewUnfocusedFontSize = await read<double, double>(kKeyLyricsViewUnfocusedFontSize, defaults);
    _lyricsViewUnfocusedLineHeight = await read<double, double>(kKeyLyricsViewUnfocusedLineHeight, defaults);
    _lyricsTranslationLanguage = await read<dynamic, Language>(kKeyLyricsTranslationLanguage, defaults, (value) => Language.fromJson(value));
    _mediaLibraryAddPlaylistToNowPlaying = await read<bool, bool>(kKeyMediaLibraryAddPlaylistToNowPlaying, defaults);
    _mediaLibraryAlbumGroupingParameters = await read<dynamic, Set<AlbumGroupingParameter>>(kKeyMediaLibraryAlbumGroupingParameters, defaults, (value) => value.map<AlbumGroupingParameter>((e) => AlbumGroupingParameter.values[e]).toSet());
    _mediaLibraryAlbumSortAscending = await read<bool, bool>(kKeyMediaLibraryAlbumSortAscending, defaults);
    _mediaLibraryAlbumSortType = await read<int, AlbumSortType>(kKeyMediaLibraryAlbumSortType, defaults, (value) => AlbumSortType.values[value]);
    _mediaLibraryArtistImages = await read<bool, bool>(kKeyMediaLibraryArtistImages, defaults);
    _mediaLibraryArtistSortAscending = await read<bool, bool>(kKeyMediaLibraryArtistSortAscending, defaults);
    _mediaLibraryArtistSortType = await read<int, ArtistSortType>(kKeyMediaLibraryArtistSortType, defaults, (value) => ArtistSortType.values[value]);
    _mediaLibraryCoverFallback = await read<bool, bool>(kKeyMediaLibraryCoverFallback, defaults);
    _mediaLibraryDirectories = await read<dynamic, Set<Directory>>(kKeyMediaLibraryDirectories, defaults, (value) => value.map<Directory>((e) => Directory(e)).toSet());
    _mediaLibraryFolderFileExplorerViewType = await read<int, FileExplorerViewType>(kKeyMediaLibraryFolderFileExplorerViewType, defaults, (value) => FileExplorerViewType.values[value]);
    _mediaLibraryFolderFileExplorerSortType = await read<int, FileExplorerSortType>(kKeyMediaLibraryFolderFileExplorerSortType, defaults, (value) => FileExplorerSortType.values[value]);
    _mediaLibraryFolderFileExplorerSortAscending = await read<bool, bool>(kKeyMediaLibraryFolderFileExplorerSortAscending, defaults);
    _mediaLibraryFolderFileExplorerShowHiddenFiles = await read<bool, bool>(kKeyMediaLibraryFolderFileExplorerShowHiddenFiles, defaults);
    _mediaLibraryGenreSortAscending = await read<bool, bool>(kKeyMediaLibraryGenreSortAscending, defaults);
    _mediaLibraryGenreSortType = await read<int, GenreSortType>(kKeyMediaLibraryGenreSortType, defaults, (value) => GenreSortType.values[value]);
    _mediaLibraryHideSecondaryArtists = await read<bool, bool>(kKeyMediaLibraryHideSecondaryArtists, defaults);
    _mediaLibraryMinimumFileSize = await read<int, int>(kKeyMediaLibraryMinimumFileSize, defaults);
    _mediaLibraryPath = await read<String, String>(kKeyMediaLibraryPath, defaults);
    _mediaLibraryRefreshUponStart = await read<bool, bool>(kKeyMediaLibraryRefreshUponStart, defaults);
    _mediaLibraryTagReaderFallback = await read<bool, bool>(kKeyMediaLibraryTagReaderFallback, defaults);
    _mediaLibraryTrackSortAscending = await read<bool, bool>(kKeyMediaLibraryTrackSortAscending, defaults);
    _mediaLibraryTrackSortType = await read<int, TrackSortType>(kKeyMediaLibraryTrackSortType, defaults, (value) => TrackSortType.values[value]);
    _mediaLibraryVisibleTabs = await read<dynamic, Set<MediaLibraryTab>>(kKeyMediaLibraryVisibleTabs, defaults, (value) => value.map<MediaLibraryTab>((e) => MediaLibraryTab.values[e]).toSet());
    _mediaPlayerPlaybackState = await read<dynamic, PlaybackState>(kKeyMediaPlayerPlaybackState, defaults, (value) => PlaybackState.fromJson(value));
    _mobileMediaLibraryAlbumGridSpan = await read<int, int>(kKeyMobileMediaLibraryAlbumGridSpan, defaults);
    _mobileMediaLibraryArtistGridSpan = await read<int, int>(kKeyMobileMediaLibraryArtistGridSpan, defaults);
    _mobileMediaLibraryGenreGridSpan = await read<int, int>(kKeyMobileMediaLibraryGenreGridSpan, defaults);
    _mobileNotificationLyricsHidden = await read<bool, bool>(kKeyMobileNotificationLyricsHidden, defaults);
    _mobileNowPlayingRipple = await read<bool, bool>(kKeyMobileNowPlayingRipple, defaults);
    _mobileNowPlayingVolumeSlider = await read<bool, bool>(kKeyMobileNowPlayingVolumeSlider, defaults);
    _mpvOptions = await read<dynamic, Map<String, String>>(kKeyMpvOptions, defaults, (value) => Map<String, String>.from(value));
    _mpvPath = await read<String, String>(kKeyMpvPath, defaults);
    _notificationLyrics = await read<bool, bool>(kKeyNotificationLyrics, defaults);
    _nowPlayingAudioFormat = await read<bool, bool>(kKeyNowPlayingAudioFormat, defaults);
    _nowPlayingDisplayUponPlay = await read<bool, bool>(kKeyNowPlayingDisplayUponPlay, defaults);
    _nowPlayingLyricsFtuxCount = await read<int, int>(kKeyNowPlayingLyricsFtuxCount, defaults);
    _nowPlayingStartMixAfterEnding = await read<bool, bool>(kKeyNowPlayingStartMixAfterEnding, defaults);
    _themeAnimationDuration = await read<dynamic, AnimationDuration>(kKeyThemeAnimationDuration, defaults, (value) => AnimationDuration.fromJson(value));
    _themeMaterialStandard = await read<int, int>(kKeyThemeMaterialStandard, defaults);
    _themeMode = await read<int, ThemeMode>(kKeyThemeMode, defaults, (value) => ThemeMode.values[value]);
    _themeSystemColorScheme = await read<bool, bool>(kKeyThemeSystemColorScheme, defaults);
    _updateCheckVersion = await read<String, String>(kKeyUpdateCheckVersion, defaults);
    _windowsTaskbarProgress = await read<bool, bool>(kKeyWindowsTaskbarProgress, defaults);
  }

  Future<O> read<I, O>(String key, Map<String, dynamic> defaults, [O Function(I)? map]) async {
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

/// Returns the default localization.
Future<LocalizationData> getDefaultLocalization() async {
  try {
    final values = await Localization.instance.values;

    final locale = PlatformDispatcher.instance.locale;
    final languageCode = locale.languageCode.toLowerCase();
    final countryCode = locale.countryCode?.toUpperCase();

    LocalizationData? match;

    match ??= values.firstWhereOrNull((e) => e.code == '${languageCode}_$countryCode');
    match ??= values.firstWhereOrNull((e) => e.code.split('_').first == languageCode);

    return match!;
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
    return const LocalizationData(code: 'en_US', name: 'English', country: 'United States');
  }
}

/// Returns the default lyrics translation language.
Future<Language> getDefaultLyricsTranslationLanguage() {
  return getDefaultLocalization().then((value) => Language(code: value.code.split('_').first, name: value.name));
}

/// Returns the default directory to save the application data.
Future<String> getDefaultDirectory() async {
  if (Platform.isAndroid) {
    final result = await AndroidStorageController.instance.getCacheDirectory();
    return path.normalize(result.path);
  } else if (Platform.isIOS) {
    final result = await path.getApplicationSupportDirectory();
    return path.normalize(result.path);
  } else if (Platform.isLinux) {
    String? value;

    try {
      final result = Platform.environment['XDG_CONFIG_HOME'];
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
        value ??= path.normalize(result);
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    return value!;
  } else if (Platform.isMacOS) {
    final result = await path.getApplicationSupportDirectory();
    return path.normalize(result.path);
  } else if (Platform.isWindows) {
    String? value;

    final rfid = GUIDFromString(FOLDERID_LocalAppData);
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

/// Returns the legacy default directory to save the application data.
Future<String> getLegacyDefaultDirectory() async {
  if (Platform.isAndroid) {
    final result = await AndroidStorageController.instance.getCacheDirectory();
    return path.normalize(result.path);
  } else if (Platform.isIOS) {
    final result = await path.getApplicationSupportDirectory();
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
  } else if (Platform.isIOS || Platform.isMacOS) {
    final result = await DarwinStorageController.instance.getDefaultMediaLibraryDirectory();
    return [if (result != null) result.path];
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

extension on Set<MediaLibraryTab> {
  List<int> toJson() => map((e) => e.index).toList();
}
