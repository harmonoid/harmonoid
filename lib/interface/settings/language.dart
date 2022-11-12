/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';

class LanguageSetting extends StatelessWidget {
  Future<void> action(BuildContext context) async {
    final available = await Language.instance.available;
    LanguageData value = Language.instance.current;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Language.instance.SETTING_LANGUAGE_TITLE),
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
                maxHeight: MediaQuery.of(context).size.height / 2,
              ),
              child: StatefulBuilder(
                builder: (context, setState) => Material(
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                    child: Column(
                      children: available
                          .map(
                            (data) => RadioListTile<LanguageData>(
                              value: data,
                              groupValue: value,
                              onChanged: (e) {
                                if (e != null) {
                                  setState(() => value = e);
                                }
                              },
                              title: Text(
                                data.name,
                                style: isDesktop
                                    ? Theme.of(context).textTheme.headlineMedium
                                    : null,
                              ),
                            ),
                          )
                          .toList(),
                    ),
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
              await Language.instance.set(value: value);
              await Configuration.instance.save(language: value);
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
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return SettingsTile(
        title: Language.instance.SETTING_LANGUAGE_TITLE,
        subtitle: Language.instance.SETTING_LANGUAGE_SUBTITLE,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                [
                  Language.instance.current.name,
                  Language.instance.current.country,
                ].join(' • '),
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const SizedBox(width: 8.0),
                TextButton(
                  onPressed: () => action(context),
                  child: Text(
                    Language.instance.EDIT.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
              ],
            ),
          ],
        ),
      );
    }
    return ListTile(
      onTap: () => action(context),
      title: Text(Language.instance.SETTING_LANGUAGE_TITLE),
      subtitle: Text(
        [
          Language.instance.current.name,
          Language.instance.current.country,
        ].join(' • '),
      ),
    );
  }
}
