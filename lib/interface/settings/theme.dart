/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/constants/language.dart';

class ThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
        title: Language.instance.SETTING_THEME_TITLE,
        subtitle: Language.instance.SETTING_THEME_SUBTITLE,
        child: Consumer<Visuals>(
          builder: (context, visuals, _) => Column(
            children: [
              if (Platform.isAndroid || Platform.isIOS || Platform.isWindows)
                RadioListTile(
                  value: ThemeMode.system,
                  title: Text(
                    Language.instance.THEME_MODE_SYSTEM,
                    style: isDesktop
                        ? Theme.of(context).textTheme.headline4
                        : null,
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
                  style:
                      isDesktop ? Theme.of(context).textTheme.headline4 : null,
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
                  style:
                      isDesktop ? Theme.of(context).textTheme.headline4 : null,
                ),
                groupValue: visuals.themeMode,
                onChanged: (dynamic themeMode) => visuals.update(
                  themeMode: themeMode,
                  context: context,
                ),
              ),
            ],
          ),
        ));
  }
}
