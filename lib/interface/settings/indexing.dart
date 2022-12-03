/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_library/media_library.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';

class IndexingSetting extends StatefulWidget {
  const IndexingSetting({Key? key}) : super(key: key);
  IndexingState createState() => IndexingState();
}

class IndexingState extends State<IndexingSetting>
    with AutomaticKeepAliveClientMixin {
  List<Directory>? volumes;
  bool hovered = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final volumes = await StorageRetriever.instance.volumes;
        setState(() => this.volumes = volumes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<CollectionRefresh>(
      builder: (context, controller, _) => SettingsTile(
        title: Language.instance.SETTING_INDEXING_TITLE,
        subtitle: Language.instance.SETTING_INDEXING_SUBTITLE,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mobile specific layout.
            if (isMobile) ...[
              ListTile(
                dense: false,
                onTap:
                    controller.isCompleted ? pickNewFolder : showProgressDialog,
                title: Text(Language.instance.ADD_NEW_FOLDER),
                subtitle: Text(Language.instance.ADD_NEW_FOLDER_SUBTITLE),
              ),
              ListTile(
                dense: false,
                onTap: controller.isCompleted
                    ? () async {
                        Collection.instance.refresh(
                          onProgress: (progress, total, _) {
                            controller.set(progress, total);
                          },
                        );
                      }
                    : showProgressDialog,
                title: Text(Language.instance.REFRESH),
                subtitle: Text(Language.instance.REFRESH_SUBTITLE),
              ),
              ListTile(
                dense: false,
                onTap: controller.isCompleted
                    ? () async {
                        Collection.instance.index(
                          onProgress: (progress, total, _) {
                            controller.set(progress, total);
                          },
                        );
                      }
                    : showProgressDialog,
                title: Text(Language.instance.REINDEX),
                subtitle: Text(Language.instance.REINDEX_SUBTITLE),
              ),
              ListTile(
                onTap: showEditAlbumParametersDialog,
                dense: false,
                title: Text(Language.instance.EDIT_ALBUM_PARAMETERS_TITLE),
                subtitle:
                    Text(Language.instance.EDIT_ALBUM_PARAMETERS_SUBTITLE),
              ),
              ListTile(
                onTap: showEditMinimumFileSizeDialog,
                dense: false,
                title: Text(Language.instance.MINIMUM_FILE_SIZE),
                subtitle: Text(
                  Configuration.instance.minimumFileSize.asFormattedByteSize,
                ),
              ),
            ],
            Container(
              margin: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextButton(
                          onPressed: CollectionRefresh.instance.isCompleted
                              ? pickNewFolder
                              : showProgressDialog,
                          child: Text(
                            Language.instance.ADD_NEW_FOLDER.toUpperCase(),
                          ),
                        ),
                      ],
                    ),
                  // Currently selected directories.
                  SizedBox(height: 12.0),
                  Container(
                    margin: EdgeInsets.only(left: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Language.instance.SELECTED_DIRECTORIES,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8.0),
                        if (!Platform.isAndroid || volumes != null)
                          ...Configuration.instance.collectionDirectories
                              .map(
                                (directory) => Container(
                                  width: isDesktop
                                      ? 572.0
                                      : MediaQuery.of(context).size.width,
                                  height: isDesktop ? 40.0 : 56.0,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 40.0,
                                        child: Icon(
                                          FluentIcons.folder_32_regular,
                                          size: 32.0,
                                        ),
                                      ),
                                      SizedBox(width: isDesktop ? 2.0 : 16.0),
                                      Expanded(
                                        child: Text(
                                          volumes == null
                                              ? directory.path.overflow
                                              : directory.path
                                                  .replaceAll(
                                                    volumes!.first.path,
                                                    Language.instance.PHONE,
                                                  )
                                                  .replaceAll(
                                                    volumes!.last.path,
                                                    Language.instance.SD_CARD,
                                                  )
                                                  .overflow,
                                          style: isDesktop
                                              ? null
                                              : Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          try {
                                            debugPrint(directory.toString());
                                            final c = Collection.instance;
                                            final conf = Configuration.instance;
                                            final cr =
                                                CollectionRefresh.instance;
                                            if (!cr.isCompleted) {
                                              await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .cardTheme
                                                          .color,
                                                  title: Text(
                                                    Language.instance
                                                        .INDEXING_ALREADY_GOING_ON_TITLE,
                                                  ),
                                                  content: Text(
                                                    Language.instance
                                                        .INDEXING_ALREADY_GOING_ON_SUBTITLE,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          Navigator.of(context)
                                                              .pop,
                                                      child: Text(
                                                          Language.instance.OK),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              return;
                                            }
                                            if (conf.collectionDirectories
                                                    .length ==
                                                1) {
                                              await showDialog(
                                                context: context,
                                                builder: (subContext) =>
                                                    AlertDialog(
                                                  title: Text(
                                                    Language.instance.WARNING,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.fromLTRB(
                                                    24.0,
                                                    20.0,
                                                    24.0,
                                                    8.0,
                                                  ),
                                                  content: Text(
                                                    Language.instance
                                                        .LAST_COLLECTION_DIRECTORY_REMOVED,
                                                    style: Theme.of(subContext)
                                                        .textTheme
                                                        .displaySmall,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(subContext)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                          Language.instance.OK),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              return;
                                            }
                                            await c.removeDirectories(
                                              refresh: false,
                                              directories: {directory},
                                              onProgress: (progress, total,
                                                  isCompleted) {
                                                cr.set(progress, total);
                                              },
                                            );
                                            await conf.save(
                                              collectionDirectories: c
                                                  .collectionDirectories
                                                  .difference(
                                                {
                                                  directory,
                                                },
                                              ),
                                            );
                                            setState(() {});
                                          } catch (exception, stacktrace) {
                                            debugPrint(exception.toString());
                                            debugPrint(stacktrace.toString());
                                          }
                                        },
                                        child: Text(
                                          Language.instance.REMOVE
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        // Show progress bar on desktop only.
                        if (isDesktop) ...[
                          const SizedBox(height: 8.0),
                          if (!controller.isCompleted)
                            Container(
                              height: 56.0,
                              width: 324.0,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  controller.progress == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              Language
                                                  .instance.DISCOVERING_FILES,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall,
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 6.0,
                                              ),
                                              height: 4.0,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  32.0,
                                              child: LinearProgressIndicator(
                                                value: null,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.2),
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : TweenAnimationBuilder(
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: (controller.progress ?? 0) /
                                                controller.total,
                                          ),
                                          duration: Duration(milliseconds: 400),
                                          child: Text(
                                            Language.instance
                                                .SETTING_INDEXING_LINEAR_PROGRESS_INDICATOR
                                                .replaceAll(
                                                  'NUMBER_STRING',
                                                  controller.progress
                                                      .toString(),
                                                )
                                                .replaceAll(
                                                  'TOTAL_STRING',
                                                  controller.total.toString(),
                                                ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall,
                                          ),
                                          builder: (_, dynamic value, child) =>
                                              Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              child!,
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                height: 4.0,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    32.0,
                                                child: LinearProgressIndicator(
                                                  value: value,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withOpacity(0.2),
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  // Desktop specific layout.
                  if (isDesktop) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextButton(
                          onPressed: controller.isCompleted
                              ? () async {
                                  Collection.instance.refresh(
                                    onProgress: (progress, total, _) {
                                      controller.set(progress, total);
                                    },
                                  );
                                }
                              : showProgressDialog,
                          child: Text(
                            Language.instance.REFRESH.toUpperCase(),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        TextButton(
                          onPressed: controller.isCompleted
                              ? () async {
                                  Collection.instance.index(
                                    onProgress: (progress, total, _) {
                                      controller.set(progress, total);
                                    },
                                  );
                                }
                              : showProgressDialog,
                          child: Text(
                            Language.instance.REINDEX.toUpperCase(),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.0),
                          Text(
                            '${Language.instance.REFRESH.toUpperCase()}: ${Language.instance.REFRESH_INFORMATION}',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            '${Language.instance.REINDEX.toUpperCase()}: ${Language.instance.REINDEX_INFORMATION}',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextButton(
                      onPressed: showEditAlbumParametersDialog,
                      child: Text(
                        Language.instance.EDIT_ALBUM_PARAMETERS_TITLE
                            .toUpperCase(),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        Language.instance.EDIT_ALBUM_PARAMETERS_SUBTITLE_,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextButton(
                      onPressed: showEditMinimumFileSizeDialog,
                      child: Text(
                        Language.instance.EDIT_MINIMUM_FILE_SIZE.toUpperCase(),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        Language.instance.MINIMUM_FILE_SIZE_WARNING,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pickNewFolder() async {
    final directory = await pickDirectory();
    if (directory != null) {
      if (Configuration.instance.collectionDirectories
          .contains(directory.path)) {
        return;
      }
      await Collection.instance.addDirectories(
        directories: {directory},
        onProgress: (progress, total, isCompleted) {
          CollectionRefresh.instance.set(progress, total);
        },
      );
      await Configuration.instance.save(
        collectionDirectories: Collection.instance.collectionDirectories.union(
          {
            directory,
          },
        ),
      );
    }
  }

  Future<void> showProgressDialog() {
    if (!CollectionRefresh.instance.isCompleted) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text(
            Language.instance.INDEXING_ALREADY_GOING_ON_TITLE,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24.0,
            20.0,
            24.0,
            8.0,
          ),
          content: Text(
            Language.instance.INDEXING_ALREADY_GOING_ON_SUBTITLE,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(Language.instance.OK),
            ),
          ],
        ),
      );
    }
    return Future.value();
  }

  Future<void> showEditMinimumFileSizeDialog() {
    int value = Configuration.instance.minimumFileSize;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Language.instance.MINIMUM_FILE_SIZE),
        contentPadding: const EdgeInsets.only(top: 20.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              height: 1.0,
              thickness: 1.0,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height / 2,
              ),
              child: Material(
                color: Colors.transparent,
                child: StatefulBuilder(
                  builder: (ctx, setState) => SingleChildScrollView(
                    child: Column(
                      children: kDefaultMinimumFileSizes.entries
                          .map(
                            (e) => RadioListTile<int>(
                              groupValue: value,
                              value: e.key,
                              onChanged: (e) {
                                if (e != null) {
                                  setState(() => value = e);
                                }
                              },
                              title: Text(
                                '${e.value} ${e.key == 1024 * 1024 ? Language.instance.RECOMMENDED_HINT : ''}',
                                style: isDesktop
                                    ? Theme.of(ctx).textTheme.headlineMedium
                                    : null,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1.0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).maybePop();
              // Do not proceed if some indexing related operation is going on.
              if (!CollectionRefresh.instance.isCompleted) {
                await showProgressDialog();
                return;
              }
              // Save the new value to `package:media_library` & cache.
              await Collection.instance.setMinimumFileSize(value);
              await Configuration.instance.save(
                minimumFileSize: value,
              );
              // Re-render.
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 500));
              // Show recommendation to perform a full re-indexing.
              await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 72.0,
                    vertical: 24.0,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(
                    24.0,
                    20.0,
                    24.0,
                    8.0,
                  ),
                  title: Text(
                    Language.instance.WARNING,
                  ),
                  content: Text(
                    Language.instance.MINIMUM_FILE_SIZE_WARNING,
                    style: Theme.of(ctx).textTheme.displaySmall,
                  ),
                  actions: [
                    TextButton(
                      onPressed: Navigator.of(ctx).pop,
                      child: Text(Language.instance.OK),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              Language.instance.OK,
            ),
          ),
          TextButton(
            onPressed: Navigator.of(ctx).maybePop,
            child: Text(
              Language.instance.CANCEL,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showEditAlbumParametersDialog() {
    Set<AlbumHashCodeParameter> parameters =
        Collection.instance.albumHashCodeParameters;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Language.instance.EDIT_ALBUM_PARAMETERS_TITLE),
        contentPadding: const EdgeInsets.only(top: 20.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              height: 1.0,
              thickness: 1.0,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 2,
              ),
              child: Material(
                color: Colors.transparent,
                child: StatefulBuilder(
                  builder: (context, setState) => SingleChildScrollView(
                    child: Column(
                      children: [
                        // Always enable identification based on the album's title.
                        ListTile(
                          leading: Checkbox(
                            value: true,
                            onChanged: null,
                          ),
                          title: Text(
                            Language.instance.TITLE,
                            style: isDesktop
                                ? Theme.of(context).textTheme.headlineMedium
                                : null,
                          ),
                        ),
                        ...AlbumHashCodeParameter.values.skip(1).map((e) {
                          void edit() async {
                            if (parameters.contains(e)) {
                              parameters = parameters.difference({e});
                            } else {
                              parameters = parameters.union({e});
                            }
                            setState(() {});
                          }

                          return ListTile(
                            leading: Checkbox(
                              value: parameters.contains(e),
                              onChanged: (_) => edit(),
                            ),
                            onTap: edit,
                            title: Text(
                              {
                                AlbumHashCodeParameter.albumArtistName:
                                    Language.instance.ALBUM_ARTIST,
                                AlbumHashCodeParameter.year:
                                    Language.instance.YEAR,
                              }[e]!,
                              style: isDesktop
                                  ? Theme.of(context).textTheme.headlineMedium
                                  : null,
                            ),
                          );
                        })
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1.0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).maybePop();
              if (!CollectionRefresh.instance.isCompleted) {
                await showProgressDialog();
                return;
              }
              debugPrint(parameters.toString());
              await Collection.instance.setAlbumHashCodeParameters(parameters);
              await Configuration.instance.save(
                albumHashCodeParameters: parameters,
              );
            },
            child: Text(
              Language.instance.OK,
            ),
          ),
          TextButton(
            onPressed: Navigator.of(context).maybePop,
            child: Text(
              Language.instance.CANCEL,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Default values available for setting the minimum file size.
/// For granular control, users may edit JSON directly.
const kDefaultMinimumFileSizes = {
  0: '0 MB',
  512 * 1024: '512 KB',
  1024 * 1024: '1 MB',
  2 * 1024 * 1024: '2 MB',
  5 * 1024 * 1024: '5 MB',
  10 * 1024 * 1024: '10 MB',
  20 * 1024 * 1024: '20 MB',
};

extension on int {
  /// Formats the size in bytes to a human readable string e.g. 2 KB or 5 MB etc.
  ///
  /// If the value is found in [kDefaultMinimumFileSizes], then prefers that.
  /// Otherwise, returns calculated value with truncated to 2 decimal places.
  ///
  String get asFormattedByteSize {
    final result = kDefaultMinimumFileSizes[this];
    if (result == null) {
      if (this > 1000 * 1000) {
        return '${(this / (1000 * 1000)).toStringAsFixed(2)} MB';
      } else {
        return '${(this / 1000 * 1000).toStringAsFixed(2)} KB';
      }
    }
    return result;
  }
}
