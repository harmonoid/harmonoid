import 'dart:io';
import 'package:flutter/material.dart';

import 'package:harmonoid/screens/home.dart';
import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/appstate.dart';
import 'package:harmonoid/constants/constantsupdater.dart';


class Harmonoid extends StatefulWidget {
  Harmonoid({Key key}) : super(key: key);
  HarmonoidState createState() => HarmonoidState();
}


class HarmonoidState extends State<Harmonoid> {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode switchTheme() {
    this.setState(() {
      this._themeMode = this._themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    return this._themeMode;
  }

  @override
  void initState() {
    super.initState();
    AppState.switchTheme = this.switchTheme;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'harmonoid',
      theme: new ThemeData(
        splashFactory: InkRipple.splashFactory,
        brightness: Brightness.light,
        primaryColorLight: Colors.deepPurpleAccent,
        primaryColor: Colors.deepPurpleAccent[400],
        primaryColorDark: Colors.deepPurpleAccent[700],
        scaffoldBackgroundColor: Colors.grey[100],
        cursorColor: Colors.deepPurpleAccent[700],
        accentColor: Colors.deepPurpleAccent[400],
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          brightness: Brightness.light,
          elevation: 2,
          iconTheme: IconThemeData(
            color: Colors.black54,
            size: 24,
          ),
          actionsIconTheme: IconThemeData(
            color: Colors.black54,
            size: 24,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black54,
          size: 24,
        ),
        bottomNavigationBarTheme: new BottomNavigationBarThemeData(
          backgroundColor: Colors.deepPurpleAccent[700],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
        ),
        textTheme: new TextTheme(
          headline1: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.black87,
            fontSize: 18,
          ),
          headline2: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.black87,
            fontSize: 16,
          ),
          headline3: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.black54,
            fontSize: 16,
          ),
          headline4: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.black54,
            fontSize: 14,
          ),
          headline5: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ),
      darkTheme: new ThemeData(
        splashFactory: InkRipple.splashFactory,
        brightness: Brightness.dark,
        primaryColorLight: Colors.deepPurpleAccent[100],
        primaryColor: Colors.deepPurpleAccent[100],
        primaryColorDark: Colors.deepPurpleAccent[100],
        scaffoldBackgroundColor: Color(0xFF121212),
        cursorColor: Colors.deepPurpleAccent[100],
        accentColor: Colors.deepPurpleAccent[100],
        cardColor: Colors.white.withOpacity(0.10),
        appBarTheme: AppBarTheme(
          color: Color.fromRGBO(42, 42, 42, 1),
          brightness: Brightness.dark,
          elevation: 2,
          iconTheme: IconThemeData(
            color: Colors.black54,
            size: 24,
          ),
          actionsIconTheme: IconThemeData(
            color: Colors.black54,
            size: 24,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.54),
          size: 24,
        ),
        bottomNavigationBarTheme: new BottomNavigationBarThemeData(
          backgroundColor: Color.fromRGBO(42, 42, 42, 1),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
        ),
        textTheme: new TextTheme(
          headline1: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.white.withOpacity(0.87),
            fontSize: 18,
          ),
          headline2: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.white.withOpacity(0.87),
            fontSize: 16,
          ),
          headline3: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.white.withOpacity(0.54),
            fontSize: 16,
          ),
          headline4: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.white.withOpacity(0.54),
            fontSize: 14,
          ),
          headline5: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.white.withOpacity(0.54),
            fontSize: 12,
          ),
        ),
      ),
      themeMode: this._themeMode,
      initialRoute: 'home',
      routes: {
        'home': (BuildContext context) => new Home(),
      },
    );
  }
}


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Stopwatch stopwatch = new Stopwatch()..start();

  collection = new Collection(
    collectionDirectory: Directory('/home/alex/Music'),
    cacheDirectory: Directory('/home/alex/Documents/cache'),
  );
  await collection.getFromCache();
  await ConstantsUpdater.update(LanguageRegion.enUs);

  print('Time Elapsed : ${stopwatch.elapsedMilliseconds}ms');
  stopwatch.stop();


  runApp(new Harmonoid());
}
