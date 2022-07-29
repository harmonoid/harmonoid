/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:filepicker_windows/filepicker_windows.dart';

import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/state/now_playing_visuals.dart';
import 'package:harmonoid/utils/widgets.dart';

class NowPlayingVisualsSetting extends StatefulWidget {
  NowPlayingVisualsSetting({Key? key}) : super(key: key);
  NowPlayingVisualsSettingState createState() =>
      NowPlayingVisualsSettingState();
}

class NowPlayingVisualsSettingState extends State<NowPlayingVisualsSetting> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      title: Language.instance.VISUALS_TITLE,
      subtitle: Language.instance.VISUALS,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              shrinkWrap: true,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              crossAxisCount:
                  (MediaQuery.of(context).size.width - 32.0) ~/ 100.0,
              children: NowPlayingVisuals.instance.preloaded
                      .map(
                        (e) => StillGIF.asset(
                          e,
                          height: 100.0,
                          width: 100.0,
                        ),
                      )
                      .toList()
                      .cast<Widget>() +
                  NowPlayingVisuals.instance.user
                      .map(
                        (e) => Stack(
                          children: [
                            StillGIF.file(
                              e,
                              height: 100.0,
                              width: 100.0,
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  await NowPlayingVisuals.instance.remove(e);
                                  setState(() {});
                                },
                                child: Container(
                                  height: 100.0,
                                  width: 100.0,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.close,
                                    size: 36.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList()
                      .cast<Widget>() +
                  [
                    InkWell(
                      onTap: () async {
                        // TODO: Using un-safe FileSystem APIs.
                        Uint8List? file;
                        if (Platform.isWindows) {
                          OpenFilePicker picker = OpenFilePicker()
                            ..filterSpecification = {
                              'Images': kSupportedImageFormats
                                  .map((e) => '*.$e')
                                  .join(';'),
                            }
                            ..defaultFilterIndex = 0
                            ..defaultExtension = kSupportedImageFormats.first;
                          file = await picker.getFile()!.readAsBytes();
                        }
                        if (Platform.isLinux) {
                          final xFile = await openFile(
                            acceptedTypeGroups: [
                              XTypeGroup(
                                label: 'Images',
                                extensions: kSupportedImageFormats +
                                    kSupportedImageFormats
                                        .map((e) => e.toLowerCase())
                                        .toList(),
                              ),
                            ],
                          );
                          if (xFile != null) {
                            file = await File(xFile.path).readAsBytes();
                          }
                        }
                        if (Platform.isAndroid ||
                            Platform.isIOS ||
                            Platform.isMacOS) {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                          );
                          if (result!.count > 0) {
                            file = result.files.first.bytes;
                          }
                        }
                        if (file != null) {
                          await NowPlayingVisuals.instance.add(file);
                          setState(() {});
                        }
                      },
                      child: Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).iconTheme.color!,
                            width: 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.add,
                          size: 36.0,
                        ),
                      ),
                    )
                  ],
            ),
          ],
        ),
      ),
    );
  }
}
