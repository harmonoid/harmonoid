import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/link.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

class VersionSetting extends StatefulWidget {
  VersionSetting({Key? key}) : super(key: key);
  VersionState createState() => VersionState();
}

class VersionState extends State<VersionSetting> {
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

  TableRow getVersionTableRow(String versionLabel, Release release) {
    final hasLink = release.htmlUrl != null && release.htmlUrl!.isNotEmpty;

    return TableRow(
      children: [
        Text(versionLabel),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: isLoadingVersion
              ? Align(
                  key: Key('loading_icon'),
                  alignment: Alignment(-0.7, 0.0),
                  child: SizedBox(
                    height: Theme.of(context).textTheme.bodyText2!.fontSize,
                    width: Theme.of(context).textTheme.bodyText2!.fontSize,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Align(
                  key: Key('version_details'),
                  alignment: Alignment.centerLeft,
                  child: Link(
                    uri: Uri.parse(release.htmlUrl ?? ''),
                    builder: (context, openLink) => MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: hasLink ? openLink : null,
                        child: Text(
                          fetchVersionFailed
                              ? Language.instance.NO_INTERNET_TITLE
                              : release.tagName,
                          style: TextStyle(
                            color: hasLink
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Language.instance.SETTING_APP_VERSION_TITLE,
      subtitle: Language.instance.SETTING_APP_VERSION_SUBTITLE,
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 360),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                getVersionTableRow(
                  Language.instance.SETTING_APP_VERSION_INSTALLED,
                  Release(tagName: kVersion),
                ),
                getVersionTableRow(
                  Language.instance.SETTING_APP_VERSION_LATEST,
                  latestRelease,
                ),
              ],
            ),
          ),
        ],
      ),
      margin: EdgeInsets.all(16.0),
      actions: kVersion == latestRelease.tagName
          ? null
          : [
              MaterialButton(
                onPressed: () =>
                    launch('https://github.com/harmonoid/harmonoid/releases'),
                child: Text(
                  Language.instance.DOWNLOAD_UPDATE,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
    );
  }
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
