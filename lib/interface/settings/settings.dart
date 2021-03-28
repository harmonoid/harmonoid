import 'package:flutter/material.dart';

import 'package:harmonoid/interface/settings/accent.dart';
import 'package:harmonoid/interface/settings/server.dart';
import 'package:harmonoid/interface/settings/about.dart';
import 'package:harmonoid/interface/settings/collectiontabs.dart';
import 'package:harmonoid/interface/settings/indexing.dart';
import 'package:harmonoid/interface/settings/language.dart';
import 'package:harmonoid/interface/settings/miscellaneous.dart';
import 'package:harmonoid/interface/settings/theme.dart';
import 'package:harmonoid/interface/settings/version.dart';
import 'package:harmonoid/constants/language.dart';


class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
          iconSize: Theme.of(context).iconTheme.size,
          splashRadius: Theme.of(context).iconTheme.size - 8,
          onPressed: () {},
          tooltip: language.STRING_MENU,
        ),
        title: Text(language.STRING_SETTING),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        children: [
          AboutSetting(),
          ThemeSetting(),
          AccentSetting(),
          IndexingSetting(),
          ServerSetting(),
          LanguageSetting(),
          CollectionTabs(),
          MiscellaneousSetting(),
          VersionSetting(),
        ],
      ),
    );
  }
}


class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final EdgeInsets margin;
  final List<Widget> actions;

  const SettingsTile({
    Key key,
    @required this.title,
    @required this.subtitle,
    @required this.child,
    this.actions,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 4.0,
        top: 4.0,
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
                  this.title,
                  style: Theme.of(context).textTheme.headline2,
                ),
                Divider(color: Colors.transparent, height: 4.0),
                Text(
                  this.subtitle,
                  style: Theme.of(context).textTheme.headline5,
                ),
                Divider(color: Colors.transparent, height: 8.0),
                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: 1.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
          Container(
            margin: this.margin ?? EdgeInsets.zero,
            child: this.child ?? Container(),
          ),
          Divider(color: Colors.transparent, height: 8.0),
          if (this.actions != null) ...[
            Divider(
              color: Theme.of(context).dividerColor,
              thickness: 1.0,
              indent: 16.0,
              endIndent: 16.0,
              height: 1.0,
            ),
            ButtonBar(
              alignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: this.actions,
            ),
          ],
        ],
      ),
    );
  }
}
