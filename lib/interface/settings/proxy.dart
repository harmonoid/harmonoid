/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2022, Mitja Ševerkar <mytja@protonmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:ytm_client/ytm_client.dart';

class ProxySetting extends StatefulWidget {
  ProxySetting({Key? key}) : super(key: key);
  ProxyState createState() => ProxyState();
}

class ProxyState extends State<ProxySetting> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: Configuration.instance.proxyURL);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Language.instance.PROXY_TITLE,
      subtitle: Language.instance.PROXY_SUBTITLE,
      child: TextField(
        controller: controller,
        onEditingComplete: () async {
          await Configuration.instance.save(proxyURL: controller.text);
          ytm_request_authority =
              controller.text == "" ? null : controller.text;
        },
      ),
      margin: EdgeInsets.only(bottom: 16.0),
    );
  }
}
