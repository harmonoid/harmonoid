/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/widgets.dart';

class EnableNewLayoutSetting extends StatefulWidget {
  const EnableNewLayoutSetting({super.key});

  @override
  State<EnableNewLayoutSetting> createState() => _EnableNewLayoutSettingState();
}

class _EnableNewLayoutSettingState extends State<EnableNewLayoutSetting> {
  @override
  Widget build(BuildContext context) {
    return CorrectedSwitchListTile(
      title:
          "${Language.instance.USE_MODERN_LAYOUT} (${Language.instance.REQUIRES_APP_RESTART})",
      subtitle: Language.instance.USE_MODERN_LAYOUT_SUBTITLE,
      onChanged: (_) => Configuration.instance
          .save(
            isModernLayout: !Configuration.instance.isModernLayout,
          )
          .then((value) => setState(() {})),
      value: Configuration.instance.isModernLayout,
    );
  }
}
