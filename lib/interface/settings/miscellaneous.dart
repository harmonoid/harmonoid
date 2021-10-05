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

import 'package:flutter/material.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

class MiscellaneousSetting extends StatefulWidget {
  MiscellaneousSettingState createState() => MiscellaneousSettingState();
}

class MiscellaneousSettingState extends State<MiscellaneousSetting> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: language!.STRING_SETTING_MISCELLANEOUS_TITLE,
      subtitle: language!.STRING_SETTING_MISCELLANEOUS_SUBTITLE,
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              language!.STRING_ENABLE_ACRYLIC_BLUR,
              style: Theme.of(context).textTheme.headline4,
            ),
            value: configuration.acrylicEnabled!,
            onChanged: (bool enabled) async {
              await configuration.save(
                acrylicEnabled: enabled,
              );
              // Causes scaffoldBackgroundColor to update.
              Provider.of<Visuals>(context, listen: false).update();
            },
          ),
          SwitchListTile(
            title: Text(
              language!.STRING_NOTIFICATION_LYRICS_TITLE,
              style: Theme.of(context).textTheme.headline4,
            ),
            value: configuration.notificationLyrics!,
            onChanged: (bool enabled) async {
              await configuration.save(
                notificationLyrics: enabled,
              );
              this.setState(() {});
            },
          ),
          SwitchListTile(
            title: Text(
              language!.STRING_ENABLE_125_SCALING,
              style: Theme.of(context).textTheme.headline4,
            ),
            value: configuration.enable125Scaling!,
            onChanged: (bool enabled) async {
              await configuration.save(
                enable125Scaling: enabled,
              );
              Provider.of<Visuals>(context, listen: false).update();
            },
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 8.0),
    );
  }
}