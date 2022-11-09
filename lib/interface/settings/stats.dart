/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';

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
      child: Table(),
    );
  }
}

class Table extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ??
              Theme.of(context).dividerColor,
          width: 1.0,
        ),
      ),
      margin: isDesktop
          ? EdgeInsets.only(top: tileMargin)
          : EdgeInsets.only(top: tileMargin, bottom: 2 * tileMargin),
      child: Consumer<Collection>(
        builder: (context, collection, _) => DataTable(
          headingRowHeight: isDesktop ? 44.0 : 52.0,
          dataRowHeight: isDesktop ? 44.0 : 52.0,
          columnSpacing: 0.0,
          columns: [
            DataColumn(
              label: Container(
                width: 56.0,
                child: Text(''),
              ),
            ),
            DataColumn(
              label: Container(
                width: isDesktop
                    ? 160.0
                    : (MediaQuery.of(context).size.width - 56.0) / 2,
                child: Text(Language.instance.TYPE),
              ),
            ),
            DataColumn(
              label: Container(
                width: isDesktop
                    ? 60.0
                    : (MediaQuery.of(context).size.width - 56.0) / 2,
                child: Text(Language.instance.COUNT),
              ),
            ),
          ],
          rows: [
            DataRow(
              cells: [
                DataCell(Icon(Icons.music_note)),
                DataCell(Text(Language.instance.TRACK)),
                DataCell(Text(collection.tracks.length.toString())),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Icon(Icons.album)),
                DataCell(Text(Language.instance.ALBUM)),
                DataCell(Text(collection.albums.length.toString())),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Icon(Icons.person)),
                DataCell(Text(Language.instance.ARTIST)),
                DataCell(Text(collection.artists.length.toString())),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Icon(Icons.piano)),
                DataCell(Text(Language.instance.GENRE)),
                DataCell(Text(collection.genres.length.toString())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
