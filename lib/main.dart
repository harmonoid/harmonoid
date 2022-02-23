/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/interface/harmonoid.dart';
import 'package:harmonoid/interface/exception.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/override_window_destroy.dart';

const String kTitle = 'Harmonoid';
const String kVersion = '0.2.1';
const String kAuthor = 'Harmonoid Project Authors';
const String kLicense = 'End-User License Agreement for Harmonoid';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Platform.isWindows) {
      await Configuration.initialize();
      if (kReleaseMode || kProfileMode) {
        await MPV.initialize();
        await SMTC.initialize();
      }
      await Intent.initialize(args: args);
      await HotKeys.initialize();
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
      if (kReleaseMode || kProfileMode) {
        await MPV.initialize();
      }
      await Intent.initialize(args: args);
      await HotKeys.initialize();
      OverrideWindowDestroy.initialize();
      DiscordRPC.initialize();
    }
    if (Platform.isAndroid) {
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
      await Intent.initialize();
    }
    await Collection.initialize(
      collectionDirectories: Configuration.instance.collectionDirectories,
      cacheDirectory: Configuration.instance.cacheDirectory,
      collectionSortType: Configuration.instance.collectionSortType,
      collectionOrderType: Configuration.instance.collectionOrderType,
    );
    await Collection.instance.refresh(onProgress: (progress, total, _) {
      CollectionRefresh.instance.set(progress, total);
    });
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
