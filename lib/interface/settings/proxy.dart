/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2022, Mitja Ševerkar <mytja@protonmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';
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
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          height: isDesktop ? 40.0 : null,
          width: isDesktop ? 480.0 : MediaQuery.of(context).size.width - 32.0,
          alignment: Alignment.center,
          padding: isDesktop ? EdgeInsets.only(top: 2.0) : null,
          child: Focus(
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                HotKeys.instance.disableSpaceHotKey();
              } else {
                HotKeys.instance.enableSpaceHotKey();
              }
            },
            child: TextField(
              controller: controller,
              onEditingComplete: () async {
                if (controller.text.isEmpty) return;
                await Configuration.instance.save(proxyURL: controller.text);
                ytm_request_authority =
                    controller.text.isEmpty ? null : controller.text;
              },
              cursorWidth: isDesktop ? 1.0 : 2.0,
              cursorColor: isDesktop
                  ? Theme.of(context).brightness == Brightness.light
                      ? Color(0xFF212121)
                      : Colors.white
                  : null,
              textAlignVertical: isDesktop ? TextAlignVertical.bottom : null,
              style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
              decoration: isDesktop
                  ? inputDecoration(
                      context,
                      Language.instance.PROXY_URL,
                      trailingIcon: Icon(
                        Icons.check,
                        size: 20.0,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      trailingIconOnPressed: () {
                        if (controller.text.isEmpty) return;
                        Configuration.instance.save(proxyURL: controller.text);
                        ytm_request_authority =
                            controller.text.isEmpty ? null : controller.text;
                      },
                    )
                  : InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(12, 26, 12, 10),
                      hintText: Language.instance.PROXY_URL,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .iconTheme
                              .color!
                              .withOpacity(0.4),
                          width: 1.8,
                        ),
                      ),
                      suffixIcon: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          splashRadius: 14.0,
                          highlightColor: Colors.transparent,
                          onPressed: () {
                            Configuration.instance
                                .save(proxyURL: controller.text);
                            ytm_request_authority = controller.text.isEmpty
                                ? null
                                : controller.text;
                          },
                          icon: Icon(
                            Icons.check,
                            size: 20.0,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .iconTheme
                              .color!
                              .withOpacity(0.4),
                          width: 1.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.8,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
