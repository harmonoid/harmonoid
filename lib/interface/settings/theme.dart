/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///

import 'dart:io';
import 'package:flutter/material.dart';
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
                    style: Theme.of(context).textTheme.headline4,
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
                  style: Theme.of(context).textTheme.headline4,
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
                  style: Theme.of(context).textTheme.headline4,
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
