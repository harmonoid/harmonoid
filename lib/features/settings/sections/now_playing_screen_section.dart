import 'package:flutter/material.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/now_playing/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/features/now_playing/state/now_playing_visuals_notifier.dart';
import 'package:harmonoid/features/settings/settings_section.dart';
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
        if ( /* ONLY DESKTOP */ isDesktop)
          Padding(
            padding: EdgeInsets.only(
              left: 16.0 - textButtonPadding,
              right: 16.0 - textButtonPadding,
              bottom: 8.0,
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
        if ( /* DESKTOP & MATERIAL 2 */ isDesktop)
          ListItem(
            trailing: Switch(
              value: Configuration.instance.desktopNowPlayingBarColorPalette,
              onChanged: !isMaterial2
                  ? null
                  : (value) async {
                      await Configuration.instance.set(desktopNowPlayingBarColorPalette: value);
                      NowPlayingColorPaletteNotifier.instance.clear();
                      setState(() {});
                    },
            ),
            title: Localization.instance.USE_COLOR_PALETTE,
            onTap: !isMaterial2
                ? null
                : () async {
                    await Configuration.instance.set(desktopNowPlayingBarColorPalette: !Configuration.instance.desktopNowPlayingBarColorPalette);
                    NowPlayingColorPaletteNotifier.instance.clear();
                    setState(() {});
                  },
          ),
        if ( /* MOBILE & MATERIAL 2 */ isMobile)
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
        ListItem(
          trailing: Switch(
            value: Configuration.instance.nowPlayingStartMixAfterEnding,
            onChanged: (value) async {
              await MediaPlayer.instance.setMix(value);
              setState(() {});
            },
          ),
          title: Localization.instance.START_MIX_AFTER_ENDING,
          onTap: () async {
            await MediaPlayer.instance.mixOrUnmix();
            setState(() {});
          },
        ),
        ListItem(
          trailing: Switch(
            value: Configuration.instance.mediaLibraryAddPlaylistToNowPlaying,
            onChanged: (value) async {
              await Configuration.instance.set(mediaLibraryAddPlaylistToNowPlaying: value);
              setState(() {});
            },
          ),
          title: Localization.instance.ADD_PLAYLIST_TO_NOW_PLAYING,
          onTap: () async {
            await Configuration.instance.set(mediaLibraryAddPlaylistToNowPlaying: !Configuration.instance.mediaLibraryAddPlaylistToNowPlaying);
            setState(() {});
          },
        ),
      ],
    );
  }
}
