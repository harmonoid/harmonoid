import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:harmonoid/constants/constants.dart';
import 'package:harmonoid/screens/musiccollection.dart';


class Home extends StatefulWidget {

  Home({Key key}) : super(key : key);
  HomeState createState() => HomeState();
}


class HomeState extends State<Home> with TickerProviderStateMixin {

  int _index = 1;
  Animation<double> _opacity;
  AnimationController _controller;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    this._controller = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 200),
    );
    this._opacity = new Tween<double>(begin: 1.0, end: 0.0).animate(new CurvedAnimation(
      parent: this._controller,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    ));

    this._scrollController.addListener(() {
      if (this._scrollController.position.userScrollDirection == ScrollDirection.reverse && this._controller.isDismissed) {
        this._controller.forward();
      }
      else if (this._scrollController.position.userScrollDirection == ScrollDirection.forward  && this._controller.isCompleted) {
        this._controller.reverse();
      }
    });
  }

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
      MusicCollection(),
      Center(
        child: Text('Coming Soon...')
      ),
    ];

    return Scaffold(
      body: screens[this._index],
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
            icon: Icon(Icons.wifi),
            label: Constants.STRING_DISCOVER,
          )
        ],
      ),
    );
  }
}