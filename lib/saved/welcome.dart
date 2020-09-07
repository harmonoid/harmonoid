import 'package:animations/animations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';

import 'package:harmonoid/globals.dart' as Globals;
import 'package:harmonoid/saved/savedalbumresults.dart';
import 'package:harmonoid/saved/nowplaying.dart';
import 'package:harmonoid/scripts/refreshcollection.dart';
import 'package:harmonoid/searchbar.dart';
import 'package:harmonoid/setting.dart';


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
  StreamSubscription _nowPlayingNotificationStream;
  bool notRefreshing = true;

  Future<void> refreshCollection() async {
    await RefreshCollection.refreshAlbumsCollection();
    await this._savedAlbumResultsKey.currentState.refresh();
  }

  @override
  void initState() {
    super.initState();

    if (Globals.globalTheme == 0) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      ));
    }
    else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
      ));
    }

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

    this._nowPlayingNotificationStream = AudioService.notificationClickEventStream.listen((event) {
      if (event) {
        this.setState(() {
          this._index = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    this._nowPlayingNotificationStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Globals.globalContext = context;

    final List<Widget> _screens = [
      NowPlaying(),
      Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            color: Globals.globalTheme == 0 ? Colors.black.withOpacity(0.02) : Color(0xFF121212),
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: SavedAlbumResults(
              scrollController : _albumsScrollController, 
              key: _savedAlbumResultsKey,
            ),
          ),
          Search(key: this._search, refreshCollection: this.refreshCollection),
          Container(
            color: Globals.globalTheme == 0 ? Colors.white : Color(0xFF121212),
            height: MediaQuery.of(context).padding.top,
            width: MediaQuery.of(context).size.width,
          )
        ],
      ),
      Setting(),
    ];

    return Scaffold(
      backgroundColor: Globals.globalTheme == 0 ? Colors.white : Color(0xFF121212),
      floatingActionButton: this._index == 1 ? TweenAnimationBuilder(
        duration: Duration(seconds: 1),
        tween: Tween<double>(begin: 0.0, end: this._rotationValue),
        builder: (context, value, child) => Transform.rotate(
          angle: value,
          child: FloatingActionButton(
            onPressed: () async {
              if (this.notRefreshing) {
                this.notRefreshing = false;
                await RefreshCollection.refreshAlbumsCollection();
                this.setState(() {
                  this._rotations++;
                  this._rotationValue = 2 * this._rotations * pi;
                  this._savedAlbumResultsKey.currentState.refresh();
                  this.notRefreshing = true;
                });
              }
            },
            child: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          alignment: Alignment.center,
        ),
      ) : null,
      body: PageTransitionSwitcher(
        duration: Duration(milliseconds: 400),
        child: _screens[this._index],
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) => FadeThroughTransition(
          fillColor: Globals.globalTheme == 0 ? Colors.black.withOpacity(0.02) : Color(0xFF121212),
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8.0,
        currentIndex: this._index,
        onTap: (int index) => this.setState(() {
          this._index = index;
          this._rotations = 1;
          this._rotationValue = 2 * pi;
        }),
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        backgroundColor: Globals.globalTheme == 0 ? Theme.of(context).primaryColor : Colors.white.withOpacity(0.16),
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.play_arrow), title: Text(Globals.STRING_NOW_PLAYING)),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), title: Text(Globals.STRING_COLLECTION)),
          BottomNavigationBarItem(icon: Icon(Icons.settings), title: Text(Globals.STRING_SETTING)),
        ],
      ),
    );
  }
}