import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:async';

import 'package:harmonoid/globals.dart';
import 'package:harmonoid/albumviewer.dart';

class SearchResultArguments {
  final String keyword;
  final String searchMode;
  SearchResultArguments(this.keyword, this.searchMode);
}

class SearchResult extends StatefulWidget {
  final String keyword;
  final String searchMode;
  static String pageRoute = '/searchresult';
  
  SearchResult({Key key, @required this.keyword, @required this.searchMode}) : super(key : key);
  _SearchResult createState() => _SearchResult();
}

class _SearchResult extends State<SearchResult> with TickerProviderStateMixin {

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
        'limit' : '10',
        'offset' : '0',
      });
      
      http.get(uri)
      .then((response) {
        this._albums = convert.jsonDecode(response.body)[widget.searchMode.toLowerCase()];

        int elementsPerRow = MediaQuery.of(context).size.width ~/ 172.0;
        List<Widget> rowChildren = new List<Widget>();
        for (int index = 1; index < 10; index++) { 
          rowChildren.add(
            Container(
              margin: EdgeInsets.all(8),
              child: OpenContainer(
                closedElevation: 2,
                closedBuilder: (ctx, act) => Container(
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
                          this._albums[index]['album_art_300'],
                          height: 156,
                          width: 156,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 2, right: 2),
                        child: Column(
                          children: [
                            Divider(
                              color: Colors.white,
                              height: 2,
                              thickness: 2,
                            ),
                            Container(
                              height: 38,
                              child: Text(
                                this._albums[index]['${widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1)}_name'].split('(')[0].trim(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Divider(
                              color: Colors.white,
                              height: 8,
                              thickness: 8,
                            ),
                            widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1) == 'track' ? 
                            Text(
                              this._albums[index]['album_name'].split('(')[0].trim(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ) :
                            Container(),
                            Text(
                              this._albums[index]['album_artists'].join(', '),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '(${this._albums[index]['year']})',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            Divider(
                              color: Colors.white,
                              height: 4,
                              thickness: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                openBuilder: (ctx, act) => AlbumViewer(
                  albumId: this._albums[index]['album_id'],
                  headerName: this._albums[index]['${widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1)}_name'].split('(')[0].trim(),
                  albumArt: this._albums[index]['album_art_300'],
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
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: OpenContainer(
              closedBuilder: (ctx, act) => Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          this._albums[0]['album_art_300'],
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
                                this._albums[0]['${widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1)}_name'].split('(')[0].trim(),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.start,
                              ),
                              Divider(
                                color: Colors.white,
                                height: 12,
                                thickness: 12,
                              ),
                              widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1) == 'track' ? 
                              Text(
                                this._albums[0]['album_name'].split('(')[0].trim(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.start,
                              ) :
                              Container(),
                              Divider(
                                color: Colors.white,
                                height: 2,
                                thickness: 2,
                              ),
                              Text(
                                this._albums[0]['album_artists'].join(', '),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.start,
                              ),
                              Divider(
                                color: Colors.white,
                                height: 2,
                                thickness: 2,
                              ),
                              Text(
                                '(${this._albums[0]['year']})',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.black12,
                      height: 1,
                      thickness: 1,
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        MaterialButton(
                          splashColor: Colors.deepPurple[50],
                          highlightColor: Colors.deepPurple[100],
                          onPressed: () {},
                          child: Text(
                            _searchResultLabels.stringSearchResultTopButtonLabel0,
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                        ),
                        MaterialButton(
                          splashColor: Colors.deepPurple[50],
                          highlightColor: Colors.deepPurple[100],
                          onPressed: () {},
                          child: Text(
                            _searchResultLabels.stringSearchResultTopButtonLabel1,
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ),
              openBuilder: (ctx, act) => AlbumViewer(
                  albumId: this._albums[0]['album_id'],
                  headerName: this._albums[0]['${widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1)}_name'].split('(')[0].trim(),
                  albumArt: this._albums[0]['album_art_300'],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
            child: Text(
              _searchResultLabels.stringSearchResultOtherSubheader,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
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
                  color: Colors.black54,
                ),
                Text(
                  Globals.STRING_INTERNET_ERROR,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
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
              title: Text(widget.searchMode),
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
                  width: 148,
                  height: 36,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(Globals.STRING_SEARCH_RESULT_LOADER_LABEL, style: TextStyle(fontSize: 16, color: Colors.black87)),
                      LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent[400],),
                        backgroundColor: Colors.deepPurpleAccent[100],
                        value: this._searchProgressAnimation.value,
                      ),
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