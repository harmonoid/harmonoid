import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as AudioPlayer;

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/lyrics.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

// TODO: Implement lyrics visualizing & caching.

class NowPlaying extends StatefulWidget {
  const NowPlaying({Key? key}) : super(key: key);

  NowPlayingState createState() => NowPlayingState();
}

class NowPlayingState extends State<NowPlaying> with TickerProviderStateMixin {
  Track? _track;
  String _duration = '0:00';
  bool _isPlaying = true;
  bool _isInfoShowing = true;
  int _durationSeconds = 0;
  Duration _position = Duration.zero;
  bool _init = true;
  late AnimationController _playPauseController;
  late AnimationController _animationController;
  late Animation<double> _animationCurved;
  late AnimationController _animationController1;
  late Animation<double> _animationCurved1;
  List<StreamSubscription?> _streamSubscriptions = <StreamSubscription?>[
    null,
    null,
    null,
    null
  ];
  List<Widget> _playlist = [const SizedBox()];
  Widget _playlistList = const SizedBox();
  double? _playlistEnd;
  double albumArtHeight = 0.0;
  AudioPlayer.LoopMode _loopMode = AudioPlayer.LoopMode.none;

  Duration get animationDuration => Duration(milliseconds: 400);

  String _getDurationString(int durationSeconds) {
    int minutes = durationSeconds ~/ 60;
    String seconds = durationSeconds - (minutes * 60) > 9
        ? '${durationSeconds - (minutes * 60)}'
        : '0${durationSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    this._playPauseController = AnimationController(
      vsync: this,
      duration: this.animationDuration,
    );
    super.initState();
  }

  @override
  void dispose() {
    this._streamSubscriptions.forEach((subscription) {
      subscription?.cancel();
    });
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      if (Platform.isAndroid) {
        _streamSubscriptions[0] =
            audioPlayer.currentPosition.listen((duration) {
          setState(() => this._position = duration);
        });
        this._streamSubscriptions[1] =
            audioPlayer.current.listen((AudioPlayer.Playing? playing) {
          if (playing == null) return;
          this.setState(() {
            this._track = Track.fromMap(playing.audio.audio.metas.extra);
            this._durationSeconds = playing.audio.duration.inSeconds;
            this._duration = this._getDurationString(this._durationSeconds);
            this._playlist = <Widget>[];
            this._playlistEnd = playing.playlist.audios.length * 72.0;
            playing.playlist.audios
                .asMap()
                .forEach((int index, AudioPlayer.Audio audio) {
              this._playlist.add(
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          '${audio.metas.extra?['trackNumber'] ?? 1}',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundImage: audio.metas.extra == null
                            ? null
                            : FileImage(
                                Track.fromMap(audio.metas.extra!)!.albumArt,
                              ),
                      ),
                      title: Text(
                        audio.metas.title ?? '',
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                      subtitle: audio.metas.artist == null
                          ? null
                          : Text(
                              audio.metas.artist ?? '',
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                            ),
                      trailing: this._track!.trackName == audio.metas.title
                          ? Icon(
                              Icons.music_note,
                              color: Theme.of(context).accentColor,
                            )
                          : null,
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
            this._animationCurved1 = Tween<double>(
              begin: 0,
              end: this._playlistEnd,
            ).animate(CurvedAnimation(
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
              parent: this._animationController1,
            ));
          });
        });
        this._streamSubscriptions[2] = audioPlayer.isPlaying.listen(
          (bool isPlaying) {
            this.setState(() => this._isPlaying = isPlaying);
            if (isPlaying)
              this._playPauseController.reverse();
            else
              this._playPauseController.forward();
          },
        );
        this._streamSubscriptions[2] = audioPlayer.loopMode.listen(
          (AudioPlayer.LoopMode loopMode) {
            this.setState(() {
              this._loopMode = loopMode;
            });
          },
        );
        this.albumArtHeight = MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom -
            2 * 8.0 -
            56.0 -
            210.0;
        if (this.albumArtHeight < 0.0) this.albumArtHeight = 0.0;
        this._animationController = AnimationController(
          vsync: this,
          duration: animationDuration,
          reverseDuration: animationDuration,
        );
        this._animationCurved =
            Tween<double>(begin: 0, end: this.albumArtHeight)
                .animate(CurvedAnimation(
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
          parent: this._animationController,
        ));
        if (this._track == null) {
          this._animationController1 = AnimationController(
            vsync: this,
            duration: animationDuration,
            reverseDuration: animationDuration,
          );
          this._animationCurved1 =
              Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
            parent: this._animationController1,
          ));
        }
        Timer(Duration(milliseconds: 100), () {
          this._animationController.forward();
          this._animationController1.reverse();
        });
      } else {
        _streamSubscriptions[0] = vlcplayer.positionStream.listen((event) {
          setState(() {
            vlcplayer.current.media!.parse(Duration(milliseconds: 100));
            Map<String, dynamic> metas = vlcplayer.current.media!.metas;
            metas["trackName"] = metas["title"];
            metas["albumName"] = metas["album"];
            metas["trackArtistNames"] = metas["artist"];
            metas["year"] = metas["date"];
            metas["type"] = "Track";
            metas["albumArtistName"] = metas["artist"].split("/")[0];
            this._track = Track.fromMap(metas);
            this._playlist = <Widget>[];
            this._playlistEnd = vlcplayer.current.medias.length * 72.0;
            this._durationSeconds = event.duration!.inSeconds;
            this._duration = this._getDurationString(event.duration!.inSeconds);
            this._position = event.position!;
          });
        });

        this._streamSubscriptions[1] = vlcplayer.currentStream.listen((event) {
          print("Listening to currentStream");
          this.setState(() {
            this._track = Track.fromMap(event.media?.metas);
            //print(this._track);
            this._playlist = <Widget>[];
            this._playlistEnd = vlcplayer.current.medias.length * 72.0;
            print(event.medias);
            event.medias.asMap().forEach((int index, media) {
              this._playlist.add(
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          '${media.metas['trackNumber'] ?? 1}',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundImage: media.metas["albumArtHigh"] == null
                            ? null
                            : FileImage(
                                Track.fromMap(media.metas)!.albumArt,
                              ),
                      ),
                      title: Text(
                        media.metas["title"] ?? '',
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                      subtitle: media.metas["artist"] == null
                          ? null
                          : Text(
                              media.metas["artist"] ?? '',
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                            ),
                      trailing: this._track!.trackName == media.metas["title"]
                          ? Icon(
                              Icons.music_note,
                              color: Theme.of(context).accentColor,
                            )
                          : null,
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
            this._animationCurved1 = Tween<double>(
              begin: 0,
              end: this._playlistEnd,
            ).animate(CurvedAnimation(
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
              parent: this._animationController1,
            ));
          });
        });
        this._streamSubscriptions[2] = vlcplayer.playbackStream.listen(
          (isPlaying) {
            this.setState(() => this._isPlaying = isPlaying.isPlaying);
            if (isPlaying.isPlaying)
              this._playPauseController.reverse();
            else
              this._playPauseController.forward();
          },
        );
        //this._streamSubscriptions[2] = vlcplayer.playbackStream.listen(
        //  (loopMode) {
        //    this.setState(() {
        //      this._loopMode = loopMode.isLoo;
        //    });
        //  },
        //);
        this.albumArtHeight = MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom -
            2 * 8.0 -
            56.0 -
            210.0;
        if (this.albumArtHeight < 0.0) this.albumArtHeight = 0.0;
        this._animationController = AnimationController(
          vsync: this,
          duration: animationDuration,
          reverseDuration: animationDuration,
        );
        this._animationCurved =
            Tween<double>(begin: 0, end: this.albumArtHeight)
                .animate(CurvedAnimation(
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
          parent: this._animationController,
        ));
        if (this._track == null) {
          this._animationController1 = AnimationController(
            vsync: this,
            duration: animationDuration,
            reverseDuration: animationDuration,
          );
          this._animationCurved1 =
              Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
            parent: this._animationController1,
          ));
        }
        Timer(Duration(milliseconds: 100), () {
          this._animationController.forward();
          this._animationController1.reverse();
        });
      }
    }
    this._init = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: this._isInfoShowing
          ? null
          : FloatingActionButton(
              onPressed: this._track == null
                  ? null
                  : () {
                      if (Platform.isAndroid) {
                        if (this._isPlaying) {
                          this._playPauseController.forward();
                          audioPlayer.pause();
                        } else {
                          this._playPauseController.reverse();
                          audioPlayer.play();
                        }
                      } else {
                        if (this._isPlaying) {
                          this._playPauseController.forward();
                          vlcplayer.pause();
                        } else {
                          this._playPauseController.reverse();
                          vlcplayer.play();
                        }
                      }
                    },
              child: AnimatedIcon(
                icon: AnimatedIcons.pause_play,
                progress: this._playPauseController,
                color: Colors.white,
                size: 28.0,
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: ListView(children: [
          Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width - 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => Container(
                      height: _animationCurved.value,
                      child: Stack(
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.bottomRight,
                        children: [
                          Image(
                            image: (this._track == null
                                    ? AssetImage(
                                        'assets/images/collection-album.jpg')
                                    : FileImage(this._track!.albumArt))
                                as ImageProvider<Object>,
                            height: this.albumArtHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FloatingActionButton(
                                  mini: true,
                                  onPressed: this._track == null
                                      ? null
                                      : () {
                                          if (this._loopMode.index == 2)
                                            this._loopMode =
                                                AudioPlayer.LoopMode.none;
                                          else
                                            this._loopMode =
                                                AudioPlayer.LoopMode.values[
                                                    this._loopMode.index + 1];
                                          this.setState(() {});
                                        },
                                  child: Icon(
                                    <AudioPlayer.LoopMode, IconData>{
                                      AudioPlayer.LoopMode.none:
                                          Icons.arrow_forward,
                                      AudioPlayer.LoopMode.single:
                                          Icons.repeat_one,
                                      AudioPlayer.LoopMode.playlist:
                                          Icons.repeat,
                                    }[this._loopMode],
                                    color: Colors.white,
                                    size: _animationCurved.value *
                                        28 /
                                        this.albumArtHeight,
                                  ),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                FloatingActionButton(
                                  mini: true,
                                  onPressed: this._track == null
                                      ? null
                                      : () {
                                          audioPlayer.toggleShuffle();
                                          this.setState(() {});
                                        },
                                  child: Icon(
                                    Icons.shuffle,
                                    color: !audioPlayer.shuffle
                                        ? Colors.white
                                        : Theme.of(context).primaryColor,
                                    size: _animationCurved.value *
                                        28 /
                                        this.albumArtHeight,
                                  ),
                                  backgroundColor: !audioPlayer.shuffle
                                      ? Theme.of(context).primaryColor
                                      : Colors.white,
                                ),
                                SizedBox(
                                  width: 4.0,
                                ),
                                FloatingActionButton(
                                  onPressed: this._track == null
                                      ? null
                                      : () {
                                          if (Platform.isAndroid) {
                                            audioPlayer.playOrPause();
                                          } else {
                                            vlcplayer.playOrPause();
                                          }
                                          this.setState(() {});
                                        },
                                  child: AnimatedIcon(
                                    icon: AnimatedIcons.pause_play,
                                    progress: this._playPauseController,
                                    color: Colors.white,
                                    size: _animationCurved.value *
                                        28 /
                                        this.albumArtHeight,
                                  ),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 210.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(top: 16, bottom: 4),
                          child: Row(children: [
                            Container(
                              margin: EdgeInsets.only(left: 16, right: 16),
                              child: CircleAvatar(
                                child: Text(
                                  '${this._track?.trackNumber ?? 1}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundImage: this._track == null
                                    ? null
                                    : FileImage(
                                        this._track!.albumArt,
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Marquee(
                                    text: this._track?.trackName ??
                                        language!
                                            .STRING_NOW_PLAYING_NOT_PLAYING_TITLE,
                                    style:
                                        Theme.of(context).textTheme.headline1!,
                                    blankSpace: 100.0,
                                    velocity: 20.0,
                                    pauseAfterRound: Duration(seconds: 1),
                                  ),
                                  Divider(
                                    color: Colors.transparent,
                                    height: 1,
                                  ),
                                  Marquee(
                                    text: this._track?.albumName ??
                                        language!
                                            .STRING_NOW_PLAYING_NOT_PLAYING_SUBTITLE,
                                    style:
                                        Theme.of(context).textTheme.headline4!,
                                    blankSpace: 100.0,
                                    velocity: 20.0,
                                    pauseAfterRound: Duration(seconds: 1),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 72, bottom: 16),
                          child: Text(
                            this._track == null
                                ? language!
                                    .STRING_NOW_PLAYING_NOT_PLAYING_HEADER
                                : (this._track!.albumArtistName! +
                                    ' ' +
                                    '(${this._track!.year ?? 'Unknown Year'})'),
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
                                this._getDurationString(
                                    this._position.inSeconds),
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                child: Slider(
                                  inactiveColor:
                                      Theme.of(context).iconTheme.color,
                                  min: 0.0,
                                  max: this._durationSeconds.toDouble(),
                                  value: this._position.inSeconds.toDouble(),
                                  onChanged: (value) => setState(
                                    () => this._position = Duration(
                                      seconds: value.toInt(),
                                    ),
                                  ),
                                  onChangeEnd: (value) {
                                    if (Platform.isAndroid) {
                                      audioPlayer.seek(Duration(
                                        seconds: value.toInt(),
                                      ));
                                    } else {
                                      vlcplayer.seek(Duration(
                                        seconds: value.toInt(),
                                      ));
                                    }
                                  },
                                ),
                                data: SliderThemeData(
                                  disabledInactiveTrackColor: Colors.white,
                                  thumbColor: Theme.of(context).primaryColor,
                                  activeTrackColor:
                                      Theme.of(context).primaryColor,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  trackHeight: 0.5,
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
                        Divider(color: Colors.transparent, height: 4),
                        Divider(
                          color: Theme.of(context).dividerColor,
                          height: 1,
                          thickness: 1,
                        ),
                        Row(children: [
                          Container(
                            height: 56,
                            width: 56,
                            alignment: Alignment.center,
                            child: IconButton(
                              iconSize: 24,
                              icon: RotationTransition(
                                turns: Tween<double>(
                                  begin: 0,
                                  end: 0.5,
                                ).animate(_animationController),
                                child: Icon(
                                  Icons.expand_more,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                              splashRadius: 20,
                              onPressed: this._track == null
                                  ? null
                                  : () {
                                      this._isInfoShowing =
                                          !this._isInfoShowing;
                                      if (this
                                          ._animationController
                                          .isCompleted) {
                                        this._animationController.reverse();
                                        this._animationController1.forward();
                                      } else if (this
                                          ._animationController
                                          .isDismissed) {
                                        this._animationController.forward();
                                        this._animationController1.reverse();
                                      }
                                      this.setState(() {});
                                    },
                            ),
                          ),
                          Expanded(
                            child: ButtonBar(
                              alignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                MaterialButton(
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (subContext) => SimpleDialog(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.all(16.0),
                                          child: Marquee(
                                            text: this._track?.trackName ??
                                                language!
                                                    .STRING_NOW_PLAYING_NOT_PLAYING_TITLE,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline1!,
                                            blankSpace: 100.0,
                                            velocity: 20.0,
                                            pauseAfterRound:
                                                Duration(seconds: 1),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Text(
                                            lyrics.current.isNotEmpty
                                                ? lyrics.current
                                                    .map((lyric) => lyric.words)
                                                    .join('\n')
                                                : language!
                                                    .STRING_LYRICS_NOT_FOUND,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    language!.STRING_LYRICS.toUpperCase(),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () => audioPlayer.previous(),
                                  child: Text(
                                    language!.STRING_NOW_PLAYING_PREVIOUS_TRACK,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () => audioPlayer.next(),
                                  child: Text(
                                    language!.STRING_NOW_PLAYING_NEXT_TRACK,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animationController1,
                    child: this._playlistList,
                    builder: (context, child) => Container(
                      height: _animationCurved1.value,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.center,
                          heightFactor: _animationController1.value,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
