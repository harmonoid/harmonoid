/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/window_lifecycle.dart';
import 'package:window_plus/window_plus.dart';

/// Updater
/// -------
///
/// Checks for the available update & notifies the user.
/// Must be run in an asynchronous suspension.
///
abstract class Updater {
  static void initialize() async {
    try {
      final response = await http.get(
        Uri.https(
          'raw.githubusercontent.com',
          '/alexmercerind/alexmercerind/main/latest_version.json',
        ),
      );
      final body = jsonDecode(response.body);
      final String version = body['version'];
      final bool mandatory = body['mandatory'];
      final String message = body['message'];
      final String url = body['url'];
      final List<String> platforms = body['platforms'].cast<String>();
      if (version != kVersion && platforms.contains(Platform.operatingSystem)) {
        final choice = await FlutterPlatformAlert.showCustomAlert(
          windowTitle: Language.instance.UPDATE_AVAILABLE.replaceAll(
            'VERSION',
            version,
          ),
          text: message,
          positiveButtonTitle: Language.instance.DOWNLOAD,
          negativeButtonTitle:
              mandatory ? null : Language.instance.REMIND_ME_NEXT_TIME,
          neutralButtonTitle: null,
          options: FlutterPlatformAlertOption(
            preferMessageBoxOnWindows: false,
            additionalWindowTitleOnWindows: Language.instance.DOWNLOAD_UPDATE,
            showAsLinksOnWindows: true,
          ),
        );
        if (choice == CustomButton.positiveButton) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
          final result = await WindowLifecycle.windowCloseHandler(
            showInterruptAlert: false,
          );
          if (result) {
            WindowPlus.instance.destroy();
          }
        }
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }
}
