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
import 'package:harmonoid/utils/widgets.dart';
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
        title: language!.STRING_SETTING_INDEXING_TITLE,
        subtitle: language!.STRING_SETTING_INDEXING_SUBTITLE,
        child: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Selected directories:',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                ] +
                configuration.collectionDirectories!
                    .map(
                      (directory) => Container(
                        margin: EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                    builder: (subContext) =>
                                        FractionallyScaledWidget(
                                      child: AlertDialog(
                                        backgroundColor: Theme.of(context)
                                            .appBarTheme
                                            .backgroundColor,
                                        title: Text(
                                          language!.STRING_WARNING,
                                          style: Theme.of(subContext)
                                              .textTheme
                                              .headline1,
                                        ),
                                        content: Text(
                                          language!
                                              .STRING_LAST_COLLECTION_DIRECTORY_REMOVED,
                                          style: Theme.of(subContext)
                                              .textTheme
                                              .headline5,
                                        ),
                                        actions: [
                                          MaterialButton(
                                            textColor:
                                                Theme.of(context).primaryColor,
                                            onPressed: () async {
                                              Navigator.of(subContext).pop();
                                            },
                                            child: Text(language!.STRING_OK),
                                          ),
                                        ],
                                      ),
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
                                  onProgress: (progress, total, isCompleted) {
                                    collectionRefresh.set(progress, total);
                                  },
                                );
                              },
                              child: Text(
                                'REMOVE',
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
                  SizedBox(
                    height: 4.0,
                  ),
                  Divider(color: Colors.transparent, height: 4.0),
                  Container(
                    alignment: Alignment.topLeft,
                    child: controller.progress != controller.total
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TweenAnimationBuilder(
                                tween: Tween<double>(
                                  begin: 0,
                                  end: controller.progress / controller.total,
                                ),
                                duration: Duration(milliseconds: 400),
                                child: Text(
                                  (language!
                                      .STRING_SETTING_INDEXING_LINEAR_PROGRESS_INDICATOR
                                      .replaceAll(
                                    'NUMBER_STRING',
                                    controller.progress.toString(),
                                  )).replaceAll(
                                    'TOTAL_STRING',
                                    controller.total.toString(),
                                  ),
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                builder: (_, dynamic value, child) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    child!,
                                    Container(
                                      margin: EdgeInsets.only(top: 6.0),
                                      height: 4.0,
                                      width: MediaQuery.of(context)
                                              .size
                                              .width
                                              .normalized -
                                          32.0,
                                      child: LinearProgressIndicator(
                                        value: value,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.2),
                                        valueColor: AlwaysStoppedAnimation(
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 12.0,
                              ),
                              Text(
                                language!.STRING_COLLECTION_INDEXING_LABEL,
                                overflow: TextOverflow.ellipsis,
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
                              language!.STRING_SETTING_INDEXING_DONE,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                  ),
                  // No longer necessary.
                  // Text(
                  //   language!.STRING_SETTING_INDEXING_WARNING,
                  //   style: Theme.of(context).textTheme.headline4,
                  // ),
                ],
          ),
        ),
        actions: [
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
                      var path = await FilePicker.platform.getDirectoryPath();
                      if (path != null) {
                        directory = Directory(path);
                      }
                    }
                    if (directory != null) {
                      await configuration.save(
                        collectionDirectories:
                            configuration.collectionDirectories! + [directory],
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
              language!.STRING_ADD_NEW_FOLDER,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
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
              language!.STRING_REFRESH,
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
