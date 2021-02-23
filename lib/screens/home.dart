import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/screens/collection/collectionmusic.dart';
import 'package:harmonoid/screens/collection/collectionsearch.dart';
import 'package:harmonoid/screens/discover/discovermusic.dart';
import 'package:harmonoid/screens/nowplaying.dart';
import 'package:harmonoid/screens/settings/settings.dart';
import 'package:harmonoid/language/constants.dart';
import 'package:harmonoid/scripts/fileintent.dart';


enum Screen {
  discover,
  collection,
  nowPlaying,
  settings,
}


class Home extends StatefulWidget {
  Home({Key key}) : super(key : key);
  HomeState createState() => HomeState();
}


class HomeState extends State<Home> with TickerProviderStateMixin, WidgetsBindingObserver {
  int index = fileIntent.startScreen.index;
  List<GlobalKey<NavigatorState>> navigatorKeys = <GlobalKey<NavigatorState>>[
    new GlobalKey<NavigatorState>(),
    new GlobalKey<NavigatorState>(),
    new GlobalKey<NavigatorState>(),
    new GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    if (fileIntent.startScreen == Screen.nowPlaying) fileIntent.play();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (this.navigatorKeys[this.index].currentState.canPop()) {
      this.navigatorKeys[this.index].currentState.pop();
    }
    else {
      showDialog(
        context: context,
        builder: (subContext) => AlertDialog(
          title: Text(
            Constants.STRING_EXIT_TITLE,
            style: Theme.of(subContext).textTheme.headline1,
          ),
          content: Text(
            Constants.STRING_EXIT_SUBTITLE,
            style: Theme.of(subContext).textTheme.headline5,
          ),
          actions: [
            MaterialButton(
              textColor: Theme.of(context).primaryColor,
              onPressed: SystemNavigator.pop,
              child: Text(Constants.STRING_YES),
            ),
            MaterialButton(
              textColor: Theme.of(context).primaryColor,
              onPressed: Navigator.of(subContext).pop,
              child: Text(Constants.STRING_NO),
            ),
          ],
        ),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      Navigator(
        key: this.navigatorKeys[0],
        initialRoute: 'discoverMusic',
        onGenerateRoute: (RouteSettings routeSettings) {
          Route route;
          if (routeSettings.name == 'discoverMusic') {
            route = MaterialPageRoute(builder: (_) => DiscoverMusic());
          }
          return route;
        },
      ),
      Navigator(
        key: this.navigatorKeys[1],
        initialRoute: 'collectionMusic',
        onGenerateRoute: (RouteSettings routeSettings) {
          Route<dynamic> route;
          if (routeSettings.name == 'collectionMusic') {
            route = new MaterialPageRoute(builder: (BuildContext context) => CollectionMusic());
          }
          if (routeSettings.name == 'collectionSearch') {
            route = new PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 400),
              reverseTransitionDuration: Duration(milliseconds: 400),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              ),
              pageBuilder: (context, animation, secondaryAnimation) => CollectionSearch(),
            );
          }
          return route;
        },
      ),
      Navigator(
        key: this.navigatorKeys[2],
        initialRoute: 'nowPlaying',
        onGenerateRoute: (RouteSettings routeSettings) {
          Route route;
          if (routeSettings.name == 'nowPlaying') {
            route = MaterialPageRoute(
              builder: (BuildContext context) => NowPlaying(),
            );
          }
          return route;
        },
      ),
      Navigator(
        key: this.navigatorKeys[3],
        initialRoute: 'settings',
        onGenerateRoute: (RouteSettings routeSettings) {
          Route route;
          if (routeSettings.name == 'settings') {
            route = MaterialPageRoute(
              builder: (BuildContext context) => Settings(),
            );
          }
          return route;
        },
      ),
    ];
    return Scaffold(
      body: PageTransitionSwitcher(
        child: screens[this.index],
        duration: Duration(milliseconds: 400),
        transitionBuilder: (child, animation, secondaryAnimation) => FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: this.index,
        onTap: (int index) => this.setState(() => this.index = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.album),
            label: Constants.STRING_DISCOVER,
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: Constants.STRING_COLLECTION,
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: Constants.STRING_NOW_PLAYING,
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: Constants.STRING_SETTING,
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
        ],
      ),
    );
  }
}