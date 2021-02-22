
import 'package:flutter/material.dart';
import 'package:harmonoid/language/constants.dart';

import 'package:harmonoid/screens/settings/settings.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/scripts/states.dart';


class MiscellaneousSetting extends StatefulWidget {
  MiscellaneousSetting({Key key}) : super(key: key);
  MiscellaneousSettingState createState() => MiscellaneousSettingState();
}


class MiscellaneousSettingState extends State<MiscellaneousSetting> {

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Constants.STRING_SETTING_MISCELLANEOUS_TITLE,
      subtitle: Constants.STRING_SETTING_MISCELLANEOUS_SUBTITLE,
      child: Column(
        children: [
          SwitchListTile(
            title: Text(Constants.STRING_SETTING_MISCELLANEOUS_ENABLE_IOS_TITLE),
            subtitle: Text(Constants.STRING_SETTING_MISCELLANEOUS_ENABLE_IOS_SUBTITLE),
            value: configuration.enableiOS,
            onChanged: (bool value) async {
              await configuration.save(
                enableiOS: value,
              );
              States.refreshThemeData?.call();
            },
          ),
        ],
      ),
      margin: EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0, bottom: 8.0),
    );
  }
}