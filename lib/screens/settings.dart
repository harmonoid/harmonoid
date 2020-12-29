import 'package:flutter/material.dart';

import 'package:harmonoid/constants/constants.dart';
import 'package:harmonoid/constants/constantsupdater.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/scripts/states.dart';


class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  SettingsTile({Key key, @required this.title, @required this.subtitle, @required this.child}) : super(key: key);

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
                  height: 2.0,
                ),
                Text(
                  this.subtitle,
                  style: Theme.of(context).textTheme.headline4,
                ),
                Divider(
                  color: Colors.transparent,
                  height: 16.0,
                ),
                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: 1.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
          this.child ?? Container(),
          Divider(
            color: Colors.transparent,
            height: 8.0,
          ),
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
  AppTheme _appTheme;
  LanguageRegion _languageRegion;

  Future<void> _setAppTheme(AppTheme value) async {
    await configuration.setConfiguration(ConfigurationType.appTheme, value.index);
    States.refreshAppTheme(value);
    this.setState(() => this._appTheme = value);
  }

  Future<void> _setLanguageRegion(LanguageRegion value) async {
    await configuration.setConfiguration(ConfigurationType.languageRegion, value.index);
    this.setState(() => this._languageRegion = value);
  }

  Future<void> _refresh() async {
    this._appTheme = AppTheme.values[await configuration.getConfiguration(ConfigurationType.appTheme)];
    this._languageRegion = LanguageRegion.values[await configuration.getConfiguration(ConfigurationType.languageRegion)];
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
          splashRadius: Theme.of(context).iconTheme.size - 4,
          onPressed: () {},
          tooltip: Constants.STRING_MENU,
        ),
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SettingsTile(
            title: Constants.STRING_SETTING_THEME_TITLE,
            subtitle: Constants.STRING_SETTING_THEME_SUBTITLE,
            child: Column(
              children: [
                RadioListTile(
                  value: AppTheme.system,
                  title: Text(AppTheme.system.data),
                  groupValue: this._appTheme,
                  onChanged: (Object object) => this._setAppTheme(object),
                ),
                RadioListTile(
                  value: AppTheme.light,
                  title: Text(AppTheme.light.data),
                  groupValue: this._appTheme,
                  onChanged: (Object object) => this._setAppTheme(object),
                ),
                RadioListTile(
                  value: AppTheme.dark,
                  title: Text(AppTheme.dark.data),
                  groupValue: this._appTheme,
                  onChanged: (Object object) => this._setAppTheme(object),
                ),
              ],
            )
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
              ],
            )
          ),
          SettingsTile(
            title: Constants.STRING_SETTING_ACCENT_COLOR_TITLE,
            subtitle: Constants.STRING_SETTING_ACCENT_COLOR_SUBTITLE,
            child: null
          ),
          SettingsTile(
            title: Constants.STRING_SETTING_SERVER_CHANGE_TITLE,
            subtitle: Constants.STRING_SETTING_SERVER_CHANGE_SUBTITLE,
            child: null
          ),
          SettingsTile(
            title: Constants.STRING_SETTING_APP_VERSION_TITLE,
            subtitle: Constants.STRING_SETTING_APP_VERSION_SUBTITLE,
            child: null
          ),
          SettingsTile(
            title: Constants.STRING_ABOUT_TITLE,
            subtitle: Constants.STRING_ABOUT_SUBTITLE,
            child: null
          ),
        ],
      ),
    );
  }
}
