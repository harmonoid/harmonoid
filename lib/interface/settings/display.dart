/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';

import 'package:harmonoid/constants/language.dart';

class DisplaySetting extends StatefulWidget {
  DisplaySetting({Key? key}) : super(key: key);

  @override
  State<DisplaySetting> createState() => _DisplaySettingState();
}

class _DisplaySettingState extends State<DisplaySetting> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Language.instance.SETTING_DISPLAY_TITLE,
      subtitle: Language.instance.SETTING_DISPLAY_SUBTITLE,
      child: Consumer<Visuals>(
        builder: (context, visuals, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child: Text(
                  Language.instance.SETTING_THEME_SUBTITLE,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (Platform.isWindows)
                RadioListTile(
                  value: ThemeMode.system,
                  title: Text(
                    Language.instance.THEME_MODE_SYSTEM,
                    style: isDesktop
                        ? Theme.of(context).textTheme.bodyLarge
                        : null,
                  ),
                  groupValue: visuals.themeMode,
                  onChanged: (ThemeMode? themeMode) =>
                      visuals.update(themeMode: themeMode),
                ),
              RadioListTile(
                value: ThemeMode.light,
                title: Text(
                  Language.instance.THEME_MODE_LIGHT,
                  style:
                      isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
                groupValue: visuals.themeMode,
                onChanged: (ThemeMode? themeMode) =>
                    visuals.update(themeMode: themeMode),
              ),
              RadioListTile(
                value: ThemeMode.dark,
                title: Text(
                  Language.instance.THEME_MODE_DARK,
                  style:
                      isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
                groupValue: visuals.themeMode,
                onChanged: (ThemeMode? themeMode) =>
                    visuals.update(themeMode: themeMode),
              ),
              const SizedBox(height: 8.0),
            ],
            if (isMobile) ...[
              ListTile(
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) => SimpleDialog(
                        title: Text(Language.instance.SETTING_THEME_TITLE),
                        children: ThemeMode.values
                            .map(
                              (e) => RadioListTile<ThemeMode>(
                                title: Text(
                                  {
                                    ThemeMode.system:
                                        Language.instance.THEME_MODE_SYSTEM,
                                    ThemeMode.light:
                                        Language.instance.THEME_MODE_LIGHT,
                                    ThemeMode.dark:
                                        Language.instance.THEME_MODE_DARK,
                                  }[e]!,
                                ),
                                groupValue: visuals.themeMode,
                                onChanged: (e) {
                                  if (e != null) {
                                    visuals.update(themeMode: e);
                                    Navigator.of(context).maybePop();
                                  }
                                },
                                value: e,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
                title: Text(Language.instance.SETTING_THEME_TITLE),
                subtitle: Text(
                  {
                    ThemeMode.system: Language.instance.THEME_MODE_SYSTEM,
                    ThemeMode.light: Language.instance.THEME_MODE_LIGHT,
                    ThemeMode.dark: Language.instance.THEME_MODE_DARK,
                  }[visuals.themeMode]!,
                ),
              ),
              const SizedBox(height: 8.0),
            ],
            Padding(
              padding: EdgeInsets.only(
                top: 2.0,
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Language.instance.SPEED_ANIMATION_EFFECTS,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Container(
              width: isDesktop ? 540.0 : MediaQuery.of(context).size.width,
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
                    ScrollableSlider(
                      min: 50.0,
                      max: 1000.0,
                      value: Configuration
                          .instance.animationDuration.medium.inMilliseconds
                          .toDouble()
                          .clamp(50.0, 1000.0),
                      enabled: Configuration.instance.animationDuration !=
                          AnimationDuration.disabled(),
                      onScrolledUp: () async {},
                      onScrolledDown: () async {},
                      onChanged: (v) async {
                        final fast = v ~/ 2;
                        final medium = v ~/ 1;
                        final slow = v * 3 ~/ 2;
                        await Visuals.instance.update(
                          animationDuration: AnimationDuration(
                            fast: Duration(milliseconds: fast),
                            medium: Duration(milliseconds: medium),
                            slow: Duration(milliseconds: slow),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 8.0),
                TextButton(
                  onPressed: () => Visuals.instance.update(
                    animationDuration: AnimationDuration(),
                  ),
                  child: Text(
                    label(context, Language.instance.RESTORE_DEFAULTS),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            SwitchListTile(
              value: Configuration.instance.animationDuration !=
                  AnimationDuration.disabled(),
              onChanged: (enabled) async {
                await Visuals.instance.update(
                  animationDuration: Configuration.instance.animationDuration ==
                          AnimationDuration.disabled()
                      ? AnimationDuration()
                      : AnimationDuration.disabled(),
                );
              },
              title: Text(
                Language.instance.ENABLE_ANIMATION_EFFECTS,
                style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
              ),
            ),
            CorrectedSwitchListTile(
              title: Language
                  .instance.CHANGE_NOW_PLAYING_BAR_COLOR_BASED_ON_MUSIC_TITLE,
              subtitle:
                  Language.instance.CHANGE_NOW_PLAYING_BAR_COLOR_BASED_ON_MUSIC,
              onChanged: (_) => Configuration.instance
                  .save(
                    dynamicNowPlayingBarColoring:
                        !Configuration.instance.dynamicNowPlayingBarColoring,
                  )
                  .then((_) => setState(() {
                        if (!Configuration
                            .instance.dynamicNowPlayingBarColoring) {
                          NowPlayingColorPalette.instance.cleanup();
                        } else {
                          try {
                            NowPlayingColorPalette.instance.update(
                              Playback.instance.tracks[Playback.instance.index],
                              force: true,
                            );
                          } catch (exception, stacktrace) {
                            debugPrint(exception.toString());
                            debugPrint(stacktrace.toString());
                          }
                        }
                      })),
              value: Configuration.instance.dynamicNowPlayingBarColoring,
            ),
          ],
        ),
      ),
    );
  }
}
