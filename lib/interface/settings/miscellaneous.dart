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
