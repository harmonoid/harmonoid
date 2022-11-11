/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/foundation.dart';
import 'package:window_plus/window_plus.dart';
import 'package:media_engine/media_engine.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/core/app_state.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/state/now_playing_visuals.dart';
import 'package:harmonoid/utils/updater.dart';
import 'package:harmonoid/utils/tagger_client.dart';
import 'package:harmonoid/utils/window_lifecycle.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/interface/harmonoid.dart';
import 'package:harmonoid/interface/exception.dart';
import 'package:harmonoid/constants/language.dart';

const String kApplication = 'com.alexmercerind.harmonoid';
const String kAuthor = 'Hitesh Kumar Saini <saini123hitesh@gmail.com>';
const String kCaption = 'Harmonoid Music';
const String kLicense = 'End-User License Agreement for Harmonoid';
const String kTitle = 'Harmonoid';
const String kVersion = 'v0.3.4';

Future<void> main(List<String> args) async {
  try {
    debugPrint(Platform.operatingSystemVersion);
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
  WidgetsFlutterBinding.ensureInitialized();
  try {
    HttpOverrides.global = _HttpOverrides();
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
  try {
    if (Platform.isWindows) {
      await WindowPlus.ensureInitialized(
        application: kApplication,
        enableEventStreams: false,
      );
      WindowLifecycle.initialize();
      await Configuration.initialize();
      await AppState.initialize();
      await NowPlayingVisuals.initialize();
      await MPV.initialize();
      if (kReleaseMode || kProfileMode) {
        await SystemMediaTransportControls.initialize();
      }
      await Intent.initialize(args: args);
      await HotKeys.initialize();
      DiscordRPC.initialize();
    }
    if (Platform.isLinux) {
      await WindowPlus.ensureInitialized(
        application: kApplication,
        enableEventStreams: false,
      );
      WindowLifecycle.initialize();
      await Configuration.initialize();
      await AppState.initialize();
      await NowPlayingVisuals.initialize();
      await MPV.initialize();
      await TaggerClient.initialize();
      await Intent.initialize(args: args);
      await HotKeys.initialize();
      DiscordRPC.initialize();
    }
    if (Platform.isAndroid) {
      await StorageRetriever.initialize();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarDividerColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
      // Android 12 or lower.
      if (StorageRetriever.instance.version < 33) {
        if (await Permission.storage.isDenied ||
            await Permission.storage.isPermanentlyDenied) {
          final state = await Permission.storage.request();
          if (!state.isGranted) {
            await SystemNavigator.pop(
              animated: true,
            );
          }
        }
      }
      // Android 13 or higher.
      else {
        if (await Permission.audio.isDenied ||
            await Permission.storage.isPermanentlyDenied) {
          final state = await Permission.audio.request();
          if (!state.isGranted) {
            await SystemNavigator.pop(
              animated: true,
            );
          }
        }
      }
      await Configuration.initialize();
      await AppState.initialize();
      await Intent.initialize();
    }
    await Collection.initialize(
      collectionDirectories: Configuration.instance.collectionDirectories,
      cacheDirectory: Configuration.instance.cacheDirectory,
      albumsSort: Configuration.instance.albumsSort,
      artistsSort: Configuration.instance.artistsSort,
      tracksSort: Configuration.instance.tracksSort,
      genresSort: Configuration.instance.genresSort,
      albumsOrderType: Configuration.instance.albumsOrderType,
      tracksOrderType: Configuration.instance.tracksOrderType,
      artistsOrderType: Configuration.instance.artistsOrderType,
      genresOrderType: Configuration.instance.genresOrderType,
      minimumFileSize: Configuration.instance.minimumFileSize,
      albumHashCodeParameters: Configuration.instance.albumHashCodeParameters,
    );
    await Lyrics.initialize();
    await Collection.instance.refresh(
      onProgress: (progress, total, _) {
        CollectionRefresh.instance.set(progress, total);
      },
      update: Configuration.instance.automaticMusicLookup,
    );
    await Playback.initialize();
    await Language.initialize(
      language: Configuration.instance.language,
    );
    Updater.initialize();
    runApp(Harmonoid());
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
    WindowLifecycle.initialize();
    runApp(
      ExceptionApp(
        exception: exception,
        stacktrace: stacktrace,
      ),
    );
  }
}

class _HttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    environment ??= Platform.environment;
    return super.findProxyFromEnvironment(url, environment);
  }
}
