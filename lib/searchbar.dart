import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/scripts/searchhistory.dart';

import 'package:harmonoid/globals.dart' as Globals;
import 'package:harmonoid/searchalbumresults.dart';

enum SearchMode {
  album,
  track,
  artist,
}


class SearchScreen extends StatefulWidget {
  final Function refreshCollection;
  SearchScreen({Key key, @required this.refreshCollection}) : super(key : key);
  _SearchScreen createState() => _SearchScreen();
}


class _SearchScreen extends State<SearchScreen> with TickerProviderStateMixin {

  List<Animation<double>> _scaleAnimation = new List<Animation<double>>(3);
  List<Color> _scaleColor = new List<Color>(3);
  List<AnimationController> _scaleController = new List<AnimationController>(3);
  String _keyword = '';
  SearchMode _searchMode = SearchMode.album;
  List<StatelessWidget> _searchHistoryItems = new List<StatelessWidget>();

  void _selectSearchMode(SearchMode value) {
    for (int index = 0; index <= 2; index++) {
      this._scaleController[index].reverse();
      this._scaleColor[index] = Globals.globalTheme == 0 ? Colors.black54: Colors.white.withOpacity(0.87);
    }
    if (value == SearchMode.album) {
      this._scaleController[0].forward();
      this._scaleColor[0] = Theme.of(context).primaryColor;
    }
    else if (value == SearchMode.track) {
      this._scaleController[1].forward();
      this._scaleColor[1] = Theme.of(context).primaryColor;
    }
    else if (value == SearchMode.artist) {
      this._scaleController[2].forward();
      this._scaleColor[2] = Theme.of(context).primaryColor;
    } 
  }

  void _searchHandler(keyword) {
    if (keyword!='') {
      List<String> resultTitle(SearchMode mode) {
        String resultTitle;
        String resultMode;
        if (mode == SearchMode.album) {
          resultTitle = Globals.STRING_ALBUM;
          resultMode = Globals.ALBUM;
        }
        else if (mode == SearchMode.track) {
          resultTitle = Globals.STRING_TRACK;
          resultMode = Globals.TRACK;
        }
        else if (mode == SearchMode.artist) {
          resultTitle = Globals.STRING_ARTIST;
          resultMode = Globals.ARTIST;
        }
        return [resultMode, resultTitle];
      }

      SearchHistory.addSearchHistory(keyword, resultTitle(this._searchMode)[0], resultTitle(this._searchMode)[1]);

      Navigator.of(context).pushNamed(
        '/searchresult',
        arguments: SearchAlbumResultArguments(this._keyword, resultTitle(this._searchMode)[0], resultTitle(this._searchMode)[1])
      );
    }
  }

  @override
  void initState() {
    super.initState();

    (() async {
      List<dynamic> searchHistory = (await SearchHistory.getSearchHistory())['searches'];
      for (int index = 0; index < searchHistory.length; index++) {
        this._searchHistoryItems.add(
          ListTile(
            onTap: () => Navigator.of(context).pushNamed(
              '/searchresult',
              arguments: SearchAlbumResultArguments(searchHistory[index]['keyword'], searchHistory[index]['mode'], searchHistory[index]['title'])
            ),
            leading: CircleAvatar(
              child: Icon(
                Icons.search,
                color: Globals.globalTheme == 0 ? Colors.black26: Colors.white.withOpacity(0.60),
              ),
              backgroundColor: Color(0x00000000),
            ),
            title: Text(
              searchHistory[index]['keyword'],
              style: TextStyle(
                color: Globals.globalTheme == 0 ? Colors.black87: Colors.white.withOpacity(0.87),
              ),
            ),
            subtitle: Text(searchHistory[index]['title'], 
              style: TextStyle(
                fontSize: 12,
                color: Globals.globalTheme == 0 ? Colors.black54: Colors.white.withOpacity(0.60),
              ),
            ),
          ),
        );
      }
      this.setState(() {});
    })();

    for (int index = 0; index <= 2; index++){
      this._scaleColor[index] = Globals.globalTheme == 0 ? Colors.black54: Colors.white.withOpacity(0.87);
      this._scaleController[index] = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
      );
      this._scaleAnimation[index] = Tween<double>(begin: 1.0, end: 1.6).animate(new CurvedAnimation(
        curve: Curves.easeInOutCubic,
        parent: this._scaleController[index],
      ));
    }
    Timer(Duration(milliseconds: 200), () {
      this._scaleController[0].forward();
      this._scaleColor[0] = Theme.of(context).primaryColor;
    });
  }

  @override void dispose() {
    for (int index = 0; index <= 2; index++){
      this._scaleController[index].dispose();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    widget.refreshCollection();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: this._onWillPop,
      child: Scaffold(
        backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Globals.globalTheme == 0 ? Theme.of(context).primaryColor : Colors.white10,
          leading: Container(
            height: 56,
            width: 56,
            alignment: Alignment.center,
            child: IconButton(
              iconSize: 24,
              icon: Icon(
                Icons.arrow_back,
                color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.87),
              ),
              splashRadius: 20,
              onPressed: () {
                Navigator.of(context).pop();
                widget.refreshCollection();
              },
            )
          ),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  height: 56,
                  child: TextField(
                    onSubmitted: (value) => this._searchHandler(this._keyword),
                    autocorrect: false,
                    autofocus: true,
                    cursorWidth: 1,
                    cursorColor: Colors.white,
                    style: TextStyle(
                      color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.87),
                      fontSize: 16,
                    ),
                    onChanged: (value) => this.setState(() {
                      this._keyword = value;
                    }),
                    decoration: InputDecoration.collapsed(
                      hintText: Globals.STRING_SEARCH_HEADER,
                      hintStyle: TextStyle(
                        color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.87),
                      ),
                    )
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Container(
              height: 56,
              width: 56,
              alignment: Alignment.center,
              child: IconButton(
                iconSize: 24,
                icon: Icon(
                  Icons.search,
                  color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.87),
                ),
                splashRadius: 20,
                onPressed: () => this._searchHandler(this._keyword),
              )
            ),
          ],
        ),
        body: ListView(
          children: [
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
                      child: Text(
                        Globals.STRING_SEARCH_MODE_SUBHEADER,
                        style: TextStyle(
                          fontSize: 12,
                          color: Globals.globalTheme == 0 ? Colors.black54: Colors.white.withOpacity(0.60),
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () => this.setState(() {
                        this._selectSearchMode(SearchMode.album);
                        this._searchMode = SearchMode.album;
                      }),
                      leading: CircleAvatar(
                        child: ScaleTransition(child: Icon(Icons.album, color: this._scaleColor[0], size: 24,), scale: this._scaleAnimation[0]),
                        backgroundColor: Color(0x00000000),
                      ),
                      title: Text(
                        Globals.STRING_ALBUM,
                        style: TextStyle(
                          color: Globals.globalTheme == 0 ? Colors.black87: Colors.white.withOpacity(0.87),
                        ),
                      ),
                      subtitle: Text(
                        Globals.STRING_SEARCH_MODE_SUBTITLE_ALBUM, 
                        style: TextStyle(
                          fontSize: 12,
                          color: Globals.globalTheme == 0 ? Colors.black54: Colors.white.withOpacity(0.60),
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () => this.setState(() {
                        this._selectSearchMode(SearchMode.track);
                        this._searchMode = SearchMode.track;
                      }),
                      leading: CircleAvatar(
                        child: ScaleTransition(child: Icon(Icons.music_note, color: this._scaleColor[1], size: 24,), scale: this._scaleAnimation[1]),
                        backgroundColor: Color(0x00000000),
                      ),
                      title: Text(
                        Globals.STRING_TRACK,
                        style: TextStyle(
                          color: Globals.globalTheme == 0 ? Colors.black87: Colors.white.withOpacity(0.87),
                        ),
                      ),
                      subtitle: Text(
                        Globals.STRING_SEARCH_MODE_SUBTITLE_TRACK, 
                        style: TextStyle(
                          fontSize: 12,
                          color: Globals.globalTheme == 0 ? Colors.black54: Colors.white.withOpacity(0.60),
                        )
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
                      child: Text(
                        Globals.STRING_SEARCH_HISTORY_SUBHEADER,
                        style: TextStyle(
                          fontSize: 12,
                          color: Globals.globalTheme == 0 ? Colors.black54: Colors.white.withOpacity(0.60),
                        ),
                      ),
                    ),
                  ] + this._searchHistoryItems,
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class Search extends StatefulWidget {
  final Function refreshCollection;
  Search({Key key, @required this.refreshCollection}) : super(key : key);

  SearchState createState() => SearchState();
}


class SearchState extends State<Search> with SingleTickerProviderStateMixin {

  AnimationController _showController;
  Animation<Offset> _showAnimation;

  void showSearchBar() {
    this._showController.reverse();
  }

  void hideSearchBar() {
    this._showController.forward();
  }

  @override
  void dispose() {
    this._showController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    this._showController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 200),
    )..addListener(() => this.setState(() {}));
    this._showAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -0.28)).animate(
      new CurvedAnimation(
        curve: Curves.easeInCubic,
        reverseCurve: Curves.easeInCubic,
        parent: this._showController,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: this._showAnimation,
      child: Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 8 + MediaQuery.of(context).padding.top),
        child: Column(
          children: [
            OpenContainer(
              closedColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
              openColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
              closedElevation: 1,
              transitionDuration: Duration(milliseconds: 400),
              closedBuilder: (ctx, act) => Container(
                height: 56,
                color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.10),
                width: MediaQuery.of(context).size.width - 36.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.menu,
                          color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.87),
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          Globals.STRING_SEARCH_HEADER,
                          style: TextStyle(
                            fontSize: 16,
                            color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.87),
                          ),
                        ),
                      ),
                      Container(
                        height: 56,
                        width: 56,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.search,
                          color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.87),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              openBuilder: (ctx, act) => SearchScreen(refreshCollection: widget.refreshCollection,),
            ),
            ],
          ),
        ),
    );
  }
}