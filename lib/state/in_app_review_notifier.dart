import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/models/remote_config_key.dart';
import 'package:harmonoid/models/remote_config_value.dart';
import 'package:harmonoid/state/remote_config_provider.dart';

/// {@template in_app_review_notifier}
///
/// InAppReviewNotifier
/// -------------------
/// Implementation to request the in-app review prompt after eligible app usage.
///
/// {@endtemplate}
class InAppReviewNotifier {
  static const Duration kInstallAgeThreshold = Duration(days: 5);
  static const int kLaunchCountThreshold = 10;

  /// Singleton instance.
  static final InAppReviewNotifier instance = InAppReviewNotifier._();

  /// Whether the [InAppReviewNotifier] is initialized.
  static bool initialized = false;

  /// {@macro in_app_review_notifier}
  InAppReviewNotifier._();

  /// Initializes the [instance].
  static Future<void> ensureInitialized() async {
    if (initialized) return;
    initialized = true;
    await Configuration.instance.set(metaLaunchCount: Configuration.instance.metaLaunchCount + 1);
  }

  /// Requests the in-app review.
  Future<void> requestReview({bool force = false}) async {
    if (_requesting) return;
    _requesting = true;
    try {
      if (!Platform.isAndroid && !Platform.isIOS) return;
      if (!force) {
        if (Configuration.instance.metaInAppReviewSubmitted) return;
        if (Configuration.instance.metaLaunchCount <= kLaunchCountThreshold) return;
        if (DateTime.now().difference(DateTime.parse(Configuration.instance.metaInstallDate)) <= kInstallAgeThreshold) return;
        if (!await _isRemoteEnabled()) return;
      }
      if (!await InAppReview.instance.isAvailable()) return;

      await InAppReview.instance.requestReview();
      await Configuration.instance.set(metaInAppReviewSubmitted: true);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    } finally {
      _requesting = false;
    }
  }

  Future<bool> _isRemoteEnabled() async {
    final response = await RemoteConfigProvider().get(RemoteConfigKey.enableInAppReview);
    if (response is EnableInAppReview) {
      return response.value;
    }
    return false;
  }

  bool _requesting = false;
}
