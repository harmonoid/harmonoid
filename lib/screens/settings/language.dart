import 'package:flutter/material.dart';

import 'package:harmonoid/screens/settings/settings.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/language/language.dart';
import 'package:harmonoid/language/constants.dart';


class LanguageSetting extends StatefulWidget {
  LanguageSetting({Key key}) : super(key: key);

  @override
  LanguageState createState() => LanguageState();
}

class LanguageState extends State<LanguageSetting> {
  LanguageRegion languageRegion;

  @override
  void initState() { 
    super.initState();
    this.languageRegion = configuration.languageRegion;
  }

  Future<void> setLanguageRegion(LanguageRegion value) async {
    await configuration.save(languageRegion: value);
    this.setState(() => this.languageRegion = value);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Constants.STRING_SETTING_LANGUAGE_TITLE,
      subtitle: Constants.STRING_SETTING_LANGUAGE_SUBTITLE,
      child: Column(
        children: [
          RadioListTile(
            value: LanguageRegion.enUs,
            title: Text(LanguageRegion.enUs.data[0]),
            subtitle: Text(LanguageRegion.enUs.data[1]),
            groupValue: this.languageRegion,
            onChanged: (Object object) => this.setLanguageRegion(object),
          ),
          RadioListTile(
            value: LanguageRegion.ruRu,
            title: Text(LanguageRegion.ruRu.data[0]),
            subtitle: Text(LanguageRegion.ruRu.data[1]),
            groupValue: this.languageRegion,
            onChanged: (Object object) => this.setLanguageRegion(object),
          ),
          RadioListTile(
            value: LanguageRegion.slSi,
            title: Text(LanguageRegion.slSi.data[0]),
            subtitle: Text(LanguageRegion.slSi.data[1]),
            groupValue: this.languageRegion,
            onChanged: (Object object) => this.setLanguageRegion(object),
          ),
          RadioListTile(
            value: LanguageRegion.ptBr,
            title: Text(LanguageRegion.ptBr.data[0]),
            subtitle: Text(LanguageRegion.ptBr.data[1]),
            groupValue: this.languageRegion,
            onChanged: (Object object) => this.setLanguageRegion(object),
          ),
          RadioListTile(
            value: LanguageRegion.hiIn,
            title: Text(LanguageRegion.hiIn.data[0]),
            subtitle: Text(LanguageRegion.hiIn.data[1]),
            groupValue: this.languageRegion,
            onChanged: (Object object) => this.setLanguageRegion(object),
          ),
          RadioListTile(
            value: LanguageRegion.deDe,
            title: Text(LanguageRegion.deDe.data[0]),
            subtitle: Text(LanguageRegion.deDe.data[1]),
            groupValue: this.languageRegion,
            onChanged: (Object object) => this.setLanguageRegion(object),
          ),
          RadioListTile(
            value: LanguageRegion.nlNl,
            title: Text(LanguageRegion.nlNl.data[0]),
            subtitle: Text(LanguageRegion.nlNl.data[1]),
            groupValue: this.languageRegion,
            onChanged: (Object object) => this.setLanguageRegion(object),
          ),
        ],
      )
    );
  }
}
