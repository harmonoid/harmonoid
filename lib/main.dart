import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:harmonoid/scripts/states.dart';

import 'package:harmonoid/screens/home.dart';
import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/fileintent.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/screens/nowplaying.dart';
import 'package:harmonoid/screens/exception.dart';
import 'package:harmonoid/language/language.dart';
import 'package:harmonoid/scripts/discover.dart';
import 'package:harmonoid/scripts/download.dart';
import 'package:harmonoid/scripts/methods.dart';
import 'package:harmonoid/scripts/vars.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  try {
    await Configuration.init(
      cacheDirectory: Directory(CACHE_DIRECTORY),
    );
    await Methods.askStoragePermission();
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


class Harmonoid extends StatefulWidget {
  Harmonoid({Key key}) : super(key: key);
  HarmonoidState createState() => HarmonoidState();
}


class HarmonoidState extends State<Harmonoid> {
  ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    States.refreshThemeData = () => this.setState(() {});
  }

  @override
  void dispose() {
    States.refreshThemeData = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'harmonoid',
      theme: Methods.getThemeData(
        color: ACCENT_COLORS[configuration.accentColor][0],
        themeMode: ThemeMode.light,
      ),
      darkTheme: Methods.getThemeData(
        color: ACCENT_COLORS[configuration.accentColor][1],
        themeMode: ThemeMode.dark,
      ),
      themeMode: configuration.themeMode,
      home: Home(),
      onGenerateRoute: (RouteSettings routeSettings) {
        PageRoute route;
        if (routeSettings.name == 'nowPlaying') {
          route = new PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 700),
            reverseTransitionDuration: Duration(milliseconds: 700),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            ),
            pageBuilder: (context, animation, secondaryAnimation) => NowPlaying(),
          );
        }
        return route;
      },
    );
  }
}

final FlutterLocalNotificationsPlugin notification = FlutterLocalNotificationsPlugin();
final InitializationSettings notificationSettings = InitializationSettings(
  android: AndroidInitializationSettings('mipmap/ic_launcher'),
);
