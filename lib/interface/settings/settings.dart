/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'package:flutter/material.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration.dart';

import 'package:harmonoid/interface/settings/accent.dart';
import 'package:harmonoid/interface/settings/about.dart';
import 'package:harmonoid/interface/settings/indexing.dart';
import 'package:harmonoid/interface/settings/language.dart';
import 'package:harmonoid/interface/settings/miscellaneous.dart';
import 'package:harmonoid/interface/settings/theme.dart';
import 'package:harmonoid/interface/settings/version.dart';
import 'package:harmonoid/utils/widgets.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 56.0,
          decoration: BoxDecoration(
            color: configuration.acrylicEnabled!
                ? Colors.transparent
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.10)
                    : Colors.black.withOpacity(0.10),
            border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.12)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NavigatorPopButton(),
              SizedBox(
                width: 16.0,
              ),
              Text(
                language.SETTING,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Color(0xFF202020),
            child: CustomListView(
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: 4.0,
                ),
                IndexingSetting(),
                ThemeSetting(),
                AccentSetting(),
                LanguageSetting(),
                MiscellaneousSetting(),
                AboutSetting(),
                VersionSetting(),
                SizedBox(
                  height: 8.0,
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class SettingsTile extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final EdgeInsets? margin;
  final List<Widget>? actions;

  const SettingsTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 0.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  this.title!,
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      ?.copyWith(fontSize: 24.0),
                ),
                SizedBox(height: 2.0),
                Text(
                  this.subtitle!,
                  style: Theme.of(context).textTheme.headline3,
                ),
                // Divider(
                //   color: Theme.of(context).dividerColor,
                //   thickness: 1.0,
                //   height: 1.0,
                // ),
              ],
            ),
          ),
          Container(
            margin: this.margin ?? EdgeInsets.zero,
            child: this.child,
          ),
          if (this.actions != null) ...[
            // Divider(
            //   color: Theme.of(context).dividerColor,
            //   thickness: 1.0,
            //   indent: 16.0,
            //   endIndent: 16.0,
            //   height: 1.0,
            // ),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: ButtonBar(
                alignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: this.actions!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
