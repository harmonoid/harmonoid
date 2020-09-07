import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:async';

import 'package:harmonoid/globals.dart' as Globals;
import 'package:harmonoid/searchalbumviewer.dart';

class SearchAlbumResultArguments {
  final String keyword;
  final String searchMode;
  final String searchTitle;
  SearchAlbumResultArguments(this.keyword, this.searchMode, this.searchTitle);
}

class SearchAlbumResults extends StatefulWidget {
  final String keyword;
  final String searchMode;
  final String searchTitle;
  static String pageRoute = '/searchresult';
  
  SearchAlbumResults({Key key, @required this.keyword, @required this.searchMode, @required this.searchTitle}) : super(key : key);
  _SearchAlbumResults createState() => _SearchAlbumResults();
}

class _SearchAlbumResults extends State<SearchAlbumResults> with TickerProviderStateMixin {

  SearchResultLabels _searchResultLabels;
  AnimationController _searchProgressController;
  Animation<double> _searchProgressAnimation;
  Animation<double> _searchResultOpacity;
  AnimationController _searchResultOpacityController;
  double _welcomeOpacity = 1.0;
  List _albums;
  List<Widget> _albumElements = new List<Widget>();
  bool _searchResultState = false;
  List<Widget> _sliverListDelegateList = [Container()];

  void switchLoaderResult() {
    this.setState(() {
      this._welcomeOpacity = 0.0;
      Timer(Duration(milliseconds: 200), () {
        this._searchResultState = true;
        Timer(Duration(milliseconds: 200), () => this._searchResultOpacityController.forward());
      }); 
    });
  }

  @override
  void initState() {
    super.initState();
    
    this._searchResultLabels = SearchResultLabels(widget.searchMode);

    (() async {
      Uri uri = Uri.https(Globals.STRING_HOME_URL, '/search', {
        'keyword': widget.keyword,
        'mode' : widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1),
        'limit' : '20',
        'offset' : '0',
      });
      
      http.get(uri)
      .then((response) {
        this._albums = convert.jsonDecode(response.body)[widget.searchMode.toLowerCase()];

        int elementsPerRow = MediaQuery.of(context).size.width ~/ 172.0;
        List<Widget> rowChildren = new List<Widget>();
        for (int index = 1; index < this._albums.length; index++) { 
          rowChildren.add(
            Container(
              margin: EdgeInsets.all(8),
              child: OpenContainer(
                closedElevation: 1,
                closedColor: Globals.globalTheme == 0 ? Colors.white : Color(0xFF121212),
                openColor: Globals.globalTheme == 0 ? Colors.white : Color(0xFF121212),
                transitionDuration: Duration(milliseconds: 400),
                closedBuilder: (ctx, act) => Container(
                  color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.10),
                  width: 156,
                  height: widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1) == 'track' ? 272 : 246,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 156,
                        width: 156,
                        child: Image.network(
                          this._albums[index]['album_art_640'],
                          height: 156,
                          width: 156,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 2, right: 2),
                        child: Column(
                          children: [
                            Divider(
                              color: Color(0x00000000),
                              height: 2,
                              thickness: 2,
                            ),
                            Container(
                              height: 38,
                              child: Text(
                                this._albums[index]['${widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1)}_name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Divider(
                              color: Color(0x00000000),
                              height: 8,
                              thickness: 8,
                            ),
                            widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1) == 'track' ? 
                            Text(
                              this._albums[index]['album_name'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ) :
                            Container(),
                            Text(
                              this._albums[index]['album_artists'].join(', '),
                              style: TextStyle(
                                fontSize: 14,
                                color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '(${this._albums[index]['year']})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            Divider(
                              color: Color(0x00000000),
                              height: 4,
                              thickness: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                openBuilder: (ctx, act) => SearchAlbumViewer(
                  albumJson: this._albums[index],
                ),
              ),
            )
          );
          if (rowChildren.length == elementsPerRow) {
            this._albumElements.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: rowChildren,
              ),
            );
            rowChildren = new List<Widget>();
          }
        }

        this._sliverListDelegateList = [
          Container(
            margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
            child: Text(
              _searchResultLabels.stringSearchResultTopSubheader,
              style: TextStyle(
                fontSize: 12,
                color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: OpenContainer(
              closedElevation: 1,
              transitionDuration: Duration(milliseconds: 400),
              closedColor: Globals.globalTheme == 0 ? Colors.white : Color(0xFF121212),
              openColor: Globals.globalTheme == 0 ? Colors.white : Color(0xFF121212),
              closedBuilder: (ctx, act) => Container(
                color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          this._albums[0]['album_art_640'],
                          height: 156,
                          width: 156,
                          fit: BoxFit.fill,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 18),
                          width: MediaQuery.of(context).size.width - 16 - 16 - 156,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                this._albums[0]['${widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1)}_name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.start,
                              ),
                              Divider(
                                color: Color(0x00000000),
                                height: 12,
                                thickness: 12,
                              ),
                              widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1) == 'track' ? 
                              Text(
                                this._albums[0]['album_name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.start,
                              ) :
                              Container(),
                              Divider(
                                color: Color(0x00000000),
                                height: 2,
                                thickness: 2,
                              ),
                              Text(
                                this._albums[0]['album_artists'].join(', '),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.start,
                              ),
                              Divider(
                                color: Color(0x00000000),
                                height: 2,
                                thickness: 2,
                              ),
                              Text(
                                '(${this._albums[0]['year']})',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ),
              openBuilder: (ctx, act) => SearchAlbumViewer(
                  albumJson: this._albums[0],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
            child: Text(
              _searchResultLabels.stringSearchResultOtherSubheader,
              style: TextStyle(
                fontSize: 12,
                color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
              ),
            ),
          ),
        ];

        this._sliverListDelegateList+=this._albumElements;

        switchLoaderResult();
      })
      .catchError((error) {
        this._sliverListDelegateList = [
          Container(
            height: 128,
            margin: EdgeInsets.all(36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.signal_cellular_connected_no_internet_4_bar, 
                  size: 64,
                  color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                ),
                Text(
                  Globals.STRING_INTERNET_ERROR,
                  style: TextStyle(
                    fontSize: 14,
                    color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                  ),
                )
              ],
            ),
          ),
        ];
        switchLoaderResult();
      });
    })();

    this._searchProgressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..addListener(() {
      this.setState(() {});
    });
    this._searchProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(this._searchProgressController);

    this._searchResultOpacityController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addListener(() {
      this.setState(() {});
    });
    this._searchResultOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(this._searchResultOpacityController);

    this._searchProgressController.forward(); 
  }

  @override void dispose() {
    this._searchProgressController.dispose(); 
    this._searchResultOpacityController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.globalTheme == 0 ? Colors.white : Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            brightness: Brightness.dark,
            backgroundColor: Globals.globalTheme == 0 ? Theme.of(context).primaryColor : Color.fromRGBO(42, 42, 42, 1),
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
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.searchTitle,
                style: TextStyle(
                  color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.87),
                ),
              ),
              background: Image.asset(
                'assets/images/${widget.searchMode.toLowerCase()}.jpg',
                fit: BoxFit.fitWidth,
              ),
            ),
            pinned: true,
            expandedHeight: 162,
          ),
          this._searchResultState ? 
          SliverOpacity(
            opacity: this._searchResultOpacity.value,
            sliver: SliverList(
              delegate: SliverChildListDelegate(this._sliverListDelegateList),
            ),
          )
          :
          SliverFillRemaining(
            child: Center(
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: this._welcomeOpacity,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        Globals.STRING_SEARCH_RESULT_LOADER_LABEL, 
                        style: TextStyle(
                        fontSize: 14,
                        color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                        ),
                      ),
                      Container(
                        width: 148,
                        height: 36,
                        alignment: Alignment.center,
                        child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
                          value: this._searchProgressAnimation.value,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ),
          ),
        ],
      ),
    );
  }
}


class SearchResultLabels {
  String stringSearchResultTopSubheader;
  String stringSearchResultTopButtonLabel0;
  String stringSearchResultTopButtonLabel1;
  String stringSearchResultOtherSubheader;

  SearchResultLabels(searchMode) {
    if (searchMode.toLowerCase() == 'albums') {
      this.stringSearchResultTopSubheader = Globals.STRING_SEARCH_RESULT_TOP_SUBHEADER_ALBUM;
      this.stringSearchResultTopButtonLabel0 = Globals.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_0_ALBUM;
      this.stringSearchResultTopButtonLabel1 = Globals.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_1_ALBUM;
      this.stringSearchResultOtherSubheader = Globals.STRING_SEARCH_RESULT_OTHER_SUBHEADER_ALBUM;
    }
    else if (searchMode.toLowerCase() == 'tracks') {
      this.stringSearchResultTopSubheader = Globals.STRING_SEARCH_RESULT_TOP_SUBHEADER_TRACK;
      this.stringSearchResultTopButtonLabel0 = Globals.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_0_TRACK;
      this.stringSearchResultTopButtonLabel1 = Globals.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_1_TRACK;
      this.stringSearchResultOtherSubheader = Globals.STRING_SEARCH_RESULT_OTHER_SUBHEADER_TRACK;
    }
    else if (searchMode.toLowerCase() == 'artists') {
      this.stringSearchResultTopSubheader = Globals.STRING_SEARCH_RESULT_TOP_SUBHEADER_ARTIST;
      this.stringSearchResultTopButtonLabel0 = Globals.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_0_ARTIST;
      this.stringSearchResultTopButtonLabel1 = Globals.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_1_ARTIST;
      this.stringSearchResultOtherSubheader = Globals.STRING_SEARCH_RESULT_OTHER_SUBHEADER_ARTIST;
    }
  }
}