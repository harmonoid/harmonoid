/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';
import 'package:harmonoid/constants/language.dart';

import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/interface/settings/indexing.dart';
import 'package:harmonoid/interface/settings/language.dart';
import 'package:harmonoid/interface/settings/desktop_header.dart';
import 'package:harmonoid/interface/settings/stats.dart';
import 'package:harmonoid/interface/settings/miscellaneous.dart';
import 'package:harmonoid/interface/settings/experimental.dart';
import 'package:harmonoid/interface/settings/theme.dart';
import 'package:harmonoid/interface/settings/version.dart';
import 'package:harmonoid/interface/settings/proxy.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? Scaffold(
            body: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: desktopTitleBarHeight + kDesktopAppBarHeight,
                  ),
                  child: CustomListView(
                    cacheExtent: MediaQuery.of(context).size.height * 4,
                    shrinkWrap: true,
                    children: [
                      const Header(),
                      const SizedBox(height: 4.0),
                      IndexingSetting(),
                      StatsSetting(),
                      ThemeSetting(),
                      MiscellaneousSetting(),
                      ExperimentalSetting(),
                      ProxySetting(),
                      LanguageSetting(),
                      VersionSetting(),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
                DesktopAppBar(
                  title: Language.instance.SETTING,
                ),
              ],
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(
                Language.instance.SETTING,
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            body: NowPlayingBarScrollHideNotifier(
              child: CustomListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 4.0),
                  IndexingSetting(),
                  Divider(thickness: 1.0),
                  ThemeSetting(),
                  Divider(thickness: 1.0),
                  MiscellaneousSetting(),
                  Divider(thickness: 1.0),
                  ExperimentalSetting(),
                  Divider(thickness: 1.0),
                  ProxySetting(),
                  Divider(thickness: 1.0),
                  LanguageSetting(),
                  Divider(thickness: 1.0),
                  VersionSetting(),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          );
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
      margin: isDesktop
          ? EdgeInsets.symmetric(
              horizontal: 8.0,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isDesktop)
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
                        .headline1
                        ?.copyWith(fontSize: 20.0),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    this.subtitle!,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ],
              ),
            ),
          if (isMobile) SubHeader(this.title!),
          Container(
            margin: this.margin ?? EdgeInsets.zero,
            child: this.child,
          ),
          if (this.actions != null) ...[
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
