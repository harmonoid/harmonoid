import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:harmonoid/globals.dart' as Globals;
import 'package:harmonoid/scripts/getsavedmusic.dart';
import 'package:harmonoid/scripts/addsavedmusic.dart';


class TrackElement extends StatefulWidget {
  final Function downloadTrack;
  final Function cancelDownloadTrack;
  final List<dynamic> albumTracks;
  final int index;
  final Map<String, dynamic> albumJson;
  TrackElement({Key key, @required this.index, @required this.albumTracks, @required this.albumJson, @required this.downloadTrack, this.cancelDownloadTrack}) : super(key: key);
  TrackElementState createState() => TrackElementState();
}


class TrackElementState extends State<TrackElement> {

  Widget _leading;
  bool _trailing = true;
  bool _isSaved = false;

  void switchLoader() {
    this.setState(() {
      this._trailing = false;
      this._leading =  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(Globals.globalContext).primaryColor));
    });
  }

  void switchArt() {
    this.setState(() {
      this._leading = CircleAvatar(
        child: Text(
          widget.albumTracks[widget.index]['track_number'].toString(),
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        backgroundImage: NetworkImage(widget.albumJson['album_art_64']),
      );
      this._trailing = true;
    });
  }

  Future<void> refreshSaved() async {
    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));
    if (
      await File(
        path.join(musicDirectory.path, widget.albumJson['album_id'], widget.albumTracks[widget.index]['track_number'].toString() + '.m4a')
      ).exists()
      &&
      await File(
        path.join(musicDirectory.path, widget.albumJson['album_id'], widget.albumTracks[widget.index]['track_number'].toString() + '.json')
      ).exists()
    ) {
      this.setState(() => this._isSaved = true);
    }
    else {
      this.setState(() => this._isSaved = false);
    }
  }

  @override
  void initState() {
    super.initState();
    this._leading = CircleAvatar(
      child: Text(
        widget.albumTracks[widget.index]['track_number'].toString(),
        style: TextStyle(
          fontSize: 12,
        ),
      ),
      backgroundImage: NetworkImage(widget.albumJson['album_art_64']),
    );
    this.refreshSaved();
  }

  String trackDuration(int durationMilliseconds) {
    String trackDurationLabel;
    int durationSeconds = durationMilliseconds ~/ 1000;
    int minutes = durationSeconds ~/ 60;
    int seconds = durationSeconds - minutes * 60 - 1;
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
      onTap: () => widget.downloadTrack(widget.albumTracks, widget.albumJson, widget.index, this._isSaved),
      title: Text(
        widget.albumTracks[widget.index]['track_name'],
        style: TextStyle(
          color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
        ),
      ),
      subtitle: Text(
        widget.albumTracks[widget.index]['track_artists'].join(', '),
        style: TextStyle(
          color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
        ),
      ),
      leading: this._leading,
      trailing: this._trailing ? this._isSaved ? Chip(
        avatar: CircleAvatar(
          child: Icon(
            Icons.arrow_downward,
            color: Colors.white,
          ),
          backgroundColor: Color(0x00000000),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        label: Text(
          Globals.STRING_SAVED,
        ),
        labelStyle: TextStyle(
          color: Colors.white,
        ),
      ):
      CircleAvatar(
        child: Text(
          this.trackDuration(widget.albumTracks[widget.index]['track_duration']),
          style: TextStyle(
            fontSize: 12,
            color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
          ),
        ),
        backgroundColor: Color(0x00000000),
      ) : IconButton(
        splashRadius: 24,
        onPressed: () async {
          await widget.cancelDownloadTrack(widget.index);
          this.setState(() {
            this._trailing = true; 
          });
          int result = await GetSavedMusic.deleteTrack(widget.albumJson['album_id'], widget.albumTracks[widget.index]['track_number']);
          if (result == 1) {
            await GetSavedMusic.deleteAlbum(widget.albumJson['album_id']);
          }
        },
        icon: Icon(Icons.close),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}


class SearchAlbumViewer extends StatefulWidget {
  final Map<String, dynamic> albumJson;

  SearchAlbumViewer({Key key, @required this.albumJson}): super(key: key);
  _SearchAlbumViewer createState() => _SearchAlbumViewer();
}


class _SearchAlbumViewer extends State<SearchAlbumViewer> with SingleTickerProviderStateMixin {
  
  double _loaderShowing = 1.0;
  Animation<double> _searchResultOpacity;
  AnimationController _searchResultOpacityController;
  Color _accentColor = Theme.of(Globals.globalContext).primaryColor;
  List<int> _downloadQueue = new List<int>();
  List<GlobalKey<TrackElementState>> _trackKeyList = new List<GlobalKey<TrackElementState>>();
  List<int> _nonDownloadQueue = new List<int>();
  ScrollController scrollController = new ScrollController();
  List<StreamSubscription> _downloadTask;

  void refreshUI() {
    try {
      for (int trackIndex in this._downloadQueue) {
        this._trackKeyList[trackIndex].currentState.switchLoader();
      }
      for (int trackIndex in this._nonDownloadQueue) {
        this._trackKeyList[trackIndex].currentState.switchArt();
      }
    }
    catch(e) {}
  }

  Future<void> cancelDownloadTrack(int trackIndex) async {
    await this._downloadTask[trackIndex].cancel();
    this.removeTrackQueue(trackIndex);
    this._trackKeyList[trackIndex].currentState.switchArt();
    this._trackKeyList[trackIndex].currentState.refreshSaved();
  }

  Future<void> downloadTrack(albumTracks, albumJson, index, isSaved) async {
    Future<void> proceedDownload() async {
      if (this._downloadQueue.contains(index)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
            title: Text(
              Globals.STRING_ALBUM_VIEW_DOWNLOAD_DOUBLE_TITLE,
              style: TextStyle(
                color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
              ),
            ),
            content: Text(
              Globals.STRING_ALBUM_VIEW_DOWNLOAD_DOUBLE_SUBTITLE,
              style: TextStyle(
                color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
              ),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  Globals.STRING_OK,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          )
        );
      }
      else {
        this.addTrackQueue(index);
        AddSavedMusic track = AddSavedMusic(
          albumTracks[index]['track_number'], 
          albumTracks[index]['track_id'], 
          albumJson
        );
        this._downloadTask[index] = track.save().asStream().listen((result) async {
          if (result == 400) {
            int deleteResult = await GetSavedMusic.deleteTrack(albumJson['album_id'], albumTracks[index]['track_number']);
            if (deleteResult == 1) {
              await GetSavedMusic.deleteAlbum(albumJson['album_id']);
            }
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
                title: Text(
                  Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_TITLE,
                  style: TextStyle(
                    color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                  ),
                ),
                content: Text(
                  Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_SUBTITLE,
                  style: TextStyle(
                    color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                  ),
                ),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      Globals.STRING_OK,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              )
            );
          }
          else if (result == 500) {
            int deleteResult = await GetSavedMusic.deleteTrack(albumJson['album_id'], albumTracks[index]['track_number']);
            if (deleteResult == 1) {
              await GetSavedMusic.deleteAlbum(albumJson['album_id']);
            }
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
                title: Text(
                  Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_TITLE,
                  style: TextStyle(
                    color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                  ),
                ),
                content: Text(
                  Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_SUBTITLE,
                  style: TextStyle(
                    color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                  ),
                ),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      Globals.STRING_OK,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              )
            );
          }
          else if (result == 403) {
            int deleteResult = await GetSavedMusic.deleteTrack(albumJson['album_id'], albumTracks[index]['track_number']);
            if (deleteResult == 1) {
              await GetSavedMusic.deleteAlbum(albumJson['album_id']);
            }
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
                title: Text(
                  Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_SAVING_TITLE,
                  style: TextStyle(
                    color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                  ),
                ),
                content: Text(
                  Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_SAVING_SUBTITLE,
                  style: TextStyle(
                    color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                  ),
                ),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      Globals.STRING_OK,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              )
            );
          }
          this.removeTrackQueue(index);
          this._trackKeyList[index].currentState.switchArt();
          this._trackKeyList[index].currentState.refreshSaved();
        });
      }
    }
    if (isSaved) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
          title: Text(
            Globals.STRING_ALBUM_VIEW_DOWNLOAD_ALREADY_SAVED_TITLE,
            style: TextStyle(
              color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
            ),
          ),
          content: Text(
            Globals.STRING_ALBUM_VIEW_DOWNLOAD_ALREADY_SAVED_SUBTITLE,
            style: TextStyle(
              color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await proceedDownload();
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
        )
      );
    }
    else {
      await proceedDownload();
    }
  }

  Future<bool> checkTrackQueue() async {
    if (this._downloadQueue.length == 0) {
      return true;
    }
    else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
          title: Text(
            Globals.STRING_ALBUM_VIEW_DOWNLOAD_BACK_TITLE,
            style: TextStyle(
              color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
            ),
          ),
          content: Text(
            Globals.STRING_ALBUM_VIEW_DOWNLOAD_BACK_SUBTITLE,
            style: TextStyle(
              color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                Globals.STRING_OK,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        )
      );
      return false;
    }
  }

  void addTrackQueue(int trackIndex) {
    if (!(this._downloadQueue.contains(trackIndex))) {
      this._downloadQueue.add(trackIndex);
      this._nonDownloadQueue.remove(trackIndex);
      this.refreshUI();
    }
  }
  void removeTrackQueue(int trackIndex) {
    this._downloadQueue.remove(trackIndex);
    this._nonDownloadQueue.add(trackIndex);
    this.refreshUI();
  }
  void clearTrackQueue(int trackIndex) {
    this._downloadQueue.clear();
  }

  List<Widget> _albumTracks = [
    Container(
      margin: EdgeInsets.only(left: 16, top: 24, bottom: 18),
      child: Text(
        Globals.STRING_ALBUM_VIEW_TRACKS_SUBHEADER,
        style: TextStyle(
          fontSize: 12,
          color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();

    this._downloadTask = new List<StreamSubscription>(widget.albumJson['album_length']);

    for (int index = 0; index < widget.albumJson['album_length']; index++) {
      this._trackKeyList.add(new GlobalKey<TrackElementState>());
      _nonDownloadQueue.add(index);
    }

    scrollController.addListener(this.refreshUI);

    this._searchResultOpacityController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addListener(() {
      this.setState(() {});
    });
    this._searchResultOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(this._searchResultOpacityController);

    Uri uri = Uri.https(Globals.STRING_HOME_URL, '/albuminfo', {'album_id': widget.albumJson['album_id']});
    http.get(uri)
    .then((response) {
      List<dynamic> albumTracks = convert.jsonDecode(response.body)['tracks'];
      for (int index = 0; index < albumTracks.length; index++) {
        this._albumTracks.add(
          TrackElement(
            key: this._trackKeyList[index],
            index: index,
            albumTracks: albumTracks,
            albumJson: widget.albumJson,
            downloadTrack: this.downloadTrack,
            cancelDownloadTrack: this.cancelDownloadTrack,
          ),
        );
      }
      this.setState(() {
        this._loaderShowing = 0.0;
        this._albumTracks.insertAll(0, 
          [
            Container(
              margin: EdgeInsets.only(left: 16, top: 24, bottom: 18),
              child: Text(
                Globals.STRING_ALBUM_VIEW_INFO_SUBHEADER,
                style: TextStyle(
                  fontSize: 12,
                  color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                ),
              ),
            ),
            Card(
              elevation: 1,
              color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.10),
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      widget.albumJson['album_art_640'],
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
                            widget.albumJson['album_name'],
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
                            widget.albumJson['album_artists'].join(', '),
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
                            '${widget.albumJson['year']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
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
                            '${widget.albumJson['album_length']}' + ' '+ Globals.STRING_TRACK.toLowerCase(),
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
            ),
          ),
        ]
      );
      });
      this._searchResultOpacityController.forward();
    })
    .catchError((error) {
      this._albumTracks.add(
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
                  fontSize: 16,
                  color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                ),
              )
            ],
          ),
        ),
      );
      this._searchResultOpacityController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: this.checkTrackQueue,
      child: Scaffold(
        backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
        body: CustomScrollView(
          controller: scrollController,
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
                    Icons.close,
                    color: Colors.white,
                  ),
                  splashRadius: 20,
                  onPressed: () {
                    if (this._downloadQueue.length == 0) {
                      Navigator.of(context).pop();
                    }
                    else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
                          title: Text(
                            Globals.STRING_ALBUM_VIEW_DOWNLOAD_BACK_TITLE,
                            style: TextStyle(
                              color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                            ),
                          ),
                          content: Text(
                            Globals.STRING_ALBUM_VIEW_DOWNLOAD_BACK_SUBTITLE,
                            style: TextStyle(
                              color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                            ),
                          ),
                          actions: [
                            MaterialButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                Globals.STRING_OK,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ],
                        )
                      );
                    }
                  },
                ),
              ),
              pinned: true,
              expandedHeight: MediaQuery.of(context).size.width - MediaQuery.of(context).padding.top,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.albumJson['album_name'][0] == '(' ? widget.albumJson['album_name']: widget.albumJson['album_name'].split('(')[0].trim().split('-')[0].trim(),
                  style: TextStyle(
                    color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.87),
                  ),
                ),
                background: Image.network(
                  widget.albumJson['album_art_640'],
                  height: MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            this._loaderShowing != 0.0 ?
            SliverFillRemaining(
              child: Center(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: this._loaderShowing,
                  child: TweenAnimationBuilder(
                    duration: Duration(seconds: 8),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    curve: Curves.linear,
                    child: Text(
                      Globals.STRING_ALBUM_VIEW_LOADER_LABEL,
                      style: TextStyle(
                        fontSize: 16, 
                        color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                      ),
                    ),
                    builder: (context, value, child) => Container(
                      width: 148,
                      height: 36,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          child,
                          LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
                            value: value,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            :
            SliverOpacity(
              opacity: this._searchResultOpacity.value,
              sliver: SliverList(
                delegate: SliverChildListDelegate(this._albumTracks),
              ),
            ),
          ],
        ),
      ),
    );
  }
}