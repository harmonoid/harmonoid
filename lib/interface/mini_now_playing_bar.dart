/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';
import 'package:harmonoid/state/now_playing_scroll_hider.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:extended_image/extended_image.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:provider/provider.dart';

class MiniNowPlayingBar extends StatefulWidget {
  MiniNowPlayingBar({Key? key}) : super(key: key);

  @override
  State<MiniNowPlayingBar> createState() => MiniNowPlayingBarState();
}

class MiniNowPlayingBarState extends State<MiniNowPlayingBar>
    with SingleTickerProviderStateMixin {
  double _yOffset = 0.0;

  bool get isHidden => _yOffset != 0.0;

  void show() {
    if (_yOffset != 0.0) {
      setState(() => _yOffset = 0.0);
    }
  }

  void hide() {
    if (_yOffset == 0.0) {
      setState(
        () => _yOffset = kMobileNowPlayingBarHeight /
            (MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.vertical),
      );
    }
  }

  late AnimationController playOrPause;
  late VoidCallback listener;
  Iterable<Color>? palette;
  Track? track;
  bool showAlbumArtButton = false;

  @override
  void initState() {
    super.initState();
    playOrPause = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    listener = () async {
      if (Playback.instance.isPlaying) {
        playOrPause.forward();
      } else {
        playOrPause.reverse();
      }
      if (Playback.instance.index < 0 ||
          Playback.instance.index >= Playback.instance.tracks.length) {
        return;
      }
      final track = Playback.instance.tracks[Playback.instance.index];
      if (this.track != track) {
        this.track = track;
        PaletteGenerator.fromImageProvider(getAlbumArt(track, small: true))
            .then(
          (value) => setState(
            () {
              palette = value.colors;
              if (Configuration
                  .instance.changeNowPlayingBarColorBasedOnPlayingMusic) {
                NowPlayingScrollHider.instance.palette.value = value.colors;
              }
            },
          ),
        );
      }
    };
    Playback.instance.addListener(listener);
  }

  @override
  void dispose() {
    Playback.instance.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(0, _yOffset),
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(
            begin: Theme.of(context).primaryColor,
            end: palette?.first ?? Theme.of(context).primaryColor),
        duration: Duration(milliseconds: 400),
        builder: (context, color, _) => Miniplayer(
          elevation: 8.0,
          minHeight: kMobileNowPlayingBarHeight,
          maxHeight: MediaQuery.of(context).size.height,
          tapToCollapse: false,
          backgroundColor: Theme.of(context).cardColor,
          builder: (height, percentage) {
            return Consumer<Playback>(
              builder: (context, playback, _) => Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    if (height < 256.0)
                      LinearProgressIndicator(
                        value: playback.duration == Duration.zero
                            ? 0.0
                            : playback.position.inMilliseconds /
                                playback.duration.inMilliseconds,
                        minHeight: 2.0,
                        valueColor: AlwaysStoppedAnimation(
                            color ?? Theme.of(context).primaryColor),
                        backgroundColor:
                            (color ?? Theme.of(context).primaryColor)
                                .withOpacity(0.2),
                      ),
                    Expanded(
                      child: Stack(
                        children: [
                          if (height < 256.0)
                            LinearProgressIndicator(
                              value: playback.duration == Duration.zero
                                  ? 0.0
                                  : playback.position.inMilliseconds /
                                      playback.duration.inMilliseconds,
                              minHeight: height - 2.0,
                              valueColor: AlwaysStoppedAnimation(
                                  (color ?? Theme.of(context).primaryColor)
                                      .withOpacity(0.2)),
                              backgroundColor: Theme.of(context).cardColor,
                            ),
                          Positioned.fill(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ExtendedImage(
                                  image: getAlbumArt(
                                      playback.tracks[playback.index]),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width,
                                    maxHeight:
                                        MediaQuery.of(context).size.width,
                                  ),
                                  width: percentage == 1.0
                                      ? MediaQuery.of(context).size.width
                                      : percentage == 0.0
                                          ? 64.0
                                          : null,
                                  height: percentage == 1.0
                                      ? MediaQuery.of(context).size.width
                                      : percentage == 0.0
                                          ? 64.0
                                          : null,
                                  fit: BoxFit.fitWidth,
                                ),
                                if (height < 256.0) const SizedBox(width: 16.0),
                                if (height < 256.0)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          playback.tracks[playback.index]
                                              .trackName.overflow,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          playback.tracks[playback.index]
                                              .trackArtistNames
                                              .take(2)
                                              .join(', ')
                                              .overflow,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                if (height < 256.0)
                                  Material(
                                    child: Container(
                                      height: 64.0,
                                      width: 64.0,
                                      child: IconButton(
                                        onPressed: playback.playOrPause,
                                        icon: AnimatedIcon(
                                          progress: playOrPause,
                                          icon: AnimatedIcons.play_pause,
                                        ),
                                        splashRadius: 24.0,
                                      ),
                                    ),
                                    color: Colors.transparent,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MiniNowPlayingBarRefreshCollectionButton extends StatefulWidget {
  MiniNowPlayingBarRefreshCollectionButton({Key? key}) : super(key: key);

  @override
  State<MiniNowPlayingBarRefreshCollectionButton> createState() =>
      MiniNowPlayingBarRefreshCollectionButtonState();
}

class MiniNowPlayingBarRefreshCollectionButtonState
    extends State<MiniNowPlayingBarRefreshCollectionButton> {
  double _yOffset = 0.0;

  void show() {
    if (_yOffset == 0.0) {
      setState(() => _yOffset = -1.2);
    }
  }

  void hide() {
    if (_yOffset != 0.0) {
      setState(() => _yOffset = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(0, _yOffset),
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ValueListenableBuilder<Iterable<Color>?>(
        valueListenable: NowPlayingScrollHider.instance.palette,
        builder: (context, value, _) => TweenAnimationBuilder(
          duration: Duration(milliseconds: 400),
          tween: ColorTween(
            begin: Theme.of(context).primaryColor,
            end: value?.first ?? Theme.of(context).primaryColor,
          ),
          builder: (context, color, _) => RefreshCollectionButton(
            color: color as Color?,
          ),
        ),
      ),
    );
  }
}
