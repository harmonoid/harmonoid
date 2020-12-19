import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:harmonoid/screens/musiccollection.dart';
import 'package:harmonoid/screens/nowplaying.dart';
import 'package:harmonoid/constants/constants.dart';


class Home extends StatefulWidget {
  Home({Key key}) : super(key : key);
  HomeState createState() => HomeState();
}


class HomeState extends State<Home> with TickerProviderStateMixin {
  int _index = 1;
  ScrollController _scrollController = new ScrollController();

  @override
  void dispose() {
    this._scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> screens = <Widget>[
      Center(
        child: Text('Coming Soon...')
      ),
      Navigator(
        initialRoute: 'musicCollectionHome',
        onGenerateRoute: (RouteSettings routeSettings) {
          MaterialPageRoute route;
          if (routeSettings.name == 'musicCollectionHome') {
            route = new MaterialPageRoute(builder: (BuildContext context) => MusicCollectionHome());
          }
          return route;
        },
      ),
    ];

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: screens[this._index],
          ),
          NowPlaying(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: this._index,
        onTap: (int index) => this.setState(() => this._index = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.image_search),
            label: Constants.STRING_DISCOVER,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: Constants.STRING_COLLECTION,
          ),
        ],
      ),
    );
  }
}