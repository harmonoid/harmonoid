/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

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

const String kTitle = 'Harmonoid';
const String kVersion = '0.1.9';
const String kAuthor = 'Hitesh Kumar Saini <saini123hitesh@gmail.com>';
const String kLicense = 'GPL-3.0';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Platform.isWindows) {
      await Configuration.initialize();
      if (kReleaseMode) {
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
      if (kReleaseMode) {
        await MPV.initialize();
      }
      await Intent.initialize(args: args);
      await HotKeys.initialize();
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
