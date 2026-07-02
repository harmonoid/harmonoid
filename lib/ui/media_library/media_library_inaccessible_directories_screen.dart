import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/extensions/configuration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/darwin_storage_controller.dart';
import 'package:harmonoid/utils/rendering.dart';

class MediaLibraryInaccessibleDirectoriesScreen extends StatefulWidget {
  final List<Directory> directories;

  const MediaLibraryInaccessibleDirectoriesScreen({super.key, required this.directories});

  static Future<bool> showIfRequired(BuildContext context) async {
    final directories = <Directory>[];
    for (final directory in FileSystemMediaLibrary.instance.directories) {
      if (Platform.isIOS || Platform.isMacOS) {
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
      await context.push('/$kInaccessibleDirectoriesPath', extra: InaccessibleDirectoriesPathExtra(directories: directories));
    }

    return directories.isNotEmpty;
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
      for (final directory in FileSystemMediaLibrary.instance.directories) {
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
      await FileSystemMediaLibrary.instance.removeDirectories({directory});

      await refresh();

      if (Platform.isMacOS || Platform.isIOS) {
        await DarwinStorageController.instance.invalidateAccess(directory);
      }
    } catch (_) {}
    removing = false;
  }

  void ignore() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return HeroContentScreen(
      palette: [Colors.red.shade800],
      caption: kCaption,
      title: Localization.instance.MEDIA_LIBRARY_INACCESSIBLE_FOLDERS_TITLE,
      subtitle: isDesktop
          ? Localization.instance.MEDIA_LIBRARY_INACCESSIBLE_FOLDERS_SUBTITLE.replaceAll('"OPERATING_SYSTEM"', operatingSystem)
          // No new-line characters on mobile.
          : Localization.instance.MEDIA_LIBRARY_INACCESSIBLE_FOLDERS_SUBTITLE.replaceAll('"OPERATING_SYSTEM"', operatingSystem).replaceAll(RegExp(r'\s'), ' '),
      implyBackButton: false,
      actions: {
        Icons.refresh: (context, _) => refresh(),
        Icons.visibility_off: (context, _) => ignore(),
        Icons.settings: (context, _) => context.push('/$kSettingsPath'),
      },
      labels: {
        Icons.refresh: Localization.instance.REFRESH,
        Icons.visibility_off: Localization.instance.IGNORE,
        Icons.settings: Localization.instance.SETTINGS,
      },
      tabs: [''],
      content: [
        ListItemTable(
          columns: [Localization.instance.FOLDER, ''],
          itemCount: directories.length,
          itemBuilder: (context, i) => ListItemData(
            key: ValueKey(i.toString()),
            children: [
              TappableText(text: [TappableTextData(text: directories[i].path)]),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => remove(directories[i]), child: Text(label(Localization.instance.REMOVE))),
              ),
            ],
          ),
          leadingBuilder: (context, i) => const Icon(FluentIcons.folder_32_regular, size: 32.0),
          desktopColumnRatios: [0.8, 0.2],
        ),
      ],
    );
  }
}
