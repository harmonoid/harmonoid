import 'package:flutter/material.dart';

import 'package:harmonoid/screens/settings/settings.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/language/constants.dart';


class ThemeSetting extends StatefulWidget {
  ThemeSetting({Key key}) : super(key: key);
  ThemeState createState() => ThemeState();
}


class ThemeState extends State<ThemeSetting> {
  ThemeMode theme;

  Future<void> setTheme(ThemeMode value) async {
    await configuration.save(themeMode: value);
    this.setState(() => this.theme = value);
    States?.refreshThemeData();
  }

  @override
  void initState() { 
    super.initState();
    this.theme = configuration.themeMode;
  }
  
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Constants.STRING_SETTING_THEME_TITLE,
      subtitle: Constants.STRING_SETTING_THEME_SUBTITLE,
      child: Column(
        children: [
          RadioListTile(
            value: ThemeMode.system,
            title: Text(Constants.STRING_THEME_MODE_SYSTEM),
            groupValue: this.theme,
            onChanged: (Object object) => this.setTheme(object),
          ),
          RadioListTile(
            value: ThemeMode.light,
            title: Text(Constants.STRING_THEME_MODE_LIGHT),
            groupValue: this.theme,
            onChanged: (Object object) => this.setTheme(object),
          ),
          RadioListTile(
            value: ThemeMode.dark,
            title: Text(Constants.STRING_THEME_MODE_DARK),
            groupValue: this.theme,
            onChanged: (Object object) => this.setTheme(object),
          ),
        ],
      )
    );
  }
}