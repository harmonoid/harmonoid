import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/main.dart';
import 'package:harmonoid/search/searchalbumviewer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:harmonoid/globals.dart' as Globals;


class SearchArtistViewer extends StatefulWidget {
  final List<dynamic> artists;
  final List<dynamic> artistInfo;
  final index;
  SearchArtistViewer({Key key, @required this.index, @required this.artists, this.artistInfo}) : super(key : key);
  SearchArtistViewerState createState() => SearchArtistViewerState();
}


class SearchArtistViewerState extends State<SearchArtistViewer> with SingleTickerProviderStateMixin {
  List<Widget> albums = new List<Widget>();
  Widget albumsWidget = Center(
    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(Globals.globalContext).primaryColor)),
  );
  ScrollController _scrollController = new ScrollController();
  AnimationController aboutController;
  Animation<double> aboutTween;
  double _parallaxPosition = 0;
  List<String> artistInfo = ['', '', ''];

  Future<void> _artistInfo() async {
    Uri uri = Uri.https(Globals.STRING_HOME_URL, '/artistinfo', {
      'artist_id': widget.artists[widget.index]['artist_id']}
    );
    http.Response response = await http.get(uri);
    Map<String, dynamic> artistData = convert.jsonDecode(response.body);
    this.artistInfo = [
      artistData['description'], 
      artistData['subscribers'] + ' ' + Globals.STRING_FOLLOWERS, 
      artistData['views'].replaceAll('views', Globals.STRING_PLAYS),
    ];
  }

  @override
  void initState() {
    super.initState();

    this.aboutController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),  
      reverseDuration: Duration(milliseconds: 200),  
    );

    this.aboutTween = Tween<double>(begin: 0, end: 192).animate(
      new CurvedAnimation(
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
        parent: this.aboutController,
      )
    );

    this._scrollController.addListener(() {
      if (this._scrollController.position.pixels > 0) {
        this.setState(() {
          this._parallaxPosition = this._scrollController.position.pixels * 0.2;
        });
      }
    });

    (() async {
      Uri uri = Uri.https(Globals.STRING_HOME_URL, '/artistalbums', {
        'artist_id': widget.artists[widget.index]['artist_id'],
      });
      if (widget.artistInfo == null) {
        await this._artistInfo();
      } else {
        this.artistInfo = widget.artistInfo;
      }
      http.Response response = await http.get(uri);
      return convert.jsonDecode(response.body)['albums'];
    })()
    .then((_albums) {
      for (int index = 1; index < _albums.length; index++) { 
        this.albums.add(
          Container(
            child: OpenContainer(
              closedElevation: 1,
              closedColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
              openColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
              transitionDuration: Duration(milliseconds: 400),
              closedBuilder: (ctx, act) => Container(
                color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.10),
                width: 156,
                height: 246,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 156,
                      width: 156,
                      child: Image.network(
                        _albums[index]['album_art_640'],
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
                              _albums[index]['album_name'],
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
                          Text(
                            _albums[index]['album_artists'].join(', '),
                            style: TextStyle(
                              fontSize: 14,
                              color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '(${_albums[index]['year']})',
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
                albumJson: _albums[index],
              ),
            ),
          ),
        );
      }
      this.setState(() {
        this.albumsWidget = Column(
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: MediaQuery.of(Globals.globalContext).size.height - MediaQuery.of(Globals.globalContext).size.width, end: 0),
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              builder: (ctx, value, child) => Container(
                height: value,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: MediaQuery.of(context).size.width - 2 * (16 + 156),
                mainAxisSpacing: 16,
                children: this.albums,
                childAspectRatio: 156 / 246,
                clipBehavior: Clip.antiAlias,
              ),
            ),
          ],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.network(
            widget.artists[widget.index]['artist_art_640'],
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
          ),
          Positioned(
            top: MediaQuery.of(context).size.width - this._parallaxPosition > 0 ? MediaQuery.of(context).size.width - 256 - this._parallaxPosition : -256,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 256,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x00000000),
                        Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 1.0],
                    ),
                  ),
                ),
                Container(
                  color: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ],
            )
          ),
          ListView(
            controller: this._scrollController,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.width - 128,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 16 - 16,
                margin: EdgeInsets.only(left: 16, right: 16),
                child: Card(
                  color: Globals.globalTheme == 0 ? Colors.white : Color.fromRGBO(42, 42, 42, 1),
                  elevation: 1,
                  child: Container(
                    margin: EdgeInsets.only(top: 16, left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.artists[widget.index]['artist_name'],
                          style: TextStyle(
                            fontSize: 24,
                            color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                          ),
                        ),
                        Divider(
                          height: 18,
                          color: Color(0x00000000),
                        ),
                        Text(
                          this.artistInfo[1],
                          style: TextStyle(
                            fontSize: 14,
                            color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                          ),
                        ),
                        Divider(
                          height: 4,
                          color: Color(0x00000000),
                        ),
                        Text(
                          this.artistInfo[2],
                          style: TextStyle(
                            fontSize: 14,
                            color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                          ),
                        ),
                        Divider(
                          height: 18,
                          color: Color(0x00000000),
                        ),
                        Divider(
                          height: 1,
                        ),
                        Row(
                          children: [
                            /* IconButton(
                              iconSize: 24,
                              icon: Icon(
                                this.aboutTween.isDismissed ? Icons.expand_more : Icons.expand_less,
                                color: Globals.globalTheme == 0 ? Colors.black45 : Colors.white.withOpacity(0.38),
                              ),
                              splashRadius: 20,
                              onPressed: () {
                                (this.aboutTween.isDismissed ? this.aboutController.forward : this.aboutController.reverse)();
                                this.setState(() {});
                              },
                            ), 😉 */
                            Expanded(
                              child: ButtonBar(
                                alignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  MaterialButton(
                                    onPressed: () => Navigator.of(context).pushNamed(
                                      '/artisttrackviewer',
                                      arguments: ArtistTrackViewerArguments(widget.artists[widget.index]),
                                    ),
                                    child: Text(
                                      Globals.STRING_TOP_TRACKS,
                                      style: TextStyle(color: Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AnimatedBuilder(
                          animation: this.aboutTween,
                          child: Column(
                            children: [
                              Container(
                                height: (192.0 - 18.0),
                                child: ListView(
                                  children: [
                                    Text(
                                      this.artistInfo[0],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 18,
                                color: Color(0x00000000),
                              ),
                            ],
                          ),
                          builder: (ctx, child) => Container(
                            margin: EdgeInsets.only(right: 16),
                            height: this.aboutTween.value,
                            child: child,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                color: Color(0x00000000),
                height: 18,
              ),
              this.albumsWidget,
            ],
          ),
        ],
      )
    );
  }
}