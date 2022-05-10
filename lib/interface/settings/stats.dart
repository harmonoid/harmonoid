/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/collection.dart';

import 'package:harmonoid/interface/settings/settings.dart';
import 'package:provider/provider.dart';

class StatsSetting extends StatefulWidget {
  StatsSetting({Key? key}) : super(key: key);
  StatsSettingState createState() => StatsSettingState();
}

class StatsSettingState extends State<StatsSetting> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      title: Language.instance.STATS_TITLE,
      subtitle: Language.instance.STATS_SUBTITLE,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<Collection>(
            builder: (context, collection, _) => Container(
              width: 360.0,
              child: Table(
                children: [
                  TableRow(
                    children: [
                      Text(Language.instance.TRACK + ' : '),
                      Text(collection.tracks.length.toString()),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(Language.instance.ALBUM + ' : '),
                      Text(collection.albums.length.toString()),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(Language.instance.ARTIST + ' : '),
                      Text(collection.artists.length.toString()),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(Language.instance.PLAYLIST + ' : '),
                      Text(collection.playlists.length.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
