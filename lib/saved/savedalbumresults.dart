import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:harmonoid/saved/savedalbumviewer.dart';
import 'package:harmonoid/globals.dart' as Globals;


class AlbumTile extends StatelessWidget {

  final File albumArt;
  final Function refresh;
  final Map<String, dynamic> albumJson;
  final List<TrackElement> albumTracks;
  final List<Widget> albumLeadings;
  final GlobalKey<SavedAlbumViewerState> globalKey;

  AlbumTile({Key key, @required this.albumLeadings, @required this.globalKey, @required this.albumArt,  @required this.albumJson, @required this.refresh, @required this.albumTracks});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      child: OpenContainer(
        closedElevation: 1,
        closedColor: Globals.globalTheme == 0 ? Colors.white : Color(0xFF121212),
        openColor: Globals.globalTheme == 0 ? Colors.white : Color(0xFF121212),
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
                  this.albumArt,
                  height: 156,
                  width: 156,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 2, right: 2),
                child: Column(
                  children: [
                    Divider(
                      color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.0),
                      height: 2,
                      thickness: 2,
                    ),
                    Container(
                      height: 38,
                      child: Text(
                        this.albumJson['album_name'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(
                      color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.0),
                      height: 8,
                      thickness: 8,
                    ),
                    Text(
                      this.albumJson['album_artists'].join(', '),
                      style: TextStyle(
                        fontSize: 14,
                        color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '(${this.albumJson['year']})',
                      style: TextStyle(
                        fontSize: 14,
                        color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    Divider(
                      color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.0),
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
          key: this.globalKey,
          refresh: this.refresh,
          albumJson: this.albumJson,
          albumArt: this.albumArt,
          albumLeadings: this.albumLeadings,
          albumTracks: this.albumTracks,
        ),
      ),
    );
  }
}


class NoResultsComponent extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 128,
        margin: EdgeInsets.only(top: 192),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.library_music, 
              size: 64,
              color: Globals.globalTheme == 0 ? Colors.black38 : Colors.white.withOpacity(0.38),
            ),
            Text(
              Globals.STRING_LOCAL_TOP_BODY_ALBUM_EMPTY,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.54),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class SavedAlbumResults extends StatefulWidget {
  final ScrollController scrollController;
  SavedAlbumResults({Key key, @required this.scrollController}) : super(key : key);
  SavedAlbumResultsState createState() => SavedAlbumResultsState();
}


class SavedAlbumResultsState extends State<SavedAlbumResults> with SingleTickerProviderStateMixin {

  List<List<TrackElement>> _albumTracksList = new List<List<TrackElement>>();
  List<List<Widget>> _albumLeadingsList = new List<List<Widget>>();
  List<Widget> _albumElements = new List<Widget>();
  List<Widget> _listView = new List<Widget>();
  List<GlobalKey<SavedAlbumViewerState>> _albumGlobalKeys = new List<GlobalKey<SavedAlbumViewerState>>();

  Future<void> refresh() async {

    this._albumElements.clear();
    this._albumTracksList.clear();
    this._albumLeadingsList.clear();
    this._albumElements.clear();
    this._listView.clear();
    this._albumGlobalKeys.clear();

    if (Globals.albums.length == 0) {
      this.setState(() {
        this._listView = [
          NoResultsComponent(),
        ];
      });
    }
    else {

      for (int index = 0; index < Globals.albums.length; index++) {
        this._albumGlobalKeys.add(
          new GlobalKey<SavedAlbumViewerState>(),
        );
      }

      this.setState(() {
        int elementsPerRow = MediaQuery.of(Globals.globalContext).size.width ~/ 172.0;
        List<Widget> rowChildren = new List<Widget>();
        
        if (Globals.albums.length >= 1) {
          bool incompleteRow = (Globals.albums.length) % elementsPerRow == 0 ? false : true;
          for (int index = 0; index < Globals.albums.length; index++) {
            List<TrackElement> albumTracks = [];
            List<Widget> albumLeadings = [
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
                          Globals.albumArts[index],
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
                                Globals.albums[index]['album_name'],
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
                                Globals.albums[index]['album_artists'].join(', '),
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
                                '${Globals.albums[index]['year']}',
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
                                '${Globals.albums[index]['album_length']}' + ' '+ Globals.STRING_TRACK.toLowerCase(),
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
            ];
            for (int albumIndex = 0; albumIndex < Globals.tracksList[index].length; albumIndex++) {
              albumTracks.add(
                TrackElement(
                  index: albumIndex,
                  albumTracks: Globals.tracksList[index],
                  albumJson: Globals.albums[index],
                  refresh: this.refresh,
                  refreshTracks: () => this._albumGlobalKeys[index].currentState.refreshTracks(albumIndex),
                  albumArt: Globals.albumArts[index],
                ),
              );
            }
            this._albumTracksList.add(albumTracks);
            this._albumLeadingsList.add(albumLeadings);
            rowChildren.add(
              AlbumTile(
                globalKey: this._albumGlobalKeys[index],
                refresh: this.refresh,
                albumArt: Globals.albumArts[index],
                albumJson: Globals.albums[index],
                albumTracks: this._albumTracksList[index],
                albumLeadings: this._albumLeadingsList[index],
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

          if (incompleteRow) {
            rowChildren = new List<Widget>();
            for (int index = ((Globals.albums.length) - ((Globals.albums.length) % elementsPerRow)); index < Globals.albums.length; index++) {
              rowChildren.add(
                AlbumTile(
                  globalKey: this._albumGlobalKeys[index],
                  refresh: this.refresh,
                  albumArt: Globals.albumArts[index],
                  albumJson: Globals.albums[index],
                  albumTracks: _albumTracksList[index],
                  albumLeadings: this._albumLeadingsList[index],
                ),
              );
            }
            for (int index = 0; index < elementsPerRow - (rowChildren.length - 1); index++) {
              rowChildren.add(
                Container(
                  margin: EdgeInsets.all(8),
                  child: Container(
                    width: 156,
                    height: 246,
                  ),
                )
              );
            }
            this._albumElements.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: rowChildren,
              ),
            );
          }
        }

        this._listView = [
          Container(
            height: 48,
            width: MediaQuery.of(Globals.globalContext).size.width,
          ),
          Container(
            margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
            child: Text(
              Globals.STRING_LOCAL_TOP_SUBHEADER_ALBUM,
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
              closedColor: Globals.globalTheme == 0 ? Colors.white : Color(0xFF121212),
              openColor: Globals.globalTheme == 0 ? Colors.white : Color(0xFF121212),
              transitionDuration: Duration(milliseconds: 400),
              closedBuilder: (ctx, act) => Container(
                color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.file(
                      Globals.albumArts[Globals.albumArts.length - 1],
                      height: 156,
                      width: 156,
                      fit: BoxFit.fill,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 18),
                      width: MediaQuery.of(Globals.globalContext).size.width - 16 - 16 - 156,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Globals.albums[Globals.albumArts.length - 1]['album_name'],
                            style: TextStyle(
                              fontSize: 18,
                              color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
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
                            Globals.albums[Globals.albumArts.length - 1]['album_artists'].join(', '),
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
                            '(${Globals.albums[Globals.albumArts.length - 1]['year']})',
                            style: TextStyle(
                              fontSize: 12,
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
              ),
              openBuilder: (ctx, act) => SavedAlbumViewer(
                key: this._albumGlobalKeys[Globals.albumArts.length - 1],
                refresh: this.refresh,
                albumJson: Globals.albums[Globals.albumArts.length - 1],
                albumArt: Globals.albumArts[Globals.albumArts.length - 1],
                albumLeadings: this._albumLeadingsList[Globals.albumArts.length - 1],
                albumTracks: this._albumTracksList[Globals.albumArts.length - 1],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
            child: Text(
              Globals.STRING_LOCAL_OTHER_SUBHEADER_ALBUM,
              style: TextStyle(
                fontSize: 12,
                color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
              ),
            ),
          ),
        ];
        this._listView.addAll(this._albumElements); 
      });
    }
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      scrollDirection: Axis.vertical,
      children: this._listView,
    );
  }
}