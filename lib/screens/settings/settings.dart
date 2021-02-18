import 'package:flutter/material.dart';

import 'package:harmonoid/language/constants.dart';
import 'package:harmonoid/screens/settings/accent.dart';
import 'package:harmonoid/screens/settings/server.dart';
import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/language/language.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/widgets.dart';


class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final EdgeInsets margin;
  final List<Widget> actions;
  SettingsTile({Key key, @required this.title, @required this.subtitle, @required this.child, this.actions, this.margin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
      elevation: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0, left: 16.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  this.title,
                  style: Theme.of(context).textTheme.headline1,
                ),
                Divider(
                  color: Colors.transparent,
                  height: 4.0,
                ),
                Text(
                  this.subtitle,
                  style: Theme.of(context).textTheme.headline5,
                ),
                Divider(
                  color: Colors.transparent,
                  height: 8.0,
                ),
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
          Divider(
            color: Colors.transparent,
            height: 8.0,
          ),
          (this.actions != null) ? Divider(
            color: Theme.of(context).dividerColor,
            thickness: 1.0,
            indent: 16.0,
            endIndent: 16.0,
            height: 1.0,
          ) : Container(),
          (this.actions != null) ? ButtonBar(
            alignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: this.actions,
          ) : Container(),
        ],
      ),
    );
  }
}


class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);
  SettingsState createState() => SettingsState();
}


class SettingsState extends State<Settings> {
  ThemeMode _themeMode;
  LanguageRegion _languageRegion;
  List<int> _refreshLinearProgressIndicatorValues;

  Future<void> _setThemeMode(ThemeMode value) async {
    await configuration.save(themeMode: value);
    this.setState(() => this._themeMode = value);
    States?.refreshThemeData();
  }

  Future<void> _setLanguageRegion(LanguageRegion value) async {
    await configuration.save(languageRegion: value);
    this.setState(() => this._languageRegion = value);
  }

  Future<void> _refresh() async {
    this._themeMode = configuration.themeMode;
    this._languageRegion = configuration.languageRegion;
    this.setState(() {});
  }

  @override
  void initState() {
    super.initState();
    this._refresh();
  }
  
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
          tooltip: Constants.STRING_MENU,
        ),
        title: Text(Constants.STRING_SETTING),
      ),
      body: ListView(
        children: [
          SettingsTile(
            title: Constants.STRING_SETTING_THEME_TITLE,
            subtitle: Constants.STRING_SETTING_THEME_SUBTITLE,
            child: Column(
              children: [
                RadioListTile(
                  value: ThemeMode.system,
                  title: Text(Constants.STRING_THEME_MODE_SYSTEM),
                  groupValue: this._themeMode,
                  onChanged: (Object object) => this._setThemeMode(object),
                ),
                RadioListTile(
                  value: ThemeMode.light,
                  title: Text(Constants.STRING_THEME_MODE_LIGHT),
                  groupValue: this._themeMode,
                  onChanged: (Object object) => this._setThemeMode(object),
                ),
                RadioListTile(
                  value: ThemeMode.dark,
                  title: Text(Constants.STRING_THEME_MODE_DARK),
                  groupValue: this._themeMode,
                  onChanged: (Object object) => this._setThemeMode(object),
                ),
              ],
            )
          ),
          SettingsTile(
            title: Constants.STRING_SETTING_ACCENT_COLOR_TITLE,
            subtitle: Constants.STRING_SETTING_ACCENT_COLOR_SUBTITLE,
            child: Accent(),
            margin: EdgeInsets.all(16.0),
          ),
          SettingsTile(
            title: Constants.STRING_SETTING_LANGUAGE_TITLE,
            subtitle: Constants.STRING_SETTING_LANGUAGE_SUBTITLE,
            child: Column(
              children: [
                RadioListTile(
                  value: LanguageRegion.enUs,
                  title: Text(LanguageRegion.enUs.data[0]),
                  subtitle: Text(LanguageRegion.enUs.data[1]),
                  groupValue: this._languageRegion,
                  onChanged: (Object object) => this._setLanguageRegion(object),
                ),
                RadioListTile(
                  value: LanguageRegion.ruRu,
                  title: Text(LanguageRegion.ruRu.data[0]),
                  subtitle: Text(LanguageRegion.ruRu.data[1]),
                  groupValue: this._languageRegion,
                  onChanged: (Object object) => this._setLanguageRegion(object),
                ),
                RadioListTile(
                  value: LanguageRegion.slSi,
                  title: Text(LanguageRegion.slSi.data[0]),
                  subtitle: Text(LanguageRegion.slSi.data[1]),
                  groupValue: this._languageRegion,
                  onChanged: (Object object) => this._setLanguageRegion(object),
                ),
                RadioListTile(
                  value: LanguageRegion.ptBr,
                  title: Text(LanguageRegion.ptBr.data[0]),
                  subtitle: Text(LanguageRegion.ptBr.data[1]),
                  groupValue: this._languageRegion,
                  onChanged: (Object object) => this._setLanguageRegion(object),
                ),
                RadioListTile(
                  value: LanguageRegion.hiIn,
                  title: Text(LanguageRegion.hiIn.data[0]),
                  subtitle: Text(LanguageRegion.hiIn.data[1]),
                  groupValue: this._languageRegion,
                  onChanged: (Object object) => this._setLanguageRegion(object),
                ),
                RadioListTile(
                  value: LanguageRegion.deDe,
                  title: Text(LanguageRegion.deDe.data[0]),
                  subtitle: Text(LanguageRegion.deDe.data[1]),
                  groupValue: this._languageRegion,
                  onChanged: (Object object) => this._setLanguageRegion(object),
                ),
                RadioListTile(
                  value: LanguageRegion.nlNl,
                  title: Text(LanguageRegion.nlNl.data[0]),
                  subtitle: Text(LanguageRegion.nlNl.data[1]),
                  groupValue: this._languageRegion,
                  onChanged: (Object object) => this._setLanguageRegion(object),
                ),
              ],
            )
          ),
          SettingsTile(
            title: Constants.STRING_SETTING_INDEXING_TITLE,
            subtitle: Constants.STRING_SETTING_INDEXING_SUBTITLE,
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 56.0,
                    alignment: Alignment.topLeft,
                    child: this._refreshLinearProgressIndicatorValues != null ? TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: this._refreshLinearProgressIndicatorValues[0]/this._refreshLinearProgressIndicatorValues[1]),
                      duration: Duration(milliseconds: 400),
                      child: Text(
                        (
                          Constants.STRING_SETTING_INDEXING_LINEAR_PROGRESS_INDICATOR
                          .replaceAll('NUMBER_STRING', this._refreshLinearProgressIndicatorValues[0].toString())
                        ).replaceAll('TOTAL_STRING', this._refreshLinearProgressIndicatorValues[1].toString()),
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      builder: (_, value, child) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          child,
                          Container(
                            margin: EdgeInsets.only(top: 6.0),
                            height: 4.0,
                            width: MediaQuery.of(context).size.width - 32.0,
                            child: LinearProgressIndicator(
                              value: value,
                            ),
                          ),
                        ],
                      )
                    ): Container(
                      child: Chip(
                        backgroundColor: Theme.of(context).accentColor,
                        avatar: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        label: Text(
                          Constants.STRING_SETTING_INDEXING_DONE,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    ),
                  ),
                  Text(Constants.STRING_SETTING_INDEXING_WARNING,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
            ),
            actions: [
              MaterialButton(
                onPressed: () async {
                  await collection.refresh(callback: (completed, total, isCompleted) {
                    this.setState(() {
                      this._refreshLinearProgressIndicatorValues = [completed, total];
                    });
                  });
                  this._refreshLinearProgressIndicatorValues = null;
                },
                child: Text(
                  Constants.STRING_REFRESH,
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ],
          ),
          SettingsTile(
            title: Constants.STRING_SETTING_SERVER_CHANGE_TITLE,
            subtitle: Constants.STRING_SETTING_SERVER_CHANGE_SUBTITLE,
            child: Server(),
            margin: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
          ),
          SettingsTile(
            title: Constants.STRING_SETTING_APP_VERSION_TITLE,
            subtitle: Constants.STRING_SETTING_APP_VERSION_SUBTITLE,
            child: Text('[WIP]'),
            margin: EdgeInsets.all(16.0),
          ),
          SettingsTile(
            title: Constants.STRING_ABOUT_TITLE,
            subtitle: Constants.STRING_ABOUT_SUBTITLE,
            child: Text('[WIP]'),
            margin: EdgeInsets.all(16.0),
          ),
        ],
      ),
    );
  }
}
