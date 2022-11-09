/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class ExperimentalSetting extends StatefulWidget {
  ExperimentalSetting({Key? key}) : super(key: key);
  ExperimentalSettingState createState() => ExperimentalSettingState();
}

class ExperimentalSettingState extends State<ExperimentalSetting> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Language.instance.EXPERIMENTAL,
      subtitle: Language.instance.EXPERIMENTAL_SUBTITLE.replaceAll('\n', ' '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isMobile)
            Container(
              padding: const EdgeInsets.only(left: 16.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                Language.instance.EXPERIMENTAL_SUBTITLE,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(height: 1.2),
              ),
            ),
          CorrectedSwitchListTile(
            title: Language.instance.AUTO_REFRESH_SETTING_TITLE,
            subtitle: Language.instance.AUTO_REFRESH_SETTING,
            onChanged: (_) => Configuration.instance
                .save(
                  automaticMusicLookup:
                      !Configuration.instance.automaticMusicLookup,
                )
                .then((value) => setState(() {})),
            value: Configuration.instance.automaticMusicLookup,
          ),
          CorrectedSwitchListTile(
            title: Language.instance.FALLBACK_ALBUM_ARTS,
            subtitle: Language.instance.FALLBACK_ALBUM_ARTS,
            onChanged: (_) => Configuration.instance
                .save(
                  lookupForFallbackAlbumArt:
                      !Configuration.instance.lookupForFallbackAlbumArt,
                )
                .then((value) => setState(() {})),
            value: Configuration.instance.lookupForFallbackAlbumArt,
          ),
        ],
      ),
    );
  }
}
