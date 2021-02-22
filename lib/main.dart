import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/fileintent.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/screens/harmonoid.dart';
import 'package:harmonoid/screens/exception.dart';
import 'package:harmonoid/language/language.dart';
import 'package:harmonoid/scripts/discover.dart';
import 'package:harmonoid/scripts/download.dart';
import 'package:harmonoid/scripts/methods.dart';
import 'package:harmonoid/scripts/vars.dart';


const String TITLE   = 'harmonoid';
const String VERSION = '0.0.3+2';
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
    await Configuration.init(
      cacheDirectory: Directory(CACHE_DIRECTORY),
    );
    await Collection.init(
      collectionDirectory: Directory(MUSIC_DIRECTORY),
      cacheDirectory: Directory(CACHE_DIRECTORY),
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
}
