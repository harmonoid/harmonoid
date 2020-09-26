import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/scripts/addsavedmusic.dart';
import 'package:harmonoid/scripts/getsavedmusic.dart';
import 'package:harmonoid/search/searchalbumviewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as path;
import 'package:path/path.dart' as path;
import 'dart:convert' as convert;
import 'dart:async';

import 'package:harmonoid/globals.dart' as Globals;


class TrackElement extends StatefulWidget {
  final Function downloadTrack;
  final Function cancelDownloadTrack;
  final List<dynamic> tracks;
  final int index;
  TrackElement({Key key, @required this.index, @required this.tracks, @required this.downloadTrack, @required this.cancelDownloadTrack}) : super(key: key);
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
          widget.tracks[widget.index]['track_number'].toString(),
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        backgroundImage: NetworkImage(widget.tracks[widget.index]['album_art_64']),
      );
      this._trailing = true;
    });
  }

  Future<void> refreshSaved() async {
    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));
    if (
      (
        await File(
          path.join(musicDirectory.path, widget.tracks[widget.index]['album_id'], widget.tracks[widget.index]['track_number'].toString() + '.m4a')
        ).exists() || await File(
          path.join(musicDirectory.path, widget.tracks[widget.index]['album_id'], widget.tracks[widget.index]['track_number'].toString() + '.mp3')
        ).exists()
      )
      &&
      await File(
        path.join(musicDirectory.path, widget.tracks[widget.index]['album_id'], widget.tracks[widget.index]['track_number'].toString() + '.json')
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
        widget.tracks[widget.index]['track_number'].toString(),
        style: TextStyle(
          fontSize: 12,
        ),
      ),
      backgroundImage: NetworkImage(widget.tracks[widget.index]['album_art_64']),
    );
    this.refreshSaved();
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
      onTap: () => widget.downloadTrack(widget.tracks, widget.tracks[widget.index], widget.index, this._isSaved),
      title: Text(
        widget.tracks[widget.index]['track_name'],
        style: TextStyle(
          color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
        ),
      ),
      subtitle: Text(
        widget.tracks[widget.index]['track_artists'].join(', '),
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
          this.trackDuration(widget.tracks[widget.index]['track_duration']),
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
          int result = await GetSavedMusic.deleteTrack(widget.tracks[widget.index]['album_id'], widget.tracks[widget.index]['track_number']);
          if (result == 1) {
            await GetSavedMusic.deleteAlbum(widget.tracks[widget.index]['album_id']);
          }
        },
        icon: Icon(Icons.close),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}


class TrackElementHero extends StatefulWidget {
  final Function downloadTrack;
  final Function cancelDownloadTrack;
  final Map<String, dynamic> track;
  TrackElementHero({Key key, @required this.track, @required this.downloadTrack, @required this.cancelDownloadTrack}) : super(key: key);
  TrackElementStateHero createState() => TrackElementStateHero();
}


class TrackElementStateHero extends State<TrackElementHero> {

  bool _leading = false;
  bool _trailing = true;
  bool _isSaved = false;

  void switchLoader() {
    this.setState(() {
      this._trailing = false;
      this._leading =  true;
    });
  }

  void switchArt() {
    this.setState(() {
      this._leading = false;
      this._trailing = true;
    });
  }

  Future<void> refreshSaved() async {
    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));
    if (
      (
        await File(
          path.join(musicDirectory.path, widget.track['album_id'], widget.track['track_number'].toString() + '.m4a')
        ).exists() || await File(
          path.join(musicDirectory.path, widget.track['album_id'], widget.track['track_number'].toString() + '.mp3')
        ).exists()
      )
      &&
      await File(
        path.join(musicDirectory.path, widget.track['album_id'], widget.track['track_number'].toString() + '.json')
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
    this.refreshSaved();
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
    return Card(
      elevation: 1,
      color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.10),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            widget.track['album_art_640'],
            height: 156,
            width: MediaQuery.of(context).size.width - 32,
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
          ),
          Divider(
            color: Color(0x00000000),
            height: 16,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.track['track_name'],
                      style: TextStyle(
                        fontSize: 18,
                        color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                      ),
                    ),
                    Divider(
                      color: Color(0x00000000),
                      height: 4,
                    ),
                    Text(
                      widget.track['album_name'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                      ),
                    ),
                    Divider(
                      color: Color(0x00000000),
                      height: 4,
                    ),
                    Text(
                      widget.track['track_artists'].join(', '),
                      style: TextStyle(
                        fontSize: 14,
                        color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.only(right: 16),
                    child: this._trailing ? (this._isSaved ? Chip(
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
                      this.trackDuration(widget.track['track_duration']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                      ),
                    ),
                    backgroundColor: Color(0x00000000),
                  )) : IconButton(
                    splashRadius: 24,
                    onPressed: () async {
                      await widget.cancelDownloadTrack();
                      this.setState(() {
                        this._trailing = true; 
                      });
                      int result = await GetSavedMusic.deleteTrack(widget.track['album_id'], widget.track['track_number']);
                      if (result == 1) {
                        await GetSavedMusic.deleteAlbum(widget.track['album_id']);
                      }
                    },
                    icon: Icon(Icons.close),
                    color: Theme.of(context).primaryColor,
                  )
                  ),
                )
              ],
            )
          ),
          Divider(
            height: 8,
            color: Color(0x00000000),
          ),
          Divider(
            indent: 16,
            endIndent: 16,
            thickness: 1,
            height: 1,
            color: Globals.globalTheme == 0 ? Colors.black12 : Colors.white.withOpacity(0.12),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 32),
                child: this._leading ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(Globals.globalContext).primaryColor)) : Container(),
              ),
              Expanded(
                child: ButtonBar(
                  alignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    this._leading ? Container() :
                    MaterialButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (BuildContext ctx) => SearchAlbumViewer(
                          albumJson: widget.track,
                        )
                      )),
                      child: Text(
                        Globals.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_1_ALBUM,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    OutlineButton(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor
                      ),
                      onPressed: () => widget.downloadTrack([widget.track], widget.track, 0, this._isSaved),
                      child: Text(
                        Globals.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_0_TRACK,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class SearchTrackResults extends StatefulWidget {
  final String keyword;
  static String pageRoute = '/searchtrackresults';
  
  SearchTrackResults({Key key, @required this.keyword}) : super(key : key);
  _SearchTrackResults createState() => _SearchTrackResults();
}

class _SearchTrackResults extends State<SearchTrackResults> with TickerProviderStateMixin {

  AnimationController _searchProgressController;
  Animation<double> _searchProgressAnimation;
  Animation<double> _searchResultOpacity;
  AnimationController _searchResultOpacityController;
  double _welcomeOpacity = 1.0;
  List _tracks;
  List<Widget> _trackElements = new List<Widget>();
  bool _searchResultState = false;
  List<Widget> _sliverListDelegateList = [Container()];

  List<int> _downloadQueue = new List<int>();
  List<GlobalKey<dynamic>> _trackKeyList = new List<GlobalKey<dynamic>>();
  List<int> _nonDownloadQueue = new List<int>();
  List<StreamSubscription> _downloadTask;
  ScrollController scrollController = new ScrollController();

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

    this.scrollController.addListener(this.refreshUI);
    
    Uri uri = Uri.https(Globals.STRING_HOME_URL, '/search', {
      'keyword': widget.keyword,
      'mode' :'track',
      'limit' : '20',
      'offset' : '0',
    });
    
    http.get(uri)
    .then((response) {
      this._tracks = convert.jsonDecode(response.body)['tracks'];

      this._downloadTask = new List<StreamSubscription>(this._tracks.length);

      for (int index = 0; index < this._tracks.length; index++) {
        _nonDownloadQueue.add(index);
        if (index == 0) {
          this._trackKeyList.add(new GlobalKey<TrackElementStateHero>());
        }
        if (index != 0) {
          this._trackKeyList.add(new GlobalKey<TrackElementState>());
          this._trackElements.add(
            TrackElement(
              key: this._trackKeyList[index],
              index: index,
              tracks: this._tracks,
              downloadTrack: this.downloadTrack,
              cancelDownloadTrack: this.cancelDownloadTrack,
            ),
          );
        }
      }

      this._sliverListDelegateList = [
        Container(
          margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
          child: Text(
            Globals.STRING_SEARCH_RESULT_TOP_SUBHEADER_TRACK,
            style: TextStyle(
              fontSize: 12,
              color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
            ),
          ),
        ),
        TrackElementHero(
          key: this._trackKeyList[0],
          track: this._tracks[0],
          downloadTrack: this.downloadTrack,
          cancelDownloadTrack: this.cancelDownloadTrack,
        ),
        Container(
          margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
          child: Text(
            Globals.STRING_SEARCH_RESULT_OTHER_SUBHEADER_TRACK,
            style: TextStyle(
              fontSize: 12,
              color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
            ),
          ),
        ),
      ];

      this._sliverListDelegateList+=this._trackElements;

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

    this.scrollController.addListener(this.refreshUI);

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
    return WillPopScope(
      onWillPop: this.checkTrackQueue,
      child: Scaffold(
        backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
        body: CustomScrollView(
          controller: this.scrollController,
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
                  onPressed: () async {
                    if (await this.checkTrackQueue()) {
                      Navigator.of(context).pop();
                    }
                  }
                )
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  Globals.STRING_TRACK,
                  style: TextStyle(
                    color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.87),
                  ),
                ),
                background: Image.asset(
                  'assets/images/tracks.jpg',
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
      )
    );
  }

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
}
