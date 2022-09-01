import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

class VersionSetting extends StatefulWidget {
  VersionSetting({Key? key}) : super(key: key);
  VersionState createState() => VersionState();
}

class VersionState extends State<VersionSetting>
    with AutomaticKeepAliveClientMixin {
  String latest = kVersion;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      final response = await get(
        Uri.https(
          'api.github.com',
          '/repos/harmonoid/harmonoid/releases/latest',
        ),
      );
      final body = json.decode(response.body);
      if (mounted) {
        setState(() {
          latest = body['tag_name'];
        });
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SettingsTile(
      title: Language.instance.SETTING_APP_VERSION_TITLE,
      subtitle: Language.instance.SETTING_APP_VERSION_SUBTITLE,
      margin: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      child: Column(
        children: [
          const SizedBox(height: 4.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Language.instance.SETTING_APP_VERSION_INSTALLED + ':'),
              const SizedBox(width: 8.0),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    kVersion,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Language.instance.SETTING_APP_VERSION_LATEST + ':'),
              const SizedBox(width: 8.0),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    latest,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: latest == kVersion
          ? null
          : [
              TextButton(
                onPressed: () => launchUrl(
                  Uri.https(
                    'github.com',
                    '/harmonoid/harmonoid/releases',
                  ),
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(
                  Language.instance.DOWNLOAD_UPDATE.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
