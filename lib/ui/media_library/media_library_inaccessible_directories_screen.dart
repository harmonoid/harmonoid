import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/extensions/configuration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/macos_storage_controller.dart';
import 'package:harmonoid/utils/rendering.dart';

class MediaLibraryInaccessibleDirectoriesScreen extends StatefulWidget {
  final List<Directory> directories;

  const MediaLibraryInaccessibleDirectoriesScreen({super.key, required this.directories});

  static Future<bool> showIfRequired(BuildContext context) async {
    final directories = <Directory>[];
    for (final directory in MediaLibrary.instance.directories) {
      // On macOS, try to list the contents of the directory to check if it's accessible.
      // On other platforms, just check if the directory exists.
      if (Platform.isMacOS) {
        try {
          // NOTE: Not using package:safe_local_storage API.
          directory.listSync();
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
          directories.add(directory);
        }
      } else {
        if (!await directory.exists_()) {
          directories.add(directory);
        }
      }
    }

    if (directories.isNotEmpty) {
      context.push(
        '/$kInaccessibleDirectoriesPath',
        extra: InaccessibleDirectoriesPathExtra(directories: directories),
      );
      return true;
    }

    return false;
  }

  @override
  State<MediaLibraryInaccessibleDirectoriesScreen> createState() => _MediaLibraryInaccessibleDirectoriesScreenState();
}

class _MediaLibraryInaccessibleDirectoriesScreenState extends State<MediaLibraryInaccessibleDirectoriesScreen> {
  bool removing = false;
  bool refreshing = false;

  late final directories = widget.directories;

  Future<void> refresh() async {
    if (refreshing) return;
    refreshing = true;
    try {
      directories.clear();
      for (final directory in MediaLibrary.instance.directories) {
        if (!await directory.exists_()) {
          directories.add(directory);
        }
      }
      setState(() {});
      if (directories.isEmpty) {
        context.pop();
      }
    } catch (_) {}
    refreshing = false;
  }

  Future<void> remove(Directory directory) async {
    if (removing) return;
    removing = true;
    try {
      await Configuration.instance.removeMediaLibraryDirectory(directory);
      await MediaLibrary.instance.removeDirectories({directory});
      await MacOSStorageController.instance.invalidateAccess(directory);
      await refresh();
    } catch (_) {}
    removing = false;
  }

  @override
  Widget build(BuildContext context) {
    return HeaderListItemsScreen(
      palette: [Colors.red.shade800],
      caption: kCaption,
      title: Localization.instance.MEDIA_LIBRARY_INACCESSIBLE_FOLDERS_TITLE,
      subtitle: isDesktop
          ? Localization.instance.MEDIA_LIBRARY_INACCESSIBLE_FOLDERS_SUBTITLE.replaceAll('"OPERATING_SYSTEM"', operatingSystem)
          // No new-line characters on mobile.
          : Localization.instance.MEDIA_LIBRARY_INACCESSIBLE_FOLDERS_SUBTITLE.replaceAll('"OPERATING_SYSTEM"', operatingSystem).replaceAll(RegExp(r'\s'), ' '),
      leading: IconButton(
        onPressed: () => refresh(),
        icon: const Icon(Icons.arrow_back),
        iconSize: 24.0,
        splashRadius: 20.0,
      ),
      listItemCount: directories.length,
      listItemDisplayIndex: false,
      listItemHeaders: [Text(Localization.instance.FOLDER)],
      listItemBuilder: (context, i) => [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(FluentIcons.folder_32_regular, size: 32.0),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                directories[i].path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(width: 8.0),
            TextButton(
              onPressed: () => remove(directories[i]),
              child: Text(label(Localization.instance.REMOVE)),
            ),
          ],
        ),
      ],
      actions: {
        Icons.refresh: (context) => refresh(),
        Icons.settings: (context) => context.push('/$kSettingsPath'),
      },
      labels: {
        Icons.refresh: Localization.instance.REFRESH,
        Icons.settings: Localization.instance.SETTINGS,
      },
    );
  }
}
