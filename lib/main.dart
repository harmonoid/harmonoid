import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:palette_generator/palette_generator.dart';

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
import 'package:harmonoid/scripts/states.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
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


class Harmonoid extends StatefulWidget {
  Harmonoid({Key key}) : super(key: key);
  HarmonoidState createState() => HarmonoidState();
}


class HarmonoidState extends State<Harmonoid> {
  Color _automaticAccentColor;

  @override
  void initState() {
    super.initState();
    States.refreshThemeData = () => this.setState(() {});
    States.setAccentColor = (Track track) async {
      PaletteGenerator pallete = await PaletteGenerator.fromImageProvider(
        FileImage(collection.getAlbumArt(track))
      );
      this.setState(() {
        this._automaticAccentColor = pallete?.darkVibrantColor?.color;
      });
    };
  }

  @override
  void dispose() {
    States.refreshThemeData = null;
    States.setAccentColor = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'harmonoid',
      theme: Methods.getThemeData(
        color: this._automaticAccentColor ?? ACCENT_COLORS[configuration.accentColor][0],
        themeMode: ThemeMode.light,
      ),
      darkTheme: Methods.getThemeData(
        color: this._automaticAccentColor ?? ACCENT_COLORS[configuration.accentColor][1],
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
