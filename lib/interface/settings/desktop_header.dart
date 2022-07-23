/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:convert' as convert;
import 'package:harmonoid/interface/settings/about.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/constants/language.dart';

class Header extends StatefulWidget {
  const Header({Key? key}) : super(key: key);
  HeaderState createState() => HeaderState();
}

class HeaderState extends State<Header> with AutomaticKeepAliveClientMixin {
  Release latestRelease = Release(tagName: kVersion);
  bool isLoadingVersion = true;
  bool fetchVersionFailed = false;

  @override
  void initState() {
    super.initState();
    getAppVersion()
        .catchError((_) => setState(() => fetchVersionFailed = true))
        .whenComplete(() => setState(() => isLoadingVersion = false));
  }

  /// Get the the installed and the latest version from github releases:
  /// https://api.github.com/repos/harmonoid/harmonoid/releases
  Future<void> getAppVersion() async {
    var response = await http.get(
        Uri.parse('https://api.github.com/repos/harmonoid/harmonoid/releases'));

    List<dynamic> releasesJson = convert.jsonDecode(response.body);
    List<Release> releases = releasesJson
        .map((release) => Release.fromJson(release))
        .toList()
        .cast<Release>();

    setState(() {
      if (releases.length > 0) latestRelease = releases.first;
    });
  }

  Widget getVersionTableRow(String versionLabel, Release release) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(versionLabel,
            style: Theme.of(context)
                .textTheme
                .headline4
                ?.copyWith(color: Colors.white)),
        const SizedBox(width: 8.0),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: Align(
            key: Key('version_details'),
            alignment: Alignment.centerLeft,
            child: Text(
              release.tagName,
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          height: 96.0,
          width: MediaQuery.of(context).size.width,
          color: Color(0xFF6200EA),
          child: Row(
            children: [
              Image.asset(
                'assets/images/project.png',
                height: 96.0,
                width: 96.0,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harmonoid',
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                            color: Colors.white,
                            fontSize: 24.0,
                          ),
                    ),
                    Text(
                      'Elegant music app to play & manage music library.',
                      style: TextStyle(color: Colors.white),
                    ),
                    getVersionTableRow(
                      Language.instance.SETTING_APP_VERSION_INSTALLED + ':',
                      Release(tagName: kVersion),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaterialButton(
                padding: EdgeInsets.zero,
                onPressed: () => launchUrl(
                  Uri.parse('https://github.com/harmonoid/harmonoid'),
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(
                  Language.instance.SETTING_GITHUB.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              MaterialButton(
                padding: EdgeInsets.zero,
                onPressed: () => launchUrl(
                  Uri.parse('https://alexmercerind.github.io/donate'),
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(
                  Language.instance.DONATE.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AboutPage(),
                    ),
                  );
                },
                child: Text(
                  Language.instance.ABOUT_TITLE.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              if (kVersion != latestRelease.tagName)
                MaterialButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => launchUrl(
                    Uri.parse(
                        'https://github.com/harmonoid/harmonoid/releases'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(
                    Language.instance.DOWNLOAD_UPDATE.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Release {
  String tagName;
  DateTime? publishedAt;
  DateTime? createdAt;
  String? htmlUrl;

  Release({
    required this.tagName,
    this.publishedAt,
    this.createdAt,
    this.htmlUrl,
  });

  Release.fromJson(Map<String, dynamic> json)
      : tagName = json['tag_name'],
        publishedAt = DateTime.parse(json['published_at']),
        createdAt = DateTime.parse(json['created_at']),
        htmlUrl = json['html_url'];
}
