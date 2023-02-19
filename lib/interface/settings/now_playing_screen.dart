/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2022, Mitja Ševerkar <mytja@protonmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/state/now_playing_visuals.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';

import 'package:harmonoid/constants/language.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CorrectedSwitchListTile(
            title: Language.instance.SHOW_NOW_PLAYING_AFTER_PLAYING,
            subtitle: Language.instance.SHOW_NOW_PLAYING_AFTER_PLAYING_SUBTITLE,
            onChanged: (_) => Configuration.instance
                .save(
                  jumpToNowPlayingScreenOnPlay:
                      !Configuration.instance.jumpToNowPlayingScreenOnPlay,
                )
                .then((_) => setState(() {})),
            value: Configuration.instance.jumpToNowPlayingScreenOnPlay,
          ),
          if (isMobile) ...[
            CorrectedSwitchListTile(
              title: Language.instance.MOBILE_ENABLE_NOW_PLAYING_RIPPLE_EFFECT,
              subtitle:
                  Language.instance.MOBILE_ENABLE_NOW_PLAYING_RIPPLE_EFFECT,
              onChanged: (_) => Configuration.instance
                  .save(
                mobileEnableNowPlayingScreenRippleEffect: !Configuration
                    .instance.mobileEnableNowPlayingScreenRippleEffect,
              )
                  .then((_) {
                setState(() {});
                MobileNowPlayingController.instance.hide();
              }),
              value: Configuration
                  .instance.mobileEnableNowPlayingScreenRippleEffect,
            ),
          ],
          if (isDesktop) ...[
            CorrectedSwitchListTile(
              title: Language.instance.USE_MODERN_NOW_PLAYING_SCREEN,
              subtitle: Language.instance.USE_MODERN_NOW_PLAYING_SCREEN,
              onChanged: (_) => Configuration.instance
                  .save(
                    modernNowPlayingScreen:
                        !Configuration.instance.modernNowPlayingScreen,
                  )
                  .then((value) => setState(() {})),
              value: Configuration.instance.modernNowPlayingScreen,
            ),
            Container(
              width:
                  isDesktop ? 540.0 : MediaQuery.of(context).size.width - 32.0,
              alignment: Alignment.center,
              padding: isDesktop ? EdgeInsets.only(top: 2.0) : null,
              child: Padding(
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
                      style: Theme.of(context).textTheme.bodyLarge,
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
                      style: Theme.of(context).textTheme.bodyLarge,
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
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const SizedBox(width: 8.0),
                TextButton(
                  onPressed: () async {
                    await Configuration.instance.save(
                      highlightedLyricsSize: 38.0,
                      unhighlightedLyricsSize: 14.0,
                    );
                    setState(() {});
                  },
                  child: Text(
                    label(context, Language.instance.RESTORE_DEFAULTS),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  Text(
                    Language.instance.VISUALS,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16.0),
                  GridView.extent(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    maxCrossAxisExtent: 84.0,
                    children: NowPlayingVisuals.instance.preloaded
                            .map(
                              (e) => StillGIF.asset(
                                e,
                                height: 84.0,
                                width: 84.0,
                              ),
                            )
                            .toList()
                            .cast<Widget>() +
                        NowPlayingVisuals.instance.user
                            .map(
                              (e) => Stack(
                                children: [
                                  StillGIF.file(
                                    e,
                                    height: 84.0,
                                    width: 84.0,
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        await NowPlayingVisuals.instance
                                            .remove(e);
                                        setState(() {});
                                      },
                                      child: Container(
                                        height: 84.0,
                                        width: 84.0,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.close,
                                          size: 36.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList()
                            .cast<Widget>() +
                        [
                          InkWell(
                            onTap: () async {
                              final file = await pickFile(
                                label: Language.instance.IMAGES,
                                extensions: kSupportedImageFormats,
                              );
                              if (file != null) {
                                await NowPlayingVisuals.instance.add(file);
                                setState(() {});
                              }
                            },
                            child: Container(
                              height: 100.0,
                              width: 100.0,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).iconTheme.color!,
                                  width: 1.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.add,
                                size: 36.0,
                              ),
                            ),
                          )
                        ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
