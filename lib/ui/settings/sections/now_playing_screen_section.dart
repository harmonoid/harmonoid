import 'package:flutter/material.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/state/now_playing_visuals_notifier.dart';
import 'package:harmonoid/ui/settings/settings_section.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class NowPlayingScreenSection extends StatefulWidget {
  const NowPlayingScreenSection({super.key});

  @override
  State<NowPlayingScreenSection> createState() => _NowPlayingScreenSectionState();
}

class _NowPlayingScreenSectionState extends State<NowPlayingScreenSection> {
  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_NOW_PLAYING_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_NOW_PLAYING_SUBTITLE,
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${Localization.instance.LYRICS_SIZE} ${Configuration.instance.lyricsViewUnfocusedFontSize.toInt()}/${Configuration.instance.lyricsViewFocusedFontSize.toInt()}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 64.0,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ScrollableSlider(
            min: 12.0,
            max: 128.0,
            interval: 1.0,
            stepSize: 1.0,
            showLabels: true,
            labelFormatterCallback: (value, _) {
              return switch (value) {
                12.0 || 28.0 || 64.0 || 128.0 => '${value.toInt()}',
                _ => '',
              };
            },
            values: [
              Configuration.instance.lyricsViewUnfocusedFontSize.clamp(12.0, 128.0),
              Configuration.instance.lyricsViewFocusedFontSize.clamp(12.0, 128.0),
            ],
            onChanged: (value) async {
              await Configuration.instance.set(
                lyricsViewUnfocusedFontSize: value[0],
                lyricsViewFocusedFontSize: value[1],
              );
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 16.0),
        if (/* ONLY DESKTOP */ isDesktop)
          Padding(
            padding: EdgeInsets.only(
              left: 16.0 - textButtonPadding,
              right: 16.0 - textButtonPadding,
              bottom: 16.0,
            ),
            child: TextButton(
              onPressed: () async {
                final directory = NowPlayingVisualsNotifier.instance.directory;
                if (await directory.exists_()) {
                  await directory.create_();
                }
                directory.explore_();
              },
              child: Text(label(Localization.instance.MODIFY_BACKGROUND_IMAGES)),
            ),
          ),
        ListItem(
          trailing: Switch(
            value: Configuration.instance.nowPlayingDisplayUponPlay,
            onChanged: (value) async {
              await Configuration.instance.set(nowPlayingDisplayUponPlay: value);
              setState(() {});
            },
          ),
          title: Localization.instance.DISPLAY_UPON_PLAYBACK,
          onTap: () async {
            await Configuration.instance.set(nowPlayingDisplayUponPlay: !Configuration.instance.nowPlayingDisplayUponPlay);
            setState(() {});
          },
        ),
        ListItem(
          trailing: Switch(
            value: Configuration.instance.nowPlayingAudioFormat,
            onChanged: (value) async {
              await Configuration.instance.set(nowPlayingAudioFormat: value);
              NowPlayingColorPaletteNotifier.instance.resetCurrent();
              setState(() {});
            },
          ),
          title: Localization.instance.DISPLAY_AUDIO_FORMAT,
          onTap: () async {
            await Configuration.instance.set(nowPlayingAudioFormat: !Configuration.instance.nowPlayingAudioFormat);
            NowPlayingColorPaletteNotifier.instance.resetCurrent();
            setState(() {});
          },
        ),
        if (/* DESKTOP & MATERIAL 2 */ isDesktop)
          ListItem(
            trailing: Switch(
              value: Configuration.instance.desktopNowPlayingBarColorPalette,
              onChanged: !isMaterial2
                  ? null
                  : (value) async {
                      await Configuration.instance.set(desktopNowPlayingBarColorPalette: value);
                      NowPlayingColorPaletteNotifier.instance.resetCurrent();
                      setState(() {});
                    },
            ),
            title: Localization.instance.USE_COLOR_PALETTE,
            onTap: !isMaterial2
                ? null
                : () async {
                    await Configuration.instance.set(desktopNowPlayingBarColorPalette: !Configuration.instance.desktopNowPlayingBarColorPalette);
                    NowPlayingColorPaletteNotifier.instance.resetCurrent();
                    setState(() {});
                  },
          ),
        if (/* MOBILE & MATERIAL 2 */ isMobile)
          ListItem(
            trailing: Switch(
              value: Configuration.instance.mobileNowPlayingRipple,
              onChanged: !isMaterial2
                  ? null
                  : (value) async {
                      await Configuration.instance.set(mobileNowPlayingRipple: value);
                      NowPlayingColorPaletteNotifier.instance.resetCurrent();
                      setState(() {});
                    },
            ),
            title: Localization.instance.USE_COLOR_PALETTE,
            onTap: !isMaterial2
                ? null
                : () async {
                    await Configuration.instance.set(mobileNowPlayingRipple: !Configuration.instance.mobileNowPlayingRipple);
                    NowPlayingColorPaletteNotifier.instance.resetCurrent();
                    setState(() {});
                  },
          ),
        if (/* MOBILE */ isMobile)
          ListItem(
            trailing: Switch(
              value: Configuration.instance.mobileNowPlayingVolumeSlider,
              onChanged: (value) async {
                await Configuration.instance.set(mobileNowPlayingVolumeSlider: value);
                setState(() {});
              },
            ),
            title: Localization.instance.DISPLAY_VOLUME_SLIDER,
            onTap: () async {
              await Configuration.instance.set(mobileNowPlayingVolumeSlider: !Configuration.instance.mobileNowPlayingVolumeSlider);
              setState(() {});
            },
          ),
      ],
    );
  }
}
