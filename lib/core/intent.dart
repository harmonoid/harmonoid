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
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:libmpv/libmpv.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'package:harmonoid/models/media.dart' hide Media;
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';

/// Intent
/// ------
///
/// Handles the opened audio file from file explorer in [Harmonoid](https://github.com/harmonoid/harmonoid).
/// Primary purpose being to retrieve the path, saving metadata & playback of the possibly opened file.
///
class Intent {
  /// [Intent] object instance. Must call [Intent.initialize].
  static late Intent instance = Intent();

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
        instance = Intent(
          file: file,
        );
      } catch (exception) {
        instance = Intent();
      }
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (args.isNotEmpty)
        instance = Intent(
          file: File(args.first),
        );
      else
        instance = Intent();
    }
  }

  /// Returns the opened file on Android.
  ///
  static Future<File> get openFile async {
    String? response =
        await MethodChannel('com.alexmercerind.harmonoid/openFile')
            .invokeMethod('getOpenFile', {});
    String uri = response!;
    File file = File(uri);
    if (await file.exists())
      return file;
    else
      throw Exception();
  }

  /// Starts playing the possibly opened file & saves its metadata before doing it.
  ///
  Future<void> play() async {
    if (file != null) {
      var metadata = <String, String>{
        'uri': file!.uri.toString(),
      };
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        try {
          metadata.addAll(await tagger.parse(
            Media(file!.uri.toString()),
            coverDirectory: Collection.instance.albumArtDirectory,
          ));
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        final track = Track.fromTagger(metadata);
        Playback.instance.open([track]);
      } else {
        final _metadata = await MetadataRetriever.fromFile(file!);
        metadata.addAll(_metadata.toJson().cast());
        final track = Track.fromTagger(metadata);
        if (_metadata.albumArt != null) {
          await File(path.join(
            Collection.instance.cacheDirectory.path,
            kAlbumArtsDirectoryName,
            track.albumArtFileName,
          )).writeAsBytes(_metadata.albumArt!);
        }
        Playback.instance.open([track]);
      }
    }
  }
}
