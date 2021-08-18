import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

class MiscellaneousSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: language!.STRING_SETTING_MISCELLANEOUS_TITLE,
      subtitle: language!.STRING_SETTING_MISCELLANEOUS_SUBTITLE,
      child: Column(
        children: [
          Consumer<Visuals>(
            builder: (context, visuals, _) => SwitchListTile(
              title: Text(
                language!.STRING_SETTING_MISCELLANEOUS_ENABLE_IOS_TITLE,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
              subtitle: Text(
                language!.STRING_SETTING_MISCELLANEOUS_ENABLE_IOS_SUBTITLE,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black.withOpacity(0.8),
                  fontSize: 14.0,
                ),
              ),
              value: visuals.platform == TargetPlatform.iOS,
              onChanged: (bool isiOS) => visuals.update(
                platform: isiOS ? TargetPlatform.iOS : TargetPlatform.android,
              ),
            ),
          ),
          Consumer<NotificationLyrics>(
            builder: (context, lyrics, _) => SwitchListTile(
              title: Text(
                language!.STRING_NOTIFICATION_LYRICS_TITLE,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
              subtitle: Text(
                language!.STRING_NOTIFICATION_LYRICS_SUBTITLE,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black.withOpacity(0.8),
                  fontSize: 14.0,
                ),
              ),
              value: lyrics.enabled,
              onChanged: (bool enabled) => lyrics.update(enabled: enabled),
            ),
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 8.0),
    );
  }
}
