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
              'Enable Windows acrylic blur',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
            subtitle: Text(
              'Add blur effect to the app\'s background.',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.8)
                    : Colors.black.withOpacity(0.8),
                fontSize: 14.0,
              ),
            ),
            value: configuration.acrylicEnabled!,
            onChanged: (bool enabled) async {
              await configuration.save(
                acrylicEnabled: enabled,
              );
              await Acrylic.setEffect(
                effect: enabled ? AcrylicEffect.acrylic : AcrylicEffect.solid,
                gradientColor: Theme.of(context).brightness == ThemeMode.light
                    ? Colors.white
                    : Color(0xCC222222),
              );
              // Causes scaffoldBackgroundColor to update.
              Provider.of<Visuals>(context, listen: false).update();
              this.setState(() {});
            },
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 8.0),
    );
  }
}
