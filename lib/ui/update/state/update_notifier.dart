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
  static const String kDesktopDownloadUrl = 'https://harmonoid.com/downloads';
  static const String kAndroidDownloadUrl = 'https://play.google.com/store/apps/details?id=com.alexmercerind.harmonoid';

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

    final latestVersion = release.tagName;
    const currentVersion = kVersion;

    latestRelease = release;
    updateAvailable = _compareVersions(latestVersion, currentVersion);
    notifyListeners();

    if (Configuration.instance.updateCheckVersion != latestVersion && updateAvailable) {
      final result = await showUpdate();
      if (result) {
        await download();
      } else {
        await Configuration.instance.set(updateCheckVersion: latestVersion);
      }
    }
  }

  Future<void> download() {
    return launchUrlString(
      Platform.isAndroid ? kAndroidDownloadUrl : kDesktopDownloadUrl,
      mode: LaunchMode.externalApplication,
    );
  }

  bool _compareVersions(String? latestVersion, String currentVersion) {
    if (latestVersion == null) return false;
    final latestVersionParts = latestVersion.substring(1).split('.');
    final currentVersionParts = currentVersion.substring(1).split('.');
    for (int i = 0; i < max(latestVersionParts.length, currentVersionParts.length); i++) {
      final latestPart = int.parse(latestVersionParts.elementAtOrNull(i) ?? '0');
      final currentPart = int.parse(currentVersionParts.elementAtOrNull(i) ?? '0');
      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    return false;
  }
}
