import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/screens/collection/collectionmusic.dart';
import 'package:harmonoid/screens/nowplaying.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/constants/constants.dart';


class Home extends StatefulWidget {
  Home({Key key}) : super(key : key);
  HomeState createState() => HomeState();
}


class HomeState extends State<Home> with TickerProviderStateMixin, WidgetsBindingObserver {
  int _index = 2;
  GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  void showNowPlaying() {
    Navigator.of(context).pushNamed('nowPlaying');
  }

  @override
  void initState() {
    super.initState();
    States.showNowPlaying = this.showNowPlaying;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (this.navigatorKey.currentState.canPop()) {
      this.navigatorKey.currentState.pop();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      Center(
        child: Text('Coming Soon...')
      ),
      Center(
        child: Text('Coming Soon...')
      ),
      Navigator(
        key: this.navigatorKey,
        initialRoute: 'collectionMusic',
        onGenerateRoute: (RouteSettings routeSettings) {
          Route<dynamic> route;
          if (routeSettings.name == 'collectionMusic') {
            route = new MaterialPageRoute(builder: (BuildContext context) => CollectionMusic());
          }
          if (routeSettings.name == 'collectionMusicSearch') {
            route = new PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 400),
              reverseTransitionDuration: Duration(milliseconds: 400),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              ),
              pageBuilder: (context, animation, secondaryAnimation) => CollectionMusicSearch(),
            );
          }
          return route;
        },
      ),
      Center(
        child: NowPlaying(),
      ),
      Center(
        child: Text('Coming Soon...')
      ),
    ];
    return Scaffold(
      body: PageTransitionSwitcher(
        child: screens[this._index],
        duration: Duration(milliseconds: 400),
        transitionBuilder: (child, animation, secondaryAnimation) => FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: this._index,
        onTap: (int index) => this.setState(() => this._index = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_downward),
            label: Constants.STRING_TRANSFERS,
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
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