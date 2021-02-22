import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/methods.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/scripts/vars.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/screens/nowplaying.dart';
import 'package:harmonoid/screens/home.dart';


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
