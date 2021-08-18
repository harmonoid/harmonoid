import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flag/flag.dart';

import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/interface/settings/about/thirdpartypage.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({
    Key? key,
    required this.repository,
  }) : super(key: key);

  final Map<String, dynamic>? repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          iconSize: Theme.of(context).iconTheme.size!,
          splashRadius: Theme.of(context).iconTheme.size! - 8,
          onPressed: Navigator.of(context).pop,
        ),
        title: Text(language!.STRING_ABOUT_TITLE),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              top: 4.0,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 16.0),
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).cardColor,
                          backgroundImage: this.repository == null
                              ? null
                              : NetworkImage(
                                  this.repository!['owner']['avatar_url'],
                                ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Harmonoid',
                            style: Theme.of(context).textTheme.headline1,
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
                        : this.repository!['license']['name'],
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
                          '${this.repository!['stargazers_count']} stars',
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
                          '${this.repository!['forks']} forks',
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
                          this.repository!['description'],
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
                      onPressed: () => launch(
                        'https://discord.com/invite/ZG7Pj9SREG',
                      ),
                      child: Text(
                        language!.STRING_DISCORD,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () => launch(
                        'https://github.com/alexmercerind/harmonoid/blob/master/README.md',
                      ),
                      child: Text(
                        language!.STRING_SETTING_STAR_GITHUB,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SettingsTile(
            title: 'Developers',
            subtitle:
                'People making this project. Adding more people to the list.',
            child: Column(
              children: [
                ListTile(
                  onTap: () => launch('https://github.com/alexmercerind'),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://avatars.githubusercontent.com/u/28951144',
                    ),
                  ),
                  title: Text(
                    'alexmercerind',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Deals with playback & metadata parsing of music files. Maintains core C++ plugins for project. Writes UI code. Targets Windows.',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black.withOpacity(0.8),
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(FluentIcons.link_20_regular),
                ),
                ListTile(
                  onTap: () => launch('https://github.com/raitonoberu'),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://avatars.githubusercontent.com/u/64320078',
                    ),
                  ),
                  title: Text(
                    'raitonoberu',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Deals with music streaming & discovery inside the application. Fixes many crucial bugs inside the apps.',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black.withOpacity(0.8),
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(FluentIcons.link_20_regular),
                ),
                ListTile(
                  onTap: () => launch('https://github.com/mytja'),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://avatars.githubusercontent.com/u/52399966',
                    ),
                  ),
                  title: Text(
                    'mytja',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Does everything that everyone else cannot. Deals with networking and playback.',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black.withOpacity(0.8),
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(FluentIcons.link_20_regular),
                ),
                ListTile(
                  onTap: () => launch('https://github.com/bdlukaa'),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://avatars.githubusercontent.com/u/45696119',
                    ),
                  ),
                  title: Text(
                    'bdlukaa',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Deals with UI development, app lifecycle & state management. Targets Android.',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black.withOpacity(0.8),
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(FluentIcons.link_20_regular),
                ),
              ],
            ),
          ),
          SettingsTile(
            title: language!.STRING_SETTING_LANGUAGE_PROVIDERS_TITLE,
            subtitle: language!.STRING_SETTING_LANGUAGE_PROVIDERS_SUBTITLE,
            child: Column(
              children: List.generate(LanguageRegion.values.length, (index) {
                final region = LanguageRegion.values[index]!;
                return ListTile(
                  onTap: () => launch(region.github),
                  title: Text(
                    region.translator,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    region.name,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black.withOpacity(0.8),
                      fontSize: 14.0,
                    ),
                  ),
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
