import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

class IndexingSetting extends StatefulWidget {
  IndexingSetting({Key? key}) : super(key: key);
  IndexingState createState() => IndexingState();
}

class IndexingState extends State<IndexingSetting> {
  List<dynamic>? linearProgressIndicatorValues;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
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
                          Text(directory.path),
                          MaterialButton(
                            onPressed: () async {
                              // TODO (alexmercerind): Show alert dialog.
                              if (configuration.collectionDirectories!.length ==
                                  1) return;
                              configuration.collectionDirectories!
                                  .remove(directory);
                              await configuration.save(
                                collectionDirectories:
                                    configuration.collectionDirectories,
                              );
                              this.setState(() {});
                              Provider.of<Collection>(context, listen: false)
                                  .refresh(
                                onProgress: (progress, total, completed) =>
                                    this.setState(
                                  () => this.linearProgressIndicatorValues = [
                                    progress,
                                    total
                                  ],
                                ),
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
                  height: 56.0,
                  alignment: Alignment.topLeft,
                  child: this.linearProgressIndicatorValues != null
                      ? TweenAnimationBuilder(
                          tween: Tween<double>(
                              begin: 0,
                              end: this.linearProgressIndicatorValues![0] /
                                  this.linearProgressIndicatorValues![1]),
                          duration: Duration(milliseconds: 400),
                          child: Text(
                            (language!
                                    .STRING_SETTING_INDEXING_LINEAR_PROGRESS_INDICATOR
                                    .replaceAll(
                                        'NUMBER_STRING',
                                        this
                                            .linearProgressIndicatorValues![0]
                                            .toString()))
                                .replaceAll(
                                    'TOTAL_STRING',
                                    this
                                        .linearProgressIndicatorValues![1]
                                        .toString()),
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          builder: (_, dynamic value, child) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  child!,
                                  Container(
                                    margin: EdgeInsets.only(top: 6.0),
                                    height: 4.0,
                                    width: MediaQuery.of(context).size.width -
                                        32.0,
                                    child: LinearProgressIndicator(
                                      value: value,
                                      valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).accentColor),
                                    ),
                                  ),
                                ],
                              ))
                      : Container(
                          child: Chip(
                          backgroundColor: Theme.of(context).accentColor,
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
                Text(
                  language!.STRING_SETTING_INDEXING_WARNING,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () async {
            Directory? directory;
            // TODO (alexmercerind): Handle Android specific calls. Will require requestLegacyExternalStorage.
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
            if (directory != null) {
              await Future.wait([
                configuration.save(
                  collectionDirectories:
                      configuration.collectionDirectories! + [directory],
                ),
                Provider.of<Collection>(context, listen: false).setDirectories(
                  collectionDirectories: configuration.collectionDirectories,
                  cacheDirectory: configuration.cacheDirectory,
                  onProgress: (progress, total, completed) {
                    this.setState(() => this.linearProgressIndicatorValues = [
                          progress,
                          total,
                          completed
                        ]);
                  },
                ),
              ]);
              this.setState(() => this.linearProgressIndicatorValues = null);
            }
          },
          child: Text(
            'ADD NEW FOLDER',
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
        MaterialButton(
          onPressed: this.linearProgressIndicatorValues == null
              ? () async {
                  await Provider.of<Collection>(context, listen: false).index(
                    onProgress: (progress, total, completed) {
                      this.setState(() => this.linearProgressIndicatorValues = [
                            progress,
                            total
                          ]);
                    },
                  );
                  this.setState(
                      () => this.linearProgressIndicatorValues = null);
                }
              : () {},
          child: Text(
            language!.STRING_REFRESH,
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ],
    );
  }
}
