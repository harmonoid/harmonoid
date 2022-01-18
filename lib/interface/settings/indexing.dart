/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

class IndexingSetting extends StatefulWidget {
  IndexingSetting({Key? key}) : super(key: key);
  IndexingState createState() => IndexingState();
}

class IndexingState extends State<IndexingSetting> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionRefreshController>(
      builder: (context, controller, _) => SettingsTile(
        title: language.SETTING_INDEXING_TITLE,
        subtitle: language.SETTING_INDEXING_SUBTITLE,
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
                    onPressed: controller.progress != controller.total
                        ? () {}
                        : () async {
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
                              await configuration.save(
                                collectionDirectories:
                                    configuration.collectionDirectories! +
                                        [directory],
                              );
                              collection.setDirectories(
                                  collectionDirectories:
                                      configuration.collectionDirectories,
                                  cacheDirectory: configuration.cacheDirectory,
                                  onProgress: (progress, total, isCompleted) {
                                    collectionRefresh.set(progress, total);
                                  });
                            }
                          },
                    child: Text(
                      language.ADD_NEW_FOLDER,
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
                          language.SELECTED_DIRECTORIES,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                      ] +
                      configuration.collectionDirectories!
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
                                      directory.path,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      if (configuration
                                              .collectionDirectories!.length ==
                                          1) {
                                        showDialog(
                                          context: context,
                                          builder: (subContext) => AlertDialog(
                                            title: Text(
                                              language.WARNING,
                                              style: Theme.of(subContext)
                                                  .textTheme
                                                  .headline1,
                                            ),
                                            content: Text(
                                              language
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
                                                child: Text(language.OK),
                                              ),
                                            ],
                                          ),
                                        );
                                        return;
                                      }
                                      configuration.collectionDirectories!
                                          .remove(directory);
                                      await configuration.save(
                                        collectionDirectories:
                                            configuration.collectionDirectories,
                                      );
                                      collection.refresh(
                                        onProgress:
                                            (progress, total, isCompleted) {
                                          collectionRefresh.set(
                                              progress, total);
                                        },
                                      );
                                    },
                                    child: Text(
                                      language.REMOVE,
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
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(
                                        begin: 0,
                                        end: controller.progress /
                                            controller.total,
                                      ),
                                      duration: Duration(milliseconds: 400),
                                      child: Text(
                                        (language
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
                                      builder: (_, dynamic value, child) =>
                                          Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          child!,
                                          Container(
                                            margin: EdgeInsets.only(top: 6.0),
                                            height: 4.0,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                32.0,
                                            child: LinearProgressIndicator(
                                              value: value,
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
                                    language.SETTING_INDEXING_DONE,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        // No longer necessary.
                        // Text(
                        //   language.SETTING_INDEXING_WARNING,
                        //   style: Theme.of(context).textTheme.headline4,
                        // ),
                        SizedBox(
                          height: 2.0,
                        ),
                        if (controller.progress != controller.total)
                          Text(
                            language.COLLECTION_INDEXING_LABEL,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                ),
              )
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: controller.progress != controller.total
                ? () {}
                : () async {
                    collection.index(
                      onProgress: (progress, total, isCompleted) {
                        collectionRefresh.set(progress, total);
                      },
                    );
                  },
            child: Text(
              language.REFRESH,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
