import 'dart:async';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as AudioPlayer;

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/playback.dart';
import 'package:harmonoid/language/constants.dart';


class NowPlaying extends StatefulWidget {
  NowPlaying({Key key}) : super(key : key);
  NowPlayingState createState() => NowPlayingState();
}


class NowPlayingState extends State<NowPlaying> with TickerProviderStateMixin {
  Track _track;
  String _duration = '';
  String _position = '';
  bool _isPlaying = true;
  bool _isInfoShowing = true;
  int _durationSeconds = 0;
  int _positionSeconds = 0;
  bool _init = true;
  List<AudioPlayer.Audio> _currentTrackQueue = new List<AudioPlayer.Audio>();
  AnimationController _animationController;
  Animation<double> _animationCurved;
  AnimationController _animationController1;
  Animation<double> _animationCurved1;
  List<StreamSubscription> _streamSubscriptions = new List<StreamSubscription>(5);
  List<Widget> _playlist = [Container()];
  Widget _playlistList = Container();
  double _playlistEnd;

  String _getDurationString(int durationSeconds) {
    int minutes = durationSeconds ~/ 60;
    String seconds = durationSeconds - (minutes * 60) > 9 ? '${durationSeconds - (minutes * 60)}' : '0${durationSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }

  @override
  void initState() { 
    super.initState();
  }

  @override
  void dispose() {
    this._streamSubscriptions.forEach((StreamSubscription subscription) {
      subscription?.cancel();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      this._streamSubscriptions[0] = audioPlayer.currentPosition.listen((Duration duration) {
        this.setState(() {
          this._positionSeconds = duration.inSeconds;
          this._position = this._getDurationString(this._positionSeconds);
        });
      });
      this._streamSubscriptions[1] = audioPlayer.current.listen((AudioPlayer.Playing playing) {
        this.setState(() {
          this._track = Track.fromMap(playing.audio.audio.metas.extra);
          this._durationSeconds = playing.audio.duration.inSeconds;
          this._duration = this._getDurationString(this._durationSeconds);
          this._playlist = <Widget>[];
          this._playlistEnd = playing.playlist.audios.length * 72.0;
          playing.playlist.audios.asMap().forEach((int index, AudioPlayer.Audio audio) {
            this._playlist.add(
              new ListTile(
                leading: CircleAvatar(
                  child: Text(
                    '${audio.metas.extra['trackNumber']}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  backgroundImage: FileImage(
                    collection.getAlbumArt(
                      Track.fromMap(audio.metas.extra),
                    ),
                  ),
                ),
                title: Text(audio.metas.title),
                subtitle: Text(audio.metas.artist),
                trailing: this._track.trackName == audio.metas.title ? Icon(
                  Icons.music_note,
                  color: Theme.of(context).accentColor,
                ) : null,
                onTap: () {
                  audioPlayer.playlistPlayAtIndex(index);
                },
              ),
            );
          });
          this._playlistList = Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: this._playlist,
          );
          this._animationCurved1 = Tween<double>(begin: 0, end: this._playlistEnd).animate(
            new CurvedAnimation(
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
              parent: this._animationController1,
            )
          );
        });
      });
      this._streamSubscriptions[2] = audioPlayer.isPlaying.listen(
        (bool isPlaying) => this.setState(
          () => this._isPlaying = isPlaying,
        ),
      );
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
      if (this._track == null) {
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
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        children: [
          this._track == null ?
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
                            audioPlayer.seek(
                              Duration(
                                seconds: value.toInt(),
                              ),
                            );
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
                            collection.getAlbumArt(this._track),
                            height: MediaQuery.of(context).size.width - 32,
                            width: MediaQuery.of(context).size.width - 32,
                            fit: BoxFit.fitWidth,
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: FloatingActionButton(
                              onPressed: () {
                                if (this._isPlaying) {
                                  audioPlayer.pause();
                                }
                                else {
                                  audioPlayer.play();
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
                              this._track.trackNumber.toString(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundImage: FileImage(collection.getAlbumArt(this._track)),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              this._track.trackName.split('(')[0].split('[')[0].split('-')[0].split(':')[0],
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 4,
                            ),
                            Text(
                              this._track.albumName.split('(')[0].split('[')[0].split('-')[0].split(':')[0],
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
                      this._track.albumArtistName + ' ' + '(${this._track.year ?? 'Unknown Year'})',
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
                                audioPlayer.seek(
                                  Duration(
                                    seconds: value.toInt(),
                                  ),
                                );
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
                              onPressed: () => audioPlayer.previous(),
                              child: Text(
                                Constants.STRING_NOW_PLAYING_PREVIOUS_TRACK,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () => audioPlayer.next(),
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
