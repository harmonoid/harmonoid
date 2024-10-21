import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/extensions/configuration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/settings/settings_section.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class MediaLibrarySection extends StatelessWidget {
  const MediaLibrarySection({super.key});

  // --------------------------------------------------

  static const kDefaultFileSizes = [
    0,
    512 * 1024,
    1 * 1024 * 1024,
    2 * 1024 * 1024,
    5 * 1024 * 1024,
    10 * 1024 * 1024,
    20 * 1024 * 1024,
  ];

  static String intFileSizeToLabelFileSize(int size) {
    return switch (size) {
      0 => '0 MB',
      const (512 * 1024) => '512 KB',
      const (1 * 1024 * 1024) => '1 MB ${Localization.instance.RECOMMENDED_HINT}',
      const (2 * 1024 * 1024) => '2 MB',
      const (5 * 1024 * 1024) => '5 MB',
      const (10 * 1024 * 1024) => '10 MB',
      const (20 * 1024 * 1024) => '20 MB',
      _ => '${(size / 1024 * 1024).toStringAsFixed(1)} MB',
    };
  }

  // --------------------------------------------------

  static Widget buildAddedFolders(BuildContext context, MediaLibrary mediaLibrary) {
    if (mediaLibrary.directories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(FluentIcons.folder_32_regular, size: 32.0),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                Localization.instance.NO_FOLDERS_ADDED,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: mediaLibrary.directories.map((directory) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(FluentIcons.folder_32_regular, size: 32.0),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    directory.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 8.0),
                TextButton(
                  onPressed: () => MediaLibrarySection.removeFolder(context, mediaLibrary, directory),
                  child: Text(label(Localization.instance.REMOVE)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static Widget buildRefreshIndicator(BuildContext context, MediaLibrary mediaLibrary) {
    if (!mediaLibrary.refreshing) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16.0),
        Text(
          mediaLibrary.current == null
              ? Localization.instance.DISCOVERING_FILES
              : Localization.instance.ADDED_M_OF_N_FILES.replaceAll('"M"', (mediaLibrary.current ?? 0).toString()).replaceAll('"N"', (mediaLibrary.total == 0 ? 1 : mediaLibrary.total).toString()),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8.0),
        LinearProgressIndicator(
          value: mediaLibrary.current == null ? null : (mediaLibrary.current ?? 0) / (mediaLibrary.total == 0 ? 1 : mediaLibrary.total),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  // --------------------------------------------------

  static Future<void> ensureNotRefreshing(BuildContext context, MediaLibrary mediaLibrary, Future<void> Function() callback) async {
    if (mediaLibrary.refreshing) {
      await showMessage(
        context,
        Localization.instance.WARNING,
        Localization.instance.MEDIA_LIBRARY_REFRESHING_DIALOG_SUBTITLE,
      );
      return;
    }
    return callback();
  }

  static Future<void> removeFolder(BuildContext context, MediaLibrary mediaLibrary, Directory directory) => ensureNotRefreshing(context, mediaLibrary, () async {
        if (mediaLibrary.directories.length <= 1) {
          await showMessage(
            context,
            Localization.instance.WARNING,
            Localization.instance.LAST_DIRECTORY_REMOVED,
          );
          return;
        }
        await Configuration.instance.removeMediaLibraryDirectory(directory);
        await mediaLibrary.removeDirectories({directory});
      });

  static Future<void> addFolder(BuildContext context, MediaLibrary mediaLibrary) => ensureNotRefreshing(context, mediaLibrary, () async {
        final directory = await pickDirectory();
        if (directory == null) return;
        await Configuration.instance.addMediaLibraryDirectory(directory);
        await mediaLibrary.addDirectories({directory});
      });

  static Future<void> refresh(BuildContext context, MediaLibrary mediaLibrary) => ensureNotRefreshing(
        context,
        mediaLibrary,
        mediaLibrary.refresh,
      );

  static Future<void> reindex(BuildContext context, MediaLibrary mediaLibrary) => ensureNotRefreshing(
        context,
        mediaLibrary,
        mediaLibrary.reindex,
      );

  static Future<void> editAlbumParameters(BuildContext context, MediaLibrary mediaLibrary) => ensureNotRefreshing(context, mediaLibrary, () async {
        final result = {
          ...mediaLibrary.albumGroupingParameters.isNotEmpty ? mediaLibrary.albumGroupingParameters : AlbumGroupingParameter.values.toSet(),
        };

        await showDialog(
          context: context,
          builder: (ctx) => StatefulBuilder(
            builder: (ctx, setState) {
              void addOrRemove(AlbumGroupingParameter parameter, bool? value) {
                setState(() {
                  if (value == null) {
                    if (result.contains(parameter)) {
                      result.remove(parameter);
                    } else {
                      result.add(parameter);
                    }
                  } else if (value) {
                    result.add(parameter);
                  } else {
                    result.remove(parameter);
                  }
                });
              }

              return AlertDialog(
                titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0),
                contentPadding: EdgeInsets.zero,
                title: Text(Localization.instance.EDIT_ALBUM_PARAMETERS_TITLE),
                content: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1.0, thickness: 1.0),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              ListItem(
                                leading: Checkbox(
                                  value: result.contains(AlbumGroupingParameter.album),
                                  onChanged: (value) => addOrRemove(AlbumGroupingParameter.album, value),
                                ),
                                onTap: () => addOrRemove(AlbumGroupingParameter.album, null),
                                title: Localization.instance.TITLE,
                              ),
                              ListItem(
                                leading: Checkbox(
                                  value: result.contains(AlbumGroupingParameter.albumArtist),
                                  onChanged: (value) => addOrRemove(AlbumGroupingParameter.albumArtist, value),
                                ),
                                onTap: () => addOrRemove(AlbumGroupingParameter.albumArtist, null),
                                title: Localization.instance.ALBUM_ARTIST,
                              ),
                              ListItem(
                                leading: Checkbox(
                                  value: result.contains(AlbumGroupingParameter.year),
                                  onChanged: (value) => addOrRemove(AlbumGroupingParameter.year, value),
                                ),
                                onTap: () => addOrRemove(AlbumGroupingParameter.year, null),
                                title: Localization.instance.YEAR,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1.0, thickness: 1.0),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Configuration.instance.set(mediaLibraryAlbumGroupingParameters: result.isNotEmpty ? result : AlbumGroupingParameter.values.toSet());
                      mediaLibrary.setAlbumGroupingParameters(result.isNotEmpty ? result : AlbumGroupingParameter.values.toSet());
                      Navigator.of(ctx).pop();
                    },
                    child: Text(label(Localization.instance.OK)),
                  ),
                  TextButton(
                    onPressed: Navigator.of(ctx).pop,
                    child: Text(label(Localization.instance.CANCEL)),
                  ),
                ],
              );
            },
          ),
        );
      });

  static Future<void> editMinimumFileSize(BuildContext context, MediaLibrary mediaLibrary) => ensureNotRefreshing(context, mediaLibrary, () async {
        final result = await showSelection(
          context,
          Localization.instance.EDIT_MINIMUM_FILE_SIZE,
          kDefaultFileSizes,
          mediaLibrary.minimumFileSize,
          intFileSizeToLabelFileSize,
        );

        if (result != null) {
          Configuration.instance.set(mediaLibraryMinimumFileSize: result);
          mediaLibrary.setMinimumFileSize(result);

          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              showMessage(
                context,
                Localization.instance.WARNING,
                Localization.instance.MINIMUM_FILE_SIZE_WARNING,
              );
            },
          );
        }
      });

  // --------------------------------------------------

  Widget _buildDesktopLayout(BuildContext context) {
    return const DesktopMediaLibrarySection();
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    return const MobileMediaLibrarySection();
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    throw UnimplementedError();
  }
}

class DesktopMediaLibrarySection extends StatelessWidget {
  const DesktopMediaLibrarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) {
        return SettingsSection(
          title: Localization.instance.SETTINGS_SECTION_MEDIA_LIBRARY_TITLE,
          subtitle: Localization.instance.SETTINGS_SECTION_MEDIA_LIBRARY_SUBTITLE,
          children: [
            Transform.translate(
              offset: const Offset(-8.0, 0.0),
              child: TextButton(
                onPressed: () => MediaLibrarySection.addFolder(context, mediaLibrary),
                child: Text(label(Localization.instance.ADD_NEW_FOLDER)),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(Localization.instance.ADDED_FOLDERS),
            MediaLibrarySection.buildAddedFolders(context, mediaLibrary),
            MediaLibrarySection.buildRefreshIndicator(context, mediaLibrary),
            Transform.translate(
              offset: const Offset(-8.0, 0.0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => MediaLibrarySection.refresh(context, mediaLibrary),
                    child: Text(label(Localization.instance.REFRESH)),
                  ),
                  TextButton(
                    onPressed: () => MediaLibrarySection.reindex(context, mediaLibrary),
                    child: Text(label(Localization.instance.REINDEX)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Transform.translate(
              offset: const Offset(-8.0, 0.0),
              child: TextButton(
                onPressed: () => MediaLibrarySection.editAlbumParameters(context, mediaLibrary),
                child: Text(label(Localization.instance.EDIT_ALBUM_PARAMETERS_TITLE)),
              ),
            ),
            const SizedBox(height: 8.0),
            Transform.translate(
              offset: const Offset(-8.0, 0.0),
              child: TextButton(
                onPressed: () => MediaLibrarySection.editMinimumFileSize(context, mediaLibrary),
                child: Text(label(Localization.instance.EDIT_MINIMUM_FILE_SIZE)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MobileMediaLibrarySection extends StatelessWidget {
  const MobileMediaLibrarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) {
        return SettingsSection(
          title: Localization.instance.SETTINGS_SECTION_MEDIA_LIBRARY_TITLE,
          subtitle: Localization.instance.SETTINGS_SECTION_MEDIA_LIBRARY_SUBTITLE,
          children: [
            ListItem(
              title: Localization.instance.ADD_NEW_FOLDER,
              subtitle: Localization.instance.ADD_NEW_FOLDER_SUBTITLE,
              onTap: () => MediaLibrarySection.addFolder(context, mediaLibrary),
            ),
            ListItem(
              title: Localization.instance.REFRESH,
              subtitle: Localization.instance.REFRESH_SUBTITLE,
              onTap: () => MediaLibrarySection.refresh(context, mediaLibrary),
            ),
            ListItem(
              title: Localization.instance.REINDEX,
              subtitle: Localization.instance.REINDEX_SUBTITLE,
              onTap: () => MediaLibrarySection.reindex(context, mediaLibrary),
            ),
            ListItem(
              title: Localization.instance.EDIT_ALBUM_PARAMETERS_TITLE,
              subtitle: Localization.instance.EDIT_ALBUM_PARAMETERS_SUBTITLE,
              onTap: () => MediaLibrarySection.editAlbumParameters(context, mediaLibrary),
            ),
            ListItem(
              title: Localization.instance.EDIT_MINIMUM_FILE_SIZE,
              subtitle: MediaLibrarySection.intFileSizeToLabelFileSize(mediaLibrary.minimumFileSize),
              onTap: () => MediaLibrarySection.editMinimumFileSize(context, mediaLibrary),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                Localization.instance.ADDED_FOLDERS,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MediaLibrarySection.buildAddedFolders(context, mediaLibrary),
            ),
          ],
        );
      },
    );
  }
}
