/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:convert' as convert;
import 'package:harmonoid/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';

const kContributors = [
  [
    'https://github.com/alexmercerind',
    'https://avatars.githubusercontent.com/u/28951144?s=80&v=4',
    'Hitesh Kumar Saini',
    'Lead developer. Deals with playback & indexing of media. Writes UI, state management & lifecycle code. Manages native plugins.',
  ],
  [
    'https://www.github.com/YehudaKremer',
    'https://avatars.githubusercontent.com/u/946652?s=80&v=4',
    'Yehuda Kremer',
    'UI & animation improvements. Application persistence & other important features. MSIX package for the store publishing.',
  ],
  [
    'https://github.com/raitonoberu',
    'https://avatars.githubusercontent.com/u/64320078?s=80&v=4',
    'Denis',
    'Major bug-fixes & Windows installer. Russian translation.',
  ],
  [
    'https://github.com/mytja',
    'https://avatars.githubusercontent.com/u/52399966?s=80&v=4',
    'mytja',
    'WinGet package. Backward Windows compatiblity checks. Bug reports. CI. Slovenian translation.',
  ],
  [
    'https://github.com/bdlukaa',
    'https://avatars.githubusercontent.com/u/45696119?s=80&v=4',
    'Bruno D\'Luka',
    'User interface & design. Portuguese translation.',
  ],
  [
    'https://github.com/prateekmedia',
    'https://avatars.githubusercontent.com/u/41370460?s=80&v=4',
    'Prateek Sunal',
    'AppImage & Flatpak installers. Bug reports. Hindi translation.',
  ],
  [
    'https://github.com/gaetan1903',
    'https://avatars.githubusercontent.com/u/43904633?s=80&v=4',
    'Gaetan Jonathan BAKARY',
    'Linux related bug-fixes. French translation.',
  ],
  [
    'https://github.com/arafatamim',
    'https://avatars.githubusercontent.com/u/31634638?s=80&v=4',
    'Tamim Arafat',
    'User interface & design. Bug reports.',
  ],
  [
    'https://github.com/LeonHoog',
    'https://avatars.githubusercontent.com/u/75587960?s=80&v=4',
    'Leon',
    'User interface fixes, app persistence improvements. Dutch translation.'
  ],
];

const kArtists = [
  [
    'https://www.instagram.com/shinybluebelll',
    'https://drive.google.com/uc?export=view&id=1eI-dHiALVQM123_HnQIcYe9HtbX0uS_W',
    'Bluebell',
    'Artwork & iconography.'
  ],
];

const kTesters = [
  [
    'https://github.com/Sombian',
    'https://avatars.githubusercontent.com/u/23397550?s=80&v=4',
    'Sombian',
    'Testing & bug reports.'
  ],
  [
    'https://github.com/SleepDaemon',
    'https://avatars.githubusercontent.com/u/88533953?s=80&v=4',
    'SleepDaemon',
    'Testing & bug reports.',
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
];

const kTranslators = [
  [
    'https://github.com/RedyAu',
    'https://avatars.githubusercontent.com/u/12989935?s=80&v=4',
    'Fodor Benedek',
    'Hungarian translation.',
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
  ],
  [
    'https://github.com/TuranBerlin',
    'https://avatars.githubusercontent.com/u/66092540?s=80&v=4',
    'Yusuf Kamil Turan',
    'Turkish translation.'
  ],
  [
    'https://github.com/yulog',
    'https://avatars.githubusercontent.com/u/29723448?s=80&v=4',
    'yulog',
    'Update Japanese translation.'
  ],
  [
    'https://github.com/ejacquemoud',
    'https://avatars.githubusercontent.com/u/25613162?s=80&v=4',
    'ejacquemoud',
    'Update French translation.'
  ],
  [
    'https://github.com/maisondasilva',
    'https://avatars.githubusercontent.com/u/11423362?s=80&v=4',
    'Maison',
    'Update Portuguese translation.'
  ],
  [
    'https://github.com/mi875',
    'https://avatars.githubusercontent.com/u/64814866?s=80&v=4',
    'mi875',
    'Update Japanese translation.'
  ],
  [
    'https://github.com/Lucifer25x',
    'https://avatars.githubusercontent.com/u/74368520?s=80&v=4',
    'Lucifer25x',
    'Add Azerbaijani & update Turkish translation.'
  ],
  [
    'https://github.com/0xjohn',
    'https://avatars.githubusercontent.com/u/50566073?s=80&v=4',
    '0xjohn',
    'Add Persian translation.'
  ],
  [
    'https://github.com/Feelogil',
    'https://avatars.githubusercontent.com/u/61083015?s=80&v=4',
    'Feelogil',
    'Update Russian translation.'
  ],
];

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
    return isDesktop
        ? Scaffold(
            body: Stack(
              children: [
                DesktopAppBar(
                  title: 'About',
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: desktopTitleBarHeight + kDesktopAppBarHeight,
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
                                padding:
                                    EdgeInsets.only(top: 16.0, bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 16.0, right: 16.0),
                                      child: CircleAvatar(
                                        radius: 36.0,
                                        backgroundColor:
                                            Theme.of(context).cardColor,
                                        backgroundImage: AssetImage(
                                            'assets/images/project.png'),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    SizedBox(width: 8.0),
                                    Chip(
                                      avatar: Icon(
                                          FluentIcons.branch_fork_20_regular,
                                          size: 20.0,
                                          color: Colors.white),
                                      label: Text(
                                        '${repository!['forks']} forks',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ]),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 24.0),
                          child: Text(
                            'Developers',
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                ?.copyWith(fontSize: 20.0),
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        ...kContributors
                            .map(
                              (contributor) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: ListTile(
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
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                  subtitle: Text(
                                    contributor[3],
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Icon(
                                    Icons.link,
                                    size: 22.0,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        SizedBox(
                          height: 12.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 24.0),
                          child: Text(
                            'Artists',
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                ?.copyWith(fontSize: 20.0),
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        ...kArtists
                            .map(
                              (contributor) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: ListTile(
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
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                  subtitle: Text(
                                    contributor[3],
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Icon(
                                    Icons.link,
                                    size: 22.0,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        SizedBox(
                          height: 12.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 24.0),
                          child: Text(
                            'Testers',
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                ?.copyWith(fontSize: 20.0),
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        ...kTesters
                            .map(
                              (contributor) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: ListTile(
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
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                  subtitle: Text(
                                    contributor[3],
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Icon(
                                    Icons.link,
                                    size: 22.0,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        SizedBox(
                          height: 12.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 24.0),
                          child: Text(
                            'Translators',
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                ?.copyWith(fontSize: 20.0),
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        ...kTranslators
                            .map(
                              (contributor) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: ListTile(
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
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                  subtitle: Text(
                                    contributor[3],
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Icon(
                                    Icons.link,
                                    size: 22.0,
                                  ),
                                ),
                              ),
                            )
                            .toList()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(
                'About',
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            body: NowPlayingBarScrollHideNotifier(
              child: CustomListView(
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    elevation: 4.0,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/project.png'),
                                radius: 28.0,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Harmonoid',
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                  ),
                                  Text(
                                    '@alexmercerind',
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16.0),
                          ],
                        ),
                        const Divider(height: 1.0, thickness: 1.0),
                        CorrectedListTile(
                          height: 72.0,
                          iconData: Icons.info,
                          title: 'Installed version',
                          subtitle: kVersion,
                        ),
                        CorrectedListTile(
                          height: 72.0,
                          iconData: Icons.code,
                          onTap: () =>
                              launch('https://github.com/harmonoid/harmonoid'),
                          title: 'GitHub',
                          subtitle: 'Visit development repository',
                        ),
                        CorrectedListTile(
                          height: 72.0,
                          iconData: Icons.attach_money,
                          onTap: () =>
                              launch('https://alexmercerind.github.io/donate'),
                          title: 'Donate',
                          subtitle: 'Support the project development',
                        ),
                        CorrectedListTile(
                          height: 72.0,
                          iconData: Icons.translate,
                          onTap: () => launch(
                              'https://github.com/harmonoid/harmonoid/tree/master/assets/translations'),
                          title: 'Translate',
                          subtitle: 'Provide or update existing translations',
                        ),
                        CorrectedListTile(
                          height: 64.0,
                          iconData: Icons.book,
                          onTap: () => launch(
                              'https://github.com/harmonoid/harmonoid/wiki/License'),
                          title: 'License',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
