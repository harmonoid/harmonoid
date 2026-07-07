import 'dart:async';
import 'dart:ui';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart' hide CarouselView;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:m3_expressive_shapes/m3_expressive_shapes.dart';
import 'package:measure_size/measure_size.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/duration.dart';
import 'package:harmonoid/extensions/list.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/build_context.dart';
import 'package:harmonoid/core/media_player/models/loop.dart';
import 'package:harmonoid/state/lyrics/lyrics_notifier.dart';
import 'package:harmonoid/features/now_playing/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/features/now_playing/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/features/media_library/playlists/utils/rendering.dart';
import 'package:harmonoid/features/media_library/utils/constants.dart';
import 'package:harmonoid/features/now_playing/now_playing_bar.dart';
import 'package:harmonoid/features/now_playing/now_playing_colors.dart';
import 'package:harmonoid/features/now_playing/now_playing_audio_control_panel.dart';
import 'package:harmonoid/features/now_playing/now_playing_playlist_item.dart';
import 'package:harmonoid/routing/router.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/third_party/material_wave_slider.dart';
import 'package:harmonoid/third_party/mini_player.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/third_party/sliding_up_panel.dart';
import 'package:harmonoid/utils/widgets.dart';

class M3MobileNowPlayingBar extends StatefulWidget {
  const M3MobileNowPlayingBar({super.key});

  @override
  State<M3MobileNowPlayingBar> createState() => M3MobileNowPlayingBarState();
}

class M3MobileNowPlayingBarState extends State<M3MobileNowPlayingBar> {
  final ValueNotifier<double> _valueNotifier = ValueNotifier<double>(0.0);
  final MiniPlayerController _miniPlayerController = MiniPlayerController();
  final PanelController _panelController = PanelController();
  final GlobalKey<TooltipState> _lyricsTooltipKey = GlobalKey<TooltipState>();
  String? _lyricsTooltipUri;
  bool _lyricsVisible = false;
  Timer? _lyricsTooltipTimer;
  Timer? _miniPlayerControllerCallbackTimer;

  // FIXED
  late final double _carouselHeight = (MediaQuery.sizeOf(context).width * 7 / 9).clamp(0.0, (MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).vertical) * 2 / 5);

  // DYNAMIC
  double _detailsHeight = 0.0;
  double _controlsHeight = 0.0;

  double get _slidingUpPanelMaxHeight => MediaQuery.sizeOf(context).height - (MediaQuery.paddingOf(context).top + 16.0 + 40.0 + 16.0);

  double get _slidingUpPanelMinHeight => MediaQuery.sizeOf(context).height - (MediaQuery.paddingOf(context).top + kToolbarHeight + _carouselHeight + _detailsHeight + _controlsHeight);

  Color? get _slidingUpPanelColor => ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<NowPlayingMobileNotifier>().setM3MobileNowPlayingBarStateRef(this));
  }

  @override
  void dispose() {
    _lyricsTooltipTimer?.cancel();
    _miniPlayerControllerCallbackTimer?.cancel();
    _valueNotifier.dispose();
    super.dispose();
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
          value: NowPlayingColors.fromPalette(context, null),
          builder: (context, _) {
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

                            final wasMaximized = _valueNotifier.value == 1.0;
                            _valueNotifier.value = percentage;
                            if (!wasMaximized && percentage == 1.0) {
                              context.read<NowPlayingMobileNotifier>().didMaximizeNowPlayingBar();
                            }
                            context.read<NowPlayingMobileNotifier>().setBottomNavigationBarVisibility((1.0 - percentage * 2.0).clamp(0.0, 1.0));
                          } catch (_) {}
                        });
                        // https://discord.com/channels/935994617663483916/1214229474497929216/1465018704478601288
                        _miniPlayerControllerCallbackTimer?.cancel();
                        _miniPlayerControllerCallbackTimer = Timer(const Duration(milliseconds: 100), () {
                          context.read<NowPlayingMobileNotifier>().setBottomNavigationBarVisibility((1.0 - percentage * 2.0).clamp(0.0, 1.0));
                        });

                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned.fill(
                              child: ColoredBox(color: Theme.of(context).navigationBarTheme.backgroundColor ?? Colors.transparent),
                            ),
                            if (percentage > 0.5)
                              Opacity(
                                opacity: ((percentage - 0.5) / 0.5).clamp(0.0, 1.0),
                                child: AnnotatedRegion<SystemUiOverlayStyle>(
                                  value: context.toSystemUiOverlayStyle(),
                                  child: Container(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _buildAppBar(context, mediaPlayer, percentage),
                                        _buildCarousel(context, mediaPlayer, percentage),
                                        _buildDetails(context, mediaPlayer),
                                        _buildControls(context, mediaPlayer),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IgnorePointer(
                                  child: Opacity(
                                    opacity: percentage == 1.0 ? 0.0 : 1.0,
                                    child: Container(
                                      width: lerpDouble(NowPlayingBar.height, MediaQuery.sizeOf(context).width, percentage),
                                      padding: EdgeInsets.only(
                                        top: lerpDouble(0.0, kToolbarHeight + MediaQuery.paddingOf(context).top, percentage) ?? 0.0,
                                        left: lerpDouble(0.0, MediaQuery.sizeOf(context).width * 1 / 9 + 4.0, percentage) ?? 0.0,
                                        right: lerpDouble(0.0, MediaQuery.sizeOf(context).width * 1 / 9 + 4.0, percentage) ?? 0.0,
                                      ),
                                      child: ClipRRect(
                                        clipBehavior: Clip.antiAlias,
                                        borderRadius: BorderRadius.circular(lerpDouble(0.0, 28.0, percentage) ?? 0.0),
                                        child: Image(
                                          image: cover(uri: mediaPlayer.current.uri),
                                          fit: BoxFit.cover,
                                          width: lerpDouble(NowPlayingBar.height, MediaQuery.sizeOf(context).width * 7 / 9, percentage),
                                          height: lerpDouble(NowPlayingBar.height, _carouselHeight, percentage),
                                        ),
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
                                                    TappableText(
                                                      text: mediaPlayer.current.subtitle.ifEmpty(['']).map((e) => TappableTextData(text: e.isEmpty ? kDefaultArtist : e)).toList(),
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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

  void _showLyricsTooltipIfNeeded(double percentage, String? currentUri) {
    if (percentage != 1.0 || currentUri == null || _lyricsTooltipUri == currentUri || Configuration.instance.mobileNowPlayingLyricsFtux > 5) return;
    _lyricsTooltipUri = currentUri;
    _lyricsTooltipTimer?.cancel();
    _lyricsTooltipTimer = Timer(const Duration(seconds: 3), () => _showLyricsTooltip(currentUri));
  }

  Future<void> _showLyricsTooltip(Object currentUri) async {
    _lyricsTooltipTimer = null;
    if (!mounted || _lyricsTooltipUri != currentUri) return;

    final state = _lyricsTooltipKey.currentState;
    if (state == null) return;

    unawaited(Configuration.instance.set(mobileNowPlayingLyricsFtux: Configuration.instance.mobileNowPlayingLyricsFtux + 1));

    state.ensureTooltipVisible();

    await Future.delayed(const Duration(seconds: 3));
    Tooltip.dismissAllToolTips();
  }

  Widget _buildAppBar(BuildContext context, MediaPlayer mediaPlayer, double percentage) {
    return Container(
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
              _showLyricsTooltipIfNeeded(percentage, mediaPlayer.current.uri);
              return Tooltip(
                key: _lyricsTooltipKey,
                message: Localization.instance.SHOW_LYRICS,
                showDuration: const Duration(seconds: 3),
                child: IconButton(
                  onPressed: () async {
                    _lyricsVisible = true;
                    await context.push('/$kNowPlayingLyricsPath');
                    _lyricsVisible = false;
                  },
                  icon: const Icon(Icons.text_format),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => NowPlayingAudioControlPanel.show(context),
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
    );
  }

  Widget _buildCarousel(BuildContext context, MediaPlayer mediaPlayer, double percentage) {
    return SizedBox(
      height: _carouselHeight,
      child: StatefulCarouselViewBuilder(
        flexWeights: const [1, 7, 1],
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
        onTap: (i) async {
          if (mediaPlayer.state.index == i) return;
          mediaPlayer.jump(i);
        },
      ),
    );
  }

  Widget _buildDetails(BuildContext context, MediaPlayer mediaPlayer) {
    return MeasureSize(
      onChange: (size) {
        if (_detailsHeight != 0.0) return;
        setState(() => _detailsHeight = size.height);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width * 1 / 9 + 4.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mediaPlayer.current.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface).copyWith(height: 1.0),
              strutStyle: StrutStyle.fromTextStyle(Theme.of(context).textTheme.headlineMedium!.copyWith(height: 1.5)),
            ),
            TappableText(
              text: mediaPlayer.current.subtitle.ifEmpty(['']).map((e) => TappableTextData(text: e.isEmpty ? kDefaultArtist : e)).toList(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant).copyWith(height: 1.0),
            ),
            if (Configuration.instance.nowPlayingAudioFormat)
              Text(
                mediaPlayer.state.getAudioFormatLabel(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant).copyWith(height: 1.0),
                strutStyle: StrutStyle.fromTextStyle(Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.5)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, MediaPlayer mediaPlayer) {
    return MeasureSize(
      onChange: (size) {
        if (_controlsHeight != 0.0) return;
        setState(() => _controlsHeight = size.height);
      },
      child: const Controls(),
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
            child: Builder(
              builder: (context) {
                final mixOffset = mediaPlayer.state.mixOffset;
                final adjustedMixOffset = mixOffset != null && mixOffset >= diff ? mixOffset - diff : null;

                return ReorderableListView.builder(
                  onReorderStart: (_) => _panelController.scrollingEnabledAllowed = false,
                  onReorderEnd: (_) => _panelController.scrollingEnabledAllowed = true,
                  onReorder: (from, to) {
                    int fromPlayable = from + diff;
                    int toPlayable = to + diff;

                    if (fromPlayable != toPlayable) {
                      if (mixOffset != null) {
                        if (fromPlayable == mixOffset) return;
                        if (fromPlayable > mixOffset) fromPlayable--;
                        if (toPlayable > mixOffset) toPlayable--;
                      }
                      mediaPlayer.move(fromPlayable, toPlayable);
                    }
                  },
                  physics: physics,
                  scrollController: controller,
                  padding: EdgeInsets.zero,
                  itemExtent: kMobileLinearTileHeight + 1.0,
                  itemCount: (mediaPlayer.state.playables.length - diff) + 1,
                  itemBuilder: (context, listIndex) {
                    if ((adjustedMixOffset == null && listIndex == mediaPlayer.state.playables.length - diff) || (adjustedMixOffset != null && listIndex == adjustedMixOffset)) {
                      return Column(
                        key: const ValueKey('Mix'),
                        children: [
                          SubHeader(
                            Localization.instance.MIX,
                            height: kMobileLinearTileHeight,
                            leading: const Icon(Icons.shuffle),
                            trailing: Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Switch(
                                  value: mediaPlayer.state.mixOffset != null,
                                  onChanged: (value) => mediaPlayer.mixOrUnmix(),
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1.0, thickness: 1.0),
                        ],
                      );
                    }
                    if (adjustedMixOffset != null) {
                      if (listIndex > adjustedMixOffset) {
                        final playableIndex = listIndex + diff - 1;
                        return NowPlayingPlaylistItem(
                          key: ValueKey((playableIndex, mediaPlayer.state.playables[playableIndex])),
                          listIndex: listIndex + diff,
                          playableIndex: playableIndex,
                          width: double.infinity,
                          height: kMobileLinearTileHeight,
                        );
                      }
                    }

                    final playableIndex = listIndex + diff;
                    return NowPlayingPlaylistItem(
                      key: ValueKey((playableIndex, mediaPlayer.state.playables[playableIndex])),
                      listIndex: playableIndex,
                      playableIndex: playableIndex,
                      width: double.infinity,
                      height: kMobileLinearTileHeight,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Controls extends StatelessWidget {
  const Controls({super.key});

  @override
  Widget build(BuildContext context) {
    final nowPlayingColors = context.read<NowPlayingColors>();
    return SliderTheme(
      data: nowPlayingColors.toSliderThemeData(),
      child: Consumer<MediaPlayer>(
        builder: (context, mediaPlayer, _) {
          const sliderMin = 0.0;
          final sliderMax = mediaPlayer.state.duration.inMilliseconds.toDouble();
          final sliderValue = mediaPlayer.state.position.inMilliseconds.clamp(sliderMin, sliderMax).toDouble();
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: (MediaQuery.sizeOf(context).width * 1 / 9 + 4.0 - 2 * 16.0).clamp(0.0, MediaQuery.sizeOf(context).width)),
                child: MaterialWaveSlider(
                  height: 28.0,
                  amplitude: 28.0 / 10.0,
                  min: sliderMin,
                  max: sliderMax,
                  value: sliderValue,
                  onChanged: (value) => mediaPlayer.seek(Duration(milliseconds: value.round())),
                  paused: !mediaPlayer.state.playing,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: (MediaQuery.sizeOf(context).width * 1 / 9 + 4.0 - 2 * 16.0).clamp(0.0, MediaQuery.sizeOf(context).width)),
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
                  AnimatedContainer(
                    width: 72.0,
                    height: 72.0,
                    curve: const ElasticOutCurve(0.85),
                    duration: const Duration(milliseconds: 500),
                    decoration: ShapeDecoration(
                      color: nowPlayingColors.foreground,
                      shape: RoundedPolygonBorder(polygon: mediaPlayer.state.playing ? MaterialShapes.sunny : MaterialShapes.square),
                    ),
                    child: Tooltip(
                      message: mediaPlayer.state.playing ? Localization.instance.PAUSE : Localization.instance.PLAY,
                      child: InkWell(
                        onTap: mediaPlayer.playOrPause,
                        child: Center(
                          child: StatefulAnimatedIcon(
                            dismissed: mediaPlayer.state.playing,
                            icon: AnimatedIcons.play_pause,
                            size: Theme.of(context).iconTheme.size! * 1.5,
                            color: nowPlayingColors.foregroundIcon,
                            duration: const Duration(milliseconds: 500),
                          ),
                        ),
                      ),
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
