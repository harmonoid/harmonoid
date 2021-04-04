import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  // try {
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
  // }
  // catch(exception) {
  //   runApp(
  //     new ExceptionMaterialApp(
  //       exception: exception,
  //     ),
  //   );
  // }
}
