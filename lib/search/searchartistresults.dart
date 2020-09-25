import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:harmonoid/search/searchartistviewer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:async';

import 'package:harmonoid/globals.dart' as Globals;


class SearchArtistResults extends StatefulWidget {
  final String keyword;
  static String pageRoute = '/searchartistresults';
  
  SearchArtistResults({Key key, @required this.keyword}) : super(key : key);
  _SearchArtistResults createState() => _SearchArtistResults();
}

class _SearchArtistResults extends State<SearchArtistResults> with TickerProviderStateMixin {

  AnimationController _searchProgressController;
  Animation<double> _searchProgressAnimation;
  Animation<double> _searchResultOpacity;
  AnimationController _searchResultOpacityController;
  double _welcomeOpacity = 1.0;
  List _artists;
  List<Widget> _albumElements = new List<Widget>();
  bool _searchResultState = false;
  List<Widget> _sliverListDelegateList = [Container()];
  List<String> _artistInfoLabel = ['', '', ''];

  void switchLoaderResult() {
    this.setState(() {
      this._welcomeOpacity = 0.0;
      Timer(Duration(milliseconds: 200), () {
        this._searchResultState = true;
        Timer(Duration(milliseconds: 200), () => this._searchResultOpacityController.forward());
      }); 
    });
  }

  Future<void> _artistInfo() async {
    Uri uri = Uri.https(Globals.STRING_HOME_URL, '/artistinfo', {
      'artist_id': this._artists[0]['artist_id']}
    );
    http.Response response = await http.get(uri);
    Map<String, dynamic> artistData = convert.jsonDecode(response.body);
    this._artistInfoLabel = [
      artistData['description'], 
      artistData['subscribers'] + ' ' + Globals.STRING_FOLLOWERS,
      artistData['views'].replaceAll('views', Globals.STRING_PLAYS),
    ];
  }

  @override
  void initState() {
    super.initState();
    
    (() async {
      Uri uri = Uri.https(Globals.STRING_HOME_URL, '/search', {
        'keyword': widget.keyword,
        'mode' : 'artist',
        'limit' : '20',
        'offset' : '0',
      });
      http.Response response = await http.get(uri);

      this._artists = convert.jsonDecode(response.body)['artists'];
      await this._artistInfo();
    })()
    .then((onSuccess) {
      
      int elementsPerRow = MediaQuery.of(context).size.width ~/ 172.0;
      List<Widget> rowChildren = new List<Widget>();
      for (int index = 1; index < this._artists.length; index++) { 
        rowChildren.add(
          Container(
            margin: EdgeInsets.all(8),
            child: OpenContainer(
              closedElevation: 1,
              closedColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
              openColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
              transitionDuration: Duration(milliseconds: 400),
              closedBuilder: (ctx, act) => Container(
                color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.10),
                width: 156,
                height: 216,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 156,
                      width: 156,
                      alignment: Alignment.center,
                      child: ClipOval(
                        child: Image.network(
                          this._artists[index]['artist_art_640'],
                          height: 138,
                          width: 138,
                        ),
                      ),
                    ),
                    Container(
                      height: 36,
                      margin: EdgeInsets.only(left: 2, right: 2),
                      alignment: Alignment.center,
                      child: Text(
                        this._artists[index]['artist_name'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              openBuilder: (ctx, act) => SearchArtistViewer(
                index: index,
                artists: this._artists,
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
            Globals.STRING_SEARCH_RESULT_TOP_SUBHEADER_ARTIST,
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
            closedColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
            openColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
            closedBuilder: (ctx, act) => Container(
              height: 156,
              color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        this._artists[0]['artist_art_640'],
                        height: 156,
                        width: 156,
                        fit: BoxFit.fill,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16),
                        height: 156,
                        width: MediaQuery.of(context).size.width - 16 - 16 - 156,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              this._artists[0]['artist_name'],
                              style: TextStyle(
                                fontSize: 18,
                                color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.start,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  this._artistInfoLabel[1],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                                  ),
                                ),
                                Text(
                                  this._artistInfoLabel[2],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ),
            openBuilder: (ctx, act) => SearchArtistViewer(
              index: 0,
              artists: this._artists,
              artistInfo: this._artistInfoLabel
            )
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
          child: Text(
            Globals.STRING_SEARCH_RESULT_OTHER_SUBHEADER_ARTIST,
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
      backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
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
                Globals.STRING_ARTIST,
                style: TextStyle(
                  color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.87),
                ),
              ),
              background: Image.asset(
                'assets/images/artists.jpg',
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
