import 'dart:async';
import 'dart:io';

import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/duration.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/state/theme_notifier.dart';
import 'package:harmonoid/ui/media_library/media_library_hyperlinks.dart';
import 'package:harmonoid/ui/now_playing/desktop/desktop_now_playing_playlist.dart';
import 'package:harmonoid/ui/now_playing/desktop/desktop_now_playing_screen_carousel.dart';
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
  int _desktopNowPlayingScreenCarousel = Configuration.instance.desktopNowPlayingCarousel;
  bool _desktopNowPlayingScreenLyrics = Configuration.instance.desktopNowPlayingLyrics;

  Timer? _fullscreenTimer;

  void setDesktopNowPlayingCarousel(int value) {
    _desktopNowPlayingScreenCarousel = value;
    Configuration.instance.set(desktopNowPlayingCarousel: value);
    setState(() {});
  }

  void setDesktopNowPlayingLyrics(bool value) {
    _desktopNowPlayingScreenLyrics = value;
    Configuration.instance.set(desktopNowPlayingLyrics: value);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _fullscreenTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        return Theme(
          data: ThemeNotifier.instance.darkTheme,
          child: Provider<NowPlayingColors>(
            create: (context) => NowPlayingColors.of(context),
            builder: (context, _) => Scaffold(
              body: Consumer<MediaPlayer>(
                builder: (context, mediaPlayer, _) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: DesktopNowPlayingScreenCarousel(value: _desktopNowPlayingScreenCarousel),
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
                          duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          child: SizedBox(
                            key: ValueKey(_desktopNowPlayingScreenLyrics),
                            width: double.infinity,
                            height: double.infinity,
                            child: _desktopNowPlayingScreenLyrics ? const NowPlayingLyrics() : const SizedBox(),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () async {
                            if (_fullscreenTimer?.isActive ?? false) {
                              WindowPlus.instance.setIsFullscreen(!await WindowPlus.instance.fullscreen);
                            }
                            _fullscreenTimer = Timer(const Duration(milliseconds: 200), () => _fullscreenTimer = null);
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
                          setDesktopNowPlayingCarousel: setDesktopNowPlayingCarousel,
                          setDesktopNowPlayingLyrics: setDesktopNowPlayingLyrics,
                        ),
                      ),
                      Positioned(
                        top: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: FutureBuilder<bool>(
                          future: WindowPlus.instance.fullscreen,
                          builder: (context, snapshot) {
                            if (!Platform.isMacOS && (snapshot.data ?? false)) {
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
          ),
        );
      },
    );
  }
}

class Controls extends StatelessWidget {
  final void Function(int value) setDesktopNowPlayingCarousel;
  final void Function(bool value) setDesktopNowPlayingLyrics;

  const Controls({
    super.key,
    required this.setDesktopNowPlayingCarousel,
    required this.setDesktopNowPlayingLyrics,
  });

  @override
  Widget build(BuildContext context) {
    final nowPlayingColors = NowPlayingColors.of(context);
    return Material(
      color: Colors.transparent,
      child: SliderTheme(
        data: nowPlayingColors.toSliderThemeData(),
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
                      final audioFormatLabel = mediaPlayer.state.getAudioFormatLabel();
                      return Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(width: 32.0),
                          // NOTE: The style is kept same in all cases.
                          SizedBox(
                            width: coverDimension,
                            height: coverDimension,
                            child: Card(
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
                                ),
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
                                  Row(
                                    children: [
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
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: nowPlayingColors.backgroundText),
                                      ),
                                      if (mediaPlayer.current.description.isNotEmpty) ...[
                                        Text(
                                          ' • ',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: nowPlayingColors.backgroundText),
                                        ),
                                        Text(
                                          mediaPlayer.current.description.join(' • '),
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: nowPlayingColors.backgroundText),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                                if (Configuration.instance.nowPlayingAudioFormat) ...[
                                  const SizedBox(height: 4.0),
                                  Text(
                                    audioFormatLabel,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: nowPlayingColors.backgroundText),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 32.0),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: FloatingActionButton(
                                heroTag: 'desktop_now_playing_screen_playlist_$i',
                                mini: true,
                                backgroundColor: nowPlayingColors.foreground,
                                foregroundColor: nowPlayingColors.foregroundIcon,
                                onPressed: () => DesktopNowPlayingPlaylist.show(context),
                                tooltip: Localization.instance.PLAYLIST,
                                child: const Icon(Icons.queue_music),
                              ),
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
                        onPressed: () => setDesktopNowPlayingLyrics(!Configuration.instance.desktopNowPlayingLyrics),
                        color: Configuration.instance.desktopNowPlayingLyrics ? nowPlayingColors.backgroundEnabledIcon : nowPlayingColors.backgroundDisabledIcon,
                        icon: const Icon(Icons.text_format),
                        splashRadius: 20.0,
                        tooltip: Configuration.instance.desktopNowPlayingLyrics ? Localization.instance.HIDE_LYRICS : Localization.instance.SHOW_LYRICS,
                      ),
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
                      const Spacer(),
                      IconButton(
                        onPressed: () => setDesktopNowPlayingCarousel(
                          (Configuration.instance.desktopNowPlayingCarousel - 1) % DesktopNowPlayingScreenCarousel.itemCount,
                        ),
                        color: nowPlayingColors.backgroundEnabledIcon,
                        icon: const Icon(Icons.chevron_left),
                        splashRadius: 20.0,
                        tooltip: Localization.instance.PREVIOUS,
                      ),
                      IconButton(
                        onPressed: () => setDesktopNowPlayingCarousel(
                          (Configuration.instance.desktopNowPlayingCarousel + 1) % DesktopNowPlayingScreenCarousel.itemCount,
                        ),
                        color: nowPlayingColors.backgroundEnabledIcon,
                        icon: const Icon(Icons.chevron_right),
                        splashRadius: 20.0,
                        tooltip: Localization.instance.NEXT,
                      ),
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
      ),
    );
  }
}
