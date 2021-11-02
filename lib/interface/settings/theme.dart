/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

class ThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
        title: language.SETTING_THEME_TITLE,
        subtitle: language.SETTING_THEME_SUBTITLE,
        child: Consumer<Visuals>(
          builder: (context, visuals, _) => Column(
            children: [
              if (Platform.isAndroid || Platform.isIOS)
                RadioListTile(
                  value: ThemeMode.system,
                  title: Text(
                    language.THEME_MODE_SYSTEM,
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
                  language.THEME_MODE_LIGHT,
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
                  language.THEME_MODE_DARK,
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
