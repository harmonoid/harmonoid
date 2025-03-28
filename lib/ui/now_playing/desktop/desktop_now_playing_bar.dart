import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/duration.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/ui/media_library/media_library_hyperlinks.dart';
import 'package:harmonoid/ui/now_playing/now_playing_bar.dart';
import 'package:harmonoid/ui/now_playing/now_playing_colors.dart';
import 'package:harmonoid/ui/now_playing/now_playing_control_panel.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/material_wave_slider.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/ripple_surface.dart';
import 'package:harmonoid/utils/widgets.dart';

class DesktopNowPlayingBar extends StatefulWidget {
  const DesktopNowPlayingBar({super.key});

  @override
  State<DesktopNowPlayingBar> createState() => DesktopNowPlayingBarState();
}

class DesktopNowPlayingBarState extends State<DesktopNowPlayingBar> {
  final ValueNotifier<bool> _coverHoverNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    super.dispose();
    _coverHoverNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingColorPaletteNotifier>(
      builder: (context, nowPlayingColorPaletteNotifier, _) {
        return Provider<NowPlayingColors>.value(
          value: NowPlayingColors.fromPalette(
            context,
            isMaterial2 && Configuration.instance.desktopNowPlayingBarColorPalette ? nowPlayingColorPaletteNotifier.palette : null,
          ),
          builder: (context, _) {
            final nowPlayingColors = context.read<NowPlayingColors>();
            return Material(
              color: nowPlayingColors.background,
              elevation: Theme.of(context).bottomAppBarTheme.elevation ?? kDefaultHeavyElevation,
              child: Consumer<MediaPlayer>(
                builder: (context, mediaPlayer, _) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: RippleSurface(color: nowPlayingColors.background),
                      ),
                      SliderTheme(
                        data: nowPlayingColors.toSliderThemeData(),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: NowPlayingBar.height,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              () {
                                try {
                                  return Expanded(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        MouseRegion(
                                          onEnter: (_) => _coverHoverNotifier.value = true,
                                          onExit: (_) => _coverHoverNotifier.value = false,
                                          child: Stack(
                                            children: [
                                              ClipRect(
                                                child: ScaleOnHover(
                                                  child: Image(
                                                    width: NowPlayingBar.height,
                                                    height: NowPlayingBar.height,
                                                    image: cover(
                                                      uri: mediaPlayer.current.uri,
                                                      cacheWidth: NowPlayingBar.height.toInt(),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              ValueListenableBuilder<bool>(
                                                valueListenable: _coverHoverNotifier,
                                                builder: (context, value, _) {
                                                  return Positioned.fill(
                                                    child: AnimatedOpacity(
                                                      opacity: value ? 1.0 : 0.0,
                                                      duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
                                                      curve: Curves.easeInOut,
                                                      child: Material(
                                                        color: Colors.black.withValues(alpha: 0.5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            context.push('/$kNowPlayingPath');
                                                          },
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.music_note,
                                                              size: 32.0,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                mediaPlayer.current.title,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: nowPlayingColors.backgroundText),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (mediaPlayer.current.subtitle.isNotEmpty)
                                                HyperLink(
                                                  text: TextSpan(
                                                    children: [
                                                      for (final artist in mediaPlayer.current.subtitle) ...[
                                                        TextSpan(
                                                          text: artist.isEmpty ? kDefaultArtist : artist,
                                                          recognizer: TapGestureRecognizer()
                                                            ..onTap = () {
                                                              navigateToArtist(context, ArtistLookupKey(artist: artist));
                                                            },
                                                        ),
                                                        const TextSpan(
                                                          text: ', ',
                                                        ),
                                                      ]
                                                    ]..removeLast(),
                                                  ),
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: nowPlayingColors.backgroundText),
                                                ),
                                              if (Configuration.instance.nowPlayingAudioFormat)
                                                Text(
                                                  mediaPlayer.state.getAudioFormatLabel(),
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: nowPlayingColors.backgroundText),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                      ],
                                    ),
                                  );
                                } catch (_) {
                                  return const Spacer();
                                }
                              }(),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: Controls(
                                  key: ValueKey(Theme.of(context).extension<MaterialStandard>()?.value ?? 0),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Spacer(),
                                    const SizedBox(width: 12.0),
                                    IconButton(
                                      onPressed: mediaPlayer.muteOrUnmute,
                                      color: nowPlayingColors.backgroundEnabledIcon,
                                      icon: Icon(mediaPlayer.state.volume == 0.0 ? Icons.volume_off : (mediaPlayer.state.volume < 50.0 ? Icons.volume_down : Icons.volume_up)),
                                      splashRadius: 20.0,
                                      iconSize: 20.0,
                                      tooltip: mediaPlayer.state.volume == 0.0 ? Localization.instance.UNMUTE : Localization.instance.MUTE,
                                    ),
                                    SizedBox(
                                      width: 108.0,
                                      child: ScrollableSlider(
                                        min: 0.0,
                                        max: 100.0,
                                        value: mediaPlayer.state.volume.clamp(0.0, 100.0),
                                        onChanged: (value) => mediaPlayer.setVolume(value),
                                        onScrolledDown: () => mediaPlayer.setVolume((mediaPlayer.state.volume - 5.0).clamp(0.0, 100.0)),
                                        onScrolledUp: () => mediaPlayer.setVolume((mediaPlayer.state.volume + 5.0).clamp(0.0, 100.0)),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => NowPlayingControlPanel.show(context),
                                      color: nowPlayingColors.backgroundEnabledIcon,
                                      icon: const Icon(Icons.more_horiz),
                                      splashRadius: 20.0,
                                      iconSize: 20.0,
                                      tooltip: Localization.instance.CONTROL_PANEL,
                                    ),
                                    const SizedBox(width: 12.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class Controls extends StatelessWidget {
  const Controls({super.key});

  static double? get floatingActionButtonElevation => isMaterial3 ? 0.0 : null;
  static double? get floatingActionButtonDimension => isMaterial3 ? null : 48.0;

  @override
  Widget build(BuildContext context) {
    final nowPlayingColors = context.read<NowPlayingColors>();
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) {
        const sliderMin = 0.0;
        final sliderMax = mediaPlayer.state.duration.inMilliseconds.toDouble();
        final sliderValue = mediaPlayer.state.position.inMilliseconds.clamp(sliderMin, sliderMax).toDouble();
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8.0),
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
                SizedBox.square(
                  dimension: floatingActionButtonDimension,
                  child: FloatingActionButton(
                    heroTag: '***',
                    elevation: floatingActionButtonElevation,
                    focusElevation: floatingActionButtonElevation,
                    hoverElevation: floatingActionButtonElevation,
                    highlightElevation: floatingActionButtonElevation,
                    onPressed: mediaPlayer.playOrPause,
                    backgroundColor: nowPlayingColors.foreground,
                    foregroundColor: nowPlayingColors.foregroundIcon,
                    tooltip: mediaPlayer.state.playing ? Localization.instance.PAUSE : Localization.instance.PLAY,
                    child: StatefulAnimatedIcon(
                      dismissed: mediaPlayer.state.playing,
                      icon: AnimatedIcons.play_pause,
                      size: Theme.of(context).iconTheme.size! * 1.4,
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
            const Spacer(),
            Transform.translate(
              offset: Offset(0.0, isMaterial2 ? -2.0 : 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      mediaPlayer.state.position.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: nowPlayingColors.backgroundText,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  if (isMaterial3)
                    Expanded(
                      child: MaterialWaveSlider(
                        height: 28.0,
                        min: sliderMin,
                        max: sliderMax,
                        value: sliderValue,
                        onChanged: (value) => mediaPlayer.seek(Duration(milliseconds: value.round())),
                        paused: !mediaPlayer.state.playing,
                      ),
                    ),
                  if (isMaterial2)
                    Expanded(
                      child: ScrollableSlider(
                        min: sliderMin,
                        max: sliderMax,
                        value: sliderValue,
                        onChanged: (value) => mediaPlayer.seek(Duration(milliseconds: value.round())),
                      ),
                    ),
                  const SizedBox(width: 12.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      mediaPlayer.state.duration.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: nowPlayingColors.backgroundText,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
