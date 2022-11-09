import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_plus/window_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:media_engine/media_engine.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/interface/now_playing_bar.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/now_playing_visuals.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
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
  }

  @override
  void dispose() {
    Playback.instance.removeListener(listener);
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Consumer<NowPlayingColorPalette>(
      builder: (context, colors, _) => Theme(
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
            ),
            palette: colors.palette,
            images: NowPlayingVisuals.instance.preloaded
                    .map((e) => AssetImage(e))
                    .toList()
                    .cast<ImageProvider>() +
                NowPlayingVisuals.instance.user
                    .map((e) => FileImage(File(e)))
                    .toList()
                    .cast<ImageProvider>(),
            mouseValue: Playback.instance.volume.clamp(0.0, 100.0),
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
                        if (Lyrics.instance.current.length > 1) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: (Lyrics.instance.current.length > 1 &&
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
                                          .asMap()
                                          .entries
                                          .map((e) {
                                        return LyricsLineModel()
                                          ..mainText = e.value.words
                                          ..startTime = e.value.time
                                          ..endTime = e.key + 1 <
                                                  Lyrics.instance.current.length
                                              ? Lyrics.instance
                                                  .current[e.key + 1].time
                                              : 1 << 32;
                                      }).toList(),
                                    position: playback.position.inMilliseconds,
                                    lyricUi: LyricsStyle()
                                      ..defaultSize = Configuration
                                          .instance.highlightedLyricsSize
                                      ..otherMainSize = Configuration
                                          .instance.unhighlightedLyricsSize
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
                  child: PageView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    controller: pageController,
                    // onPageChanged: (page) {
                    //   currentPage = page;
                    // },
                    itemCount: Playback.instance.tracks.length,
                    itemBuilder: (context, i) => Consumer<Playback>(
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
                              elevation: kDefaultHeavyElevation,
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
                                            valueColor: AlwaysStoppedAnimation(
                                              Theme.of(context).primaryColor,
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
                                                .displayLarge
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
                                          playback.tracks[i].trackName.overflow,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge
                                              ?.copyWith(
                                            fontSize: 28.0,
                                            color: Colors.white,
                                            shadows: <Shadow>[
                                              Shadow(
                                                offset: Offset(-2.0, 2.0),
                                                blurRadius: 3.0,
                                                color:
                                                    Color.fromARGB(96, 0, 0, 0),
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
                                        const SizedBox(height: 4.0),
                                        Text(
                                          [
                                            if (!playback.tracks[i]
                                                .hasNoAvailableArtists)
                                              playback
                                                  .tracks[i].trackArtistNames
                                                  .take(2)
                                                  .join(', ')
                                                  .overflow,
                                            if (!playback
                                                .tracks[i].hasNoAvailableAlbum)
                                              playback.tracks[i].albumName,
                                            if (![
                                              kUnknownYear,
                                              ''
                                            ].contains(playback.tracks[i].year))
                                              playback.tracks[i].year
                                          ].join(' • '),
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                            color: Colors.white70,
                                            shadows: <Shadow>[
                                              Shadow(
                                                offset: Offset(-2.0, 2.0),
                                                blurRadius: 3.0,
                                                color:
                                                    Color.fromARGB(96, 0, 0, 0),
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
                                        if (Configuration
                                                .instance.displayAudioFormat &&
                                            playback.audioFormatLabelSmall
                                                .isNotEmpty)
                                          Text(
                                            playback.audioFormatLabel,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall
                                                ?.copyWith(
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
                            const SizedBox(width: 32.0),
                          ],
                        ),
                      ),
                    ),
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
                                      color: colors.palette?.last,
                                      secondaryColor: colors.palette?.first,
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
                            IconButton(
                              onPressed: () {
                                shuffleCooldown = Timer(
                                    const Duration(milliseconds: 300), () {});
                                playback.toggleShuffle();
                              },
                              iconSize: 20.0,
                              color: playback.isShuffling
                                  ? Color.lerp(Colors.black, Colors.white, 0.87)
                                  : Color.lerp(
                                      Colors.black, Colors.white, 0.54),
                              splashRadius: 18.0,
                              icon: Icon(
                                Icons.shuffle,
                              ),
                              tooltip: Language.instance.SHUFFLE,
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
                              color: (playback.playlistLoopMode !=
                                      PlaylistLoopMode.none)
                                  ? Color.lerp(Colors.black, Colors.white, 0.87)
                                  : Color.lerp(
                                      Colors.black, Colors.white, 0.54),
                              splashRadius: 18.0,
                              icon: Icon(
                                playback.playlistLoopMode ==
                                        PlaylistLoopMode.single
                                    ? Icons.repeat_one
                                    : Icons.repeat,
                              ),
                              tooltip: Language.instance.REPEAT,
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
                              color: Configuration.instance.lyricsVisible
                                  ? Color.lerp(Colors.black, Colors.white, 0.87)
                                  : Color.lerp(
                                      Colors.black, Colors.white, 0.54),
                              tooltip: Language.instance.SHOW_LYRICS,
                            ),
                            if (LibmpvPluginUtils.isSupported(
                                playback.tracks[playback.index].uri))
                              IconButton(
                                splashRadius: 20.0,
                                iconSize: 20.0,
                                onPressed: () {
                                  launchUrl(
                                    playback.tracks[playback.index].uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: Icon(
                                  Icons.open_in_new,
                                ),
                                color: Colors.white,
                                tooltip: Language.instance.OPEN_IN_BROWSER,
                              ),
                            if (LibmpvPluginUtils.isSupported(
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
                                color: colors.palette?.last,
                                secondaryColor: colors.palette?.first,
                                inferSliderInactiveTrackColor: false,
                                min: 0,
                                max: 100.0,
                                value: playback.volume.clamp(0.0, 100.0),
                                onScrolledUp: () {
                                  playback.setVolume(
                                    (playback.volume.clamp(0.0, 100.0) + 5.0)
                                        .clamp(0.0, 100.0),
                                  );
                                },
                                onScrolledDown: () {
                                  playback.setVolume(
                                    (playback.volume.clamp(0.0, 100.0) - 5.0)
                                        .clamp(0.0, 100.0),
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
                                  RenderBox box = controlPanelKey
                                      .currentContext!
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
  bool playlistVisible = false;

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
  }

  void toggle({bool? hide}) async {
    if (hide != null) {
      await WindowPlus.instance.setIsFullscreen(!hide);
      _isFullscreen = !hide;
      return;
    }
    await WindowPlus.instance.setIsFullscreen(!_isFullscreen);
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
              color: Colors.black,
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
              color: Colors.black,
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
            color: Colors.black,
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
                        widget.height ?? MediaQuery.of(context).size.height / 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black87,
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
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: 32.0,
                bottom: 96.0 + 16.0,
              ),
              child: FloatingActionButton(
                heroTag: 'playlist_button_modern_now_playing_screen',
                onPressed: () {
                  setState(() {
                    playlistVisible = !playlistVisible;
                  });
                },
                child: Icon(Icons.queue_music),
                mini: true,
                backgroundColor: widget.palette?.last,
                foregroundColor:
                    (widget.palette?.last ?? Theme.of(context).primaryColor)
                            .isDark
                        ? Colors.white
                        : Colors.black,
              ),
            ),
          ),
          Positioned.fill(
            child: TweenAnimationBuilder<Color?>(
              child: Expanded(
                child: CustomListViewBuilder(
                  controller: ScrollController(
                      initialScrollOffset: 48.0 *
                          (Playback.instance.index - 2)
                              .clamp(0, 9223372036854775807)),
                  itemExtents: List.generate(
                    Playback.instance.tracks.length,
                    (index) => 48.0,
                  ),
                  itemCount: Playback.instance.tracks.length,
                  itemBuilder: (context, index) => Material(
                    color: Playback.instance.index == index
                        ? Theme.of(context)
                            .dividerTheme
                            .color
                            ?.withOpacity(0.12)
                        : Colors.transparent,
                    child: TrackTile(
                      leading: Playback.instance.index == index
                          ? Icon(
                              Icons.play_arrow,
                              size: 24.0,
                            )
                          : Text(
                              '${index + 1}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                      track: Playback.instance.tracks[index],
                      index: 0,
                      onPressed: () {
                        Playback.instance.play();
                        Playback.instance.jump(index);
                      },
                      disableContextMenu: true,
                    ),
                  ),
                ),
              ),
              tween: ColorTween(
                begin: Colors.transparent,
                end: playlistVisible ? Colors.black38 : Colors.transparent,
              ),
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              builder: (context, color, child) => GestureDetector(
                onTap: () {
                  setState(() {
                    playlistVisible = false;
                  });
                },
                child: Container(
                  alignment: Alignment.bottomCenter,
                  color: color == Colors.transparent ? null : color,
                  width: double.infinity,
                  height: double.infinity,
                  child: color == Colors.transparent
                      ? null
                      : TweenAnimationBuilder<Offset>(
                          tween: Tween<Offset>(
                            begin: Offset(
                              0,
                              MediaQuery.of(context).size.height,
                            ),
                            end: playlistVisible
                                ? Offset.zero
                                : Offset(
                                    0,
                                    MediaQuery.of(context).size.height,
                                  ),
                          ),
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          builder: (context, offset, _) => Transform.translate(
                            offset: offset,
                            child: Card(
                              elevation: 20.0,
                              clipBehavior: Clip.antiAlias,
                              margin: EdgeInsets.all(32.0),
                              child: Container(
                                width:
                                    MediaQuery.of(context).size.width * 2 / 3,
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: Column(
                                  children: [
                                    Container(
                                      height: 102.0,
                                      padding: EdgeInsets.all(16.0),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  playlistVisible = false;
                                                });
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              child: Container(
                                                height: 40.0,
                                                width: 40.0,
                                                child: Icon(
                                                  Icons.arrow_back,
                                                  size: 24.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 20.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  Language.instance.NOW_PLAYING,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayLarge
                                                      ?.copyWith(
                                                          fontSize: 24.0),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 8.0),
                                                Text(
                                                  '${Language.instance.TRACK}: ${Playback.instance.tracks.length}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      height: 1.0,
                                    ),
                                    if (child != null) child,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
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
  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingColorPalette>(
      builder: (context, color, _) => TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          begin: color.palette?.first,
          end: color.palette?.first ?? Colors.transparent,
        ),
        duration: Duration(milliseconds: 400),
        builder: (context, color, _) => Container(
          color: Colors.black,
          child: Container(
            color: color,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
        ),
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
  TextStyle getPlayingExtTextStyle() => TextStyle(
        color: Colors.grey[300],
        fontSize: defaultExtSize,
        height: 1.2,
      );

  @override
  TextStyle getOtherExtTextStyle() => TextStyle(
        color: Colors.grey[300],
        fontSize: defaultExtSize,
        fontFamily: Platform.isLinux ? 'Inter' : null,
        height: 1.2,
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
        fontFamily: Platform.isLinux ? 'Inter' : null,
        height: 1.2,
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
        fontFamily: Platform.isLinux ? 'Inter' : null,
        height: 1.2,
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

extension on Color {
  bool get isDark => (0.299 * red) + (0.587 * green) + (0.114 * blue) < 128.0;
}
