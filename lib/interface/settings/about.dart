import 'package:flutter/material.dart';
import 'package:harmonoid/interface/settings/about/aboutpage.dart';

import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

class AboutSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: language.ABOUT_TITLE,
      subtitle: language.ABOUT_SUBTITLE,
      child: Container(),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AboutPage(),
              ),
            );
          },
          child: Text(
            language.KNOW_MORE,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        )
      ],
    );
  }
}
