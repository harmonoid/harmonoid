import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/constants/constants.dart';


class NowPlayingTile extends StatefulWidget {
  NowPlayingTile({Key key}) : super(key: key);
  NowPlayingTileState createState() => NowPlayingTileState();
}


class NowPlayingTileState extends State<NowPlayingTile> {
  StreamSubscription _playingStreamSubscription;
  bool _isPlaying = false;
  Map<String, dynamic> _track = new Track().toDictionary();

  @override
  void initState() {
    super.initState();
    this._playingStreamSubscription = AudioService.customEventStream.listen((event) {
      if (event[0] == 'currentTrackQueue') {
        this.setState(() => this._track = event[1][1][event[1][0]].extras);
      }
      if (event[0] == 'playing') {
        this.setState(() => this._isPlaying = event[1]);
      }
    });
  }

  @override
  void dispose() {
    this._playingStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: States.showNowPlaying,
      child: Card(
        shape: RoundedRectangleBorder(),
        margin: EdgeInsets.zero,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(left: 8, right: 8),
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 56,
                width: 56,
                padding: EdgeInsets.all(8.0),
                child: this._track['albumArtId'] != null ? CircleAvatar(
                  backgroundImage: FileImage(collection.getAlbumArt(this._track['albumArtId'])),
                  child: Text('${this._track['trackNumber']}'),
                ) : CircleAvatar(
                  child: Icon(Icons.music_note),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 0, left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        this._track['trackName'] ?? Constants.STRING_NOW_PLAYING_NOT_PLAYING_TITLE,
                        style: Theme.of(context).textTheme.headline2,
                        maxLines: 1,
                      ),
                      Text(
                        this._track['artistNames'] == null ? Constants.STRING_NOW_PLAYING_NOT_PLAYING_SUBTITLE : this._track['artistNames'].join(', '),
                        style: Theme.of(context).textTheme.headline4,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 56,
                width: 56,
                padding: EdgeInsets.all(0.0),
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    tooltip: this._isPlaying ? Constants.STRING_PAUSE : Constants.STRING_PLAY,
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(this._isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (this._isPlaying) {
                        AudioService.pause();
                      }
                      else {
                        AudioService.play();
                      }
                    },
                    iconSize: Theme.of(context).iconTheme.size,
                    color: Theme.of(context).iconTheme.color,
                    splashRadius: Theme.of(context).iconTheme.size - 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NowPlaying extends StatefulWidget {
  NowPlaying({Key key}) : super(key : key);
  NowPlayingState createState() => NowPlayingState();
}


class NowPlayingState extends State<NowPlaying> with TickerProviderStateMixin {
  File _albumArt;
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
  bool _init = true;
  List<MediaItem> _currentTrackQueue = new List<MediaItem>();
  int _currentTrackIndex = 0;
  List<Widget> _playlist = [Container()];
  Widget _playlistList = Container();
  StreamSubscription _currentMediaItemStreamSubscription;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      this._playingStreamSubscription = AudioService.customEventStream.listen((event) {
        if (event[0] == 'playing') {
          this.setState(() => this._isPlaying = event[1]);
        }
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
                      child: Text(mediaItem.extras['trackNumber'].toString()),
                      backgroundImage: FileImage(
                        collection.getAlbumArt(mediaItem.extras['albumArtId'])
                      ),
                    ),
                    title: Text(
                      mediaItem.title,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    subtitle: Text(
                      mediaItem.album,
                      style: Theme.of(context).textTheme.headline4,
                    ),
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
      this._currentMediaItemStreamSubscription = AudioService.currentMediaItemStream.listen((state) {
        this.setState(() {
          try {
            this._albumArt = collection.getAlbumArt(state.extras['albumArtId']);
            this._trackName = state.title;
            this._albumName = state.album;
            this._trackArtist = state.artist;
            this._trackNumber= state.extras['trackNumber'].toString();
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
      AudioService.customAction('currentTrackDuration', []);
      AudioService.customAction('playingTrackDuration', []);
      AudioService.customAction('currentTrackQueue', []);
      this._animationController = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
        reverseDuration: Duration(milliseconds: 400),
      );
      this._animationCurved = Tween<double>(begin: 0, end: MediaQuery.of(context).size.width - 32).animate(
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
    this._init = false;
  }
  
  @override
  void dispose() {
    this._playingStreamSubscription.cancel();
    this._currentMediaItemStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        children: [
          this._trackName == null ?
          Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.only(left: 16, right: 16),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => Container(
                      height: _animationCurved.value,
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
                                size: _animationCurved.value * 28 / (MediaQuery.of(context).size.width - 32),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          )
                        ],
                      ),
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
                              Constants.STRING_NOW_PLAYING_NOT_PLAYING_TITLE,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 4,
                            ),
                            Text(
                              Constants.STRING_NOW_PLAYING_NOT_PLAYING_SUBTITLE,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ],
                        ),
                      ],
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 72, bottom: 16),
                    child: Text(
                      Constants.STRING_NOW_PLAYING_NOT_PLAYING_HEADER,
                      style: Theme.of(context).textTheme.headline4,
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
                          style: Theme.of(context).textTheme.headline4,
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
                          inactiveTrackColor: Theme.of(context).dividerColor,
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
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 4,
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor,
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
                            color: Theme.of(context).iconTheme.color,
                          ),
                          
                          splashRadius: 20,
                          onPressed: () {},
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
                                Constants.STRING_NOW_PLAYING_PREVIOUS_TRACK,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {},
                              child: Text(
                                Constants.STRING_NOW_PLAYING_NEXT_TRACK,
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
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.only(left: 16, right: 16),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => Container(
                      height: _animationCurved.value,
                      child: Stack(
                        overflow: Overflow.clip,
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.bottomRight,
                        children: [
                          Image.file(
                            this._albumArt,
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
                                size: _animationCurved.value * 28 / (MediaQuery.of(context).size.width - 32),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          )
                        ],
                      ),
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
                            backgroundImage: FileImage(this._albumArt),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              this._trackName,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 4,
                            ),
                            Text(
                              this._albumName,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headline4,
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
                      style: Theme.of(context).textTheme.headline4,
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
                          style: Theme.of(context).textTheme.headline4,
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
                              inactiveTrackColor: Theme.of(context).iconTheme.color,
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
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 4,
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor,
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
                            color: Theme.of(context).iconTheme.color,
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
                                Constants.STRING_NOW_PLAYING_PREVIOUS_TRACK,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () => AudioService.skipToNext(),
                              child: Text(
                                Constants.STRING_NOW_PLAYING_NEXT_TRACK,
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
            color: Colors.transparent,
            height: 8,
          )
        ],
      ),
    );
  }
}
