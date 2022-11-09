/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2022, Mitja Ševerkar <mytja@protonmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';
import 'package:harmonoid/core/configuration.dart';

import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/utils/widgets.dart';

class NowPlayingScreenSetting extends StatefulWidget {
  NowPlayingScreenSetting({Key? key}) : super(key: key);
  NowPlayingScreenState createState() => NowPlayingScreenState();
}

class NowPlayingScreenState extends State<NowPlayingScreenSetting> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Language.instance.NOW_PLAYING_SCREEN,
      subtitle: Language.instance.NOW_PLAYING_SCREEN_SETTING_SUBTITLE,
      child: Container(
        width: isDesktop ? 540.0 : MediaQuery.of(context).size.width - 32.0,
        alignment: Alignment.center,
        padding: isDesktop ? EdgeInsets.only(top: 2.0) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 8.0),
                TextButton(
                  onPressed: () async {
                    await Configuration.instance.save(
                      highlightedLyricsSize: 24.0,
                      unhighlightedLyricsSize: 14.0,
                    );
                    setState(() {});
                  },
                  child: Text(
                    Language.instance.RESTORE_DEFAULTS.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 2.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  Text(
                    '${Language.instance.HIGHLIGHTED_LYRICS_SIZE}: ${Configuration.instance.highlightedLyricsSize.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8.0),
                  ScrollableSlider(
                    min: 4.0,
                    max: 96.0,
                    value: Configuration.instance.highlightedLyricsSize,
                    onScrolledUp: () async {},
                    onScrolledDown: () async {},
                    onChanged: (v) async {
                      await Configuration.instance.save(
                        highlightedLyricsSize: v,
                      );
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${Language.instance.UNHIGHLIGHTED_LYRICS_SIZE}: ${Configuration.instance.unhighlightedLyricsSize.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8.0),
                  ScrollableSlider(
                    min: 4.0,
                    max: 96.0,
                    value: Configuration.instance.unhighlightedLyricsSize,
                    onScrolledUp: () async {},
                    onScrolledDown: () async {},
                    onChanged: (v) async {
                      await Configuration.instance.save(
                        unhighlightedLyricsSize: v,
                      );
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
