import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:harmonoid/saved/savedalbumviewer.dart';
import 'package:harmonoid/scripts/getsavedmusic.dart';
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
        transitionDuration: Duration(milliseconds: 400),
        closedBuilder: (ctx, act) => Container(
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
                      color: Colors.white,
                      height: 2,
                      thickness: 2,
                    ),
                    Container(
                      height: 38,
                      child: Text(
                        this.albumJson['album_name'].split('(')[0].trim().split('-')[0].trim(),
                        style: TextStyle(
                          fontSize: 16,
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
                    Text(
                      this.albumJson['album_artists'].join(', '),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '(${this.albumJson['year']})',
                      style: TextStyle(
                        fontSize: 14,
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
              color: Colors.black38,
            ),
            Text(
              Globals.STRING_LOCAL_TOP_BODY_ALBUM_EMPTY,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
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

  List<dynamic> _albums;
  List<File> _albumArts;
  List<List<TrackElement>> _albumTracksList = new List<List<TrackElement>>();
  List<List<Widget>> _albumLeadingsList = new List<List<Widget>>();
  List<Widget> _albumElements = new List<Widget>();
  List<List<dynamic>> _tracksList = new List<List<dynamic>>();
  List<Widget> _listView = new List<Widget>();
  List<GlobalKey<SavedAlbumViewerState>> _albumsGlobalKey = new List<GlobalKey<SavedAlbumViewerState>>();

  Future<void> refresh() async {
    
    this._albums = (await GetSavedMusic.albums())['albums'];
    this._albumArts = await GetSavedMusic.albumArts();

    this._albumElements.clear();
    this._albumTracksList.clear();
    this._albumLeadingsList.clear();
    this._albumElements.clear();
    this._tracksList.clear();
    this._listView.clear();
    this._albumsGlobalKey.clear();

    if (this._albums.length == 0) {
      this.setState(() {
        this._listView = [
          NoResultsComponent(),
        ];
      });
    }
    else {
      for (int index = 0; index < this._albums.length; index++) {
        this._albumsGlobalKey.add(
          new GlobalKey<SavedAlbumViewerState>(),
        );
        this._tracksList.add(
          (await GetSavedMusic.tracks(this._albums[index]['album_id']))['tracks']
        );
      }

      this.setState(() {
        int elementsPerRow = MediaQuery.of(context).size.width ~/ 172.0;
        List<Widget> rowChildren = new List<Widget>();
        
        if (this._albums.length > 1) {
          bool incompleteRow = (this._albums.length) % elementsPerRow == 0 ? false : true;
          for (int index = 0; index < this._albums.length; index++) {
            List<TrackElement> albumTracks = [];
            List<Widget> albumLeadings = [
              Container(
                  margin: EdgeInsets.only(left: 16, top: 24, bottom: 18),
                  child: Text(
                    Globals.STRING_LOCAL_ALBUM_VIEW_INFO_SUBHEADER,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Card(
                  elevation: 1,
                  margin: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.file(
                          this._albumArts[index],
                          height: 128,
                          width: 128,
                          fit: BoxFit.fill,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 18),
                          width: MediaQuery.of(context).size.width - 16 - 16 - 128,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                this._albums[index]['album_name'].split('(')[0].trim().split('-')[0].trim(),
                                style: TextStyle(
                                  fontSize: 18,
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
                              Divider(
                                color: Colors.white,
                                height: 2,
                                thickness: 2,
                              ),
                              Text(
                                this._albums[index]['album_artists'].join(', '),
                                style: TextStyle(
                                  fontSize: 14,
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
                                '${this._albums[index]['year']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.start,
                              ),
                              Divider(
                                color: Colors.white,
                                height: 2,
                                thickness: 2,
                              ),
                              Text(
                                '${this._albums[index]['album_length']}' + ' '+ Globals.STRING_TRACK.toLowerCase(),
                                style: TextStyle(
                                  fontSize: 14,
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
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, top: 24, bottom: 18),
                child: Text(
                  Globals.STRING_LOCAL_ALBUM_VIEW_TRACKS_SUBHEADER,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            ];
            for (int albumIndex = 0; albumIndex < _tracksList[index].length; albumIndex++) {
              albumTracks.add(
                TrackElement(
                  index: albumIndex,
                  albumTracks: _tracksList[index],
                  albumJson: this._albums[index],
                  refresh: this.refresh,
                  refreshTracks: () => this._albumsGlobalKey[index].currentState.refreshTracks(albumIndex),
                  albumArt: this._albumArts[index],
                ),
              );
            }
            this._albumTracksList.add(albumTracks);
            this._albumLeadingsList.add(albumLeadings);
            rowChildren.add(
              AlbumTile(
                globalKey: this._albumsGlobalKey[index],
                refresh: this.refresh,
                albumArt: this._albumArts[index],
                albumJson: this._albums[index],
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
            for (int index = ((this._albums.length) - ((this._albums.length) % elementsPerRow)); index < this._albums.length; index++) {
              rowChildren.add(
                AlbumTile(
                  globalKey: this._albumsGlobalKey[index],
                  refresh: this.refresh,
                  albumArt: this._albumArts[index],
                  albumJson: this._albums[index],
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
            width: MediaQuery.of(context).size.width,
          ),
          Container(
            margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
            child: Text(
              Globals.STRING_LOCAL_TOP_SUBHEADER_ALBUM,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: OpenContainer(
              closedElevation: 1,
              transitionDuration: Duration(milliseconds: 400),
              closedBuilder: (ctx, act) => Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.file(
                      this._albumArts[this._albumArts.length - 1],
                      height: 156,
                      width: 156,
                      fit: BoxFit.fill,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 18),
                      width: MediaQuery.of(context).size.width - 16 - 16 - 156,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            this._albums[this._albumArts.length - 1]['album_name'].split('(')[0].trim().split('-')[0].trim(),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
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
                            this._albums[this._albumArts.length - 1]['album_artists'].join(', '),
                            style: TextStyle(
                              fontSize: 14,
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
                            '(${this._albums[this._albumArts.length - 1]['year']})',
                            style: TextStyle(
                              fontSize: 12,
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
              ),
              openBuilder: (ctx, act) => SavedAlbumViewer(
                key: this._albumsGlobalKey[this._albumArts.length - 1],
                refresh: this.refresh,
                albumJson: this._albums[this._albumArts.length - 1],
                albumArt: this._albumArts[this._albumArts.length - 1],
                albumLeadings: this._albumLeadingsList[this._albumArts.length - 1],
                albumTracks: this._albumTracksList[this._albumArts.length - 1],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
            child: Text(
              Globals.STRING_LOCAL_OTHER_SUBHEADER_ALBUM,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
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