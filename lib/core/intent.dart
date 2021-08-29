import 'dart:io';
import 'package:flutter/services.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path/path.dart' as path;

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';

late Intent intent;

class Intent {
  File? file;

  Intent({this.file});

  static Future<void> init({List<String> args: const []}) async {
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

  Future<void> play() async {
    if (file != null) {
      Metadata metadata = await MetadataRetriever.fromFile(this.file!);
      Track track = Track.fromMap(metadata.toMap())!;
      if (track.trackName == 'Unknown Track') {
        track.trackName = path.basename(this.file!.path).split('.').first;
      }
      track.filePath = this.file!.path;
      if (metadata.albumArt != null) {
        File albumArtFile = File(
          path.join(
            configuration.cacheDirectory!.path,
            'albumArts',
            '${track.albumArtistName}_${track.albumName}'
                    .replaceAll(RegExp(r'[^\s\w]'), ' ') +
                '.PNG',
          ),
        );
        await albumArtFile.writeAsBytes(metadata.albumArt!);
      }
      Playback.play(
        tracks: <Track>[track],
        index: 0,
      );
    }
  }
}
