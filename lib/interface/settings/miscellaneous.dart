import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
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
        children: [
          SwitchListTile(
            value: Configuration.instance.showTrackProgressOnTaskbar,
            title: Text(
              Language.instance.SHOW_TRACK_PROGRESS_ON_TASKBAR,
              style: Theme.of(context).textTheme.headline4,
            ),
            onChanged: (_) => Configuration.instance
                .save(
                  showTrackProgressOnTaskbar:
                      !Configuration.instance.showTrackProgressOnTaskbar,
                )
                .then((value) => setState(() {})),
          ),
          SwitchListTile(
            value: Configuration
                .instance.automaticallyAddOtherSongsFromCollectionToNowPlaying,
            title: Text(
              Language.instance.AUTOMATICALLY_ADD_OTHER_SONGS_TO_NOW_PLAYING,
              style: Theme.of(context).textTheme.headline4,
            ),
            onChanged: (_) => Configuration.instance
                .save(
                  automaticallyAddOtherSongsFromCollectionToNowPlaying:
                      !Configuration.instance
                          .automaticallyAddOtherSongsFromCollectionToNowPlaying,
                )
                .then((value) => setState(() {})),
          ),
          SwitchListTile(
            value: Configuration
                .instance.automaticallyShowNowPlayingScreenAfterPlaying,
            title: Text(
              Language.instance.SHOW_NOW_PLAYING_AFTER_PLAYING,
              style: Theme.of(context).textTheme.headline4,
            ),
            onChanged: (_) => Configuration.instance
                .save(
                  automaticallyShowNowPlayingScreenAfterPlaying: !Configuration
                      .instance.automaticallyShowNowPlayingScreenAfterPlaying,
                )
                .then((value) => setState(() {})),
          ),
        ],
      ),
    );
  }
}
