import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
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
              this.setState(() {});
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
        ],
      ),
      margin: EdgeInsets.only(bottom: 8.0),
    );
  }
}
