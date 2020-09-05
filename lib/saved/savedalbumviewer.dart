import 'dart:io';

import 'package:flutter/material.dart';

import 'package:harmonoid/scripts/getsavedmusic.dart';
import 'package:harmonoid/scripts/playsavedmusic.dart';
import 'package:harmonoid/globals.dart' as Globals;
import 'package:harmonoid/scripts/refreshcollection.dart';


class TrackElement extends StatelessWidget {

  final List<dynamic> albumTracks;
  final int index;
  final Map<String, dynamic> albumJson;
  final Function refresh;
  final Function refreshTracks;
  final File albumArt;
  TrackElement({Key key, @required this.index, @required this.albumTracks, @required this.albumJson, @required this.refresh, @required this.refreshTracks, @required this.albumArt}) : super(key: key);

  String trackDuration(int durationMilliseconds) {
    String trackDurationLabel;
    int durationSeconds = durationMilliseconds ~/ 1000;
    int minutes = durationSeconds ~/ 60;
    int seconds = durationSeconds - minutes * 60;
    if (seconds.toString().length == 2) {
      trackDurationLabel = minutes.toString() + ":" + seconds.toString();
    }
    else {
      trackDurationLabel = minutes.toString() + ":0" + seconds.toString();
    }
    return trackDurationLabel;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Scaffold.of(context).showSnackBar(SnackBar(
          elevation: 1,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            textColor: Colors.white,
            label: Globals.STRING_OK,
            onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
          ),
          duration: Duration(seconds: 2),
          content: Text('${Globals.STRING_NOW_PLAYING}: ${this.albumTracks[this.index]['track_name'].split('-')[0].trim()}'),
        ));
        (() async {
          await PlaySavedMusic.playTrack(this.albumJson['album_id'], this.albumTracks[this.index]['track_number']);
        })();
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
              title: Text(Globals.STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER),
              actions: [
                MaterialButton(
                  
                  onPressed: () {
                    (() async {
                      int result = await GetSavedMusic.deleteTrack(this.albumJson['album_id'], this.albumTracks[this.index]['track_number']);
                      await RefreshCollection.refreshAlbumsCollection();
                      this.refreshTracks();
                      if (result == 1) {
                        Navigator.of(context).pop();
                        await GetSavedMusic.deleteAlbum(this.albumJson['album_id']);
                        Navigator.of(context).pop();
                        await this.refresh();
                      }
                      else {
                        Navigator.of(context).pop();
                      }
                    })();
                  },
                  child: Text(
                    Globals.STRING_YES,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    Globals.STRING_NO,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
              content: Text(Globals.STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY),
          )
        );
      },
      title: Text(this.albumTracks[this.index]['track_name'].split('-')[0].trim()),
      subtitle: Text(this.albumTracks[this.index]['track_artists'].join(', ')),
      leading: CircleAvatar(
        child: Text(
          this.albumTracks[this.index]['track_number'].toString(),
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        backgroundImage: FileImage(
          this.albumArt,
        ),
      ),
      trailing: Text(this.trackDuration(this.albumTracks[this.index]['track_duration'])),
    );
  }
}


class SavedAlbumViewer extends StatefulWidget {
  final Function refresh;
  final Map<String, dynamic> albumJson;
  final File albumArt;
  final List<Widget> albumLeadings;
  final List<Widget> albumTracks;

  SavedAlbumViewer({Key key, @required this.albumLeadings, @required this.refresh, @required this.albumJson, @required this.albumArt, @required this.albumTracks}): super(key: key);
  SavedAlbumViewerState createState() => SavedAlbumViewerState();
}


class SavedAlbumViewerState extends State<SavedAlbumViewer> with TickerProviderStateMixin {

  List<TrackElement> _albumTracks;

  @override
  void initState() {
    super.initState();
    this._albumTracks = widget.albumTracks;
  }

  void refreshTracks(int trackIndex) {
    this.setState(() {
      for (int albumIndex = 0; albumIndex < this._albumTracks.length; albumIndex++) {
        if (this._albumTracks[albumIndex].index == trackIndex) {
          this._albumTracks.removeAt(albumIndex);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [
              Container(
                height: 56,
                width: 56,
                alignment: Alignment.center,
                child: IconButton(
                  iconSize: 24,
                  icon: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  splashRadius: 20,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                          title: Text(Globals.STRING_LOCAL_ALBUM_VIEW_ALBUM_DELETE_DIALOG_HEADER),
                          actions: [
                            MaterialButton(
                              splashColor: Colors.deepPurple[50],
                              highlightColor: Colors.deepPurple[100],
                              onPressed: () {
                                Navigator.of(context).pop();
                                (() async {
                                  await GetSavedMusic.deleteAlbum(widget.albumJson['album_id']);
                                  Navigator.of(context).pop();
                                  await RefreshCollection.refreshAlbumsCollection();
                                  await widget.refresh();
                                })();
                              },
                              child: Text(
                                Globals.STRING_YES,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                            MaterialButton(
                              splashColor: Colors.deepPurple[50],
                              highlightColor: Colors.deepPurple[100],
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                Globals.STRING_NO,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ],
                          content: Text(Globals.STRING_LOCAL_ALBUM_VIEW_ALBUM_DELETE_DIALOG_BODY),
                      )
                    );
                  },
                )
              ),
            ],
            backgroundColor: Theme.of(context).primaryColor,
            leading: Container(
              height: 56,
              width: 56,
              alignment: Alignment.center,
              child: IconButton(
                iconSize: 24,
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                splashRadius: 20,
                onPressed: () => Navigator.of(context).pop(),
              )
            ),
            pinned: true,
            expandedHeight: MediaQuery.of(context).size.width - MediaQuery.of(context).padding.top,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.albumJson['album_name'].split('(')[0].trim().split('-')[0].trim()),
              background: Image.file(
                widget.albumArt,
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              widget.albumLeadings + this._albumTracks,
            ),
          ),
        ],
      ),
    );
  }
}