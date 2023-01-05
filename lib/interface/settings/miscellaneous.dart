import 'dart:io';

import 'package:flutter/material.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/modern_layout/settings_modern/enable_new_layout.dart';

class MiscellaneousSetting extends StatefulWidget {
  MiscellaneousSetting({Key? key}) : super(key: key);
  MiscellaneousSettingState createState() => MiscellaneousSettingState();
}

class MiscellaneousSettingState extends State<MiscellaneousSetting> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Language.instance.SETTING_MISCELLANEOUS_TITLE,
      subtitle: Language.instance.SETTING_MISCELLANEOUS_SUBTITLE,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CorrectedSwitchListTile(
          //   title: Language.instance.DISABLE_ANIMATIONS,
          //   subtitle: Language.instance.DISABLE_ANIMATIONS,
          //   onChanged: (_) => Configuration.instance
          //       .save(
          //         disableAnimations: !Configuration.instance.disableAnimations,
          //       )
          //       .then((_) => setState(() {})),
          //   value: Configuration.instance.disableAnimations,
          // ),
          if (isMobile) EnableNewLayoutSetting(),
          if (isMobile)
            CorrectedSwitchListTile(
              title: Language.instance.NOTIFICATION_LYRICS_TITLE,
              subtitle: Language.instance.NOTIFICATION_LYRICS_SUBTITLE,
              onChanged: (_) => Configuration.instance
                  .save(
                    notificationLyrics:
                        !Configuration.instance.notificationLyrics,
                  )
                  .then((_) => setState(() {})),
              value: Configuration.instance.notificationLyrics,
            ),
          CorrectedSwitchListTile(
            title: Language.instance.DISPLAY_AUDIO_FORMAT,
            subtitle: Language.instance.DISPLAY_AUDIO_FORMAT,
            onChanged: (_) => Configuration.instance
                .save(
              displayAudioFormat: !Configuration.instance.displayAudioFormat,
            )
                .then((_) {
              setState(() {});
            }),
            value: Configuration.instance.displayAudioFormat,
          ),
          // Sticky Miniplayer
          if (isMobile)
            CorrectedSwitchListTile(
              title: Language.instance.STICKY_MINIPLAYER,
              subtitle: Language.instance.STICKY_MINIPLAYER_SUBTITLE,
              onChanged: (_) => Configuration.instance
                  .save(
                stickyMiniplayer: !Configuration.instance.stickyMiniplayer,
              )
                  .then((_) {
                setState(() {});
              }),
              value: Configuration.instance.stickyMiniplayer,
            ),
          if (isMobile)
            CorrectedSwitchListTile(
              title: Language.instance.MOBILE_ENABLE_VOLUME_SLIDER,
              subtitle: Language.instance.MOBILE_ENABLE_VOLUME_SLIDER,
              onChanged: (_) => Configuration.instance
                  .save(
                mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen:
                    !Configuration.instance
                        .mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen,
              )
                  .then((_) {
                setState(() {});
              }),
              value: Configuration
                  .instance.mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen,
            ),
          CorrectedSwitchListTile(
            title: Language
                .instance.CHANGE_NOW_PLAYING_BAR_COLOR_BASED_ON_MUSIC_TITLE,
            subtitle:
                Language.instance.CHANGE_NOW_PLAYING_BAR_COLOR_BASED_ON_MUSIC,
            onChanged: (_) => Configuration.instance
                .save(
                  dynamicNowPlayingBarColoring:
                      !Configuration.instance.dynamicNowPlayingBarColoring,
                )
                .then((_) => setState(() {
                      if (!Configuration
                          .instance.dynamicNowPlayingBarColoring) {
                        NowPlayingColorPalette.instance.cleanup();
                      } else {
                        try {
                          NowPlayingColorPalette.instance.update(
                            Playback.instance.tracks[Playback.instance.index],
                            force: true,
                          );
                        } catch (exception, stacktrace) {
                          debugPrint(exception.toString());
                          debugPrint(stacktrace.toString());
                        }
                      }
                    })),
            value: Configuration.instance.dynamicNowPlayingBarColoring,
          ),
          if (Platform.isWindows)
            CorrectedSwitchListTile(
              title: Language.instance.SHOW_TRACK_PROGRESS_ON_TASKBAR,
              subtitle:
                  Language.instance.SHOW_TRACK_PROGRESS_ON_TASKBAR_SUBTITLE,
              onChanged: (_) => Configuration.instance
                  .save(
                    taskbarIndicator: !Configuration.instance.taskbarIndicator,
                  )
                  .then((_) => setState(() {})),
              value: Configuration.instance.taskbarIndicator,
            ),
          CorrectedSwitchListTile(
            title: Language
                .instance.AUTOMATICALLY_ADD_OTHER_SONGS_TO_NOW_PLAYING_TITLE,
            subtitle:
                Language.instance.AUTOMATICALLY_ADD_OTHER_SONGS_TO_NOW_PLAYING,
            onChanged: (_) => Configuration.instance
                .save(
                  seamlessPlayback: !Configuration.instance.seamlessPlayback,
                )
                .then((_) => setState(() {})),
            value: Configuration.instance.seamlessPlayback,
          ),
          CorrectedSwitchListTile(
            title: Language.instance.USE_LRC_FILE_FROM_TRACK_DIRECTORY,
            subtitle: Language.instance.USE_LRC_FILE_FROM_TRACK_DIRECTORY,
            onChanged: (_) => Configuration.instance
                .save(
              useLRCFromTrackDirectory:
                  !Configuration.instance.useLRCFromTrackDirectory,
            )
                .then((_) {
              setState(() {});
            }),
            value: Configuration.instance.useLRCFromTrackDirectory,
          ),
          CorrectedSwitchListTile(
            title: Language.instance.SHOW_NOW_PLAYING_AFTER_PLAYING,
            subtitle: Language.instance.SHOW_NOW_PLAYING_AFTER_PLAYING_SUBTITLE,
            onChanged: (_) => Configuration.instance
                .save(
                  jumpToNowPlayingScreenOnPlay:
                      !Configuration.instance.jumpToNowPlayingScreenOnPlay,
                )
                .then((_) => setState(() {})),
            value: Configuration.instance.jumpToNowPlayingScreenOnPlay,
          ),
          if (isDesktop)
            CorrectedSwitchListTile(
              title: Language.instance.USE_MODERN_NOW_PLAYING_SCREEN,
              subtitle: Language.instance.USE_MODERN_NOW_PLAYING_SCREEN,
              onChanged: (_) => Configuration.instance
                  .save(
                    modernNowPlayingScreen:
                        !Configuration.instance.modernNowPlayingScreen,
                  )
                  .then((value) => setState(() {})),
              value: Configuration.instance.modernNowPlayingScreen,
            ),
          if (isDesktop)
            CorrectedSwitchListTile(
              title: Language.instance.ENABLE_DISCORD_RPC,
              subtitle: Language.instance.ENABLE_DISCORD_RPC,
              onChanged: (_) => Configuration.instance
                  .save(
                discordRPC: !Configuration.instance.discordRPC,
              )
                  .then((_) {
                setState(() {});
                if (!Configuration.instance.discordRPC) {
                  Playback.instance.discord?.clearPresence();
                }
              }),
              value: Configuration.instance.discordRPC,
            ),
          if (isMobile)
            CorrectedSwitchListTile(
              title: Language.instance.MOBILE_ENABLE_NOW_PLAYING_RIPPLE_EFFECT,
              subtitle:
                  Language.instance.MOBILE_ENABLE_NOW_PLAYING_RIPPLE_EFFECT,
              onChanged: (_) => Configuration.instance
                  .save(
                mobileEnableNowPlayingScreenRippleEffect: !Configuration
                    .instance.mobileEnableNowPlayingScreenRippleEffect,
              )
                  .then((_) {
                setState(() {});
                MobileNowPlayingController.instance.hide();
              }),
              value: Configuration
                  .instance.mobileEnableNowPlayingScreenRippleEffect,
            ),
          CorrectedSwitchListTile(
            title: Language
                .instance.ADD_LIBRARY_TO_PLAYLIST_WHEN_PLAYING_FROM_TRACKS_TAB,
            subtitle: Language
                .instance.ADD_LIBRARY_TO_PLAYLIST_WHEN_PLAYING_FROM_TRACKS_TAB,
            onChanged: (_) => Configuration.instance
                .save(
                  addLibraryToPlaylistWhenPlayingFromTracksTab: !Configuration
                      .instance.addLibraryToPlaylistWhenPlayingFromTracksTab,
                )
                .then((_) => setState(() {})),
            value: Configuration
                .instance.addLibraryToPlaylistWhenPlayingFromTracksTab,
          ),
        ],
      ),
    );
  }
}
