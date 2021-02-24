import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:animations/animations.dart';

import 'package:harmonoid/widgets.dart';
import 'package:harmonoid/screens/settings/settings.dart';
import 'package:harmonoid/language/constants.dart';
import 'package:harmonoid/screens/settings/about/thirdpartypage.dart';
import 'package:harmonoid/language/language.dart';


class AboutPage extends StatelessWidget {
  const AboutPage({
    Key key,
    @required this.repository,
  }) : super(key: key);

  final Map<String, dynamic> repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: EdgeInsets.symmetric(vertical: 8.0),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 4.0,
            ),
            elevation: 2.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/about-header.jpg',
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
                          backgroundImage: this.repository == null
                              ? null
                              : NetworkImage(
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
                    this.repository == null
                        ? 'GNU General Public License v3.0'
                        : this.repository['license']['name'],
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                if (this.repository != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(children: [
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
                      SizedBox(width: 8.0),
                      Chip(
                        avatar: Icon(Icons.restaurant, color: Colors.white),
                        label: Text(
                          '${this.repository['forks']} forks',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Theme.of(context).accentColor,
                      ),
                    ]),
                  ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                  child: this.repository == null
                      ? Text(
                          '🎵 The music app you always dreamt.',
                          style: Theme.of(context).textTheme.headline5,
                        )
                      : Text(
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
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () => launcher.launch(
                        'https://github.com/alexmercerind/harmonoid/blob/master/README.md',
                      ),
                      child: Text(
                        Constants.STRING_SETTING_STAR_GITHUB,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SettingsTile(
            title: 'Collaborators',
            subtitle:
                'Thanks to these guys, irrespective of order, for contribution to the server of app & support.',
            child: Column(
              children: [
                ListTile(
                  onTap: () =>
                      launcher.launch('https://github.com/raitonoberu'),
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
              children: List.generate(LanguageRegion.values.length, (index) {
                final region = LanguageRegion.values[index];
                return ListTile(
                  onTap: () => launcher.launch(region.githubUrl),
                  trailing: SizedBox(
                    height: 15,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Flag(
                        region.countryCode,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(region.translator),
                  subtitle: Text(region.name),
                );
              }),
            ),
          ),
          OpenContainer(
            transitionDuration: Duration(milliseconds: 400),
            closedColor: Colors.transparent,
            openColor: Colors.transparent,
            closedElevation: 0.0,
            openElevation: 0.0,
            closedBuilder: (_, open) => ClosedTile(
              open: open,
              title: 'Third Party Credits',
              subtitle: 'Thanks for your indirect contribution.',
            ),
            openBuilder: (context, _) => ThirdPartyPage(),
          ),
        ],
      ),
    );
  }
}
