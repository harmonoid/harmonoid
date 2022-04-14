import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/widgets.dart';

class ExperimentalSetting extends StatefulWidget {
  ExperimentalSetting({Key? key}) : super(key: key);
  ExperimentalSettingState createState() => ExperimentalSettingState();
}

class ExperimentalSettingState extends State<ExperimentalSetting> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Language.instance.EXPERIMENTAL,
      subtitle: Language.instance.EXPERIMENTAL_SUBTITLE,
      child: Column(
        children: [
          CorrectedSwitchListTile(
            title: Language.instance.AUTO_REFRESH_SETTING_TITLE,
            subtitle: Language.instance.AUTO_REFRESH_SETTING,
            onChanged: (_) => Configuration.instance
                .save(
                  automaticallyRefreshCollectionOnFreshStart: !Configuration
                      .instance.automaticallyRefreshCollectionOnFreshStart,
                )
                .then((value) => setState(() {})),
            value: Configuration
                .instance.automaticallyRefreshCollectionOnFreshStart,
          ),
        ],
      ),
    );
  }
}
