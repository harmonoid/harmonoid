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
import 'package:harmonoid/interface/modern_layout/settings_modern/album_tile_customization.dart';
import 'package:harmonoid/interface/modern_layout/settings_modern/now_playing_screen_customization.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/modern_layout/settings_modern/track_tile_customization.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/utils/rendering.dart';

class CustomizationSetting extends StatefulWidget {
  final Color? currentTrackColor;
  CustomizationSetting({Key? key, this.currentTrackColor}) : super(key: key);
  CustomizationSettingState createState() => CustomizationSettingState();
}

class CustomizationSettingState extends State<CustomizationSetting> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Language.instance.CUSTOMIZATIONS,
      subtitle: Language.instance.CUSTOMIZATIONS_SUBTITLE.replaceAll('\n', ' '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isMobile)
            Container(
              padding: const EdgeInsets.only(left: 16.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                Language.instance.CUSTOMIZATIONS_SUBTITLE,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(height: 1.2),
              ),
            ),
          CustomSwitchListTileModern(
            passedColor: widget.currentTrackColor,
            icon: Broken.d_cube_scan,
            title:
                "${Language.instance.USE_MODERN_LAYOUT} (${Language.instance.REQUIRES_APP_RESTART})",
            subtitle: Language.instance.USE_MODERN_LAYOUT_SUBTITLE,
            onChanged: (_) => Configuration.instance
                .save(
                  isModernLayout: !Configuration.instance.isModernLayout,
                )
                .then((value) => setState(() {})),
            value: Configuration.instance.isModernLayout,
          ),
          if (isMobile)
            CustomSwitchListTileModern(
              passedColor: widget.currentTrackColor,
              // icon: Broken.pause,
              leading: Stack(
                children: [
                  ShaderMask(
                    shaderCallback: (rect) => LinearGradient(
                      stops: [0.3, 0.9],
                      begin: Alignment.topLeft,
                      colors: [
                        NowPlayingColorPalette.instance.modernColor,
                        NowPlayingColorPalette.instance.modernColor
                            .withAlpha(10),
                      ],
                    ).createShader(rect),
                    child: Icon(
                      Broken.play,
                      color: Colors.white,
                    ),
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
                        Broken.pause,
                        size: 12,
                        color: NowPlayingColorPalette.instance.modernColor,
                      ),
                    ),
                  )
                ],
              ),

              title: Language.instance.ENABLE_FADE_EFFECT_ON_PLAY_PAUSE,
              onChanged: (_) => Configuration.instance
                  .save(
                enableVolumeFadeOnPlayPause:
                    !Configuration.instance.enableVolumeFadeOnPlayPause,
              )
                  .then((_) {
                setState(() {});
              }),
              value: Configuration.instance.enableVolumeFadeOnPlayPause,
            ),
          // Sticky Miniplayer
          if (isMobile)
            CustomSwitchListTileModern(
              passedColor: widget.currentTrackColor,
              icon: Broken.external_drive,
              title: Language.instance.STICKY_MINIPLAYER,
              subtitle: Language.instance.STICKY_MINIPLAYER_SUBTITLE,
              onChanged: (_) => Configuration.instance
                  .save(
                stickyMiniplayer: !Configuration.instance.stickyMiniplayer,
              )
                  .then((_) {
                setState(() {});
              }),
              value: Configuration.instance.stickyMiniplayer,
            ),

          CustomSwitchListTileModern(
            passedColor: widget.currentTrackColor,
            icon: Broken.drop,
            title: Language.instance.ENABLE_BLUR_EFFECT,
            onChanged: (_) => Configuration.instance
                .save(
              enableBlurEffect: !Configuration.instance.enableBlurEffect,
            )
                .then((_) {
              setState(() {});
            }),
            value: Configuration.instance.enableBlurEffect,
          ),
          CustomSwitchListTileModern(
            passedColor: widget.currentTrackColor,
            icon: Broken.sun_1,
            title: Language.instance.ENABLE_GLOW_EFFECT,
            onChanged: (_) => Configuration.instance
                .save(
              enableGlowEffect: !Configuration.instance.enableGlowEffect,
            )
                .then((_) {
              setState(() {});
            }),
            value: Configuration.instance.enableGlowEffect,
          ),

          if (isMobile)
            CustomListTileModern(
              icon: Broken.rotate_left_1,
              title: Language.instance.BORDER_RADIUS_MULTIPLIER,
              trailing: Text(
                "${Configuration.instance.borderRadiusMultiplier}",
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(color: Colors.grey[500]),
              ),
              onTap: () {
                showSettingDialogWithTextField(
                    title: Language.instance.BORDER_RADIUS_MULTIPLIER,
                    context: context,
                    setState: () {
                      setState(() {});
                    },
                    borderRadiusMultiplier: true);
              },
            ),
          if (isMobile)
            CustomListTileModern(
              icon: Broken.text,
              title: Language.instance.FONT_SCALE,
              trailing: Text(
                "${(Configuration.instance.fontScaleFactor * 100).toInt()}%",
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(color: Colors.grey[500]),
              ),
              onTap: () {
                showSettingDialogWithTextField(
                    title: Language.instance.BORDER_RADIUS_MULTIPLIER,
                    context: context,
                    setState: () {
                      setState(() {});
                    },
                    fontScaleFactor: true);
              },
            ),

          // Date Format Changer
          // should be used with both layouts, use [getDateFormatted(year)] to get a String of formatted Date

          if (isMobile)
            CustomListTileModern(
              icon: Broken.calendar_edit,
              title: Language.instance.DATE_TIME_FORMAT,
              trailing: Text(
                "${Configuration.instance.dateTimeFormat}",
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(color: Colors.grey[500]),
              ),
              onTap: () {
                showSettingDialogWithTextField(
                    title: Language.instance.DATE_TIME_FORMAT,
                    context: context,
                    setState: () {
                      setState(() {});
                    },
                    dateTimeFormat: true,
                    topWidget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: kDefaultDateTimeStrings.entries
                          .map(
                            (e) => RadioListTile<String>(
                              activeColor:
                                  Theme.of(context).colorScheme.secondary,
                              groupValue: Configuration.instance.dateTimeFormat,
                              value: e.key,
                              onChanged: (e) async {
                                if (e != null) {
                                  setState(() => Configuration
                                      .instance.dateTimeFormat = e);
                                  Navigator.of(context).maybePop();

                                  await Configuration.instance
                                      .save(
                                    dateTimeFormat:
                                        Configuration.instance.dateTimeFormat,
                                  )
                                      .then((_) {
                                    setState(() {});
                                  });

                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                                }
                              },
                              title: Text(
                                '${e.value}',
                                style: isDesktop
                                    ? Theme.of(context).textTheme.headlineMedium
                                    : null,
                              ),
                            ),
                          )
                          .toList(),
                    ));
              },
            ),

          if (isMobile)
            CustomSwitchListTileModern(
              passedColor: widget.currentTrackColor,
              icon: Broken.clock,
              title: Language.instance.HOUR_FORMAT_12,
              onChanged: (_) => Configuration.instance
                  .save(
                    hourFormat12: !Configuration.instance.hourFormat12,
                  )
                  .then((value) => setState(() {})),
              value: Configuration.instance.hourFormat12,
            ),

          // Full Album tile Editor
          AlbumTileCustomization(),
          // Full track tile info Editor
          TrackTileCustomization(),

          NowPlayingScreenCustomization(),
        ],
      ),
    );
  }
}

/// Default values available for setting the Date Time Format.
const kDefaultDateTimeStrings = {
  'yyyyMMdd': '20220413',
  'dd/MM/yyyy': '13/04/2022',
  'MM/dd/yyyy': '04/13/2022',
  'yyyy/MM/dd': '2022/04/13',
  'yyyy/dd/MM': '2022/13/04',
  'dd-MM-yyyy': '13-04-2022',
  'MM-dd-yyyy': '04-13-2022',
  'MMMM dd, yyyy': 'April 13, 2022',
  'MMM dd, yyyy': 'Apr 13, 2022',
  //TODO: add more preset formats
  'MMM dd, yyyy1': 'Apr 13, 2022',
  'MMM dd, yyyy2': 'Apr 13, 2022',
  'MMM dd, yyyy3': 'Apr 13, 2022',
  'MMM dd, yyyy4': 'Apr 13, 2022',
  'MMM dd, yyyy5': 'Apr 13, 2022',
};
