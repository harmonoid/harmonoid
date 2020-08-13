import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

import 'package:audio_service/audio_service.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/saved/savedalbumresults.dart';
import 'package:harmonoid/searchbar.dart';


class Welcome extends StatefulWidget {
  Welcome({Key key}) : super(key: key);
  _Welcome createState() => _Welcome();
}


class _Welcome extends State<Welcome> {

  GlobalKey<SearchState> _search = new GlobalKey<SearchState>();
  GlobalKey<SavedAlbumResultsState> _savedAlbumResultsKey = new GlobalKey<SavedAlbumResultsState>();
  ScrollController _albumsScrollController = new ScrollController();

  int _index = 1;
  double _rotationValue = 2 * pi;
  int _rotations = 1;

  @override
  void initState() {
    super.initState();

    AudioService.start(
      backgroundTaskEntrypoint: backgroundTaskEntryPoint,
      androidNotificationChannelName: 'com.alexmercerind.harmonoid',
      androidNotificationColor: 0xFF6200EA,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidStopForegroundOnPause: true,
      androidNotificationChannelDescription: 'Harmonoid Music Playing Service' 
    );

    this._albumsScrollController..addListener(() {

      ScrollDirection currentScrollDirection;

      if (this._albumsScrollController.position.userScrollDirection == ScrollDirection.reverse && this._albumsScrollController.position.userScrollDirection != currentScrollDirection) {
        currentScrollDirection = ScrollDirection.reverse;
        _search.currentState.hideSearchBar();
      }
      else if (this._albumsScrollController.position.userScrollDirection == ScrollDirection.forward && this._albumsScrollController.position.userScrollDirection != currentScrollDirection) {
        currentScrollDirection = ScrollDirection.forward;
        _search.currentState.showSearchBar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> _screens = [
      Center(child: Text('Hello World!'),),
      Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SavedAlbumResults(
              scrollController : _albumsScrollController, 
              key: _savedAlbumResultsKey,
              ),
            Search(key: this._search),
          ],
        ),
      ),
      Center(child: Text('Hello World!'),),
    ];

    return Scaffold(
      floatingActionButton: TweenAnimationBuilder(
        duration: Duration(seconds: 1),
        tween: Tween<double>(begin: 0.0, end: this._rotationValue),
        builder: (context, value, child) => Transform.rotate(
          angle: value,
          child: FloatingActionButton(
            onPressed: () {
              this.setState(() {
                this._rotations++;
                this._rotationValue = 2 * this._rotations * pi; 
              });
              this._savedAlbumResultsKey.currentState.refresh();
            },
            child: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          alignment: Alignment.center,
        ),
      ),
      body: PageTransitionSwitcher(
        duration: Duration(milliseconds: 400),
        child: _screens[this._index],
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) => FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8.0,
        currentIndex: this._index,
        onTap: (int index) => this.setState(() => this._index = index),
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedItemColor: Colors.white,
        unselectedItemColor: Theme.of(context).primaryColorLight,
        backgroundColor: Theme.of(context).accentColor,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.play_arrow), title: Text('Now Playing')),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), title: Text('Collection')),
          BottomNavigationBarItem(icon: Icon(Icons.info), title: Text('About')),
        ],
      ),
    );
  }
}