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
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

const kContributors = [
  [
    'https://github.com/alexmercerind',
    'https://avatars.githubusercontent.com/u/28951144?s=80&v=4',
    'Hitesh Kumar Saini',
    'Lead developer. Deals with playback & parsing of music. Writes UI, state management & lifecycle code. Maintains core C++ plugins.',
  ],
  [
    'https://github.com/raitonoberu',
    'https://avatars.githubusercontent.com/u/64320078?s=80&v=4',
    'Denis',
    'Windows installer & bug fixes. Russian translation.',
  ],
  [
    'https://github.com/bdlukaa',
    'https://avatars.githubusercontent.com/u/45696119?s=80&v=4',
    'Bruno D\'Luka',
    'User interface & design. Portuguese translation.',
  ],
  [
    'https://github.com/mytja',
    'https://avatars.githubusercontent.com/u/52399966?s=80&v=4',
    'mytja',
    'WinGet package. Bug reports. CI. Slovenian translation.',
  ],
  [
    'https://github.com/prateekmedia',
    'https://avatars.githubusercontent.com/u/41370460?s=80&v=4',
    'Prateek SU',
    'AppImage & Flatpak installers. Bug reports. Hindi translation.',
  ],
  [
    'https://github.com/gaetan1903',
    'https://avatars.githubusercontent.com/u/43904633?s=80&v=4',
    'Gaetan Jonathan BAKARY',
    'Linux related bug-fixes. French translation.',
  ],
  [
    'https://github.com/RedyAu',
    'https://avatars.githubusercontent.com/u/12989935?s=80&v=4',
    'Fodor Benedek',
    'Hungarian translation.',
  ],
  [
    'https://github.com/arafatamim',
    'https://avatars.githubusercontent.com/u/31634638?s=80&v=4',
    'Tamim Arafat',
    'User interface & design. Bug reports.',
  ],
  [
    'mailto:max.haureus@gmail.com',
    'https://avatars.githubusercontent.com/u/10137?s=80&v=4',
    'Max Haureus',
    'Swedish translation.',
  ],
  [
    'https://github.com/kebabinjeneus',
    'https://avatars.githubusercontent.com/u/16196003?s=80&v=4',
    'Lars',
    'Dutch translation.',
  ],
  [
    'https://github.com/MickLesk',
    'https://avatars.githubusercontent.com/u/47820557?s=80&v=4',
    'CanbiZ',
    'German translation.',
  ],
  [
    'https://github.com/ilopX',
    'https://avatars.githubusercontent.com/u/8049534?s=80&v=4',
    'ilopX',
    'Testing & bug reports.',
  ],
  [
    'https://github.com/7HAVEN',
    'https://avatars.githubusercontent.com/u/56985621?s=80&v=4',
    'Ankit Rana',
    'Testing & bug reports.',
  ],
  [
    'https://github.com/LeonHoog',
    'https://avatars.githubusercontent.com/u/75587960?s=80&v=4',
    'Leon',
    'User interface fixes, app persistence improvements. Dutch translation.'
  ],
  [
    'https://github.com/stonega',
    'https://avatars.githubusercontent.com/u/2262007?s=80&v=4',
    'stonegate',
    'Mandarin translation & bug reports.'
  ],
  [
    'https://github.com/HiSubway',
    'https://avatars.githubusercontent.com/u/66313777?s=80&v=4',
    'さぶうぇい',
    'Japanese translation.'
  ]
];

class AboutSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Language.instance.ABOUT_TITLE,
      subtitle: Language.instance.ABOUT_SUBTITLE,
      child: Container(),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AboutPage(),
              ),
            );
          },
          child: Text(
            Language.instance.KNOW_MORE,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        )
      ],
    );
  }
}

class AboutPage extends StatefulWidget {
  const AboutPage({
    Key? key,
  }) : super(key: key);
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  dynamic repository;

  @override
  void initState() {
    super.initState();
    http
        .get(Uri.parse('https://api.github.com/repos/harmonoid/harmonoid'))
        .then(
      (response) {
        setState(() => repository = convert.jsonDecode(response.body));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          DesktopAppBar(
            title: Language.instance.ABOUT_TITLE,
          ),
          Container(
            margin: EdgeInsets.only(
              top: kDesktopTitleBarHeight + kDesktopAppBarHeight,
            ),
            child: Container(
              child: CustomListView(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: 4.0,
                      bottom: 4.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 16.0, right: 16.0),
                                child: CircleAvatar(
                                  radius: 36.0,
                                  backgroundColor: Theme.of(context).cardColor,
                                  backgroundImage: (repository == null ||
                                          this
                                              .repository!
                                              .containsKey('message'))
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline1
                                        ?.copyWith(fontSize: 24.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Text(
                            (repository == null ||
                                    repository!.containsKey('message'))
                                ? 'GNU General Public License v3.0'
                                : repository!['license']['name'],
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.black.withOpacity(0.8),
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        if (repository != null &&
                            !repository!.containsKey('message'))
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(children: [
                              Chip(
                                avatar: Icon(FluentIcons.star_20_regular,
                                    size: 20.0, color: Colors.white),
                                label: Text(
                                  '${repository!['stargazers_count']} stars',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              SizedBox(width: 8.0),
                              Chip(
                                avatar: Icon(FluentIcons.branch_fork_20_regular,
                                    size: 20.0, color: Colors.white),
                                label: Text(
                                  '${repository!['forks']} forks',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                            ]),
                          ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 8.0,
                            top: 2.0,
                          ),
                          child: (repository == null ||
                                  repository!.containsKey('message'))
                              ? Text(
                                  '🎵 Elegant music app to play & manage music library.',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(1.0)
                                        : Colors.black.withOpacity(0.8),
                                    fontSize: 14.0,
                                  ),
                                )
                              : Text(
                                  repository!['description'],
                                  style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.black.withOpacity(0.8),
                                    fontSize: 14.0,
                                  ),
                                ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Developer',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2
                                    ?.copyWith(fontSize: 20.0),
                              ),
                              Divider(color: Colors.transparent, height: 4.0),
                              Text(
                                'Maintainer & creator of the project.',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        ListTile(
                          onTap: () => launch(
                            'https://github.com/alexmercerind',
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://avatars.githubusercontent.com/u/28951144?s=80&v=4',
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          title: Text(
                            'Hitesh Kumar Saini',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          subtitle: Text(
                            'Deals with playback & parsing of music. Writes UI, state management & lifecycle code. Maintains core C++ plugins.',
                            style: Theme.of(context).textTheme.headline3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            FluentIcons.link_24_regular,
                            size: 22.0,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 8.0,
                          ),
                          child: ButtonBar(
                            alignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              MaterialButton(
                                onPressed: () => launch(
                                  'https://github.com/alexmercerind',
                                ),
                                child: Text(
                                  'GITHUB',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              ),
                              MaterialButton(
                                onPressed: () => launch(
                                  'https://twitter.com/alexmercerind',
                                ),
                                child: Text(
                                  'TWITTER',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              ),
                              MaterialButton(
                                onPressed: () => launch(
                                  'https://www.linkedin.com/in/hitesh-kumar-saini',
                                ),
                                child: Text(
                                  'LINKEDIN',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SettingsTile(
                    title: 'Contributors',
                    subtitle:
                        'People who are currently working or worked on this project in the past.',
                    child: Column(
                      children: kContributors
                          .map(
                            (contributor) => ListTile(
                              onTap: () => launch(
                                contributor[0],
                              ),
                              leading: CircleAvatar(
                                backgroundImage: contributor[1].isNotEmpty
                                    ? NetworkImage(
                                        contributor[1],
                                      )
                                    : null,
                                child: contributor[1].isEmpty
                                    ? Icon(
                                        FluentIcons.person_48_regular,
                                      )
                                    : null,
                                backgroundColor: Colors.transparent,
                              ),
                              title: Text(
                                contributor[2],
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              subtitle: Text(
                                contributor[3],
                                style: Theme.of(context).textTheme.headline3,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Icon(
                                FluentIcons.link_24_regular,
                                size: 22.0,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
