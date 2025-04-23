import 'dart:ui';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:measure_size/measure_size.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/duration.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/build_context.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/state/lyrics_notifier.dart';
import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/ui/now_playing/now_playing_bar.dart';
import 'package:harmonoid/ui/now_playing/now_playing_colors.dart';
import 'package:harmonoid/ui/now_playing/now_playing_control_panel.dart';
import 'package:harmonoid/ui/now_playing/now_playing_playlist_item.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/mini_player.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/ripple_surface.dart';
import 'package:harmonoid/utils/sliding_up_panel.dart';
import 'package:harmonoid/utils/widgets.dart';

class M2MobileNowPlayingBar extends StatefulWidget {
  const M2MobileNowPlayingBar({super.key});

  @override
  State<M2MobileNowPlayingBar> createState() => M2MobileNowPlayingBarState();
}

class M2MobileNowPlayingBarState extends State<M2MobileNowPlayingBar> {
  final ValueNotifier<double> _valueNotifier = ValueNotifier<double>(0.0);
  final MiniPlayerController _miniPlayerController = MiniPlayerController();
  final PanelController _panelController = PanelController();
  bool _lyricsVisible = false;

  // FIXED
  late final double _pageViewHeight = MediaQuery.sizeOf(context).width.clamp(0.0, (MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).vertical) * 3 / 5);

  // DYNAMIC
  double _detailsHeight = 0.0;
  double _controlsHeight = 0.0;

  double get _slidingUpPanelMaxHeight => MediaQuery.sizeOf(context).height - (MediaQuery.paddingOf(context).top + 16.0 + 40.0 + 16.0);

  double get _slidingUpPanelMinHeight => MediaQuery.sizeOf(context).height - (_pageViewHeight + _detailsHeight + _controlsHeight);

  Color? get _slidingUpPanelColor => isDarkMode ? Theme.of(context).colorScheme.surfaceContainer : Theme.of(context).colorScheme.surfaceContainerLowest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<NowPlayingMobileNotifier>().setM2MobileNowPlayingBarStateRef(this));
  }

  bool get maximized => !_lyricsVisible && _valueNotifier.value == 1.0;

  bool get slidingUpPanelOpened {
    try {
      return _panelController.isPanelOpen;
    } catch (_) {
      return false;
    }
  }

  void maximizeNowPlayingBar() {
    _miniPlayerController.animateToHeight(state: MiniPlayerPanelState.MAX);
  }

  void minimizeNowPlayingBar() {
    _miniPlayerController.animateToHeight(state: MiniPlayerPanelState.MIN);
  }

  void closeSlidingUpPanel() {
    _panelController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingColorPaletteNotifier>(
      builder: (context, nowPlayingColorPaletteNotifier, _) {
        return Provider<NowPlayingColors>.value(
          value: NowPlayingColors.fromPalette(
            context,
            Configuration.instance.mobileNowPlayingRipple ? nowPlayingColorPaletteNotifier.palette : null,
          ),
          builder: (context, _) {
            final nowPlayingColors = context.read<NowPlayingColors>();
            return Consumer<MediaPlayer>(
              builder: (context, mediaPlayer, _) {
                if (mediaPlayer.state.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Stack(
                  children: [
                    MiniPlayer(
                      controller: _miniPlayerController,
                      curve: Curves.easeInOut,
                      minHeight: NowPlayingBar.height,
                      maxHeight: MediaQuery.sizeOf(context).height,
                      elevation: kDefaultHeavyElevation,
                      tapToCollapse: false,
                      builder: (height, percentage) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          try {
                            if (percentage == 0.0) {
                              _panelController.close();
                            }

                            _valueNotifier.value = percentage;
                            context.read<NowPlayingMobileNotifier>().setBottomNavigationBarVisibility((1.0 - percentage * 2.0).clamp(0.0, 1.0));
                          } catch (_) {}
                        });

                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned.fill(
                              child: Container(
                                color: Color.lerp(Theme.of(context).colorScheme.surface, Theme.of(context).scaffoldBackgroundColor, percentage),
                              ),
                            ),
                            if (percentage > 0.5)
                              Positioned.fill(
                                child: Opacity(
                                  opacity: ((percentage - 0.5) / 0.5).clamp(0.0, 1.0),
                                  child: RippleSurface(color: nowPlayingColors.background),
                                ),
                              ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IgnorePointer(
                                  child: Opacity(
                                    opacity: percentage == 1.0 ? 0.0 : 1.0,
                                    child: SizedBox(
                                      width: lerpDouble(NowPlayingBar.height, MediaQuery.sizeOf(context).width, percentage),
                                      height: lerpDouble(NowPlayingBar.height, _pageViewHeight, percentage),
                                      child: Image(
                                        image: cover(uri: mediaPlayer.current.uri),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: percentage > 0.2
                                      ? const SizedBox.shrink()
                                      : Opacity(
                                          opacity: (1.0 - percentage / 0.2).clamp(0.0, 1.0),
                                          child: Row(
                                            children: [
                                              const SizedBox(width: 12.0),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      mediaPlayer.current.title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                                    ),
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          for (final artist in mediaPlayer.current.subtitle.isEmpty ? {''} : mediaPlayer.current.subtitle) ...[
                                                            TextSpan(
                                                              text: artist.isEmpty ? kDefaultArtist : artist,
                                                            ),
                                                            const TextSpan(text: ', '),
                                                          ]
                                                        ]..removeLast(),
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12.0),
                                              Center(
                                                child: IconButton(
                                                  onPressed: mediaPlayer.playOrPause,
                                                  icon: StatefulAnimatedIcon(
                                                    dismissed: mediaPlayer.state.playing,
                                                    icon: AnimatedIcons.play_pause,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8.0),
                                            ],
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            if (percentage > 0.5)
                              Opacity(
                                opacity: ((percentage - 0.5) / 0.5).clamp(0.0, 1.0),
                                child: AnnotatedRegion<SystemUiOverlayStyle>(
                                  value: context.toSystemUiOverlayStyle(null, ThemeMode.dark),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildPageView(context, mediaPlayer, percentage),
                                      _buildDetails(context, mediaPlayer, nowPlayingColors),
                                      _buildControls(context, mediaPlayer, nowPlayingColors),
                                    ],
                                  ),
                                ),
                              ),
                            if (percentage < 0.5)
                              Positioned(
                                left: 0.0,
                                right: 0.0,
                                bottom: 0.0,
                                child: Opacity(
                                  opacity: (1.0 - percentage / 0.5).clamp(0.0, 1.0),
                                  child: const Divider(height: 1.0, thickness: 1.0),
                                ),
                              ),
                            if (percentage < 0.5)
                              () {
                                const sliderMin = 0.0;
                                final sliderMax = mediaPlayer.state.duration.inMilliseconds.toDouble();
                                final sliderValue = mediaPlayer.state.position.inMilliseconds.clamp(sliderMin, sliderMax).toDouble();
                                final double value;
                                if (sliderMax == 0.0 || sliderValue == 0.0) {
                                  value = 0.0;
                                } else {
                                  value = sliderValue / (sliderMax - sliderMin);
                                }
                                return Positioned(
                                  left: 0.0,
                                  right: 0.0,
                                  top: 0.0,
                                  child: Opacity(
                                    opacity: (1.0 - percentage / 0.5).clamp(0.0, 1.0),
                                    child: SizedBox(
                                      height: 2.0,
                                      child: LinearProgressIndicator(
                                        value: value,
                                        color: context.read<NowPlayingColors>().sliderForeground,
                                        backgroundColor: context.read<NowPlayingColors>().sliderForeground?.withValues(alpha: 0.2),
                                      ),
                                    ),
                                  ),
                                );
                              }(),
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _valueNotifier,
                      builder: (context, percentage, child) {
                        if (MediaQuery.viewInsetsOf(rootNavigatorKey.currentContext!).bottom > 0.0) {
                          return const SizedBox.shrink();
                        }
                        if (_slidingUpPanelMaxHeight < _slidingUpPanelMinHeight) {
                          return const SizedBox.shrink();
                        }
                        return AnimatedSwitcher(
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          duration: Theme.of(context).extension<AnimationDuration>()?.slow ?? Duration.zero,
                          child: percentage == 1.0 ? child : const SizedBox.shrink(),
                        );
                      },
                      child: _slidingUpPanelMaxHeight < _slidingUpPanelMinHeight
                          ? const SizedBox.shrink()
                          : SlidingUpPanel(
                              controller: _panelController,
                              maxHeight: _slidingUpPanelMaxHeight,
                              minHeight: _slidingUpPanelMinHeight,
                              parallaxEnabled: false,
                              panelSnapping: true,
                              renderPanelSheet: true,
                              backdropEnabled: true,
                              backdropTapClosesPanel: true,
                              backdropOpacity: 0.5,
                              color: _slidingUpPanelColor ?? Colors.transparent,
                              margin: const EdgeInsets.symmetric(horizontal: 16.0),
                              borderRadius: (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius,
                              panelBuilder: (controller) => _buildPlaylist(context, mediaPlayer, 0, controller: controller),
                              collapsed: _buildPlaylist(context, mediaPlayer, mediaPlayer.state.index + 1, physics: const NeverScrollableScrollPhysics()),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, MediaPlayer mediaPlayer) {
    return IconTheme(
      data: const IconThemeData(color: Colors.white),
      child: Container(
        height: kToolbarHeight,
        margin: EdgeInsets.only(top: MediaQuery.paddingOf(context).top, left: 8.0, right: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _miniPlayerController.animateToHeight(state: MiniPlayerPanelState.MIN),
              icon: const Icon(Icons.close),
            ),
            const Spacer(),
            Consumer<LyricsNotifier>(
              builder: (context, lyricsNotifier, _) {
                if (lyricsNotifier.lyrics.isEmpty) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  onPressed: () async {
                    _lyricsVisible = true;
                    await context.push('/$kNowPlayingLyricsPath');
                    _lyricsVisible = false;
                  },
                  icon: const Icon(Icons.text_format),
                );
              },
            ),
            IconButton(
              onPressed: () => NowPlayingControlPanel.show(context),
              icon: const Icon(Icons.equalizer),
            ),
            Consumer<MediaLibrary>(
              builder: (context, mediaLibrary, _) {
                final uri = mediaPlayer.current.uri;
                final liked = mediaLibrary.playlists.liked(uri: uri);
                return IconButton(
                  onPressed: () async {
                    if (liked) {
                      await mediaLibrary.playlists.unlike(uri: uri);
                    } else {
                      await mediaLibrary.playlists.like(uri: uri);
                    }
                  },
                  icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
                );
              },
            ),
            IconButton(
              onPressed: () {
                showAddToPlaylistDialog(context, playable: mediaPlayer.current);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView(BuildContext context, MediaPlayer mediaPlayer, double percentage) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: _pageViewHeight,
          child: StatefulPageViewBuilder(
            physics: const NeverScrollableScrollPhysics(),
            index: mediaPlayer.state.index,
            itemCount: mediaPlayer.state.playables.length,
            itemBuilder: (context, i) {
              final child = Image(
                image: cover(uri: mediaPlayer.state.playables[i].uri),
                fit: BoxFit.cover,
              );
              return AnimatedOpacity(
                opacity: percentage == 1.0 ? 1.0 : 0.0,
                curve: Curves.easeInOut,
                duration: i == mediaPlayer.state.index ? Duration.zero : Theme.of(context).extension<AnimationDuration>()?.slow ?? Duration.zero,
                child: child,
              );
            },
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black26,
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [
                  0.0,
                  0.5,
                ],
              ),
            ),
          ),
        ),
        _buildAppBar(context, mediaPlayer),
      ],
    );
  }

  Widget _buildDetails(BuildContext context, MediaPlayer mediaPlayer, NowPlayingColors nowPlayingColors) {
    return MeasureSize(
      onChange: (size) {
        if (_detailsHeight != 0.0) return;
        setState(() => _detailsHeight = size.height);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mediaPlayer.current.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: nowPlayingColors.backgroundText).copyWith(height: 1.0),
              strutStyle: StrutStyle.fromTextStyle(Theme.of(context).textTheme.headlineSmall!.copyWith(height: 1.5)),
            ),
            const SizedBox(height: 2.0),
            RichText(
              text: TextSpan(
                children: [
                  for (final artist in mediaPlayer.current.subtitle.isEmpty ? {''} : mediaPlayer.current.subtitle) ...[
                    TextSpan(
                      text: artist.isEmpty ? kDefaultArtist : artist,
                    ),
                    const TextSpan(text: ', '),
                  ]
                ]..removeLast(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: nowPlayingColors.backgroundText).copyWith(height: 1.0),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              strutStyle: StrutStyle.fromTextStyle(Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.5)),
            ),
            const SizedBox(height: 2.0),
            if (Configuration.instance.nowPlayingAudioFormat)
              Text(
                mediaPlayer.state.getAudioFormatLabel(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: nowPlayingColors.backgroundText).copyWith(height: 1.0),
                strutStyle: StrutStyle.fromTextStyle(Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.5)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, MediaPlayer mediaPlayer, NowPlayingColors nowPlayingColors) {
    return MeasureSize(
      onChange: (size) {
        if (_controlsHeight != 0.0) return;
        setState(() => _controlsHeight = size.height);
      },
      child: Controls(nowPlayingColors: nowPlayingColors),
    );
  }

  Widget _buildPlaylist(
    BuildContext context,
    MediaPlayer mediaPlayer,
    int diff, {
    ScrollPhysics? physics,
    ScrollController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _slidingUpPanelColor,
        borderRadius: (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (_panelController.isPanelOpen) {
                _panelController.close();
              } else {
                _panelController.open();
              }
            },
            child: Container(
              height: 32.0,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Container(
                width: 48.0,
                height: 4.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.0),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const Divider(height: 1.0, thickness: 1.0),
          Expanded(
            child: ListView.builder(
              physics: physics,
              controller: controller,
              padding: EdgeInsets.zero,
              itemBuilder: (context, i) {
                if (i % 2 != 0) {
                  return const Divider(height: 1.0, thickness: 1.0);
                }
                return NowPlayingPlaylistItem(
                  index: (i ~/ 2) + diff,
                  width: double.infinity,
                  height: kMobileLinearTileHeight,
                );
              },
              itemExtentBuilder: (i, _) => i % 2 != 0 ? 1.0 : kMobileLinearTileHeight,
              itemCount: (2 * (mediaPlayer.state.playables.length - diff) - 1).clamp(0, 1 << 32),
            ),
          ),
        ],
      ),
    );
  }
}

class Controls extends StatelessWidget {
  final NowPlayingColors nowPlayingColors;

  const Controls({super.key, required this.nowPlayingColors});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: nowPlayingColors.toSliderThemeData(),
      child: Consumer<MediaPlayer>(
        builder: (context, mediaPlayer, _) {
          const sliderMin = 0.0;
          final sliderMax = mediaPlayer.state.duration.inMilliseconds.toDouble();
          final sliderValue = mediaPlayer.state.position.inMilliseconds.clamp(sliderMin, sliderMax).toDouble();
          return Column(
            children: [
              ScrollableSlider(
                min: sliderMin,
                max: sliderMax,
                value: sliderValue,
                onChanged: (value) => mediaPlayer.seek(Duration(milliseconds: value.round())),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Text(
                      mediaPlayer.state.position.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: nowPlayingColors.backgroundText,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      mediaPlayer.state.duration.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: nowPlayingColors.backgroundText,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: mediaPlayer.shuffleOrUnshuffle,
                    color: mediaPlayer.state.shuffle ? nowPlayingColors.backgroundEnabledIcon : nowPlayingColors.backgroundDisabledIcon,
                    icon: const Icon(Icons.shuffle),
                    splashRadius: 20.0,
                    iconSize: Theme.of(context).iconTheme.size! * 0.8,
                    tooltip: Localization.instance.SHUFFLE,
                  ),
                  IconButton(
                    onPressed: mediaPlayer.previous,
                    color: mediaPlayer.state.isFirst ? nowPlayingColors.backgroundDisabledIcon : nowPlayingColors.backgroundEnabledIcon,
                    icon: const Icon(Icons.skip_previous),
                    splashRadius: 20.0,
                    tooltip: Localization.instance.PREVIOUS,
                  ),
                  const SizedBox(width: 8.0),
                  FloatingActionButton(
                    heroTag: '***',
                    onPressed: mediaPlayer.playOrPause,
                    backgroundColor: nowPlayingColors.foreground,
                    foregroundColor: nowPlayingColors.foregroundIcon,
                    tooltip: mediaPlayer.state.playing ? Localization.instance.PAUSE : Localization.instance.PLAY,
                    child: StatefulAnimatedIcon(
                      dismissed: mediaPlayer.state.playing,
                      icon: AnimatedIcons.play_pause,
                      size: Theme.of(context).iconTheme.size! * 1.5,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    onPressed: mediaPlayer.next,
                    color: mediaPlayer.state.isLast ? nowPlayingColors.backgroundDisabledIcon : nowPlayingColors.backgroundEnabledIcon,
                    icon: const Icon(Icons.skip_next),
                    splashRadius: 20.0,
                    tooltip: Localization.instance.NEXT,
                  ),
                  IconButton(
                    onPressed: () => mediaPlayer.setLoop(Loop.values[(mediaPlayer.state.loop.index + 1) % Loop.values.length]),
                    color: switch (mediaPlayer.state.loop) {
                      Loop.off => nowPlayingColors.backgroundDisabledIcon,
                      Loop.one => nowPlayingColors.backgroundEnabledIcon,
                      Loop.all => nowPlayingColors.backgroundEnabledIcon,
                    },
                    icon: switch (mediaPlayer.state.loop) {
                      Loop.off => const Icon(Icons.repeat),
                      Loop.one => const Icon(Icons.repeat_one),
                      Loop.all => const Icon(Icons.repeat),
                    },
                    splashRadius: 20.0,
                    iconSize: Theme.of(context).iconTheme.size! * 0.8,
                    tooltip: Localization.instance.REPEAT,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          );
        },
      ),
    );
  }
}
