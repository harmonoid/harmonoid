import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/discover.dart';
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
  await Acrylic.initialize();
  await Acrylic.setEffect(
    effect: AcrylicEffect.acrylic,
    gradientColor: Color(0xCC222222),
  );
  try {
    await Methods.askStoragePermission();
    await Configuration.init();
    await Collection.init(
      collectionDirectories: configuration.collectionDirectories!,
      cacheDirectory: configuration.cacheDirectory!,
      collectionSortType: configuration.collectionSortType!,
    );
    await Discover.init(
      homeAddress: configuration.homeAddress!,
    );
    await Language.init(
      languageRegion: configuration.languageRegion!,
    );
    await FileIntent.init();
    await Download.init();
    runApp(
      new Harmonoid(),
    );
  } catch (exception) {
    runApp(
      new ExceptionMaterialApp(
        exception: exception,
      ),
    );
  }
}
