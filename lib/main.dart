import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/discover.dart';
import 'package:harmonoid/core/download.dart';
import 'package:harmonoid/core/fileintent.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/harmonoid.dart';
import 'package:harmonoid/interface/exception.dart';
import 'package:harmonoid/utils/methods.dart';
import 'package:harmonoid/constants/language.dart';

const String TITLE   = 'harmonoid';
const String VERSION = '0.0.4';
const String AUTHOR  = 'alexmercerind';
const String LICENSE = 'GPL-3.0';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await Methods.askStoragePermission();
    await Configuration.init();
    await Collection.init(
      collectionDirectory: configuration.collectionDirectory,
      cacheDirectory: configuration.cacheDirectory,
    );
    await Discover.init(
      homeAddress: configuration.homeAddress,
    );
    await Language.init(
      languageRegion: configuration.languageRegion,
    );
    await FileIntent.init();
    await Download.init();
    runApp(
      new Harmonoid(),
    );
  }
  catch(exception) {
    runApp(
      new ExceptionMaterialApp(
        exception: exception,
      ),
    );
  }
    // Check if it's in desktop
    // This should be changed in the future when Flutter Desktop get stable
  if (Methods.isDesktop) {
    doWhenWindowReady(() {
      final win = appWindow;
      final initialSize = const Size(350, 500);
      win.minSize = initialSize;
      win.size = const Size(600, 500);
      win.alignment = Alignment.center;
      win.title = "Harmonoid";
      win.show();
    });
  }
}
