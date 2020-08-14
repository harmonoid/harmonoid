import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:harmonoid/globals.dart';
import 'package:harmonoid/scripts/getsavedmusic.dart';
import 'package:harmonoid/scripts/addsavedmusic.dart';


class TrackElement extends StatefulWidget {
  final Function downloadTrack;
  final List<dynamic> albumTracks;
  final int index;
  final Map<String, dynamic> albumJson;
  TrackElement({Key key, @required this.index, @required this.albumTracks, @required this.albumJson, @required this.downloadTrack}) : super(key: key);
  TrackElementState createState() => TrackElementState();
}


class TrackElementState extends State<TrackElement> {

  Widget _leading;

  void switchLoader() {
    this.setState(() {
      this._leading =  CircularProgressIndicator();
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
    });
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
  }

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
        widget.downloadTrack(widget.albumTracks, widget.albumJson, widget.index);
      },
      title: Text(widget.albumTracks[widget.index]['track_name'].split('(')[0].trim().split('-')[0].trim()),
      subtitle: Text(widget.albumTracks[widget.index]['track_artists'].join(', ')),
      leading: this._leading,
      trailing: Text(this.trackDuration(widget.albumTracks[widget.index]['track_duration'])),
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
  Color _accentColor = Colors.black87;
  List<int> _downloadStack = new List<int>();
  List<GlobalKey<TrackElementState>> _trackKeyList = new List<GlobalKey<TrackElementState>>();
  List<int> _nonDownloadStack = new List<int>();
  ScrollController scrollController = new ScrollController();

  void refreshUI() {
    // print('Downloading    :' + _downloadStack.toString());
    // print('Non Downloading:' + _nonDownloadStack.toString());
    try {
      for (int trackNumber in this._downloadStack) {
        this._trackKeyList[trackNumber - 1].currentState.switchLoader();
      }
      for (int trackNumber in this._nonDownloadStack) {
        this._trackKeyList[trackNumber - 1].currentState.switchArt();
      }
    }
    catch(e) {}
  }

  Future<void> downloadTrack(albumTracks, albumJson, index) async {
    if (this._downloadStack.contains(albumTracks[index]['track_number'])) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_DOUBLE_TITLE),
          content: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_DOUBLE_SUBTITLE),
          actions: [
            MaterialButton(
              splashColor: Colors.deepPurple[50],
              highlightColor: Colors.deepPurple[100],
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
      this.addTrackStack(albumTracks[index]['track_number']);
      AddSavedMusic track = AddSavedMusic(
        albumTracks[index]['track_number'], 
        albumTracks[index]['track_id'], 
        albumJson
      );
      int result = await track.save();

      print('Download Status Code: ' + result.toString());

      if (result == 400) {
        GetSavedMusic.deleteTrack(albumJson['album_id'], albumTracks[index]['track_number']);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_TITLE),
            content: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_SUBTITLE),
            actions: [
              MaterialButton(
                splashColor: Colors.deepPurple[50],
                highlightColor: Colors.deepPurple[100],
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
        GetSavedMusic.deleteTrack(albumJson['album_id'], albumTracks[index]['track_number']);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_TITLE),
            content: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_SUBTITLE),
            actions: [
              MaterialButton(
                splashColor: Colors.deepPurple[50],
                highlightColor: Colors.deepPurple[100],
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
        GetSavedMusic.deleteTrack(albumJson['album_id'], albumTracks[index]['track_number']);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_SAVING_TITLE),
            content: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_SAVING_SUBTITLE),
            actions: [
              MaterialButton(
                splashColor: Colors.deepPurple[50],
                highlightColor: Colors.deepPurple[100],
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
      this.removeTrackStack(albumTracks[index]['track_number']);
      this._trackKeyList[albumTracks[index]['track_number'] - 1].currentState.switchArt();
    }
  }

  Future<bool> checkTrackStack() async {
    if (this._downloadStack.length == 0) {
      return true;
    }
    else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_BACK_TITLE),
          content: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_BACK_SUBTITLE),
          actions: [
            MaterialButton(
              splashColor: Colors.deepPurple[50],
              highlightColor: Colors.deepPurple[100],
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

  void addTrackStack(int trackNumber) {
    if (!(this._downloadStack.contains(trackNumber))) {
      this._downloadStack.add(trackNumber);
      this._nonDownloadStack.remove(trackNumber);
      this.refreshUI();
    }
  }
  void removeTrackStack(int trackNumber) {
    this._downloadStack.remove(trackNumber);
    this._nonDownloadStack.add(trackNumber);
    this.refreshUI();
  }
  void clearTrackStack(int trackNumber) {
    this._downloadStack.clear();
  }

  List<Widget> _albumTracks = [
    Container(
      margin: EdgeInsets.only(left: 16, top: 24, bottom: 18),
      child: Text(
        Globals.STRING_ALBUM_VIEW_TRACKS_SUBHEADER,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();

    for (int index = 0; index < widget.albumJson['album_length']; index++) {
      this._trackKeyList.add(new GlobalKey<TrackElementState>());
      _nonDownloadStack.add(index + 1);
    }

    scrollController.addListener(this.refreshUI);

    Future<Color> getImageColor (ImageProvider imageProvider) async {
      final PaletteGenerator paletteGenerator = await PaletteGenerator
          .fromImageProvider(imageProvider);
      return paletteGenerator.dominantColor.color;
    }
    this.setState(() {
      (() async => this._accentColor = await getImageColor(NetworkImage(widget.albumJson['album_art_64'])))(); 
    });

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
                            widget.albumJson['album_name'].split('(')[0].trim().split('-')[0].trim(),
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
                            widget.albumJson['album_artists'].join(', '),
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
                            '${widget.albumJson['year']}',
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
                            '${widget.albumJson['album_length']}' + ' '+ Globals.STRING_TRACK.toLowerCase(),
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
      );
      this._searchResultOpacityController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: this.checkTrackStack,
      child: Scaffold(
        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              backgroundColor: this._accentColor,
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
                    if (this._downloadStack.length == 0) {
                      Navigator.of(context).pop();
                    }
                    else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_BACK_TITLE),
                          content: Text(Globals.STRING_ALBUM_VIEW_DOWNLOAD_BACK_SUBTITLE),
                          actions: [
                            MaterialButton(
                              splashColor: Colors.deepPurple[50],
                              highlightColor: Colors.deepPurple[100],
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
                title: Text(widget.albumJson['album_name'].split('(')[0].trim().split('-')[0].trim()),
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
                    onEnd: () => this.setState(() {
                      this._loaderShowing = 0.0;
                    }),
                    duration: Duration(seconds: 8),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    curve: Curves.linear,
                    child: Text(Globals.STRING_ALBUM_VIEW_LOADER_LABEL, style: TextStyle(fontSize: 16, color: Colors.black87)),
                    builder: (context, value, child) => Container(
                      width: 148,
                      height: 36,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          child,
                          LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent[400],),
                            backgroundColor: Colors.deepPurpleAccent[100],
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