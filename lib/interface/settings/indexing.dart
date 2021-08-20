import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

class IndexingSetting extends StatefulWidget {
  IndexingSetting({Key? key}) : super(key: key);
  IndexingState createState() => IndexingState();
}

class IndexingState extends State<IndexingSetting> {
  List<int>? linearProgressIndicatorValues;

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
            Text(
              configuration.collectionDirectories!
                  .map((directory) => directory.path)
                  .toList()
                  .join('\n'),
            ),
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
                                width: MediaQuery.of(context).size.width - 32.0,
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
        // TODO (alexmercerind): Add support for multiple directories.
        // MaterialButton(
        //   onPressed: () async {
        //     String? directoryPath =
        //         await FilePicker.platform.getDirectoryPath();
        //     if (directoryPath != null) {
        //       await Future.wait([
        //         configuration.save(
        //           collectionDirectory: new Directory(directoryPath),
        //         ),
        //         Provider.of<Collection>(context, listen: false).setDirectories(
        //           collectionDirectory: configuration.collectionDirectory,
        //           cacheDirectory: configuration.cacheDirectory,
        //           onProgress: (completed, total, isCompleted) {
        //             this.setState(() => this.linearProgressIndicatorValues = [
        //                   completed,
        //                   total
        //                 ]);
        //           },
        //         ),
        //       ]);
        //       this.setState(() => this.linearProgressIndicatorValues = null);
        //     }
        //   },
        //   child: Text(
        //     'CHANGE DIRECTORY',
        //     style: TextStyle(
        //       color: Theme.of(context).accentColor,
        //     ),
        //   ),
        // ),
        MaterialButton(
          onPressed: () async {
            await Provider.of<Collection>(context, listen: false).index(
              onProgress: (completed, total, isCompleted) {
                this.setState(() =>
                    this.linearProgressIndicatorValues = [completed, total]);
              },
            );
            this.setState(() => this.linearProgressIndicatorValues = null);
          },
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
