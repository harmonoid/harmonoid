import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/ui/update/api/latest_release_get.dart';
import 'package:harmonoid/ui/update/models/github_release.dart';
import 'package:harmonoid/utils/constants.dart';

/// {@template update_notifier}
///
/// UpdateNotifier
/// --------------
/// Implementation to handle in-app updates.
///
/// {@endtemplate}
class UpdateNotifier extends ChangeNotifier {
  static const String kSkipInAppUpdateDialog = 'SKIP_IN_APP_UPDATE_DIALOG';
  static const String kDownloadUrl = 'https://harmonoid.com/downloads';
  static const String kAndroidDownloadUrl = 'https://play.google.com/store/apps/details?id=com.alexmercerind.harmonoid';
  static const String kIOSDownloadUrl = 'https://apps.apple.com/us/app/harmonoid/id6787241125';

  UpdateNotifier({required this.showUpdate}) {
    unawaited(check());
  }

  final Future<bool> Function() showUpdate;

  GithubRelease? latestRelease;
  bool updateAvailable = false;

  Future<void> check() async {
    final latestReleaseGet = LatestReleaseGet();
    final release = await latestReleaseGet();

    if (release == null) return;

    final skipInAppUpdateDialog = release.body.contains(kSkipInAppUpdateDialog);
    final latestVersion = release.tagName;
    const currentVersion = kVersion;

    latestRelease = release;
    updateAvailable = compareVersions(latestVersion, currentVersion);
    notifyListeners();

    if (Configuration.instance.updateCheckVersion != latestVersion && !skipInAppUpdateDialog && updateAvailable) {
      final result = await showUpdate();
      if (result) {
        await download();
      } else {
        await Configuration.instance.set(updateCheckVersion: latestVersion);
      }
    }
  }

  Future<void> download() {
    String url = kDownloadUrl;
    if (Platform.isAndroid) {
      url = kAndroidDownloadUrl;
    }
    if (Platform.isIOS) {
      url = kIOSDownloadUrl;
    }
    return launchUrlString(url, mode: LaunchMode.externalApplication);
  }
}

bool compareVersions(String? to, String from) {
  if (to == null) return false;
  final latestVersionParts = to.substring(1).split('.');
  final currentVersionParts = from.substring(1).split('.');
  for (int i = 0; i < max(latestVersionParts.length, currentVersionParts.length); i++) {
    final latestPart = int.parse(latestVersionParts.elementAtOrNull(i) ?? '0');
    final currentPart = int.parse(currentVersionParts.elementAtOrNull(i) ?? '0');
    if (latestPart > currentPart) return true;
    if (latestPart < currentPart) return false;
  }
  return false;
}
