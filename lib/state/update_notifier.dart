import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:harmonoid/api/latest_version_get.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/utils/actions.dart';
import 'package:harmonoid/utils/constants.dart';

/// {@template update_notifier}
///
/// UpdateNotifier
/// --------------
/// Implementation to handle in-app updates.
///
/// {@endtemplate}
class UpdateNotifier extends ChangeNotifier {
  static const String kDownloadUrl = 'https://harmonoid.com/downloads';

  /// Singleton instance.
  static final UpdateNotifier instance = UpdateNotifier._();

  /// {@macro update_manager}
  UpdateNotifier._();

  bool updateAvailable = false;
  String updateVersion = kVersion;

  Future<void> check([bool force = false, Future<bool> Function(String) onShowUpdate = updateNotifierCheckOnShowUpdate]) async {
    final latestVersionGet = LatestVersionGet();
    final latestVersion = await latestVersionGet();
    const currentVersion = kVersion;

    updateAvailable = _compareVersions(latestVersion, currentVersion);
    updateVersion = latestVersion ?? kVersion;
    notifyListeners();

    if ((force || Configuration.instance.updateCheckVersion != updateVersion) && updateAvailable) {
      if (await onShowUpdate(updateVersion)) {
        _download();
      } else {
        Configuration.instance.set(updateCheckVersion: updateVersion);
      }
    }
  }

  Future<void> _download() {
    return launchUrlString(kDownloadUrl, mode: LaunchMode.externalApplication);
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
