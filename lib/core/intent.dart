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
import 'package:flutter/services.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path/path.dart' as path;

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';

/// Intent
/// ------
///
/// Handles the opened audio file from file explorer.
/// Primary purpose being to retrieve the path, saving metadata & playback of the possibly opened file.
///
class Intent {
  /// The opened audio file from file explorer.
  /// `null` if no file was opened.
  File? file;

  Intent({this.file});

  /// Initializes the intent & checks for possibly opened file.
  ///
  static Future<void> initialize({List<String> args: const []}) async {
    if (Platform.isAndroid) {
      try {
        File file = await Intent.openFile;
        intent = Intent(
          file: file,
        );
      } catch (exception) {
        intent = Intent();
      }
    }
    if (Platform.isWindows || Platform.isLinux) {
      if (args.isNotEmpty)
        intent = Intent(
          file: File(args.first),
        );
      else
        intent = Intent();
    }
  }

  /// Returns the opened file on Android.
  ///
  static Future<File> get openFile async {
    String? response =
        await MethodChannel('com.alexmercerind.harmonoid/openFile')
            .invokeMethod('getOpenFile', {});
    String filePath = response!;
    File file = File(filePath);
    if (await file.exists())
      return file;
    else
      throw Exception();
  }

  /// Starts playing the possibly opened file & saves its metdaata.
  ///
  Future<void> play() async {
    if (file != null) {
      var metadata = await MetadataRetriever.fromFile(this.file!);
      var track = Track.fromJson(
          metadata.toJson()..putIfAbsent('filePath', () => this.file!.path));
      track.filePath = this.file!.path;
      if (metadata.albumArt != null) {
        await File(path.join(
          configuration.cacheDirectory!.path,
          'AlbumArts',
          track.albumArtBasename,
        )).writeAsBytes(metadata.albumArt!);
      }
      Playback.play(
        tracks: <Track>[track],
        index: 0,
      );
    }
  }
}

/// Late initialized intent object instance.
late Intent intent;
