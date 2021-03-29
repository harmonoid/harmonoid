import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'package:harmonoid/interface/settings/settings.dart';


class ExceptionMaterialApp extends StatelessWidget {
  final dynamic exception;
  ExceptionMaterialApp({Key? key, required this.exception}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        splashFactory: InkRipple.splashFactory,
        highlightColor: Colors.transparent,
        brightness: Brightness.light,
        primaryColorLight: Colors.deepPurpleAccent,
        primaryColor: Colors.deepPurpleAccent[400],
        primaryColorDark: Colors.deepPurpleAccent[700],
        scaffoldBackgroundColor: Colors.grey[100],
        accentColor: Colors.deepPurpleAccent[400],
        toggleableActiveColor: Colors.deepPurpleAccent[400],
        cardColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent[100],
        dividerColor: Colors.black12,
        disabledColor: Colors.black38,
        tabBarTheme: TabBarTheme(
          labelColor: Colors.deepPurpleAccent[700],
          unselectedLabelColor: Colors.black54,
        ),
        appBarTheme: AppBarTheme(
          color: Colors.deepPurpleAccent[700],
          brightness: Brightness.dark,
          elevation: 4.0,
          iconTheme: IconThemeData(
            color: Colors.white,
            size: 24,
          ),
          actionsIconTheme: IconThemeData(
            color: Colors.white,
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
        primaryTextTheme: new TextTheme(
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
            color: Colors.black87,
            fontSize: 14,
          ),
          headline5: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.black54,
            fontSize: 14,
          ),
          headline6: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.white,
            fontSize: 18,
          ),
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
            color: Colors.black87,
            fontSize: 14,
          ),
          headline5: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.black54,
            fontSize: 14,
          ),
          headline6: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      themeMode: ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.error),
          title: Text('Harmonoid'),
        ),
        body: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: [
            SettingsTile(
              title: 'Exception Occured',
              subtitle: 'Something wrong is experienced',
              child: Column(
                children: [
                  Text('$exception'),
                  Divider(
                    color: Colors.transparent,
                    height: 16.0,
                  ),
                  Text(
                    'You may try to clear app cache or report this on the project repository.',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              actions: [
                MaterialButton(
                  onPressed: () => UrlLauncher.launch('https://github.com/alexmercerind/harmonoid/issues'),
                  child: Text(
                    'REPORT ISSUE',
                    style: TextStyle(
                      color: Colors.deepPurpleAccent[700]
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: SystemNavigator.pop,
                  child: Text(
                    'EXIT APP',
                    style: TextStyle(
                      color: Colors.deepPurpleAccent[700]
                    ),
                  ),
                ),
              ],
              margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            ),
            Card(
              elevation: 2.0,
              margin: EdgeInsets.all(8.0),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.phone_android),
                    title: Text(
                      'Your music will stay safe',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}