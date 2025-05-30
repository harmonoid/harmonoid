import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/state/lyrics_notifier.dart';
import 'package:harmonoid/ui/settings/settings_section.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';
import 'package:harmonoid/utils/widgets.dart';

class PermissionsSection extends StatefulWidget {
  const PermissionsSection({super.key});

  @override
  State<PermissionsSection> createState() => _PermissionsSectionState();
}

class _PermissionsSectionState extends State<PermissionsSection> {
  Future<void> request(Permission permission) async {
    final result = await permission.request();
    if (result.isGranted && permission == Permission.notification) {
      LyricsNotifier.instance.initializeNotification();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!(Platform.isAndroid && AndroidStorageController.instance.version >= 33)) return const SizedBox.shrink();
    /* ANDROID */
    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_PERMISSIONS_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_PERMISSIONS_SUBTITLE,
      children: [
        FutureBuilder(
          future: AndroidStorageController.instance.version >= 33 ? Permission.audio.status : Permission.storage.status,
          builder: (context, snapshot) {
            return ListItem(
              onTap: () => request(AndroidStorageController.instance.version >= 33 ? Permission.audio : Permission.storage),
              leading: Checkbox(
                value: snapshot.data == PermissionStatus.granted,
                onChanged: (_) => request(AndroidStorageController.instance.version >= 33 ? Permission.audio : Permission.storage),
              ),
              title: Localization.instance.PERMISSION_MUSIC_AND_AUDIO,
              subtitle: Localization.instance.PERMISSION_MUSIC_AND_AUDIO_SUBTITLE,
            );
          },
        ),
        FutureBuilder(
          future: Permission.notification.status,
          builder: (context, snapshot) {
            return ListItem(
              onTap: () => request(Permission.notification),
              leading: Checkbox(
                value: snapshot.data == PermissionStatus.granted,
                onChanged: (_) => request(Permission.notification),
              ),
              title: Localization.instance.PERMISSION_NOTIFICATIONS,
              subtitle: Localization.instance.PERMISSION_NOTIFICATIONS_SUBTITLE,
            );
          },
        ),
      ],
    );
  }
}
