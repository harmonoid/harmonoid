/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:libmpv/libmpv.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/core/app_state.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/interface/harmonoid.dart';
import 'package:harmonoid/interface/exception.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/argument_vector_handler.dart';
import 'package:harmonoid/utils/override_window_destroy.dart';

const String kTitle = 'Harmonoid';
const String kVersion = 'v0.2.2';
const String kAuthor = 'Hitesh Kumar Saini <saini123hitesh@gmail.com>';
const String kLicense = 'End-User License Agreement for Harmonoid';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Platform.isWindows) {
      await Configuration.initialize();
      await AppState.initialize();
      await MPV.initialize();
      if (kReleaseMode || kProfileMode) {
        await SMTC.initialize();
      }
      await Intent.initialize(args: args);
      await HotKeys.initialize();
      ArgumentVectorHandler.initialize();
      DiscordRPC.initialize();
      doWhenWindowReady(() {
        appWindow.minSize = Size(960, 640);
        appWindow.size = Size(1024, 640);
        appWindow.alignment = Alignment.center;
        appWindow.show();
      });
    }
    if (Platform.isLinux) {
      await Configuration.initialize();
      await AppState.initialize();
      await MPV.initialize();
      await Intent.initialize(args: args);
      await HotKeys.initialize();
      OverrideWindowDestroy.initialize();
      DiscordRPC.initialize();
    }
    if (Platform.isAndroid) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      if (await Permission.storage.isDenied) {
        PermissionStatus storagePermissionState =
            await Permission.storage.request();
        if (!storagePermissionState.isGranted) {
          SystemNavigator.pop(
            animated: true,
          );
        }
      }
      await Configuration.initialize();
      await AppState.initialize();
      await Intent.initialize();
    }
    await Collection.initialize(
      collectionDirectories: Configuration.instance.collectionDirectories,
      cacheDirectory: Configuration.instance.cacheDirectory,
      collectionSortType: Configuration.instance.collectionSortType,
      collectionOrderType: Configuration.instance.collectionOrderType,
    );
    await Collection.instance.refresh(
      onProgress: (progress, total, _) {
        CollectionRefresh.instance.set(progress, total);
      },
      update: Configuration.instance.automaticallyRefreshCollectionOnFreshStart,
    );
    await Language.initialize();
    runApp(
      Harmonoid(),
    );
  } catch (exception, stacktrace) {
    print(exception);
    print(stacktrace);
    runApp(
      ExceptionApp(
        exception: exception,
        stacktrace: stacktrace,
      ),
    );
  }
}
