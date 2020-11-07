import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/constants/constants.dart';
import 'package:harmonoid/screens/musiccollection.dart';


class Home extends StatefulWidget {

  Home({Key key}) : super(key : key);
  HomeState createState() => HomeState();
}


class HomeState extends State<Home> {

  int _index = 1;

  @override
  Widget build(BuildContext context) {

    final List<Widget> screens = <Widget>[
      Center(
        child: Text('Hello #0!')
      ),
      MusicCollection(),
      Center(
        child: Text('Hello #2!')
      ),
    ];

    return Scaffold(
      body: PageTransitionSwitcher(
        duration: Duration(milliseconds: 400),
        child: screens[this._index],
        transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation) => FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: this._index,
        onTap: (int index) => this.setState(() => this._index = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: Constants.STRING_NOW_PLAYING,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: Constants.STRING_COLLECTION,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: Constants.STRING_SETTING,
          )
        ],
      ),
    );
  }
}