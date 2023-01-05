/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';

class NowPlayingScreenCustomization extends StatelessWidget {
  final Color? currentTrackColor;
  NowPlayingScreenCustomization({super.key, this.currentTrackColor});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => ExpansionTile(
        leading: Stack(
          children: [
            Icon(
              Broken.brush,
              color: currentTrackColor,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).colorScheme.background,
                          spreadRadius: 1)
                    ]),
                child: Icon(
                  Broken.slider,
                  size: 14,
                  color: currentTrackColor,
                ),
              ),
            )
          ],
        ),
        title: Text(
          Language.instance.NOW_PLAYING_SCREEN_CUSTOMIZATION,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        trailing: Icon(
          Broken.arrow_down_2,
        ),
        children: [
          CustomSwitchListTileModern(
            passedColor: currentTrackColor,
            icon: Broken.volume_high,
            title: Language.instance.MOBILE_ENABLE_VOLUME_SLIDER,
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
          CustomSwitchListTileModern(
            icon: Broken.smallcaps,
            title: Language.instance.DISPLAY_AUDIO_FORMAT,
            onChanged: (_) => Configuration.instance
                .save(
              displayAudioFormat: !Configuration.instance.displayAudioFormat,
            )
                .then((_) {
              setState(() {});
            }),
            value: Configuration.instance.displayAudioFormat,
          ),
          CustomListTileModern(
            icon: Broken.direct_normal,
            title: Language.instance.QUEUE_SHEET_MIN_HEIGHT,
            trailing: Text(
              "${Configuration.instance.queueSheetMinHeight}",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.grey[500]),
            ),
            onTap: () {
              showSettingDialogWithTextField(
                  title: Language.instance.QUEUE_SHEET_MIN_HEIGHT,
                  context: context,
                  setState: () {
                    setState(() {});
                  },
                  queueSheetMinHeight: true);
            },
          ),
          CustomListTileModern(
            leading: RotatedBox(
              quarterTurns: 2,
              child: Icon(
                Broken.direct_normal,
                color: NowPlayingColorPalette.instance.modernColor,
              ),
            ),
            // icon: Broken.direct_normal,
            title: Language.instance.QUEUE_SHEET_MAX_HEIGHT,
            trailing: Text(
              "${Configuration.instance.queueSheetMaxHeight}",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.grey[500]),
            ),
            onTap: () {
              showSettingDialogWithTextField(
                  title: Language.instance.QUEUE_SHEET_MIN_HEIGHT,
                  context: context,
                  setState: () {
                    setState(() {});
                  },
                  queueSheetMaxHeight: true);
            },
          ),
          CustomListTileModern(
            icon: Broken.slider_horizontal,
            title: Language.instance.MOBILE_CAROUSEL_HEIGHT,
            trailing: Text(
              "${Configuration.instance.nowPlayingImageContainerHeight}",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.grey[500]),
            ),
            onTap: () {
              showSettingDialogWithTextField(
                  title: Language.instance.MOBILE_CAROUSEL_HEIGHT,
                  context: context,
                  setState: () {
                    setState(() {});
                  },
                  nowPlayingImageContainerHeight: true);
            },
          ),
        ],
      ),
    );
  }
}
