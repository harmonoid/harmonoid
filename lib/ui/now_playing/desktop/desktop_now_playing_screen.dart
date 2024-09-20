import 'dart:async';

import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/extensions/duration.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/state/theme_notifier.dart';
import 'package:harmonoid/ui/now_playing/now_playing_colors.dart';
import 'package:harmonoid/ui/now_playing/now_playing_control_panel.dart';
import 'package:harmonoid/ui/now_playing/now_playing_lyrics.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/material_wave_slider.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class DesktopNowPlayingScreen extends StatefulWidget {
  const DesktopNowPlayingScreen({super.key});

  @override
  State<DesktopNowPlayingScreen> createState() => DesktopNowPlayingScreenState();
}

class DesktopNowPlayingScreenState extends State<DesktopNowPlayingScreen> {
  bool desktopNowPlayingScreenLyrics = Configuration.instance.desktopNowPlayingScreenLyrics;
  Timer? fullscreenTimer;

  void setDesktopNowPlayingScreenLyrics(bool value) {
    desktopNowPlayingScreenLyrics = value;
    Configuration.instance.set(desktopNowPlayingScreenLyrics: value);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    fullscreenTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeNotifier.instance.darkTheme,
      child: Scaffold(
        body: Consumer<MediaPlayer>(
          builder: (context, mediaPlayer, _) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Consumer<NowPlayingColorPaletteNotifier>(
                    builder: (context, nowPlayingColorPaletteNotifier, _) {
                      final palette = nowPlayingColorPaletteNotifier.palette ?? [];
                      final colors = switch (palette.length) {
                        0 => [Colors.black, Colors.black, Colors.black, Colors.black],
                        1 => [palette.elementAt(0), palette.elementAt(0), palette.elementAt(0), palette.elementAt(0)],
                        2 => [palette.reversed.elementAt(0), palette.elementAt(0), palette.reversed.elementAt(0), palette.elementAt(0)],
                        3 => [palette.reversed.elementAt(0), palette.elementAt(0), palette.reversed.elementAt(0), palette.elementAt(1)],
                        _ => [palette.reversed.elementAt(0), palette.elementAt(0), palette.reversed.elementAt(1), palette.elementAt(1)],
                      };
                      return AnimatedSwitcher(
                        duration: Theme.of(context).extension<AnimationDuration>()?.slow ?? Duration.zero,
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder: (child, animation) {
                          return Builder(
                            builder: (context) {
                              return FadeTransition(
                                key: ValueKey<Key?>(child.key),
                                opacity: animation.status == AnimationStatus.reverse || animation.status == AnimationStatus.completed ? const AlwaysStoppedAnimation(1.0) : animation,
                                child: child,
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          key: ValueKey(const ListEquality().hash(colors)),
                          width: double.infinity,
                          height: double.infinity,
                          child: AnimatedMeshGradient(
                            colors: colors,
                            options: AnimatedMeshGradientOptions(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: ColoredBox(color: Colors.black.withOpacity(0.2)),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.2, 0.5, 0.8],
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: Theme.of(context).extension<AnimationDuration>()?.slow ?? Duration.zero,
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: SizedBox(
                      key: ValueKey(desktopNowPlayingScreenLyrics),
                      width: double.infinity,
                      height: double.infinity,
                      child: desktopNowPlayingScreenLyrics ? const NowPlayingLyrics() : const SizedBox(),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () async {
                      if (fullscreenTimer?.isActive ?? false) {
                        WindowPlus.instance.setIsFullscreen(!await WindowPlus.instance.fullscreen);
                      }
                      fullscreenTimer = Timer(const Duration(milliseconds: 200), () => fullscreenTimer = null);
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Controls(
                    nowPlayingColors: NowPlayingColors.of(context),
                    setDesktopNowPlayingScreenLyrics: setDesktopNowPlayingScreenLyrics,
                  ),
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: FutureBuilder<bool>(
                    future: WindowPlus.instance.fullscreen,
                    builder: (context, snapshot) {
                      if (snapshot.data ?? false) {
                        return const SizedBox.shrink();
                      }
                      return const DesktopAppBar(
                        caption: kCaption,
                        color: Colors.transparent,
                        elevation: 0.0,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Controls extends StatelessWidget {
  final NowPlayingColors nowPlayingColors;
  final void Function(bool value) setDesktopNowPlayingScreenLyrics;
  const Controls({
    super.key,
    required this.nowPlayingColors,
    required this.setDesktopNowPlayingScreenLyrics,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        thumbColor: nowPlayingColors.sliderForeground,
        activeTrackColor: nowPlayingColors.sliderForeground,
        inactiveTrackColor: nowPlayingColors.sliderBackground,
        disabledThumbColor: nowPlayingColors.sliderForeground,
        disabledActiveTrackColor: nowPlayingColors.sliderForeground,
        disabledInactiveTrackColor: nowPlayingColors.sliderBackground,
      ),
      child: Consumer<MediaPlayer>(
        builder: (context, mediaPlayer, _) {
          const sliderMin = 0.0;
          final sliderMax = mediaPlayer.state.duration.inMilliseconds.toDouble();
          final sliderValue = mediaPlayer.state.position.inMilliseconds.clamp(sliderMin, sliderMax).toDouble();
          final coverDimension = (MediaQuery.of(context).size.height * 0.28).clamp(0.0, 256.0);
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: coverDimension,
                child: StatefulPageViewBuilder(
                  physics: const NeverScrollableScrollPhysics(),
                  index: mediaPlayer.state.index,
                  itemCount: mediaPlayer.state.playables.length,
                  itemBuilder: (context, i) {
                    final playable = i == mediaPlayer.state.index ? mediaPlayer.current : mediaPlayer.state.playables[i];
                    final title = playable.title;
                    final subtitle = [playable.subtitle.join(', '), ...playable.description].where((e) => e.isNotEmpty).join(' • ');
                    final description = mediaPlayer.state.getAudioFormatLabel();
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(width: 32.0),
                        Card(
                          // NOTE: The style is kept same in all cases.
                          color: Colors.white,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image(
                              image: cover(
                                uri: playable.uri,
                                cacheWidth: coverDimension.toInt(),
                              ),
                              fit: BoxFit.cover,
                              width: coverDimension,
                              height: coverDimension,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32.0),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: nowPlayingColors.backgroundText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subtitle.isNotEmpty) ...[
                                const SizedBox(height: 4.0),
                                Text(
                                  subtitle,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: nowPlayingColors.backgroundText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 4.0),
                                Text(
                                  description,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: nowPlayingColors.backgroundText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 32.0),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        mediaPlayer.state.position.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: nowPlayingColors.backgroundText),
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
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        mediaPlayer.state.duration.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: nowPlayingColors.backgroundText),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: mediaPlayer.previous,
                      color: mediaPlayer.state.isFirst ? nowPlayingColors.backgroundDisabledIcon : nowPlayingColors.backgroundEnabledIcon,
                      icon: const Icon(Icons.skip_previous),
                      splashRadius: 20.0,
                      tooltip: Localization.instance.PREVIOUS,
                    ),
                    IconButton(
                      onPressed: mediaPlayer.playOrPause,
                      color: nowPlayingColors.backgroundEnabledIcon,
                      icon: StatefulAnimatedIcon(
                        dismissed: mediaPlayer.state.playing,
                        icon: AnimatedIcons.play_pause,
                      ),
                      splashRadius: 20.0,
                      tooltip: mediaPlayer.state.playing ? Localization.instance.PAUSE : Localization.instance.PLAY,
                    ),
                    IconButton(
                      onPressed: mediaPlayer.next,
                      color: mediaPlayer.state.isLast ? nowPlayingColors.backgroundDisabledIcon : nowPlayingColors.backgroundEnabledIcon,
                      icon: const Icon(Icons.skip_next),
                      splashRadius: 20.0,
                      tooltip: Localization.instance.NEXT,
                    ),
                    IconButton(
                      onPressed: mediaPlayer.shuffleOrUnshuffle,
                      color: mediaPlayer.state.shuffle ? nowPlayingColors.backgroundEnabledIcon : nowPlayingColors.backgroundDisabledIcon,
                      icon: const Icon(Icons.shuffle),
                      splashRadius: 20.0,
                      iconSize: Theme.of(context).iconTheme.size! * 0.8,
                      tooltip: Localization.instance.SHUFFLE,
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
                    IconButton(
                      onPressed: () => showAddToPlaylistDialog(context, playable: mediaPlayer.current),
                      color: nowPlayingColors.backgroundEnabledIcon,
                      icon: const Icon(Icons.add),
                      splashRadius: 20.0,
                      tooltip: Localization.instance.ADD_TO_PLAYLIST,
                    ),
                    IconButton(
                      onPressed: () => setDesktopNowPlayingScreenLyrics(!Configuration.instance.desktopNowPlayingScreenLyrics),
                      color: Configuration.instance.desktopNowPlayingScreenLyrics ? nowPlayingColors.backgroundEnabledIcon : nowPlayingColors.backgroundDisabledIcon,
                      icon: const Icon(Icons.text_format),
                      splashRadius: 20.0,
                      tooltip: Configuration.instance.desktopNowPlayingScreenLyrics ? Localization.instance.HIDE_LYRICS : Localization.instance.SHOW_LYRICS,
                    ),
                    IconButton(
                      onPressed: mediaPlayer.muteOrUnmute,
                      color: nowPlayingColors.backgroundEnabledIcon,
                      icon: Icon(mediaPlayer.state.volume == 0.0 ? Icons.volume_off : (mediaPlayer.state.volume < 50.0 ? Icons.volume_down : Icons.volume_up)),
                      splashRadius: 20.0,
                      iconSize: 20.0,
                      tooltip: mediaPlayer.state.volume == 0.0 ? Localization.instance.UNMUTE : Localization.instance.MUTE,
                    ),
                    const SizedBox(width: 8.0),
                    SizedBox(
                      width: 96.0,
                      child: ScrollableSlider(
                        min: 0.0,
                        max: 100.0,
                        value: mediaPlayer.state.volume.clamp(0.0, 100.0),
                        onChanged: (value) => mediaPlayer.setVolume(value),
                        onScrolledDown: () => mediaPlayer.setVolume((mediaPlayer.state.volume - 5.0).clamp(0.0, 100.0)),
                        onScrolledUp: () => mediaPlayer.setVolume((mediaPlayer.state.volume + 5.0).clamp(0.0, 100.0)),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    IconButton(
                      onPressed: () => NowPlayingControlPanel.show(context),
                      color: nowPlayingColors.backgroundEnabledIcon,
                      icon: const Icon(Icons.more_horiz),
                      splashRadius: 20.0,
                      iconSize: 20.0,
                      tooltip: Localization.instance.CONTROL_PANEL,
                    ),
                    const Spacer(),
                    FutureBuilder<bool>(
                      future: WindowPlus.instance.fullscreen,
                      builder: (context, snapshot) {
                        final fullscreen = snapshot.data ?? false;
                        return IconButton(
                          onPressed: () => WindowPlus.instance.setIsFullscreen(!fullscreen),
                          color: nowPlayingColors.backgroundEnabledIcon,
                          icon: Icon(fullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
                          splashRadius: 20.0,
                          tooltip: Localization.instance.PREVIOUS,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          );
        },
      ),
    );
  }
}
