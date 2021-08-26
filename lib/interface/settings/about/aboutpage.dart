import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/interface/settings/settings.dart';
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
      body: Column(
        children: [
          Container(
            height: 56.0,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NavigatorPopButton(),
                SizedBox(
                  width: 24.0,
                ),
                Text(
                  language!.STRING_ABOUT_TITLE,
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
            child: ListView(
              children: [
                SizedBox(
                  height: 4.0,
                ),
                Container(
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                    top: 4.0,
                    bottom: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/about-header.jpg',
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.bottomCenter,
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
                                backgroundImage: (this.repository == null ||
                                        this.repository!.containsKey('message'))
                                    ? null
                                    : NetworkImage(
                                        'https://avatars.githubusercontent.com/u/75374037?s=200&v=4',
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
                          (this.repository == null ||
                                  this.repository!.containsKey('message'))
                              ? 'GNU General Public License v3.0'
                              : this.repository!['license']['name'],
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.black.withOpacity(0.8),
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      if (this.repository != null &&
                          !this.repository!.containsKey('message'))
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(children: [
                            Chip(
                              avatar: Icon(FluentIcons.star_20_regular,
                                  size: 20.0, color: Colors.white),
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
                              avatar: Icon(FluentIcons.branch_fork_20_regular,
                                  size: 20.0, color: Colors.white),
                              label: Text(
                                '${this.repository!['forks']} forks',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Theme.of(context).accentColor,
                            ),
                          ]),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 8.0),
                        child: (this.repository == null ||
                                this.repository!.containsKey('message'))
                            ? Text(
                                '🎵 The music app you always dreamt.',
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.black.withOpacity(0.8),
                                  fontSize: 14.0,
                                ),
                              )
                            : Text(
                                this.repository!['description'],
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.black.withOpacity(0.8),
                                  fontSize: 14.0,
                                ),
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
                              'https://github.com/alexmercerind/harmonoid/blob/master/README.md',
                            ),
                            child: Text(
                              language!.STRING_SETTING_STAR_GITHUB,
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Lead developer. Deals with playback & metadata parsing of music files. Maintains core C++ plugins for project. Writes UI code.',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Deals with music streaming & discovery inside the application. Fixes many crucial bugs inside the apps.',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Does everything that everyone else cannot. Deals with networking and playback.',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Deals with UI development, app lifecycle & state management. Targets Android.',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
                  subtitle:
                      language!.STRING_SETTING_LANGUAGE_PROVIDERS_SUBTITLE,
                  child: Column(
                    children:
                        List.generate(LanguageRegion.values.length, (index) {
                      final region = LanguageRegion.values[index]!;
                      return ListTile(
                        onTap: () => launch(region.github),
                        title: Text(
                          region.translator,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          region.name,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.black.withOpacity(0.8),
                            fontSize: 14.0,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // TODO: Update third party credits screen design.
                // OpenContainer(
                //   transitionDuration: Duration(milliseconds: 400),
                //   closedColor: Colors.transparent,
                //   openColor: Colors.transparent,
                //   closedElevation: 0.0,
                //   openElevation: 0.0,
                //   closedBuilder: (_, open) => ClosedTile(
                //     open: open,
                //     title: 'Third Party Credits',
                //     subtitle: 'Thanks for your indirect contribution.',
                //   ),
                //   openBuilder: (context, _) => ThirdPartyPage(),
                // ),
                SizedBox(
                  height: 4.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
