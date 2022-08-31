/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/file_system.dart';
import 'package:harmonoid/constants/language.dart';

class IndexingSetting extends StatefulWidget {
  const IndexingSetting({Key? key}) : super(key: key);
  IndexingState createState() => IndexingState();
}

class IndexingState extends State<IndexingSetting>
    with AutomaticKeepAliveClientMixin {
  List<Directory>? storages;

  bool hovered = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final storages = await StorageRetriever.instance.directories;
        setState(() => this.storages = storages);
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
            const SizedBox(height: 2.0),
            if (isMobile)
              ListTile(
                dense: false,
                onTap:
                    controller.isCompleted ? pickNewFolder : showProgressDialog,
                title: Text(Language.instance.ADD_NEW_FOLDER),
                subtitle: Text(Language.instance.ADD_NEW_FOLDER_SUBTITLE),
              ),
            if (isMobile)
              ListTile(
                dense: false,
                onTap: controller.progress != controller.total
                    ? showProgressDialog
                    : () async {
                        Collection.instance.refresh(
                          onProgress: (progress, total, _) {
                            controller.set(progress, total);
                          },
                        );
                      },
                title: Text(Language.instance.REFRESH),
                subtitle: Text(Language.instance.REFRESH_SUBTITLE),
              ),
            if (isMobile)
              ListTile(
                dense: false,
                onTap: controller.progress != controller.total
                    ? showProgressDialog
                    : () async {
                        Collection.instance.index(
                          onProgress: (progress, total, _) {
                            controller.set(progress, total);
                          },
                        );
                      },
                title: Text(Language.instance.REINDEX),
                subtitle: Text(Language.instance.REINDEX_SUBTITLE),
              ),
            if (isMobile)
              () {
                final sizes = {
                  0: '0 MB',
                  512 * 1024: '512 KB',
                  1024 * 1024: '1 MB ${Language.instance.RECOMMENDED_HINT}',
                  2 * 1024 * 1024: '2 MB',
                  5 * 1024 * 1024: '5 MB',
                  10 * 1024 * 1024: '10 MB',
                  20 * 1024 * 1024: '20 MB',
                };
                return ListTile(
                  onTap: () async {
                    int value = Configuration.instance.minimumFileSize;
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(Language.instance.MINIMUM_FILE_SIZE),
                        contentPadding: EdgeInsets.only(top: 20.0),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Divider(
                              height: 1.0,
                              thickness: 1.0,
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height / 2,
                              ),
                              child: StatefulBuilder(
                                builder: (context, setState) =>
                                    SingleChildScrollView(
                                  child: Column(
                                    children: sizes.entries
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
                                              e.value,
                                              style: isDesktop
                                                  ? Theme.of(context)
                                                      .textTheme
                                                      .headline4
                                                  : null,
                                            ),
                                          ),
                                        )
                                        .toList(),
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
                              if (controller.progress != controller.total) {
                                showProgressDialog();
                                return;
                              }
                              Collection.instance.minimumFileSize = value;
                              await Configuration.instance.save(
                                minimumFileSize: value,
                              );
                              setState(() {});
                              await showShouldBeReindexedDialog();
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
                  },
                  dense: false,
                  title: Text(Language.instance.MINIMUM_FILE_SIZE),
                  subtitle: Text(
                    '${sizes[Configuration.instance.minimumFileSize] == null ? () {
                        if (Configuration.instance.minimumFileSize >
                            1024 * 1024) {
                          return '${(Configuration.instance.minimumFileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
                        } else {
                          return '${(Configuration.instance.minimumFileSize / 1024).toStringAsFixed(2)} KB';
                        }
                      }() : sizes[Configuration.instance.minimumFileSize]}',
                  ),
                );
              }(),
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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 12.0),
                  Container(
                    margin: EdgeInsets.only(left: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Language.instance.SELECTED_DIRECTORIES,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        if (!Platform.isAndroid || storages != null)
                          ...Configuration.instance.collectionDirectories
                              .map(
                                (directory) => Container(
                                  width: isMobile
                                      ? MediaQuery.of(context).size.width
                                      : 480.0,
                                  height: isMobile ? 56.0 : 40.0,
                                  margin: EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      directory.existsSync_()
                                          ? Container(
                                              width: 40.0,
                                              child: Icon(
                                                FluentIcons.folder_32_regular,
                                                size: 32.0,
                                              ),
                                            )
                                          : Tooltip(
                                              message: Language
                                                  .instance.FOLDER_NOT_FOUND,
                                              verticalOffset: 24.0,
                                              waitDuration: Duration.zero,
                                              child: Container(
                                                width: 40.0,
                                                child: Icon(
                                                  Icons.warning,
                                                  size: 24.0,
                                                ),
                                              ),
                                            ),
                                      SizedBox(width: isDesktop ? 2.0 : 16.0),
                                      Expanded(
                                        child: Text(
                                          storages == null
                                              ? directory.path.overflow
                                              : directory.path
                                                  .replaceAll(
                                                    storages!.first.path,
                                                    Language.instance.PHONE,
                                                  )
                                                  .replaceAll(
                                                    storages!.last.path,
                                                    Language.instance.SD_CARD,
                                                  )
                                                  .overflow,
                                          style: isMobile
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                              : null,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if (!controller.isCompleted) {
                                            showProgressDialog();
                                            return;
                                          }
                                          if (Configuration
                                                  .instance
                                                  .collectionDirectories
                                                  .length ==
                                              1) {
                                            showDialog(
                                              context: context,
                                              builder: (subContext) =>
                                                  AlertDialog(
                                                title: Text(
                                                  Language.instance.WARNING,
                                                ),
                                                content: Text(
                                                  Language.instance
                                                      .LAST_COLLECTION_DIRECTORY_REMOVED,
                                                  style: Theme.of(subContext)
                                                      .textTheme
                                                      .headline3,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(subContext)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      Language.instance.OK,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                            return;
                                          }
                                          await Collection.instance
                                              .removeDirectories(
                                            directories: [directory],
                                            onProgress:
                                                (progress, total, isCompleted) {
                                              controller.set(
                                                progress,
                                                total,
                                              );
                                            },
                                          );
                                          await Configuration.instance.save(
                                            collectionDirectories: Configuration
                                                .instance.collectionDirectories
                                              ..remove(directory),
                                          );
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
                        if (isDesktop) const SizedBox(height: 8.0),
                        if (controller.progress != controller.total &&
                            isDesktop)
                          Container(
                            height: 56.0,
                            width: isDesktop
                                ? 320.0
                                : MediaQuery.of(context).size.width,
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
                                            Language.instance.DISCOVERING_FILES,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3,
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 6.0),
                                            height: 4.0,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                32.0,
                                            child: LinearProgressIndicator(
                                              value: null,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.2),
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary),
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
                                          (Language.instance
                                              .SETTING_INDEXING_LINEAR_PROGRESS_INDICATOR
                                              .replaceAll(
                                            'NUMBER_STRING',
                                            controller.progress.toString(),
                                          )).replaceAll(
                                            'TOTAL_STRING',
                                            controller.total.toString(),
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3,
                                        ),
                                        builder: (_, dynamic value, child) =>
                                            Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            child!,
                                            Container(
                                              margin: EdgeInsets.only(
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
                                                        .secondary
                                                        .withOpacity(0.2),
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
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
                    ),
                  ),
                  if (isDesktop)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextButton(
                          onPressed: controller.progress != controller.total
                              ? showProgressDialog
                              : () async {
                                  Collection.instance.refresh(
                                    onProgress: (progress, total, _) {
                                      controller.set(progress, total);
                                    },
                                  );
                                },
                          child: Text(
                            Language.instance.REFRESH.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        TextButton(
                          onPressed: controller.progress != controller.total
                              ? showProgressDialog
                              : () async {
                                  Collection.instance.index(
                                    onProgress: (progress, total, _) {
                                      controller.set(progress, total);
                                    },
                                  );
                                },
                          child: Text(
                            Language.instance.REINDEX.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (isDesktop)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 8.0,
                        top: 0.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.0),
                          Text(
                            '${Language.instance.REFRESH.toUpperCase()}: ${Language.instance.REFRESH_INFORMATION}',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            '${Language.instance.REINDEX.toUpperCase()}: ${Language.instance.REINDEX_INFORMATION}',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                    ),
                  if (isDesktop) ...[
                    const SizedBox(height: 8.0),
                    TextButton(
                      onPressed: () async {
                        final sizes = {
                          0: '0 MB',
                          512 * 1024: '512 KB',
                          1024 * 1024:
                              '1 MB ${Language.instance.RECOMMENDED_HINT}',
                          2 * 1024 * 1024: '2 MB',
                          5 * 1024 * 1024: '5 MB',
                          10 * 1024 * 1024: '10 MB',
                          20 * 1024 * 1024: '20 MB',
                        };
                        int value = Configuration.instance.minimumFileSize;
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(Language.instance.MINIMUM_FILE_SIZE),
                            contentPadding: EdgeInsets.only(top: 20.0),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: 420.0,
                                  ),
                                  child: StatefulBuilder(
                                    builder: (context, setState) =>
                                        SingleChildScrollView(
                                      child: Column(
                                        children: sizes.entries
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
                                                  e.value,
                                                  style: isDesktop
                                                      ? Theme.of(context)
                                                          .textTheme
                                                          .headline4
                                                      : null,
                                                ),
                                              ),
                                            )
                                            .toList(),
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
                                  if (controller.progress != controller.total) {
                                    showProgressDialog();
                                    return;
                                  }
                                  Collection.instance.minimumFileSize = value;
                                  await Configuration.instance.save(
                                    minimumFileSize: value,
                                  );
                                  setState(() {});
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
                      },
                      child: Text('EDIT MINIMUM FILE SIZE'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 8.0,
                        top: 0.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.0),
                          Text(
                            Language.instance.MINIMUM_FILE_SIZE_WARNING,
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          const SizedBox(height: 8.0),
                        ],
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
        directories: [directory],
        onProgress: (progress, total, isCompleted) {
          CollectionRefresh.instance.set(progress, total);
        },
      );
      await Configuration.instance.save(
        collectionDirectories: Collection.instance.collectionDirectories,
      );
    }
  }

  void showProgressDialog() {
    if (!CollectionRefresh.instance.isCompleted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            Language.instance.INDEXING_ALREADY_GOING_ON_TITLE,
          ),
          content: Text(
            Language.instance.INDEXING_ALREADY_GOING_ON_SUBTITLE,
            style: Theme.of(context).textTheme.headline3,
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
  }

  Future<void> showShouldBeReindexedDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          Language.instance.WARNING,
        ),
        content: Text(
          Language.instance.MINIMUM_FILE_SIZE_WARNING,
          style: Theme.of(context).textTheme.headline3,
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

  @override
  bool get wantKeepAlive => true;
}
