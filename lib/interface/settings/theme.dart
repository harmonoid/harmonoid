/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/constants/language.dart';

class ThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? SettingsTile(
            title: Language.instance.SETTING_THEME_TITLE,
            subtitle: Language.instance.SETTING_THEME_SUBTITLE,
            child: Consumer<Visuals>(
              builder: (context, visuals, _) => Column(
                children: [
                  if (Platform.isAndroid ||
                      Platform.isIOS ||
                      Platform.isWindows)
                    RadioListTile(
                      value: ThemeMode.system,
                      title: Text(
                        Language.instance.THEME_MODE_SYSTEM,
                        style: isDesktop
                            ? Theme.of(context).textTheme.headline4
                            : null,
                      ),
                      groupValue: visuals.themeMode,
                      onChanged: (dynamic themeMode) => visuals.update(
                        themeMode: themeMode,
                        context: context,
                      ),
                    ),
                  RadioListTile(
                    value: ThemeMode.light,
                    title: Text(
                      Language.instance.THEME_MODE_LIGHT,
                      style: isDesktop
                          ? Theme.of(context).textTheme.headline4
                          : null,
                    ),
                    groupValue: visuals.themeMode,
                    onChanged: (dynamic themeMode) => visuals.update(
                      themeMode: themeMode,
                      context: context,
                    ),
                  ),
                  RadioListTile(
                    value: ThemeMode.dark,
                    title: Text(
                      Language.instance.THEME_MODE_DARK,
                      style: isDesktop
                          ? Theme.of(context).textTheme.headline4
                          : null,
                    ),
                    groupValue: visuals.themeMode,
                    onChanged: (dynamic themeMode) => visuals.update(
                      themeMode: themeMode,
                      context: context,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Consumer<Visuals>(
            builder: (context, visuals, _) => ListTile(
              onTap: () async {
                ThemeMode value = visuals.themeMode;
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(Language.instance.SETTING_THEME_TITLE),
                    contentPadding: EdgeInsets.only(top: 20.0),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(
                          height: 1.0,
                          thickness: 1.0,
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 420.0,
                          ),
                          child: StatefulBuilder(
                            builder: (context, setState) =>
                                SingleChildScrollView(
                              child: Column(
                                children: ThemeMode.values
                                    .map(
                                      (e) => RadioListTile<ThemeMode>(
                                        title: Text(
                                          {
                                            ThemeMode.system: Language
                                                .instance.THEME_MODE_SYSTEM,
                                            ThemeMode.light: Language
                                                .instance.THEME_MODE_LIGHT,
                                            ThemeMode.dark: Language
                                                .instance.THEME_MODE_DARK,
                                          }[e]!,
                                        ),
                                        groupValue: value,
                                        onChanged: (e) {
                                          if (e != null) {
                                            setState(() => value = e);
                                          }
                                        },
                                        value: e,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                        const Divider(
                          height: 1.0,
                          thickness: 1.0,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).maybePop();
                          visuals.update(
                            themeMode: value,
                            context: context,
                          );
                        },
                        child: Text(
                          Language.instance.OK,
                        ),
                      ),
                      TextButton(
                        onPressed: Navigator.of(context).maybePop,
                        child: Text(
                          Language.instance.CANCEL,
                        ),
                      ),
                    ],
                  ),
                );
              },
              title: Text(Language.instance.SETTING_THEME_TITLE),
              subtitle: Text(
                {
                  ThemeMode.system: Language.instance.THEME_MODE_SYSTEM,
                  ThemeMode.light: Language.instance.THEME_MODE_LIGHT,
                  ThemeMode.dark: Language.instance.THEME_MODE_DARK,
                }[visuals.themeMode]!,
              ),
            ),
          );
  }
}
