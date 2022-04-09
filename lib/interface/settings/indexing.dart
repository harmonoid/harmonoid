/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/utils/rendering.dart';
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
        child: Container(
          margin: EdgeInsets.only(left: 8, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 2.0,
              ),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  MaterialButton(
                    onPressed: controller.isOngoing
                        ? () {
                            if (!controller.isCompleted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Theme.of(context).cardColor,
                                  title: Text(
                                    Language.instance
                                        .INDEXING_ALREADY_GOING_ON_TITLE,
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                  ),
                                  content: Text(
                                    Language.instance
                                        .INDEXING_ALREADY_GOING_ON_SUBTITLE,
                                    style:
                                        Theme.of(context).textTheme.headline3,
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
                        : () async {
                            if (!controller.isCompleted) {
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Theme.of(context).cardColor,
                                  title: Text(
                                    Language.instance
                                        .INDEXING_ALREADY_GOING_ON_TITLE,
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                  ),
                                  content: Text(
                                    Language.instance
                                        .INDEXING_ALREADY_GOING_ON_SUBTITLE,
                                    style:
                                        Theme.of(context).textTheme.headline3,
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
                              return;
                            }
                            Directory? directory;
                            if (Platform.isWindows) {
                              DirectoryPicker picker = new DirectoryPicker();
                              directory = picker.getDirectory();
                            }
                            if (Platform.isLinux) {
                              var path = await getDirectoryPath();
                              if (path != null) {
                                directory = Directory(path);
                              }
                            }
                            if (Platform.isAndroid ||
                                Platform.isIOS ||
                                Platform.isMacOS) {
                              var path =
                                  await FilePicker.platform.getDirectoryPath();
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
                                    controller.set(progress, total);
                                  });
                              await Configuration.instance.save(
                                collectionDirectories:
                                    Collection.instance.collectionDirectories,
                              );
                            }
                          },
                    child: Text(
                      Language.instance.ADD_NEW_FOLDER,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
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
                              width: 320.0,
                              height: 42.0,
                              margin: EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    FluentIcons.folder_32_regular,
                                    size: 32.0,
                                  ),
                                  SizedBox(width: 4.0),
                                  Expanded(
                                    child: Text(
                                      directory.path.overflow,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      if (!controller.isCompleted) {
                                        await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor:
                                                Theme.of(context).cardColor,
                                            title: Text(
                                              Language.instance
                                                  .INDEXING_ALREADY_GOING_ON_TITLE,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline1,
                                            ),
                                            content: Text(
                                              Language.instance
                                                  .INDEXING_ALREADY_GOING_ON_SUBTITLE,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline3,
                                            ),
                                            actions: [
                                              MaterialButton(
                                                textColor: Theme.of(context)
                                                    .primaryColor,
                                                onPressed:
                                                    Navigator.of(context).pop,
                                                child:
                                                    Text(Language.instance.OK),
                                              ),
                                            ],
                                          ),
                                        );
                                        return;
                                      }
                                      if (Configuration.instance
                                              .collectionDirectories.length ==
                                          1) {
                                        showDialog(
                                          context: context,
                                          builder: (subContext) => AlertDialog(
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
                                                child:
                                                    Text(Language.instance.OK),
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
                                    child: Text(
                                      Language.instance.REMOVE,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList() +
                      [
                        Container(
                          height: 56.0,
                          width: 320.0,
                          alignment: Alignment.centerLeft,
                          child: controller.progress != controller.total
                              ? Column(
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
                                                    .headline4,
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
                                                  .headline4,
                                            ),
                                            builder:
                                                (_, dynamic value, child) =>
                                                    Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                child!,
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 6.0),
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
                                )
                              : Container(
                                  child: Chip(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  avatar: Icon(
                                    FluentIcons.checkmark_circle_48_regular,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    Language.instance.SETTING_INDEXING_DONE,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        SizedBox(
                          height: 2.0,
                        ),
                        if (controller.progress != controller.total)
                          Text(
                            Language.instance.COLLECTION_INDEXING_LABEL,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: [
                  MaterialButton(
                    onPressed: controller.progress != controller.total
                        ? () {}
                        : () async {
                            Collection.instance.refresh(
                              onProgress: (progress, total, isCompleted) {
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
                  MaterialButton(
                    onPressed: controller.progress != controller.total
                        ? () {}
                        : () async {
                            Collection.instance.index(
                              onProgress: (progress, total, isCompleted) {
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
              Padding(
                padding: EdgeInsets.only(
                  left: 8.0,
                  top: 4.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${Language.instance.REFRESH}: ${Language.instance.REFRESH_INFORMATION}',
                        style: TextStyle(fontWeight: FontWeight.normal)),
                    Text(
                        '${Language.instance.REINDEX}: ${Language.instance.REINDEX_INFORMATION}',
                        style: TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
