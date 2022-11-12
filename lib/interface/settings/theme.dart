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

import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/constants/language.dart';

class ThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? SettingsTile(
            title: Language.instance.SETTING_THEME_TITLE,
            subtitle: Language.instance.SETTING_THEME_SUBTITLE,
            child: Consumer<Visuals>(
              builder: (context, visuals, _) => Column(
                children: [
                  if (Platform.isWindows)
                    RadioListTile(
                      value: ThemeMode.system,
                      title: Text(
                        Language.instance.THEME_MODE_SYSTEM,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      groupValue: visuals.themeMode,
                      onChanged: (dynamic themeMode) => visuals.update(
                        themeMode: themeMode,
                        context: context,
                      ),
                    ),
                  RadioListTile(
                    value: ThemeMode.light,
                    title: Text(
                      Language.instance.THEME_MODE_LIGHT,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    groupValue: visuals.themeMode,
                    onChanged: (dynamic themeMode) => visuals.update(
                      themeMode: themeMode,
                      context: context,
                    ),
                  ),
                  RadioListTile(
                    value: ThemeMode.dark,
                    title: Text(
                      Language.instance.THEME_MODE_DARK,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    groupValue: visuals.themeMode,
                    onChanged: (dynamic themeMode) => visuals.update(
                      themeMode: themeMode,
                      context: context,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Consumer<Visuals>(
            builder: (context, visuals, _) => ListTile(
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
                                  visuals.update(
                                    context: context,
                                    themeMode: e,
                                  );
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
          );
  }
}
