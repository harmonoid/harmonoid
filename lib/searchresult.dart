import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:async';

class SearchResult extends StatefulWidget {
  final String keyword;
  final String searchMode;
  
  SearchResult({Key key, @required this.keyword, @required this.searchMode}) : super(key : key);
  _SearchResult createState() => _SearchResult();
}

class _SearchResult extends State<SearchResult> with SingleTickerProviderStateMixin {

  AnimationController _searchProgressController;
  Animation<double> _searchProgressAnimation;
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
        this._welcomeOpacity = 1.0;
      }); 
    });
  }

  @override
  void initState() {
    super.initState();

    (() async {
      Uri uri = Uri.https('alexmercerind.herokuapp.com', '/search', {
        'keyword': widget.keyword,
        'mode' : widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1),
        'limit' : '10',
        'offset' : '0',
      });
      
      http.get(uri)
      .then((response) {
        this._albums = convert.jsonDecode(response.body)[widget.searchMode.toLowerCase()];

        int elementsPerRow = 2;
        List<Widget> rowChildren = new List<Widget>();
        for (int index = 1; index < 10; index++) { 
          rowChildren.add(
            Container(
              child: Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                child: Container(
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
                                this._albums[index]['${widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1)}_name'],
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
                              this._albums[index]['album_name'],
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
                )
              ),
            ),
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
              'Here is the most close ${widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1)} from your request...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            margin: EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: Container(
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
                              this._albums[0]['${widget.searchMode.toLowerCase().substring(0, widget.searchMode.length - 1)}_name'],
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
                              this._albums[0]['album_name'],
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
                          'DOWNLOAD ${widget.searchMode.toUpperCase().substring(0, widget.searchMode.length - 1)}',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      MaterialButton(
                        splashColor: Colors.deepPurple[50],
                        highlightColor: Colors.deepPurple[100],
                        onPressed: () {},
                        child: Text(
                          'SHOW ${widget.searchMode.toUpperCase().substring(0, widget.searchMode.length - 1)}',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
            child: Text(
              'More ${widget.searchMode.toLowerCase()} from the result...',
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
      .catchError((error) => print(error));
    })();

    this._searchProgressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..addListener(() {
      this.setState(() {});
    });
    this._searchProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(this._searchProgressController);

    this._searchProgressController.forward(); 
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
        SliverList(
          delegate: SliverChildListDelegate(this._sliverListDelegateList),
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
                    Text('Getting your music...', style: TextStyle(fontSize: 16, color: Colors.black87)),
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
    );
  }
}