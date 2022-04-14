import 'dart:io';

import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
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
                  changeNowPlayingBarColorBasedOnPlayingMusic: !Configuration
                      .instance.changeNowPlayingBarColorBasedOnPlayingMusic,
                )
                .then((value) => setState(() {})),
            value: Configuration
                .instance.changeNowPlayingBarColorBasedOnPlayingMusic,
          ),
          if (Platform.isWindows)
            CorrectedSwitchListTile(
              title: Language.instance.SHOW_TRACK_PROGRESS_ON_TASKBAR,
              subtitle:
                  Language.instance.SHOW_TRACK_PROGRESS_ON_TASKBAR_SUBTITLE,
              onChanged: (_) => Configuration.instance
                  .save(
                    showTrackProgressOnTaskbar:
                        !Configuration.instance.showTrackProgressOnTaskbar,
                  )
                  .then((value) => setState(() {})),
              value: Configuration.instance.showTrackProgressOnTaskbar,
            ),
          CorrectedSwitchListTile(
            title: Language
                .instance.AUTOMATICALLY_ADD_OTHER_SONGS_TO_NOW_PLAYING_TITLE,
            subtitle:
                Language.instance.AUTOMATICALLY_ADD_OTHER_SONGS_TO_NOW_PLAYING,
            onChanged: (_) => Configuration.instance
                .save(
                  automaticallyAddOtherSongsFromCollectionToNowPlaying:
                      !Configuration.instance
                          .automaticallyAddOtherSongsFromCollectionToNowPlaying,
                )
                .then((value) => setState(() {})),
            value: Configuration
                .instance.automaticallyAddOtherSongsFromCollectionToNowPlaying,
          ),
          CorrectedSwitchListTile(
            title: Language.instance.SHOW_NOW_PLAYING_AFTER_PLAYING,
            subtitle: Language.instance.SHOW_NOW_PLAYING_AFTER_PLAYING_SUBTITLE,
            onChanged: (_) => Configuration.instance
                .save(
                  automaticallyShowNowPlayingScreenAfterPlaying: !Configuration
                      .instance.automaticallyShowNowPlayingScreenAfterPlaying,
                )
                .then((value) => setState(() {})),
            value: Configuration
                .instance.automaticallyShowNowPlayingScreenAfterPlaying,
          ),
        ],
      ),
    );
  }
}
