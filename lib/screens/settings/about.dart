import 'dart:convert' as convert;
import 'package:harmonoid/language/language.dart';
import 'package:harmonoid/screens/settings/settings.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/language/constants.dart';

class AboutSetting extends StatefulWidget {
  AboutSetting({Key key}) : super(key: key);

  @override
  AboutState createState() => AboutState();
}

class AboutState extends State<AboutSetting> {
  Map<String, dynamic> repository;
  bool _init = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (this._init) {
      try {
        http.Response response = await http.get(
          Uri.https('api.github.com', '/repos/alexmercerind/harmonoid'),
        );
        this.repository = convert.jsonDecode(response.body);
        this.setState(() {});
      }
      catch (exception) {}
      this._init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 400),
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      closedElevation: 0.0,
      openElevation: 0.0,
      closedBuilder: (BuildContext context, _) => Card(
        margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 4.0),
        color: Theme.of(context).cardColor,
        elevation: 2.0,
        child: ListTile(
          title: Text(Constants.STRING_ABOUT_TITLE),
          subtitle: Text(Constants.STRING_ABOUT_SUBTITLE),
        )
      ),
      openBuilder: (BuildContext context, __) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            iconSize: Theme.of(context).iconTheme.size,
            splashRadius: Theme.of(context).iconTheme.size - 8,
            onPressed: Navigator.of(context).pop,
          ),
          title: Text(Constants.STRING_ABOUT_TITLE),
        ),
        body: ListView(
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              elevation: 2.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/about/header.jpg',
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    height: 192,
                    width: MediaQuery.of(context).size.width - 16.0,
                  ),
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: Theme.of(context).dividerColor,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).cardColor,
                            backgroundImage: this.repository == null ? null: NetworkImage(
                              this.repository['owner']['avatar_url'],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Harmonoid',
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            Text(
                              'alexmercerind',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text(
                      this.repository == null ? 'GNU General Public License v3.0': this.repository['license']['name'],
                      style: Theme.of(context).textTheme.headline5,
                    )
                  ),
                  this.repository == null ? Container(): Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Row(
                      children: [
                        Chip(
                          avatar: Icon(Icons.star_border, color: Colors.white),
                          label: Text(
                            '${this.repository['stargazers_count']} stars',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                        Container(
                          width: 8.0,
                        ),
                        Chip(
                          avatar: Icon(Icons.restaurant, color: Colors.white),
                          label: Text(
                            '${this.repository['forks']} forks',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                    child: this.repository == null ? Text(
                      '🎵 The music app you always dreamt.',
                      style: Theme.of(context).textTheme.headline5,
                    ): Text(
                      this.repository['description'],
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
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
                    children: [
                      MaterialButton(
                        onPressed: () => launcher.launch(
                          'https://discord.com/invite/ZG7Pj9SREG',
                        ),
                        child: Text(
                          Constants.STRING_DISCORD,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () => launcher.launch(
                          'https://github.com/alexmercerind/harmonoid/blob/master/README.md',
                        ),
                        child: Text(
                          Constants.STRING_SETTING_STAR_GITHUB,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SettingsTile(
              title: 'Collaborators',
              subtitle: 'Thanks to these guys, irrespective of order, for contribution to the server of app & support.',
              child: Column(
                children: [
                  ListTile(
                    onTap: () => launcher.launch('https://github.com/raitonoberu'),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://avatars.githubusercontent.com/u/64320078',
                      ),
                    ),
                    title: Text('raitonoberu'),
                  ),
                  ListTile(
                    onTap: () => launcher.launch('https://github.com/mytja'),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://avatars.githubusercontent.com/u/52399966',
                      ),
                    ),
                    title: Text('mytja'),
                  ),
                ],
              ),
            ),
            SettingsTile(
              title: Constants.STRING_SETTING_LANGUAGE_PROVIDERS_TITLE,
              subtitle: Constants.STRING_SETTING_LANGUAGE_PROVIDERS_SUBTITLE,
              child: Column(
                children: [
                  ListTile(
                    onTap: () => launcher.launch('https://github.com/raitonoberu'),
                    leading: CircleAvatar(
                      child: Text('🇷🇺'),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    title: Text('raitonoberu'),
                    subtitle: Text(LanguageRegion.ruRu.data[0]),
                  ),
                  ListTile(
                    onTap: () => launcher.launch('https://github.com/mytja'),
                    leading: CircleAvatar(
                      child: Text('🇸🇮'),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    title: Text('mytja'),
                    subtitle: Text(LanguageRegion.slSi.data[0]),
                  ),
                  ListTile(
                    onTap: () => launcher.launch('https://github.com/bdlukaa'),
                    leading: CircleAvatar(
                      child: Text('🇧🇷'),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    title: Text('bdlukaa'),
                    subtitle: Text(LanguageRegion.ptBr.data[0]),
                  ),
                  ListTile(
                    onTap: () => launcher.launch('https://github.com/alexmercerind'),
                    leading: CircleAvatar(
                      child: Text('🇮🇳'),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    title: Text('alexmercerind'),
                    subtitle: Text(LanguageRegion.hiIn.data[0]),
                  ),
                  ListTile(
                    onTap: () => launcher.launch('https://github.com/MickLesk'),
                    leading: CircleAvatar(
                      child: Text('🇩🇪'),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    title: Text('MickLesk'),
                    subtitle: Text(LanguageRegion.deDe.data[0]),
                  ),
                  ListTile(
                    onTap: () => launcher.launch('https://github.com/kebabinjeneus'),
                    leading: CircleAvatar(
                      child: Text('🇳🇱'),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    title: Text('kebabinjeneus'),
                    subtitle: Text(LanguageRegion.nlNl.data[0]),
                  ),
                ],
              ),
            ),
            OpenContainer(
              transitionDuration: Duration(milliseconds: 400),
              closedColor: Colors.transparent,
              openColor: Colors.transparent,
              closedElevation: 0.0,
              openElevation: 0.0,
              closedBuilder: (BuildContext context, _) => Card(
                margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 4.0),
                color: Theme.of(context).cardColor,
                elevation: 2.0,
                child: ListTile(
                  title: Text('Third Party Credits'),
                  subtitle: Text('Thanks for your indirect contribution.'),
                )
              ),
              openBuilder: (BuildContext context, __) => Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.close),
                    iconSize: Theme.of(context).iconTheme.size,
                    splashRadius: Theme.of(context).iconTheme.size - 8,
                    onPressed: Navigator.of(context).pop,
                  ),
                  title: Text('Third Party Credits'),
                ),
                body: ListView(
                  children: [
                    SettingsTile(
                      title: 'Images',
                      subtitle: 'Pictures & camera work credits. Thanks to following people for providing pleasant images.',
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () => launcher.launch('https://unsplash.com/photos/7x4ngEfelyE'),
                            leading: CircleAvatar(
                              backgroundImage: AssetImage('assets/images/about/credits/albums.jpg'),
                            ),
                            title: Text('Oleg Ivanov'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://unsplash.com/photos/HRyjETL87Gg'),
                            leading: CircleAvatar(
                              backgroundImage: AssetImage('assets/images/about/credits/tracks.jpg'),
                            ),
                            title: Text('Mink Mingle'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://unsplash.com/photos/hgO1wFPXl3I'),
                            leading: CircleAvatar(
                              backgroundImage: AssetImage('assets/images/about/credits/artists.jpg'),
                            ),
                            title: Text('Austin Neill'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://unsplash.com/photos/52jRtc2S_VE'),
                            leading: CircleAvatar(
                              backgroundImage: AssetImage('assets/images/about/credits/exception.jpg'),
                            ),
                            title: Text('Sarah Kilian'),
                          ),
                        ],
                      ),
                    ),
                    SettingsTile(
                      title: 'Album Arts',
                      subtitle: 'The album arts showed in various screenshots of the project belong to NoCopyrightSounds.',
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () => launcher.launch('https://www.youtube.com/watch?v=y07YAT1qdOQ'),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/CsLz1eLJ7qBu9Ad-wO8Nypz6RUAvATsW0MUTxZI2giSW1TnFs5S6HWtutXr50T14oNmTn5Ka1FcYsno=w60-h60-l90-rj'),
                            ),
                            title: Text('Sunburst'),
                            subtitle: Text('Tobu'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://www.youtube.com/watch?v=BmrSzhw3rGE'),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/npz6DWheubb-oT57BWT9RGMFnq-dICZW-Y6fP9zsqr6hYZVdZ7lquE1jXcq-TDnWjOedNMiUFIuSttl7jQ=w60-h60-l90-rj'),
                            ),
                            title: Text('Hope'),
                            subtitle: Text('Tobu'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://www.youtube.com/watch?v=Z1xRUgnT0-0'),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/2je-mCKeSSzqvtlvtBT3NjkZ8jSoVwnk-CCAsFYpZHz1TgkDk-6-cDNvyNz9miLHZWN2m88n0_nEf_Mu=w60-h60-l90-rj'),
                            ),
                            title: Text('Safe And Sound'),
                            subtitle: Text('DEAF KEV'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://www.youtube.com/watch?v=m3YZ0l0l1Q8'),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/-5xRRnRbxiaPKOTOLI8Fb7JcNkh1aGMMRA6Do86bYgGXKG5AZvRTcXhSMlVaVKN5Wv6RrKrRaCl17TIa=w60-h60-l90-rj'),
                            ),
                            title: Text('NCS: Alpha'),
                            subtitle: Text('Various Artists'),
                          ),
                        ],
                      ),
                      actions: [
                        MaterialButton(
                          onPressed: () => launcher.launch(
                            'https://www.youtube.com/user/NoCopyrightSounds',
                          ),
                          child: Text(
                            'YOUTUBE',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                        MaterialButton(
                          onPressed: () => launcher.launch(
                            'https://ncs.io/',
                          ),
                          child: Text(
                            'NOCOPYRIGHTSOUNDS',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SettingsTile(
                      title: 'Third Party Licenses',
                      subtitle: 'Open source libraries used. Following projects made this project possible.',
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () => launcher.launch('https://github.com/florent37/Flutter-AssetsAudioPlayer/blob/master/LICENSE'),
                            title: Text('assets_audio_player'),
                            subtitle: Text('florent37'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://github.com/alexmercerind/media_metadata_retriever/blob/master/LICENSE'),
                            title: Text('media_metadata_retriever'),
                            subtitle: Text('alexmercerind'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://github.com/florent37/Flutter-AssetsAudioPlayer/blob/master/LICENSE'),
                            title: Text('assets_audio_player'),
                            subtitle: Text('florent37'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://github.com/MaikuB/flutter_local_notifications/blob/master/LICENSE'),
                            title: Text('flutter_local_notifications'),
                            subtitle: Text('MaikuB'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://github.com/Baseflow/permission_handler/blob/master/LICENSE'),
                            title: Text('permission_handler'),
                            subtitle: Text('Baseflow'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://github.com/flutter/packages/blob/master/packages/animations/LICENSE'),
                            title: Text('animations'),
                            subtitle: Text('flutter'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://github.com/dart-lang/http/blob/master/LICENSE'),
                            title: Text('http'),
                            subtitle: Text('dart-lang'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://github.com/dart-lang/path/blob/master/LICENSE'),
                            title: Text('path'),
                            subtitle: Text('dart-lang'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://github.com/flutter/plugins/blob/master/packages/path_provider/path_provider/LICENSE'),
                            title: Text('path_provider'),
                            subtitle: Text('flutter'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://github.com/flutter/plugins/blob/master/packages/share/LICENSE'),
                            title: Text('share'),
                            subtitle: Text('flutter'),
                          ),
                          ListTile(
                            onTap: () => launcher.launch('https://github.com/flutter/plugins/blob/master/packages/url_launcher/url_launcher/LICENSE'),
                            title: Text('url_launcher'),
                            subtitle: Text('flutter'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}