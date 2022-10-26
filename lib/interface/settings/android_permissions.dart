/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:harmonoid/utils/extensions.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/constants/language.dart';

/// Only for Android 13 or higher i.e. SDK 33 or above.
class AndroidPermissionsSetting extends StatefulWidget {
  AndroidPermissionsSetting({Key? key}) : super(key: key);

  @override
  AndroidPermissionsSettingState createState() =>
      AndroidPermissionsSettingState();
}

class AndroidPermissionsSettingState extends State<AndroidPermissionsSetting> {
  bool music = false;
  bool notification = false;
  bool photos = false;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    try {
      // Granular music & audio permissions for Android 13 or higher.
      if (StorageRetriever.instance.version >= 33) {
        music = await Permission.audio.isGranted;
      }
      // Normal storage permissions for Android 12 or lower.
      else {
        music = await Permission.storage.isGranted;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    try {
      // Notifications permission is only required by Android 13 or higher.
      if (StorageRetriever.instance.version >= 33) {
        notification = await Permission.notification.isGranted;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    try {
      // Granular images & photos permissions for Android 13 or higher.
      if (StorageRetriever.instance.version >= 33) {
        photos = await Permission.photos.isGranted;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      margin: EdgeInsets.zero,
      title: Language.instance.PERMISSIONS,
      subtitle: Language.instance.PERMISSIONS_SUBTITLE,
      child: Column(
        children: [
          CheckboxListTile(
            value: music,
            checkboxShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            onChanged: (_) async {
              if (!music) {
                if (StorageRetriever.instance.version >= 33) {
                  final result = await Permission.audio.request();
                  debugPrint(result.toString());
                } else {
                  final result = await Permission.storage.request();
                  debugPrint(result.toString());
                }
                await refresh();
              }
            },
            title: Text(Language.instance.PERMISSION_MUSIC_AND_AUDIO),
            subtitle: Text(
              Language.instance.PERMISSION_MUSIC_AND_AUDIO_SUBTITLE.overflow,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Notifications permission is only required by Android 13 or higher.
          if (StorageRetriever.instance.version >= 33)
            CheckboxListTile(
              value: notification,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              onChanged: (_) async {
                if (!notification) {
                  if (StorageRetriever.instance.version >= 33) {
                    final result = await Permission.notification.request();
                    debugPrint(result.toString());
                    if (result == PermissionStatus.granted) {
                      // Create notification channel & setup callbacks for lyrics.
                      try {
                        Lyrics.initialize();
                      } catch (exception, stacktrace) {
                        debugPrint(exception.toString());
                        debugPrint(stacktrace.toString());
                      }
                    }
                  }
                  await refresh();
                }
              },
              title: Text(Language.instance.PERMISSION_NOTIFICATIONS),
              subtitle: Text(
                Language.instance.PERMISSION_NOTIFICATIONS_SUBTITLE.overflow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Photos & images permission is only required by Android 13 or higher.
          if (StorageRetriever.instance.version >= 33)
            CheckboxListTile(
              value: photos,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              onChanged: (_) async {
                if (!photos) {
                  if (StorageRetriever.instance.version >= 33) {
                    final result = await Permission.photos.request();
                    debugPrint(result.toString());
                  }
                  await refresh();
                }
              },
              isThreeLine: true,
              title: Text(
                Language.instance.PERMISSION_IMAGES_AND_PHOTOS,
              ),
              subtitle: Text(
                Language
                    .instance.PERMISSION_IMAGES_AND_PHOTOS_SUBTITLE.overflow,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
