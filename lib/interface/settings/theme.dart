import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

class ThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
        title: language!.STRING_SETTING_THEME_TITLE,
        subtitle: language!.STRING_SETTING_THEME_SUBTITLE,
        child: Consumer<Visuals>(
          builder: (context, visuals, _) => Column(
            children: [
              RadioListTile(
                value: ThemeMode.system,
                title: Text(
                  language!.STRING_THEME_MODE_SYSTEM,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: 14.0,
                  ),
                ),
                groupValue: visuals.themeMode,
                onChanged: (dynamic themeMode) => visuals.update(
                  themeMode: themeMode,
                ),
              ),
              RadioListTile(
                value: ThemeMode.light,
                title: Text(
                  language!.STRING_THEME_MODE_LIGHT,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: 14.0,
                  ),
                ),
                groupValue: visuals.themeMode,
                onChanged: (dynamic themeMode) => visuals.update(
                  themeMode: themeMode,
                ),
              ),
              RadioListTile(
                value: ThemeMode.dark,
                title: Text(
                  language!.STRING_THEME_MODE_DARK,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: 14.0,
                  ),
                ),
                groupValue: visuals.themeMode,
                onChanged: (dynamic themeMode) => visuals.update(
                  themeMode: themeMode,
                ),
              ),
            ],
          ),
        ));
  }
}
