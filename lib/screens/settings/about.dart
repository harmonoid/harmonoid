import 'package:flutter/material.dart';

import 'package:harmonoid/screens/settings/settings.dart';
import 'package:harmonoid/language/constants.dart';

class AboutSetting extends StatefulWidget {
  AboutSetting({Key key}) : super(key: key);

  @override
  AboutState createState() => AboutState();
}

class AboutState extends State<AboutSetting> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Constants.STRING_ABOUT_TITLE,
      subtitle: Constants.STRING_ABOUT_SUBTITLE,
      child: Text('[WIP]'),
      margin: EdgeInsets.all(16.0),
    );
  }
}