import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/visuals.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';


class ThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: language.STRING_SETTING_THEME_TITLE,
      subtitle: language.STRING_SETTING_THEME_SUBTITLE,
      child: Consumer<Visuals>(
        builder: (context, visuals, _) => Column(
          children: [
            RadioListTile(
              value: ThemeMode.system,
              title: Text(language.STRING_THEME_MODE_SYSTEM),
              groupValue: visuals.themeMode,
              onChanged: (themeMode) => visuals.update(
                themeMode: themeMode,
              ),
            ),
            RadioListTile(
              value: ThemeMode.light,
              title: Text(language.STRING_THEME_MODE_LIGHT),
              groupValue: visuals.themeMode,
              onChanged: (themeMode) => visuals.update(
                themeMode: themeMode,
              ),
            ),
            RadioListTile(
              value: ThemeMode.dark,
              title: Text(language.STRING_THEME_MODE_DARK),
              groupValue: visuals.themeMode,
              onChanged: (themeMode) => visuals.update(
                themeMode: themeMode,
              ),
            ),
          ],
        ),
      )
    );
  }
}
