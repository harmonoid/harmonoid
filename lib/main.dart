import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/download.dart';
import 'package:harmonoid/core/fileintent.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/harmonoid.dart';
import 'package:harmonoid/interface/exception.dart';
import 'package:harmonoid/utils/methods.dart';
import 'package:harmonoid/constants/language.dart';

const String TITLE = 'Harmonoid';
const String VERSION = '0.0.8';
const String AUTHOR = 'Hitesh Kumar Saini <saini123hitesh@gmail.com>';
const String LICENSE = 'GPL-3.0';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Methods.askStoragePermission();
    await Configuration.init();
    if (Platform.isWindows || Platform.isLinux) {
      await Acrylic.initialize();
      Acrylic.setEffect(
        effect: configuration.acrylicEnabled!
            ? AcrylicEffect.acrylic
            : AcrylicEffect.solid,
        gradientColor: configuration.themeMode! == ThemeMode.light
            ? Colors.white
            : Color(0xCC222222),
      );
    }
    await Collection.init(
      collectionDirectories: configuration.collectionDirectories!,
      cacheDirectory: configuration.cacheDirectory!,
      collectionSortType: configuration.collectionSortType!,
    );
    await Language.init(
      languageRegion: configuration.languageRegion!,
    );
    await FileIntent.init();
    await Download.init();
    runApp(
      Harmonoid(),
    );
  } catch (exception, stacktrace) {
    runApp(
      ExceptionApp(
        exception: exception,
        stacktrace: stacktrace,
      ),
    );
  }
  doWhenWindowReady(() {
    appWindow.minSize = Size(640, 480);
    appWindow.size = Size(1024, 640);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}
