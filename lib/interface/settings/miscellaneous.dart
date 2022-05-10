import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/utils/widgets.dart';

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
                .then((value) => setState(() {
                      if (!Configuration
                          .instance.dynamicNowPlayingBarColoring) {
                        MobileNowPlayingController.instance.palette.value =
                            null;
                      }
                    })),
            value: Configuration.instance.dynamicNowPlayingBarColoring,
          ),
          if (Platform.isAndroid)
            CorrectedSwitchListTile(
              title: Language.instance.NOTIFICATION_LYRICS_TITLE,
              subtitle: Language.instance.NOTIFICATION_LYRICS_SUBTITLE,
              onChanged: (_) => Configuration.instance
                  .save(
                    notificationLyrics:
                        !Configuration.instance.notificationLyrics,
                  )
                  .then((value) => setState(() {})),
              value: Configuration.instance.notificationLyrics,
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
                  .then((value) => setState(() {})),
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
                .then((value) => setState(() {})),
            value: Configuration.instance.seamlessPlayback,
          ),
          CorrectedSwitchListTile(
            title: Language.instance.SHOW_NOW_PLAYING_AFTER_PLAYING,
            subtitle: Language.instance.SHOW_NOW_PLAYING_AFTER_PLAYING_SUBTITLE,
            onChanged: (_) => Configuration.instance
                .save(
                  jumpToNowPlayingScreenOnPlay:
                      !Configuration.instance.jumpToNowPlayingScreenOnPlay,
                )
                .then((value) => setState(() {})),
            value: Configuration.instance.jumpToNowPlayingScreenOnPlay,
          ),
          CorrectedSwitchListTile(
            title: Language.instance.BACKGROUND_ARTWORK_TITLE,
            subtitle: Language.instance.BACKGROUND_ARTWORK_SUBTITLE,
            onChanged: (_) => Configuration.instance
                .save(
                  backgroundArtwork: !Configuration.instance.backgroundArtwork,
                )
                .then((value) =>
                    Provider.of<Visuals>(context, listen: false).update()),
            value: Configuration.instance.backgroundArtwork,
          ),
        ],
      ),
    );
  }
}
