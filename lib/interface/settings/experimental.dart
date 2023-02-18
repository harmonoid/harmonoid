/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

import 'package:harmonoid/interface/settings/settings.dart';

class ExperimentalSetting extends StatefulWidget {
  ExperimentalSetting({Key? key}) : super(key: key);
  ExperimentalSettingState createState() => ExperimentalSettingState();
}

class ExperimentalSettingState extends State<ExperimentalSetting> {
  Future<void> showAndroidVolumeBoostWarningDialog() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(Language.instance.WARNING),
        contentPadding: const EdgeInsets.fromLTRB(
          24.0,
          20.0,
          24.0,
          12.0,
        ),
        content: Text(Language.instance.ENABLE_VOLUME_BOOST_FILTER_WARNING),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(
              label(
                context,
                Language.instance.OK,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                Language.instance.EXPERIMENTAL_SUBTITLE,
                style: Theme.of(context).textTheme.bodyLarge,
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
          if (isMobile)
            CorrectedSwitchListTile(
              title: Language.instance.ENABLE_VOLUME_BOOST_FILTER,
              subtitle: Language.instance.ENABLE_VOLUME_BOOST_FILTER,
              onChanged: (_) => Configuration.instance
                  .save(
                androidEnableVolumeBoostFilter:
                    !Configuration.instance.androidEnableVolumeBoostFilter,
              )
                  .then((value) {
                setState(() {});
                if (Configuration.instance.androidEnableVolumeBoostFilter) {
                  showAndroidVolumeBoostWarningDialog();
                }
              }),
              value: Configuration.instance.androidEnableVolumeBoostFilter,
            ),
          CorrectedSwitchListTile(
            title: Language.instance.FALLBACK_ALBUM_ARTS,
            subtitle: Language.instance.FALLBACK_ALBUM_ARTS,
            onChanged: (_) {
              resolvedAlbumArts.clear();
              Configuration.instance
                  .save(
                    lookupForFallbackAlbumArt:
                        !Configuration.instance.lookupForFallbackAlbumArt,
                  )
                  .then((value) => setState(() {}));
            },
            value: Configuration.instance.lookupForFallbackAlbumArt,
          ),
        ],
      ),
    );
  }
}
