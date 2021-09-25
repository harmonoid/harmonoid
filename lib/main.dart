import 'dart:io';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/harmonoid.dart';
import 'package:harmonoid/interface/exception.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/interface/changenotifiers.dart';

const String TITLE = 'Harmonoid';
const String VERSION = '0.1.8';
const String AUTHOR = 'Hitesh Kumar Saini <saini123hitesh@gmail.com>';
const String LICENSE = 'GPL-3.0';

Future<void> main(List<String> args) async {
  try {
    if (Platform.isWindows) {
      WidgetsFlutterBinding.ensureInitialized();
      await Configuration.initialize();
      await Acrylic.initialize();
      await Acrylic.setEffect(
        effect: configuration.acrylicEnabled!
            ? AcrylicEffect.acrylic
            : AcrylicEffect.solid,
        gradientColor: configuration.themeMode! == ThemeMode.light
            ? Colors.white
            : Color(0xCC222222),
      );
      LWM.initialize();
      DiscordRPC.initialize();
      await Intent.initialize(args: args);
      await HotKeys.initialize();
      doWhenWindowReady(() {
        appWindow.minSize = Size(854, 640);
        appWindow.size = Size(1024, 640);
        appWindow.alignment = Alignment.center;
        appWindow.show();
      });
    }
    if (Platform.isLinux) {
      WidgetsFlutterBinding.ensureInitialized();
      await Configuration.initialize();
      await Acrylic.initialize();
      LWM.initialize();
      DiscordRPC.initialize();
      await Intent.initialize(args: args);
      await HotKeys.initialize();
    }
    if (Platform.isAndroid) {
      WidgetsFlutterBinding.ensureInitialized();
      if (Platform.isAndroid) if (await Permission.storage.isDenied) {
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
      collectionDirectories: configuration.collectionDirectories!,
      cacheDirectory: configuration.cacheDirectory!,
      collectionSortType: configuration.collectionSortType!,
    );
    collection.refresh(onProgress: (progress, total, _) {
      collectionRefresh.set(progress, total);
    });
    await Language.initialize(
      languageRegion: configuration.languageRegion!,
    );
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
