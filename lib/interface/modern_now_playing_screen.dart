import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extended_image/extended_image.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:libmpv/libmpv.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/interface/now_playing_bar.dart';
import 'package:harmonoid/state/now_playing_visuals.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/constants/language.dart';

class ModernNowPlayingScreen extends StatefulWidget {
  const ModernNowPlayingScreen({Key? key}) : super(key: key);

  ModernNowPlayingState createState() => ModernNowPlayingState();
}

class ModernNowPlayingState extends State<ModernNowPlayingScreen>
    with TickerProviderStateMixin {
  final GlobalKey<CarouselState> carousel = GlobalKey<CarouselState>();
  final PageController pageController =
      PageController(initialPage: Playback.instance.index.clamp(0, 1 << 32));
  int currentPage = Playback.instance.index.clamp(0, 1 << 32);
  double scale = 0.0;
  double volume = Playback.instance.volume;
  bool isShuffling = Playback.instance.isShuffling;
  int playlistLength = Playback.instance.tracks.length;
  Track? track;
  Timer shuffleCooldown = Timer(const Duration(milliseconds: 300), () {});
  final GlobalKey controlPanelKey = GlobalKey();
  late AnimationController playOrPause;
  bool controlPanelVisible = false;
  Iterable<Color>? palette;

  Future<void> listener() async {
    if (Playback.instance.isPlaying) {
      playOrPause.forward();
    } else {
      playOrPause.reverse();
    }
    if (Playback.instance.index < 0 ||
        Playback.instance.index >= Playback.instance.tracks.length) {
      return;
    }
    if (volume != Playback.instance.volume) {
      setState(() {
        volume = Playback.instance.volume;
      });
    }
    if (Playback.instance.tracks.length != playlistLength) {
      playlistLength = Playback.instance.tracks.length;
      // Cause [children] in [PageView] to update.
      setState(() {});
    }
    if (shuffleCooldown.isActive) {
      try {
        await precacheImage(
          getAlbumArt(
              Playback.instance.tracks[
                  (currentPage).clamp(0, Playback.instance.tracks.length)],
              small: true),
          context,
        );
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      if (pageController.hasClients) {
        pageController.jumpToPage(Playback.instance.index);
      }
      isShuffling = Playback.instance.isShuffling;
    } else {
      final track = Playback.instance.tracks[Playback.instance.index];
      if (this.track != track) {
        this.track = track;
        try {
          final result = await PaletteGenerator.fromImageProvider(
              getAlbumArt(track, small: true));
          setState(() {
            palette = result.colors;
          });
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        if (isShuffling == Playback.instance.isShuffling) {
          if (currentPage !=
              Playback.instance.index
                  .clamp(0, Playback.instance.tracks.length)) {
            currentPage = Playback.instance.index
                .clamp(0, Playback.instance.tracks.length);
            try {
              await precacheImage(
                getAlbumArt(
                    Playback.instance.tracks[(currentPage)
                        .clamp(0, Playback.instance.tracks.length)],
                    small: true),
                context,
              );
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
            if (pageController.hasClients) {
              pageController.animateToPage(
                Playback.instance.index,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          }
        } else {
          setState(() {
            isShuffling = Playback.instance.isShuffling;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    playOrPause = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    Playback.instance.addListener(listener);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!Playback.instance.isPlaying) {
        final result = await PaletteGenerator.fromImageProvider(getAlbumArt(
          Playback.instance.tracks[(Playback.instance.index).clamp(
            0,
            Playback.instance.tracks.length,
          )],
          small: true,
        ));
        setState(() {
          palette = result.colors;
        });
      }
    });
  }

  @override
  void dispose() {
    Playback.instance.removeListener(listener);
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(brightness: Brightness.dark),
      child: Scaffold(
        body: Carousel(
          key: carousel,
          top: DesktopAppBar(
            color: Colors.transparent,
            elevation: 0.0,
            leading: NavigatorPopButton(
              color: Colors.white,
              onTap: DesktopNowPlayingController.instance.hide,
            ),
            height: 56.0,
          ),
          palette: palette,
          images: NowPlayingVisuals.instance.preloaded
                  .map((e) => AssetImage(e))
                  .toList()
                  .cast<ImageProvider>() +
              NowPlayingVisuals.instance.user
                  .map((e) => FileImage(File(e)))
                  .toList()
                  .cast<ImageProvider>(),
          mouseValue: Playback.instance.volume,
          onMouseScrollUp: () {
            Playback.instance.setVolume(
              (Playback.instance.volume + 5.0).clamp(0.0, 100.0),
            );
          },
          onMouseScrollDown: () {
            Playback.instance.setVolume(
              (Playback.instance.volume - 5.0).clamp(0.0, 100.0),
            );
          },
          hide: DesktopNowPlayingController.instance.hide,
          duration: const Duration(milliseconds: 300),
          content: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 32.0,
                    right: 32.0,
                    top: 48.0,
                    bottom: 48.0,
                  ),
                  child: Consumer<Lyrics>(
                    builder: (context, lyrics, _) => () {
                      if (Lyrics.instance.current.length > 2) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0.0,
                            end: (Lyrics.instance.current.length > 2 &&
                                    Configuration.instance.lyricsVisible)
                                ? 1.0
                                : 0.0,
                          ),
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          builder: (context, opacity, _) => Opacity(
                            opacity: opacity,
                            child: Consumer<Playback>(
                              builder: (context, playback, _) => ShaderMask(
                                shaderCallback: (Rect rect) {
                                  return LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black,
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.black,
                                    ],
                                    stops: [0.0, 0.2, 0.8, 1.0],
                                  ).createShader(rect);
                                },
                                blendMode: BlendMode.dstOut,
                                child: LyricsReader(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  model: LyricsReaderModel()
                                    ..lyrics = Lyrics.instance.current
                                        .map(
                                          (e) => LyricsLineModel()
                                            ..mainText = e.words
                                            ..startTime = e.time
                                            ..endTime = Lyrics
                                                .instance
                                                .current[(Lyrics.instance.current
                                                            .indexOf(Lyrics
                                                                .instance
                                                                .current
                                                                .firstWhere((element) =>
                                                                    element
                                                                        .time ==
                                                                    e.time)) +
                                                        1)
                                                    .clamp(
                                                        0,
                                                        Lyrics.instance.current
                                                                .length -
                                                            1)]
                                                .time,
                                        )
                                        .toList(),
                                  position: playback.position.inMilliseconds,
                                  lyricUi: LyricsStyle()
                                    ..defaultSize = 24.0
                                    ..otherMainSize = 16.0
                                    ..highlight = false,
                                  playing: true,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }(),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 196.0,
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: pageController,
                  // onPageChanged: (page) {
                  //   currentPage = page;
                  // },
                  children: List.generate(
                    Playback.instance.tracks.length,
                    (i) => i,
                  )
                      .map(
                        (i) => Consumer<Playback>(
                          builder: (context, playback, _) => Container(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Card(
                                  margin: EdgeInsets.only(
                                    left: 24.0,
                                    bottom: 24.0,
                                  ),
                                  color: Colors.white,
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 8.0,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: ExtendedImage(
                                      image: getAlbumArt(playback.tracks[i],
                                          small: true),
                                      height: 156.0,
                                      width: 156.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 24.0),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(bottom: 24.0),
                                    child: () {
                                      if (playback.isBuffering) {
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 8.0,
                                            ),
                                            Container(
                                              height: 28.0,
                                              width: 28.0,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                  Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                strokeWidth: 4.8,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 24.0,
                                            ),
                                            Expanded(
                                              child: Text(
                                                Language.instance.BUFFERING,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 20.0,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        );
                                      } else if (playback.tracks.isEmpty ||
                                          playback.tracks.length <=
                                                  playback.index &&
                                              0 > playback.index) {
                                        return Container();
                                      } else {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              playback
                                                  .tracks[i].trackName.overflow,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline1
                                                  ?.copyWith(
                                                fontSize: 28.0,
                                                color: Colors.white,
                                                shadows: <Shadow>[
                                                  Shadow(
                                                    offset: Offset(-2.0, 2.0),
                                                    blurRadius: 3.0,
                                                    color: Color.fromARGB(
                                                        96, 0, 0, 0),
                                                  ),
                                                  Shadow(
                                                    offset: Offset(2.0, 2.0),
                                                    blurRadius: 8.0,
                                                    color: Color.fromARGB(
                                                        128, 0, 0, 0),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              [
                                                playback
                                                    .tracks[i].trackArtistNames
                                                    .take(2)
                                                    .join(', ')
                                                    .overflow,
                                                if (playback
                                                        .tracks[i].albumName !=
                                                    kUnknownAlbum)
                                                  playback.tracks[i].albumName
                                              ].join(' • '),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline3
                                                  ?.copyWith(
                                                fontSize: 16.0,
                                                color: Colors.white70,
                                                shadows: <Shadow>[
                                                  Shadow(
                                                    offset: Offset(-2.0, 2.0),
                                                    blurRadius: 3.0,
                                                    color: Color.fromARGB(
                                                        96, 0, 0, 0),
                                                  ),
                                                  Shadow(
                                                    offset: Offset(2.0, 2.0),
                                                    blurRadius: 8.0,
                                                    color: Color.fromARGB(
                                                        128, 0, 0, 0),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (![
                                              kUnknownYear,
                                              ''
                                            ].contains(playback.tracks[i].year))
                                              Text(
                                                playback.tracks[i].year,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3
                                                    ?.copyWith(
                                                  fontSize: 16.0,
                                                  color: Colors.white70,
                                                  shadows: <Shadow>[
                                                    Shadow(
                                                      offset: Offset(-2.0, 2.0),
                                                      blurRadius: 3.0,
                                                      color: Color.fromARGB(
                                                          96, 0, 0, 0),
                                                    ),
                                                    Shadow(
                                                      offset: Offset(2.0, 2.0),
                                                      blurRadius: 8.0,
                                                      color: Color.fromARGB(
                                                          128, 0, 0, 0),
                                                    ),
                                                  ],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        );
                                      }
                                    }(),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          bottom: Consumer<Playback>(
            builder: (context, playback, _) => Material(
              color: Colors.transparent,
              child: Container(
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Container(
                            width: 56.0,
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              playback.position.label,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16.0,
                          ),
                          playback.position.inMilliseconds <=
                                  playback.duration.inMilliseconds
                              ? Container(
                                  width: MediaQuery.of(context).size.width -
                                      2 * (56.0 + 16.0),
                                  child: ScrollableSlider(
                                    color: palette?.last,
                                    secondaryColor: palette?.first,
                                    inferSliderInactiveTrackColor: false,
                                    min: 0.0,
                                    value: getPlaybackPosition(playback),
                                    max: getPlaybackDuration(playback),
                                    onChanged: (value) {
                                      playback.seek(
                                        Duration(
                                          milliseconds: value.toInt(),
                                        ),
                                      );
                                    },
                                    onScrolledUp: () {
                                      if (Playback.instance.position >=
                                          Playback.instance.duration) return;
                                      playback.seek(
                                        playback.position +
                                            Duration(seconds: 10),
                                      );
                                    },
                                    onScrolledDown: () {
                                      if (Playback.instance.position <=
                                          Duration.zero) return;
                                      playback.seek(
                                        playback.position -
                                            Duration(seconds: 10),
                                      );
                                    },
                                  ))
                              : Container(),
                          SizedBox(
                            width: 16.0,
                          ),
                          Container(
                            width: 56.0,
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              playback.duration.label,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: EdgeInsets.only(left: 16.0, right: 16.0),
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        children: [
                          IconButton(
                            splashRadius: 20.0,
                            onPressed: playback.previous,
                            icon: Icon(
                              Icons.skip_previous,
                            ),
                            color: Colors.white,
                            tooltip: Language.instance.PREVIOUS,
                          ),
                          IconButton(
                            splashRadius: 20.0,
                            onPressed: playback.playOrPause,
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: playOrPause,
                            ),
                            color: Colors.white,
                            tooltip: playback.isPlaying
                                ? Language.instance.PAUSE
                                : Language.instance.PLAY,
                          ),
                          IconButton(
                            splashRadius: 20.0,
                            onPressed: playback.next,
                            icon: Icon(
                              Icons.skip_next,
                            ),
                            color: Colors.white,
                            tooltip: Language.instance.NEXT,
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 32.0,
                                width: 32.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: playback.isShuffling
                                      ? Border.all(
                                          width: 1.6,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withOpacity(0.87)
                                              : Colors.black87,
                                        )
                                      : null,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  shuffleCooldown = Timer(
                                      const Duration(milliseconds: 300), () {});
                                  playback.toggleShuffle();
                                },
                                iconSize: 20.0,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(0.87)
                                    : Colors.black87,
                                splashRadius: 18.0,
                                icon: Icon(
                                  Icons.shuffle,
                                ),
                                tooltip: Language.instance.SHUFFLE,
                              ),
                            ],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 32.0,
                                width: 32.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: playback.playlistLoopMode !=
                                          PlaylistLoopMode.none
                                      ? Border.all(
                                          width: 1.6,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withOpacity(0.87)
                                              : Colors.black87,
                                        )
                                      : null,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (playback.playlistLoopMode ==
                                      PlaylistLoopMode.loop) {
                                    playback.setPlaylistLoopMode(
                                      PlaylistLoopMode.none,
                                    );
                                    return;
                                  }
                                  playback.setPlaylistLoopMode(
                                    PlaylistLoopMode.values[
                                        playback.playlistLoopMode.index + 1],
                                  );
                                },
                                iconSize: 20.0,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(0.87)
                                    : Colors.black87,
                                splashRadius: 18.0,
                                icon: Icon(
                                  playback.playlistLoopMode ==
                                          PlaylistLoopMode.single
                                      ? Icons.repeat_one
                                      : Icons.repeat,
                                ),
                                tooltip: Language.instance.REPEAT,
                              ),
                            ],
                          ),
                          IconButton(
                            splashRadius: 20.0,
                            onPressed: () {
                              trackPopupMenuHandle(
                                context,
                                playback.tracks[playback.index],
                                2,
                              );
                            },
                            icon: Icon(
                              Icons.add,
                            ),
                            color: Colors.white,
                            tooltip: Language.instance.ADD_TO_PLAYLIST,
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 32.0,
                                width: 32.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Configuration.instance.lyricsVisible
                                      ? Border.all(
                                          width: 1.6,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withOpacity(0.87)
                                              : Colors.black87,
                                        )
                                      : null,
                                ),
                              ),
                              IconButton(
                                splashRadius: 20.0,
                                onPressed: () async {
                                  await Configuration.instance.save(
                                    lyricsVisible:
                                        !Configuration.instance.lyricsVisible,
                                  );
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.text_format,
                                ),
                                color: Colors.white,
                                tooltip: Language.instance.SHOW_LYRICS,
                              ),
                            ],
                          ),
                          if (Plugins.isWebMedia(
                              playback.tracks[playback.index].uri))
                            IconButton(
                              splashRadius: 20.0,
                              iconSize: 20.0,
                              onPressed: () {
                                launch(playback.tracks[playback.index].uri
                                    .toString());
                              },
                              icon: Icon(
                                Icons.open_in_new,
                              ),
                              color: Colors.white,
                              tooltip: Language.instance.OPEN_IN_BROWSER,
                            ),
                          if (Plugins.isWebMedia(
                              playback.tracks[playback.index].uri))
                            IconButton(
                              splashRadius: 20.0,
                              iconSize: 20.0,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: playback.tracks[playback.index].uri
                                        .toString()));
                              },
                              icon: Icon(
                                Icons.link,
                              ),
                              color: Colors.white,
                              tooltip: Language.instance.COPY_LINK,
                            ),
                          IconButton(
                            onPressed: playback.toggleMute,
                            iconSize: 20.0,
                            color: Colors.white,
                            splashRadius: 18.0,
                            tooltip: playback.isMuted
                                ? Language.instance.UNMUTE
                                : Language.instance.MUTE,
                            icon: Icon(
                              playback.volume == 0.0
                                  ? Icons.volume_off
                                  : Icons.volume_up,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            width: 84.0,
                            child: ScrollableSlider(
                              color: palette?.last,
                              secondaryColor: palette?.first,
                              inferSliderInactiveTrackColor: false,
                              min: 0,
                              max: 100.0,
                              value: playback.volume,
                              onScrolledUp: () {
                                playback.setVolume(
                                  (playback.volume + 5.0).clamp(0.0, 100.0),
                                );
                              },
                              onScrolledDown: () {
                                playback.setVolume(
                                  (playback.volume - 5.0).clamp(0.0, 100.0),
                                );
                              },
                              onChanged: (value) {
                                playback.setVolume(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          IconButton(
                            key: controlPanelKey,
                            onPressed: () {
                              {
                                RenderBox box = controlPanelKey.currentContext!
                                    .findRenderObject() as RenderBox;
                                Offset position =
                                    box.localToGlobal(Offset.zero);
                                double x = position.dx;
                                if (!controlPanelVisible) {
                                  controlPanelVisible = true;
                                  Navigator.of(context).push(
                                    RawDialogRoute(
                                      transitionDuration: Duration.zero,
                                      barrierDismissible: true,
                                      barrierLabel:
                                          MaterialLocalizations.of(context)
                                              .modalBarrierDismissLabel,
                                      barrierColor: Colors.transparent,
                                      pageBuilder: (context, __, ___) =>
                                          ControlPanel(
                                        onPop: () =>
                                            controlPanelVisible = false,
                                        x: x,
                                      ),
                                    ),
                                  );
                                } else {
                                  controlPanelVisible = false;
                                  Navigator.of(context).maybePop();
                                }
                              }
                            },
                            iconSize: 20.0,
                            color: Colors.white,
                            splashRadius: 18.0,
                            tooltip: Language.instance.CONTROL_PANEL,
                            icon: Icon(Icons.more_horiz),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double getPlaybackDuration(Playback playback) =>
      playback.duration.inMilliseconds.toDouble();

  double getPlaybackPosition(Playback playback) {
    var duration = getPlaybackDuration(playback);
    var position = playback.position.inMilliseconds.toDouble();
    if (position > duration) return duration;
    if (duration < 0 || position < 0) return 0;
    return position;
  }

  List<Track> get segment {
    if (Playback.instance.tracks.isEmpty ||
        Playback.instance.index < 0 ||
        Playback.instance.index >= Playback.instance.tracks.length) return [];
    return Playback.instance.tracks
        .skip(Playback.instance.index)
        .take(20)
        .toList();
  }
}

class Carousel extends StatefulWidget {
  final double? width;
  final double? height;
  final VoidCallback hide;
  final double mouseValue;
  final VoidCallback onMouseScrollUp;
  final VoidCallback onMouseScrollDown;
  final Widget top;
  final Widget content;
  final Widget bottom;
  final List<ImageProvider> images;
  final Duration duration;
  final Iterable<Color>? palette;
  const Carousel({
    Key? key,
    this.width,
    this.height,
    required this.hide,
    required this.mouseValue,
    required this.onMouseScrollUp,
    required this.onMouseScrollDown,
    required this.top,
    required this.content,
    required this.bottom,
    required this.images,
    required this.duration,
    required this.palette,
  }) : super(key: key);

  @override
  State<Carousel> createState() => CarouselState();
}

class CarouselState extends State<Carousel> {
  late List<Widget> widgets = [];

  int _current =
      Configuration.instance.modernNowPlayingScreenCarouselIndex.clamp(
    -1,
    NowPlayingVisuals.instance.user.length +
        NowPlayingVisuals.instance.preloaded.length,
  );
  bool _isFullscreen = false;
  Timer _timer = Timer(const Duration(milliseconds: 400), () {});
  Color? get color => _current == -1 ? widget.palette?.first : null;

  @override
  void initState() {
    super.initState();
    WindowManager.instance.ensureInitialized();
  }

  void toggle({bool? hide}) {
    if (hide != null) {
      WindowManager.instance.setFullScreen(!hide);
      _isFullscreen = !hide;
      return;
    }
    WindowManager.instance.setFullScreen(!_isFullscreen);
    _isFullscreen = !_isFullscreen;
  }

  void previous() {
    if (_timer.isActive) return;
    _timer = Timer(const Duration(milliseconds: 400), () {});
    setState(() {
      _current = _current + 1 == widget.images.length ? -1 : _current + 1;
      Configuration.instance.save(
        modernNowPlayingScreenCarouselIndex: _current,
      );
      final current = _current;
      widgets.add(
        TweenAnimationBuilder(
          onEnd: () {
            setState(() {
              widgets.removeAt(0);
            });
            _timer = Timer(const Duration(milliseconds: 400), () {});
          },
          tween: Tween<Offset>(
            begin: Offset(MediaQuery.of(context).size.width, 0),
            end: Offset.zero,
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          builder: (context, value, child) => Transform.translate(
            offset: value as Offset,
            child: Material(
              elevation: 20.0,
              color: current == -1 ? widget.palette?.first : null,
              child: current == -1
                  ? ProminentColorWidget()
                  : ExtendedImage(
                      image:
                          widget.images[current.clamp(0, widget.images.length)],
                      isAntiAlias: false,
                      width: widget.width ?? MediaQuery.of(context).size.width,
                      height:
                          widget.height ?? MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                    ),
            ),
          ),
        ),
      );
    });
  }

  void next() {
    if (_timer.isActive) return;
    _timer = Timer(const Duration(milliseconds: 400), () {});
    setState(() {
      _current = _current - 1 == -2 ? widget.images.length - 1 : _current - 1;
      Configuration.instance.save(
        modernNowPlayingScreenCarouselIndex: _current,
      );
      final current = _current;
      widgets.add(
        TweenAnimationBuilder(
          onEnd: () {
            setState(() {
              widgets.removeAt(0);
            });
          },
          tween: Tween<Offset>(
            begin: Offset(-MediaQuery.of(context).size.width, 0),
            end: Offset.zero,
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          builder: (context, value, child) => Transform.translate(
            offset: value as Offset,
            child: Material(
              elevation: 20.0,
              child: current == -1
                  ? ProminentColorWidget()
                  : ExtendedImage(
                      image:
                          widget.images[current.clamp(0, widget.images.length)],
                      isAntiAlias: false,
                      width: widget.width ?? MediaQuery.of(context).size.width,
                      height:
                          widget.height ?? MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                    ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widgets.isEmpty) {
      widgets.add(
        TweenAnimationBuilder(
          tween: Tween<Offset>(
            begin: Offset.zero,
            end: Offset.zero,
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          builder: (context, value, child) => Material(
            child: _current == -1
                ? ProminentColorWidget()
                : ExtendedImage(
                    image: widget.images[_current],
                    isAntiAlias: false,
                    width: widget.width ?? MediaQuery.of(context).size.width,
                    height: widget.height ?? MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                  ),
          ),
        ),
      );
    }
    return Container(
      width: widget.width ?? MediaQuery.of(context).size.width,
      height: widget.height ?? MediaQuery.of(context).size.height,
      color: Colors.black,
      child: Stack(
        children: [
          ...widgets,
          Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    height:
                        widget.height ?? MediaQuery.of(context).size.height / 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    height:
                        widget.height ?? MediaQuery.of(context).size.height / 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 84.0,
                  left: 0.0,
                  right: 0.0,
                  top: 0.0,
                  child: widget.content,
                ),
                GestureDetector(
                  onDoubleTap: toggle,
                  onHorizontalDragUpdate: (details) {
                    const sensitivity = 4;
                    if (details.delta.dx > sensitivity) {
                      next();
                    } else if (details.delta.dx < -sensitivity) {
                      previous();
                    }
                  },
                  onVerticalDragUpdate: (details) {
                    const sensitivity = 20;
                    if (details.delta.dy > sensitivity) {
                      toggle(hide: true);
                      widget.hide();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    width: widget.width ?? MediaQuery.of(context).size.width,
                    height: widget.height ?? MediaQuery.of(context).size.height,
                  ),
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Listener(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (!_isFullscreen) widget.top,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: widget.bottom,
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        splashRadius: 20.0,
                        onPressed: previous,
                        icon: const Icon(Icons.chevron_left),
                        color: Colors.white,
                      ),
                      IconButton(
                        splashRadius: 20.0,
                        onPressed: next,
                        icon: const Icon(Icons.chevron_right),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16.0),
                      IconButton(
                        splashRadius: 20.0,
                        onPressed: toggle,
                        icon: Icon(
                          _isFullscreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                        ),
                        color: Colors.white,
                        tooltip: _isFullscreen
                            ? Language.instance.EXIT_FULLSCREEN
                            : Language.instance.FULLSCREEN,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProminentColorWidget extends StatefulWidget {
  ProminentColorWidget({Key? key}) : super(key: key);

  @override
  State<ProminentColorWidget> createState() => _ProminentColorWidgetState();
}

class _ProminentColorWidgetState extends State<ProminentColorWidget> {
  Color? color;
  Track? track;

  @override
  void initState() {
    super.initState();
    Playback.instance.addListener(listener);
    listener();
  }

  @override
  void dispose() {
    Playback.instance.removeListener(listener);
    super.dispose();
  }

  Future<void> listener() async {
    final track = Playback.instance.tracks[Playback.instance.index];
    if (this.track != track) {
      this.track = track;
      try {
        final result = await PaletteGenerator.fromImageProvider(
            getAlbumArt(track, small: true));
        setState(() {
          color = result.colors.first;
        });
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: Colors.transparent,
        end: color ?? Colors.transparent,
      ),
      duration: Duration(milliseconds: 400),
      builder: (context, color, _) => Container(
        color: color,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class LyricsStyle extends LyricUI {
  double defaultSize;
  double defaultExtSize;
  double otherMainSize;
  double bias;
  double lineGap;
  double inlineGap;
  LyricAlign lyricAlign;
  LyricBaseLine lyricBaseLine;
  bool highlight;

  LyricsStyle({
    this.defaultSize = 20,
    this.defaultExtSize = 14,
    this.otherMainSize = 20,
    this.bias = 0.5,
    this.lineGap = 25,
    this.inlineGap = 25,
    this.lyricAlign = LyricAlign.CENTER,
    this.lyricBaseLine = LyricBaseLine.CENTER,
    this.highlight = true,
  });

  LyricsStyle.clone(LyricsStyle lyricsStyle)
      : this(
          defaultSize: lyricsStyle.defaultSize,
          defaultExtSize: lyricsStyle.defaultExtSize,
          otherMainSize: lyricsStyle.otherMainSize,
          bias: lyricsStyle.bias,
          lineGap: lyricsStyle.lineGap,
          inlineGap: lyricsStyle.inlineGap,
          lyricAlign: lyricsStyle.lyricAlign,
          lyricBaseLine: lyricsStyle.lyricBaseLine,
          highlight: lyricsStyle.highlight,
        );

  @override
  TextStyle getPlayingExtTextStyle() =>
      TextStyle(color: Colors.grey[300], fontSize: defaultExtSize);

  @override
  TextStyle getOtherExtTextStyle() => TextStyle(
        color: Colors.grey[300],
        fontSize: defaultExtSize,
      );

  @override
  TextStyle getOtherMainTextStyle() => TextStyle(
        color: Colors.grey[200],
        fontSize: otherMainSize,
        shadows: <Shadow>[
          Shadow(
            offset: Offset(-2.0, 2.0),
            blurRadius: 3.0,
            color: Color.fromARGB(128, 0, 0, 0),
          ),
          Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 8.0,
            color: Color.fromARGB(164, 0, 0, 0),
          ),
        ],
        overflow: TextOverflow.ellipsis,
      );

  @override
  TextStyle getPlayingMainTextStyle() => TextStyle(
        color: Colors.white,
        fontSize: defaultSize,
        fontWeight: FontWeight.w600,
        shadows: <Shadow>[
          Shadow(
            offset: Offset(-2.0, 2.0),
            blurRadius: 3.0,
            color: Color.fromARGB(128, 0, 0, 0),
          ),
          Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 8.0,
            color: Color.fromARGB(164, 0, 0, 0),
          ),
        ],
        overflow: TextOverflow.ellipsis,
      );

  @override
  double getInlineSpace() => inlineGap;

  @override
  double getLineSpace() => lineGap;

  @override
  double getPlayingLineBias() => bias;

  @override
  LyricAlign getLyricHorizontalAlign() => lyricAlign;

  @override
  LyricBaseLine getBiasBaseLine() => lyricBaseLine;

  @override
  bool enableHighlight() => highlight;
}
