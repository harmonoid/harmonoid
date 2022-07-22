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
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/file_system.dart';
import 'package:harmonoid/constants/language.dart';

class IndexingSetting extends StatefulWidget {
  IndexingSetting({Key? key}) : super(key: key);
  IndexingState createState() => IndexingState();
}

class IndexingState extends State<IndexingSetting> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionRefresh>(
      builder: (context, controller, _) => SettingsTile(
        title: Language.instance.SETTING_INDEXING_TITLE,
        subtitle: Language.instance.SETTING_INDEXING_SUBTITLE,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2.0),
            if (isMobile)
              CorrectedListTile(
                onTap: controller.isCompleted
                    ? _addNewFolder
                    : _showProgressDialog,
                iconData: Icons.create_new_folder,
                title: Language.instance.ADD_NEW_FOLDER,
                subtitle: Language.instance.ADD_NEW_FOLDER_SUBTITLE,
              ),
            if (isMobile)
              CorrectedListTile(
                onTap: controller.progress != controller.total
                    ? _showProgressDialog
                    : () async {
                        Collection.instance.refresh(
                          onProgress: (progress, total, _) {
                            controller.set(progress, total);
                          },
                        );
                      },
                iconData: Icons.refresh,
                title: Language.instance.REFRESH,
                subtitle: Language.instance.REFRESH_SUBTITLE,
              ),
            if (isMobile)
              CorrectedListTile(
                onTap: controller.progress != controller.total
                    ? _showProgressDialog
                    : () async {
                        Collection.instance.index(
                          onProgress: (progress, total, _) {
                            controller.set(progress, total);
                          },
                        );
                      },
                iconData: Icons.data_usage,
                title: Language.instance.REINDEX,
                subtitle: Language.instance.REINDEX_SUBTITLE,
              ),
            Container(
              margin: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop)
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          MaterialButton(
                            minWidth: 0.0,
                            padding: EdgeInsets.zero,
                            onPressed: CollectionRefresh.instance.isCompleted
                                ? _addNewFolder
                                : _showProgressDialog,
                            child: Text(
                              Language.instance.ADD_NEW_FOLDER.toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 8.0),
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
                              height: 4.0,
                            ),
                          ] +
                          Configuration.instance.collectionDirectories
                              .map(
                                (directory) => Container(
                                  width: isMobile
                                      ? MediaQuery.of(context).size.width
                                      : 560.0,
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
                                          directory.path
                                              .replaceAll(
                                                '/storage/emulated/0/',
                                                '',
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
                                      MaterialButton(
                                        onPressed: () async {
                                          if (!controller.isCompleted) {
                                            _showProgressDialog();
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
                                                  style: Theme.of(subContext)
                                                      .textTheme
                                                      .headline1,
                                                ),
                                                content: Text(
                                                  Language.instance
                                                      .LAST_COLLECTION_DIRECTORY_REMOVED,
                                                  style: Theme.of(subContext)
                                                      .textTheme
                                                      .headline3,
                                                ),
                                                actions: [
                                                  MaterialButton(
                                                    textColor: Theme.of(context)
                                                        .primaryColor,
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
                                          await Collection.instance
                                              .removeDirectories(
                                            directories: [directory],
                                            onProgress:
                                                (progress, total, isCompleted) {
                                              controller.set(progress, total);
                                            },
                                          );
                                          await Configuration.instance.save(
                                            collectionDirectories: Configuration
                                                .instance.collectionDirectories
                                              ..remove(directory),
                                          );
                                        },
                                        minWidth: 0.0,
                                        child: Text(
                                          Language.instance.REMOVE
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList() +
                          [
                            if (isDesktop) SizedBox(height: 8.0),
                            if (controller.progress != controller.total)
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
                                                Language
                                                    .instance.DISCOVERING_FILES,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3,
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 6.0),
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
                                            duration:
                                                Duration(milliseconds: 400),
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
                                            builder:
                                                (_, dynamic value, child) =>
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
                                                  child:
                                                      LinearProgressIndicator(
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
                                                                .secondary),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            if (controller.progress != controller.total)
                              Padding(
                                padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                                child: Text(
                                  Language.instance.COLLECTION_INDEXING_LABEL,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.headline3,
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
                        const SizedBox(width: 8.0),
                        MaterialButton(
                          minWidth: 0.0,
                          padding: EdgeInsets.zero,
                          onPressed: controller.progress != controller.total
                              ? _showProgressDialog
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
                        const SizedBox(width: 12.0),
                        MaterialButton(
                          minWidth: 0.0,
                          padding: EdgeInsets.zero,
                          onPressed: controller.progress != controller.total
                              ? _showProgressDialog
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
                        top: 4.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              const SizedBox(width: 8.0),
                              Icon(Icons.info),
                              const SizedBox(width: 8.0),
                              Text(
                                '${Language.instance.REFRESH.toUpperCase()}: ${Language.instance.REFRESH_INFORMATION}',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              const SizedBox(width: 8.0),
                              Icon(Icons.info),
                              const SizedBox(width: 8.0),
                              Text(
                                '${Language.instance.REINDEX.toUpperCase()}: ${Language.instance.REINDEX_INFORMATION}',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ],
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
    );
  }

  void _showProgressDialog() {
    if (!CollectionRefresh.instance.isCompleted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            Language.instance.INDEXING_ALREADY_GOING_ON_TITLE,
            style: Theme.of(context).textTheme.headline1,
          ),
          content: Text(
            Language.instance.INDEXING_ALREADY_GOING_ON_SUBTITLE,
            style: Theme.of(context).textTheme.headline3,
          ),
          actions: [
            MaterialButton(
              textColor: Theme.of(context).primaryColor,
              onPressed: Navigator.of(context).pop,
              child: Text(Language.instance.OK),
            ),
          ],
        ),
      );
    }
  }

  void _addNewFolder() async {
    Directory? directory;
    if (Platform.isWindows) {
      DirectoryPicker picker = new DirectoryPicker();
      directory = picker.getDirectory();
    }
    if (Platform.isLinux) {
      final path = await getDirectoryPath();
      if (path != null) {
        directory = Directory(path);
      }
    }
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      final path = await FilePicker.platform.getDirectoryPath();
      if (path != null) {
        directory = Directory(path);
      }
    }
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
}
