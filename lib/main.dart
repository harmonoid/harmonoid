import 'dart:io';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/harmonoid.dart';
import 'package:harmonoid/interface/exception.dart';
import 'package:harmonoid/utils/utils.dart';
import 'package:harmonoid/constants/language.dart';

const String TITLE = 'Harmonoid';
const String VERSION = '0.1.5';
const String AUTHOR = 'Hitesh Kumar Saini <saini123hitesh@gmail.com>';
const String LICENSE = 'GPL-3.0';

Future<void> main(List<String> args) async {
  try {
    if (Platform.isWindows) {
      WidgetsFlutterBinding.ensureInitialized();
      await Configuration.init();
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
      await Intent.init(args: args);
      doWhenWindowReady(() {
        appWindow.minSize = Size(640, 480);
        appWindow.size = Size(1024, 640);
        appWindow.alignment = Alignment.center;
        appWindow.show();
      });
    }
    if (Platform.isLinux) {
      WidgetsFlutterBinding.ensureInitialized();
      await Configuration.init();
      await Acrylic.initialize();
      LWM.initialize();
      DiscordRPC.initialize();
      await Intent.init(args: args);
    }
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Colors.transparent));
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await Utils.askStoragePermission();
      await Configuration.init();
      await Intent.init();
    }
    await Collection.init(
      collectionDirectories: configuration.collectionDirectories!,
      cacheDirectory: configuration.cacheDirectory!,
      collectionSortType: configuration.collectionSortType!,
    );
    await Language.init(
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
