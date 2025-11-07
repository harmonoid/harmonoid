import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:identity/identity.dart';
import 'package:media_kit/media_kit.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/configuration/database/constants.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/state/lyrics_notifier.dart';
import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/state/now_playing_visuals_notifier.dart';
import 'package:harmonoid/state/theme_notifier.dart';
import 'package:harmonoid/ui/exception.dart';
import 'package:harmonoid/ui/harmonoid.dart';
import 'package:harmonoid/ui/splash.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/macos_storage_controller.dart';
import 'package:harmonoid/utils/window_lifecycle.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    HttpOverrides.global = _HttpOverrides();
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
  try {
    if (Platform.isAndroid) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: SystemUiOverlay.values);
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      await AndroidStorageController.ensureInitialized();
      if (AndroidStorageController.instance.version >= 33) {
        if (await Permission.audio.isDenied || await Permission.audio.isPermanentlyDenied) {
          final state = await Permission.audio.request();
          if (!state.isGranted) {
            await SystemNavigator.pop();
          }
        }
      } else {
        if (await Permission.storage.isDenied || await Permission.storage.isPermanentlyDenied) {
          final state = await Permission.storage.request();
          if (!state.isGranted) {
            await SystemNavigator.pop();
          }
        }
      }
    }
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      await WindowPlus.ensureInitialized(
        application: kApplication,
        enableEventStreams: false,
      );
      await WindowPlus.instance.setMinimumSize(const Size(1024.0, 600.0));
      WindowLifecycle.ensureInitialized();
      runApp(const SplashApp());
    }

    await Configuration.ensureInitialized();

    // HACK:
    if (Platform.isMacOS) {
      await MacOSStorageController.ensureInitialized(directories: Configuration.instance.mediaLibraryDirectories);
    }

    MediaKit.ensureInitialized(libmpv: Configuration.instance.mpvPath.nullIfBlank());
    await Localization.ensureInitialized(localization: Configuration.instance.localization);
    await MediaLibrary.ensureInitialized(
      cache: Configuration.instance.directory,
      directories: Configuration.instance.mediaLibraryDirectories,
      albumSortType: Configuration.instance.mediaLibraryAlbumSortType,
      artistSortType: Configuration.instance.mediaLibraryArtistSortType,
      genreSortType: Configuration.instance.mediaLibraryGenreSortType,
      trackSortType: Configuration.instance.mediaLibraryTrackSortType,
      albumSortAscending: Configuration.instance.mediaLibraryAlbumSortAscending,
      artistSortAscending: Configuration.instance.mediaLibraryArtistSortAscending,
      genreSortAscending: Configuration.instance.mediaLibraryGenreSortAscending,
      trackSortAscending: Configuration.instance.mediaLibraryTrackSortAscending,
      minimumFileSize: Configuration.instance.mediaLibraryMinimumFileSize,
      albumGroupingParameters: Configuration.instance.mediaLibraryAlbumGroupingParameters,
    );
    await MediaPlayer.ensureInitialized();
    await Intent.ensureInitialized(args: args);
    await ThemeNotifier.ensureInitialized(
      themeMode: Configuration.instance.themeMode,
      materialStandard: Configuration.instance.themeMaterialStandard,
      systemColorScheme: Configuration.instance.themeSystemColorScheme,
      animationDuration: Configuration.instance.themeAnimationDuration,
    );
    await LyricsNotifier.ensureInitialized();
    await NowPlayingVisualsNotifier.ensureInitialized();
    await NowPlayingColorPaletteNotifier.ensureInitialized();
    await IdentityNotifier.ensureInitialized(
      getItem: (key) => Configuration.instance.db.getString(key),
      setItem: (key, value) => Configuration.instance.db.setValue(key, kTypeString, stringValue: value),
      removeItem: (key) => Configuration.instance.db.remove(key),
    );
    runApp(const Harmonoid());
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
    runApp(ExceptionApp(exception: exception, stacktrace: stacktrace));
  }
}

class _HttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (cert, host, port) => true;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    environment ??= Platform.environment;
    return super.findProxyFromEnvironment(url, environment);
  }
}
