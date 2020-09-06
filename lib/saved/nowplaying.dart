import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';

import 'package:harmonoid/globals.dart' as Globals;


class NowPlaying extends StatefulWidget {
  NowPlaying({Key key}) : super(key : key);
  NowPlayingState createState() => NowPlayingState();
}


class NowPlayingState extends State<NowPlaying> with TickerProviderStateMixin {

  String _albumArt;
  String _trackName;
  String _albumName;
  String _trackArtist;
  String _trackNumber;
  String _year;
  String _duration = '';
  String _position = '';
  bool _isPlaying = true;
  bool _isInfoShowing = true;
  int _durationSeconds = 0;
  int _positionSeconds = 0;
  List<MediaItem> _currentTrackQueue = new List<MediaItem>();
  int _currentTrackIndex = 0;
  List<Widget> _playlist = [Container()];
  Widget _playlistList = Container();
  StreamSubscription _currentMediaItemStreamSubscription;
  StreamSubscription _currentTrackDurationStreamSubscription;
  StreamSubscription _playingStreamSubscription;
  AnimationController _animationController;
  Animation<double> _animationCurved;
  AnimationController _animationController1;
  Animation<double> _animationCurved1;

  double _playlistEnd;

  String trackDuration(Duration duration) {
    String trackDurationLabel;
    int durationSeconds = duration.inMilliseconds ~/ 1000;
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
  void initState() {
    super.initState();
    try {
      (() async {
        this._playingStreamSubscription = AudioService.customEventStream.listen((event) {
          if (event[0] == 'playing') {
            this.setState(() => this._isPlaying = event[1]);
          }
        });
      })();
      this._currentMediaItemStreamSubscription = AudioService.currentMediaItemStream.listen((state) {
        this.setState(() {
          try {
            this._albumArt = state.extras['album_art'];
            this._trackName = state.title;
            this._albumName = state.album;
            this._trackArtist = state.artist;
            this._trackNumber= state.extras['track_number'].toString();
            this._year = state.extras['year'].toString();
          }
          catch(error) {
            this._animationController1 = new AnimationController(
              vsync: this,
              duration: Duration(milliseconds: 400),
              reverseDuration: Duration(milliseconds: 400),
            );
            this._animationCurved1 = Tween<double>(begin: 0, end: 0).animate(
              new CurvedAnimation(
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
                parent: this._animationController1,
              )
            );
          }
        });
      });
      this._currentTrackDurationStreamSubscription = AudioService.customEventStream.listen((event) {
        if (event[0] == 'currentTrackDuration') {
          this.setState(() {
            this._duration = this.trackDuration(event[1]);
            this._durationSeconds = event[1].inSeconds;
          });
        }
        if (event[0] == 'playingTrackDuration') {
          this.setState(() {
            this._position = this.trackDuration(event[1]);
            this._positionSeconds = event[1].inSeconds;
          });
        }
        if (event[0] == 'currentTrackQueue') {
          this.setState(() {
            this._playlist.clear();
            this._playlistList = Container();
            this._currentTrackIndex = event[1][0];
            this._currentTrackQueue = event[1][1];
            for (int index = 0; index < this._currentTrackQueue.length; index++) {
              MediaItem mediaItem = this._currentTrackQueue[index];
              this._playlist.add(
                Container(
                  height: 72,
                  child: ListTile(
                    onTap: () {
                      AudioService.customAction('currentTrackIndexSwitch', index);
                    },
                    leading: CircleAvatar(
                      child: Text(mediaItem.extras['track_number'].toString()),
                      backgroundImage: FileImage(
                        File(mediaItem.extras['album_art']),
                      ),
                    ),
                    title: Text(mediaItem.title),
                    subtitle: Text(mediaItem.album),
                  ),
                ),
              );
            }
            this._playlistList = Column(
              children: this._playlist,
            );
            this._playlistEnd = (this._playlist.length * 72).toDouble() == null ? 0.0 : (this._playlist.length * 72).toDouble();

            if (this._isInfoShowing) {
              this._animationController1 = new AnimationController(
                vsync: this,
                duration: Duration(milliseconds: 400),
                reverseDuration: Duration(milliseconds: 400),
              );
              this._animationCurved1 = Tween<double>(begin: 0, end: this._playlistEnd).animate(
                new CurvedAnimation(
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                  parent: this._animationController1,
                )
              );
            }
          });
        }
      });
    }
    catch(error) {
      print('Empty Track Queue');
    }

    AudioService.customAction('currentTrackDuration', []);
    AudioService.customAction('playingTrackDuration', []);
    AudioService.customAction('currentTrackQueue', []);

    this._animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
      reverseDuration: Duration(milliseconds: 400),
    );
    this._animationCurved = Tween<double>(begin: 0, end: MediaQuery.of(Globals.globalContext).size.width - 32).animate(
      new CurvedAnimation(
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        parent: this._animationController,
      )
    );

    if (this._trackName == null) {
      this._animationController1 = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
        reverseDuration: Duration(milliseconds: 400),
      );
      this._animationCurved1 = Tween<double>(begin: 0, end: 0).animate(
        new CurvedAnimation(
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
          parent: this._animationController1,
        )
      );
    }

    Timer(Duration(milliseconds: 100), () {
      this._animationController.forward();
      this._animationController1.reverse();
    });
  }

  @override
  void dispose() {
    this._playingStreamSubscription.cancel();
    this._currentMediaItemStreamSubscription.cancel();
    this._currentTrackDurationStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: ListView(
        children: [
          this._trackName == null ?
          Card(
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.only(left: 16, right: 16),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    child: Stack(
                      overflow: Overflow.clip,
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          color: Colors.black12,
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.width - 32,
                          width: MediaQuery.of(context).size.width - 32,
                          child: Icon(
                            Icons.album,
                            color: Colors.white,
                            size: 108,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: FloatingActionButton(
                            onPressed: () {},
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                            backgroundColor: Theme.of(context).accentColor,
                          ),
                        )
                      ],
                    ),
                    animation: _animationController,
                    builder: (context, child) => Container(
                      height: _animationCurved.value,
                      child: child,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 32,
                    padding: EdgeInsets.only(top: 16, bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 16, right: 16),
                          child: CircleAvatar(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.black12,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Globals.STRING_NOW_PLAYING_NOT_PLAYING_TITLE,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                              ),
                            ),
                            Divider(
                              color: Colors.white,
                              height: 4,
                              thickness: 0,
                            ),
                            Text(
                              Globals.STRING_NOW_PLAYING_NOT_PLAYING_SUBTITLE,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 72, bottom: 16),
                    child: Text(
                      Globals.STRING_NOW_PLAYING_NOT_PLAYING_HEADER,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 48,
                        alignment: Alignment.center,
                        child: Text(
                          '0:00',
                          style: TextStyle(
                            color: Colors.black54
                          ),
                        ),
                      ),
                      SliderTheme(
                        child: Slider(
                          inactiveColor: Colors.black26,
                          min: 0,
                          max: 1,
                          value: 0,
                          onChanged: (double value) {
                            AudioService.seekTo(Duration(seconds: value.toInt()));
                          },
                        ),
                        data: SliderThemeData(
                          thumbColor: Theme.of(context).primaryColor,
                          activeTrackColor: Theme.of(context).primaryColor,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                          trackHeight: 0.5,
                        ),
                      ),
                      Container(
                        width: 48,
                        alignment: Alignment.center,
                        child: Text(
                          '0:00',
                          style: TextStyle(
                            color: Colors.black54
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.white,
                    height: 4,
                    thickness: 0,
                  ),
                  Divider(
                    color: Colors.black12,
                    height: 1,
                    thickness: 1,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        alignment: Alignment.center,
                        child: IconButton(
                          iconSize: 24,
                          icon: Icon(
                            this._isInfoShowing ? Icons.expand_more : Icons.expand_less,
                            color: Colors.black45,
                          ),
                          splashRadius: 20,
                          onPressed: () {
                            this._isInfoShowing = !this._isInfoShowing;
                            if (this._animationController.isCompleted) {
                              this._animationController.reverse();
                              this._animationController1.forward();
                            }
                            else if (this._animationController.isDismissed) {
                              this._animationController.forward();
                              this._animationController1.reverse();
                            }
                          },
                        )
                      ),
                      Expanded(
                        child: ButtonBar(
                          alignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            MaterialButton(
                              onPressed: () {},
                              child: Text(
                                Globals.STRING_NOW_PLAYING_PREVIOUS_TRACK,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {},
                              child: Text(
                                Globals.STRING_NOW_PLAYING_NEXT_TRACK,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AnimatedBuilder(
                    animation: _animationController1,
                    child: this._playlistList,
                    builder: (context, child) => Container(
                      height: _animationCurved1.value,
                      child: child,
                    ),
                  ),
                ],
              ),
            )
          )
          :
          Card(
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.only(left: 16, right: 16),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    child: Stack(
                      overflow: Overflow.clip,
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.bottomRight,
                      children: [
                        Image.file(
                          File(this._albumArt),
                          height: MediaQuery.of(context).size.width - 32,
                          width: MediaQuery.of(context).size.width - 32,
                          fit: BoxFit.fitWidth,
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: FloatingActionButton(
                            onPressed: () {
                              this._isPlaying = !this._isPlaying;
                              if (this._isPlaying) {
                                AudioService.play();
                              }
                              else {
                                AudioService.pause();
                              }
                            },
                            child: Icon(
                              this._isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                            backgroundColor: Theme.of(context).accentColor,
                          ),
                        )
                      ],
                    ),
                    animation: _animationController,
                    builder: (context, child) => Container(
                      height: _animationCurved.value,
                      child: child,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 32,
                    padding: EdgeInsets.only(top: 16, bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 16, right: 16),
                          child: CircleAvatar(
                            child: Text(
                              this._trackNumber.toString(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundImage: FileImage(File(this._albumArt)),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              this._trackName,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                              ),
                            ),
                            Divider(
                              color: Colors.white,
                              height: 4,
                              thickness: 0,
                            ),
                            Text(
                              this._albumName,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 72, bottom: 16),
                    child: Text(
                      this._trackArtist + ' ' + '(' + this._year + ')',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 48,
                        alignment: Alignment.center,
                        child: Text(
                          this._position,
                          style: TextStyle(
                            color: Colors.black54
                          ),
                        ),
                      ),
                      TweenAnimationBuilder(
                        curve: Curves.easeOutCubic,
                        duration: Duration(milliseconds: 400),
                        tween: Tween<double>(begin: 0, end: this._positionSeconds.toDouble()),
                        builder: (context, value, child) => Container(
                          width: MediaQuery.of(context).size.width - 32 - 2 * 48,
                          alignment: Alignment.center,
                          child: SliderTheme(
                            child: Slider(
                              inactiveColor: Colors.black26,
                              min: 0,
                              max: this._durationSeconds.toDouble(),
                              value: value,
                              onChanged: (double value) {
                                AudioService.seekTo(Duration(seconds: value.toInt()));
                              },
                            ),
                            data: SliderThemeData(
                              thumbColor: Theme.of(context).primaryColor,
                              activeTrackColor: Theme.of(context).primaryColor,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                              trackHeight: 0.5,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 48,
                        alignment: Alignment.center,
                        child: Text(
                          this._duration,
                          style: TextStyle(
                            color: Colors.black54
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.white,
                    height: 4,
                    thickness: 0,
                  ),
                  Divider(
                    color: Colors.black12,
                    height: 1,
                    thickness: 1,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        alignment: Alignment.center,
                        child: IconButton(
                          iconSize: 24,
                          icon: Icon(
                            this._isInfoShowing ? Icons.expand_more : Icons.expand_less,
                            color: Colors.black45,
                          ),
                          splashRadius: 20,
                          onPressed: () {
                            
                            this._isInfoShowing = !this._isInfoShowing;
                            if (this._animationController.isCompleted) {
                              this._animationController.reverse();
                              this._animationController1.forward();
                            }
                            else if (this._animationController.isDismissed) {
                              this._animationController.forward();
                              this._animationController1.reverse();
                            }
                          },
                        )
                      ),
                      Expanded(
                        child: ButtonBar(
                          alignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            MaterialButton(
                              onPressed: () => AudioService.skipToPrevious(),
                              child: Text(
                                Globals.STRING_NOW_PLAYING_PREVIOUS_TRACK,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () => AudioService.skipToNext(),
                              child: Text(
                                Globals.STRING_NOW_PLAYING_NEXT_TRACK,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AnimatedBuilder(
                    animation: _animationController1,
                    child: this._playlistList,
                    builder: (context, child) => Container(
                      height: _animationCurved1.value,
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: Colors.white,
            height: 8,
          )
        ],
      ),
    );
  }
}