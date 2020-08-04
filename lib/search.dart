import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/searchresult.dart';

enum SearchMode {
  album,
  track,
  artist,
}


class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key : key);
  _SearchScreen createState() => _SearchScreen();
}


class _SearchScreen extends State<SearchScreen> with TickerProviderStateMixin {

  List<Animation<double>> _scaleAnimation = new List<Animation<double>>(3);
  List<Color> _scaleColor = new List<Color>(3);
  List<AnimationController> _scaleController = new List<AnimationController>(3);

  String _keyword = '';

  void _selectSearchMode(SearchMode value) {
    for (int index = 0; index <= 2; index++) {
      this._scaleController[index].reverse();
      this._scaleColor[index] = Colors.black54;
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
      String resultTitle(SearchMode mode) {
        String resultTitle;
        if (mode == SearchMode.album) {
          resultTitle = 'Albums';
        }
        else if (mode == SearchMode.track) {
          resultTitle = 'Tracks';
        }
        else if (mode == SearchMode.artist) {
          resultTitle = 'Artists';
        }
        return resultTitle;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext ctx) => Scaffold(
            body: SearchResult(
              keyword: _keyword,
              searchMode: resultTitle(_searchMode),
            ),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    for (int index = 0; index<=2; index++){
      this._scaleColor[index] = Colors.black54;
      this._scaleController[index] = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
      );
      this._scaleAnimation[index] = Tween<double>(begin: 1.0, end: 1.5).animate(new CurvedAnimation(
        curve: Curves.easeInOutCubic,
        parent: this._scaleController[index],
      ));
    }
    Timer(Duration(milliseconds: 200), () {
      this._scaleController[0].forward();
      this._scaleColor[0] = Theme.of(context).primaryColor;
    });
  }

  SearchMode _searchMode = SearchMode.album;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          height: 56,
          width: 56,
          alignment: Alignment.center,
          child: IconButton(
            iconSize: 24,
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            splashRadius: 20,
            onPressed: () => Navigator.of(context).pop(),
          )
        ),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                height: 56,
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: TextField(
                  onSubmitted: (value) => this._searchHandler(this._keyword),
                  autocorrect: false,
                  autofocus: false,
                  cursorWidth: 1,
                  cursorColor: Colors.white,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  onChanged: (value) => this.setState(() {
                    this._keyword = value;
                  }),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                    labelText: 'Search Music',
                    hintText: 'Search Music',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ),
            Container(
              height: 56,
              width: 56,
              alignment: Alignment.center,
              child: IconButton(
                iconSize: 24,
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                splashRadius: 20,
                onPressed: () => this._searchHandler(this._keyword),
              )
            ),
          ],
        ),
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
                      'What are you looking for ?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () => this.setState(() {
                      _selectSearchMode(SearchMode.album);
                      this._searchMode = SearchMode.album;
                    }),
                    leading: ScaleTransition(child: Icon(Icons.album, color: this._scaleColor[0], size: 24,), scale: _scaleAnimation[0]),
                    title: Text('Albums'),
                    subtitle: Text('Search music from your favourite albums...'),
                  ),
                  ListTile(
                    onTap: () => this.setState(() {
                      _selectSearchMode(SearchMode.track);
                      this._searchMode = SearchMode.track;
                    }),
                    leading: ScaleTransition(child: Icon(Icons.music_note, color: this._scaleColor[1], size: 24,), scale: _scaleAnimation[1]),
                    title: Text('Tracks'),
                    subtitle: Text('Search for your favourite tracks...'),
                  ),
                  ListTile(
                    onTap: () => this.setState(() {
                      _selectSearchMode(SearchMode.artist);
                      this._searchMode = SearchMode.artist;
                    }),
                    leading: ScaleTransition(child: Icon(Icons.person, color: this._scaleColor[2], size: 24,), scale: _scaleAnimation[2]),
                    title: Text('Artists'),
                    subtitle: Text('Search music from your favourite artists...'),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
                    child: Text(
                      'Your recent searches...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              ),
          ],
        ),
      );
  }
}


class Search extends StatefulWidget {
  Search({Key key,}) : super(key : key);

  SearchState createState() => SearchState();
}


class SearchState extends State<Search> {

  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 36),
      child: Column(
        children: [
          OpenContainer(
            closedElevation: 2,
            transitionDuration: Duration(milliseconds: 400),
            closedBuilder: (ctx, act) => Container(
              height: 56,
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
                        color: Colors.black54,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Search Music',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54
                        ),
                      ),
                    ),
                    Container(
                      height: 56,
                      width: 56,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.search,
                        color: Colors.black54,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            openBuilder: (ctx, act) => SearchScreen(),
          ),
          ],
        ),
      );
  }
}