/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';
import 'package:harmonoid/interface/modern_layout/settings_modern/settings_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/constants/language.dart';

class StatsSettingModern extends StatefulWidget {
  StatsSettingModern({Key? key}) : super(key: key);
  StatsSettingModernState createState() => StatsSettingModernState();
}

class StatsSettingModernState extends State<StatsSettingModern> {
  @override
  Widget build(BuildContext context) {
    return SettingsTileModern(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      title: Language.instance.STATS_TITLE,
      subtitle: Language.instance.STATS_SUBTITLE,
      child: Consumer<Collection>(
        builder: (context, collection, _) => Wrap(
          children: [
            StatsContainerModern(
              icon: Broken.music_circle,
              title: Language.instance.TRACK + ' :',
              value: collection.tracks.length.toString(),
            ),
            StatsContainerModern(
              icon: Broken.music_dashboard,
              title: Language.instance.ALBUM + ' :',
              value: collection.albums.length.toString(),
            ),
            StatsContainerModern(
              icon: Broken.profile_2user,
              title: Language.instance.ARTIST + ' :',
              value: collection.artists.length.toString(),
            ),
            StatsContainerModern(
              icon: Broken.smileys,
              title: Language.instance.GENRE + ' :',
              value: collection.genres.length.toString(),
            ),
            StatsContainerModern(
              icon: Broken.microphone,
              title: Language.instance.ALBUM_ARTIST + ' :',
              value: collection.albumArtists.length.toString(),
            ),
            // StatsContainerModern(
            //   icon: Broken.refresh,
            //   title: Language.instance.HISTORY + ' :',
            //   value: collection.historyPlaylist.tracks.length.toString(),
            // ),
            StatsContainerModern(
              icon: Broken.music_library_2,
              title: Language.instance.TOTAL_TRACKS_DURATION + ' :',
              value: getTotalTracksDurationFormatted(tracks: collection.tracks),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsContainerModern extends StatelessWidget {
  final Widget? child;
  final IconData? icon;
  final String? title;
  final String? value;

  const StatsContainerModern(
      {super.key, this.child, this.icon, this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color?.withAlpha(140),
        borderRadius: BorderRadius.circular(
            22 * Configuration.instance.borderRadiusMultiplier),
      ),
      margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 5.0),
      child: child ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              SizedBox(
                width: 8.0,
              ),
              Text(title ?? ''),
              SizedBox(
                width: 8.0,
              ),
              Text(value ?? '')
            ],
          ),
    );
  }
}
