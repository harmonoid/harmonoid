import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/state/lyrics_notifier.dart';
import 'package:harmonoid/state/now_playing_visuals_notifier.dart';
import 'package:harmonoid/state/theme_notifier.dart';
import 'package:harmonoid/ui/harmonoid.dart';
import 'package:harmonoid/ui/exception.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';
import 'package:harmonoid/utils/constants.dart';
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
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );
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
    if (Platform.isLinux) {
      await WindowPlus.ensureInitialized(
        application: kApplication,
        enableEventStreams: false,
      );
      await WindowPlus.instance.setMinimumSize(const Size(960.0, 640.0));
      WindowLifecycle.ensureInitialized();
    }
    if (Platform.isWindows) {
      await WindowPlus.ensureInitialized(
        application: kApplication,
        enableEventStreams: false,
      );
      await WindowPlus.instance.setMinimumSize(const Size(960.0, 640.0));
      WindowLifecycle.ensureInitialized();
    }
    MediaKit.ensureInitialized();
    await Configuration.ensureInitialized();
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
      materialVersion: Configuration.instance.themeMaterialVersion,
      systemColorScheme: Configuration.instance.themeSystemColorScheme,
      animationDuration: Configuration.instance.animationDuration,
    );
    await LyricsNotifier.ensureInitialized();
    await NowPlayingVisualsNotifier.ensureInitialized();
    await Language.ensureInitialized(
      language: Configuration.instance.language,
    );
    runApp(const Harmonoid());
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
    try {
      await WindowPlus.ensureInitialized(
        application: kApplication,
        enableEventStreams: false,
      );
      await WindowPlus.instance.setMinimumSize(const Size(960.0, 640.0));
      WindowLifecycle.ensureInitialized();
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
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
