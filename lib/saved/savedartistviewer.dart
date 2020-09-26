import 'dart:io';
import 'package:harmonoid/saved/savedalbumviewer.dart';
import 'package:path/path.dart' as path;
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/globals.dart' as Globals;


class SavedArtistViewer extends StatefulWidget {
  final String albumArtPath;
  final int index;
  SavedArtistViewer({Key key, @required this.albumArtPath, @required this.index}) : super(key : key);
  SavedArtistViewerState createState() => SavedArtistViewerState();
}


class SavedArtistViewerState extends State<SavedArtistViewer> with SingleTickerProviderStateMixin {
  List<Widget> albums = new List<Widget>();
  Widget albumsWidget = Center(
    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(Globals.globalContext).primaryColor)),
  );
  ScrollController _scrollController = new ScrollController();
  AnimationController aboutController;
  Animation<double> aboutTween;
  double _parallaxPosition = 0;
  List<GlobalKey<SavedAlbumViewerState>> _albumGlobalKeys = new List<GlobalKey<SavedAlbumViewerState>>();
  List<dynamic> albumTracksMutable = [];
  String artistMutable = ''; 
  List<dynamic> albumsMutable = [];

  Future<void> refresh() async {
    this._albumGlobalKeys.clear();
    this.albums.clear();
    this.albumTracksMutable.clear();
    this.albumsMutable.clear();

    this.albumTracksMutable = Globals.artistTracksList[widget.index];
    this.artistMutable = Globals.artists[widget.index]['artist']; 
    this.albumsMutable = Globals.artists[widget.index]['albums'];

    this._scrollController.addListener(() {
      if (this._scrollController.position.pixels > 0) {
        this.setState(() {
          this._parallaxPosition = this._scrollController.position.pixels * 0.4;
        });
      }
    });

    for (int index = 0; index < this.albumsMutable.length; index++) {
      List<TrackElement> albumTracks = new List<TrackElement>();
      this._albumGlobalKeys.add(new GlobalKey<SavedAlbumViewerState>());
      for (int albumIndex = 0; albumIndex < this.albumTracksMutable[index].length; albumIndex++) {
        albumTracks.add(
          TrackElement(
            index: albumIndex,
            albumTracks: this.albumTracksMutable[index],
            albumJson: this.albumsMutable[index],
            refresh: this.refresh,
            refreshTracks: () => this._albumGlobalKeys[index].currentState.refreshTracks(albumIndex),
            albumArt: File(path.join(widget.albumArtPath, this.albumsMutable[index]['album_id'], 'albumArt.png')),
          ),
        );
      }
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
                    child: Image.file(
                      File(path.join(widget.albumArtPath, this.albumsMutable[index]['album_id'], 'albumArt.png')),
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
                            this.albumsMutable[index]['album_name'],
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
                          this.albumsMutable[index]['album_artists'].join(', '),
                          style: TextStyle(
                            fontSize: 14,
                            color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '(${this.albumsMutable[index]['year']})',
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
            openBuilder: (ctx, act) => SavedAlbumViewer(
              key: this._albumGlobalKeys[index],
              refresh: this.refresh,
              albumTracks: albumTracks,
              albumJson: this.albumsMutable[index],
              albumArt: File(path.join(widget.albumArtPath, this.albumsMutable[index]['album_id'], 'albumArt.png')),
              albumLeadings: [
                Container(
                  margin: EdgeInsets.only(left: 16, top: 24, bottom: 18),
                  child: Text(
                    Globals.STRING_LOCAL_ALBUM_VIEW_INFO_SUBHEADER,
                    style: TextStyle(
                      fontSize: 12,
                      color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                    ),
                  ),
                ),
                Card(
                  elevation: 1,
                  color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.10),
                  margin: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.file(
                          File(path.join(widget.albumArtPath, this.albumsMutable[index]['album_id'], 'albumArt.png')),
                          height: 128,
                          width: 128,
                          fit: BoxFit.fill,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 18),
                          width: MediaQuery.of(Globals.globalContext).size.width - 16 - 16 - 128,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                this.albumsMutable[index]['album_name'],
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
                              Divider(
                                color: Color(0x00000000),
                                height: 2,
                                thickness: 2,
                              ),
                              Text(
                                this.albumsMutable[index]['album_artists'].join(', '),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.54),
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
                                '${this.albumsMutable[index]['year']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.54),
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.start,
                              ),
                              Divider(
                                color: Color(0x00000000),
                                height: 2,
                                thickness: 2,
                              ),
                              Text(
                                '${this.albumsMutable[index]['album_length']}' + ' '+ Globals.STRING_TRACK.toLowerCase(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.54),
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 16, top: 24, bottom: 18),
                  child: Text(
                    Globals.STRING_LOCAL_ALBUM_VIEW_TRACKS_SUBHEADER,
                    style: TextStyle(
                      fontSize: 12,
                      color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                    ),
                  ),
                ),
              ],
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
            margin: EdgeInsets.only(left: 18, right: 18),
            child: GridView.count(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: MediaQuery.of(Globals.globalContext).size.width - 2 * (16 + 156),
              mainAxisSpacing: 16,
              children: this.albums,
              childAspectRatio: 156 / 246,
              clipBehavior: Clip.antiAlias,
            ),
          ),
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.file(
            File(path.join(widget.albumArtPath, this.albumsMutable[0]['album_id'], 'albumArt.png')),
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
                    padding: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          this.artistMutable,
                          style: TextStyle(
                            fontSize: 24,
                            color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16, bottom: 16),
                          child: Text(
                            'Here are the saved albums from this artist',
                            style: TextStyle(
                              fontSize: 12,
                              color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                            ),
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