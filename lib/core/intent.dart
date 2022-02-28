/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:libmpv/libmpv.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'package:harmonoid/models/media.dart' hide Media;
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/state/now_playing_launcher.dart';
import 'package:harmonoid/utils/file_system.dart';

import 'package:harmonoid/youtube/youtube_api.dart';

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
  final File? file;

  /// `Add to Harmonoid's Playlist` on Windows.
  final Directory? directory;

  Intent({this.file, this.directory});

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
      if (args.isNotEmpty) {
        if (FileSystemEntity.typeSync(args.first) ==
            FileSystemEntityType.file) {
          instance = Intent(
            file: File(args.first),
          );
        } else {
          instance = Intent(
            directory: Directory(args.first),
          );
        }
      } else {
        instance = Intent();
      }
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
    if (await file.exists_())
      return file;
    else
      throw Exception();
  }

  /// Starts playing the possibly opened file & saves its metadata before doing it.
  ///
  Future<void> play() async {
    if (file != null) {
      final metadata = <String, String>{
        'uri': file!.uri.toString(),
      };
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        try {
          metadata.addAll(await tagger.parse(
            file!.uri.toString(),
            coverDirectory: Collection.instance.albumArtDirectory,
          ));
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        final track = Track.fromTagger(metadata);
        Playback.instance.open([track]);
        NowPlayingLauncher.instance.maximized = true;
      } else {
        final _metadata = await MetadataRetriever.fromFile(file!);
        metadata.addAll(_metadata.toJson().cast());
        final track = Track.fromJson(metadata);
        if (_metadata.albumArt != null) {
          await File(path.join(
            Collection.instance.cacheDirectory.path,
            kAlbumArtsDirectoryName,
            track.albumArtFileName,
          )).writeAsBytes(_metadata.albumArt!);
        }
        Playback.instance.open([track]);
        NowPlayingLauncher.instance.maximized = true;
      }
    }
    if (directory != null) {
      bool playing = false;
      for (final file in await directory!.list_()) {
        if (kSupportedFileTypes.contains(file.extension)) {
          final metadata = <String, String>{
            'uri': file.uri.toString(),
          };
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
            try {
              metadata.addAll(await tagger.parse(
                file.uri.toString(),
                coverDirectory: Collection.instance.albumArtDirectory,
              ));
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
            final track = Track.fromTagger(metadata);
            if (!playing) {
              Playback.instance.open([track]);
              NowPlayingLauncher.instance.maximized = true;
              playing = true;
            } else {
              Playback.instance.add([track]);
            }
          } else {
            try {
              final _metadata = await MetadataRetriever.fromFile(file);
              metadata.addAll(_metadata.toJson().cast());
              final track = Track.fromJson(metadata);
              if (_metadata.albumArt != null) {
                await File(path.join(
                  Collection.instance.cacheDirectory.path,
                  kAlbumArtsDirectoryName,
                  track.albumArtFileName,
                )).writeAsBytes(_metadata.albumArt!);
              }
              if (!playing) {
                Playback.instance.open([track]);
                NowPlayingLauncher.instance.maximized = true;
                playing = true;
              } else {
                Playback.instance.add([track]);
              }
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
          }
        }
      }
    }
  }

  /// Starts playing the possibly opened file & saves its metadata before doing it.
  ///
  Future<void> playUri(Uri uri) async {
    if (uri.isScheme('FILE') || await File(uri.toString()).exists_()) {
      final metadata = <String, String>{
        'uri': uri.toString(),
      };
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        try {
          metadata.addAll(
            await tagger.parse(
              uri.toString(),
              coverDirectory: Collection.instance.albumArtDirectory,
            ),
          );
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        final track = Track.fromTagger(metadata);
        Playback.instance.open([track]);
        NowPlayingLauncher.instance.maximized = true;
      } else {
        final _metadata =
            await MetadataRetriever.fromFile(File(uri.toFilePath()));
        metadata.addAll(_metadata.toJson().cast());
        final track = Track.fromJson(metadata);
        if (_metadata.albumArt != null) {
          await File(path.join(
            Collection.instance.cacheDirectory.path,
            kAlbumArtsDirectoryName,
            track.albumArtFileName,
          )).writeAsBytes(_metadata.albumArt!);
        }
        Playback.instance.open([track]);
        NowPlayingLauncher.instance.maximized = true;
      }
    } else {
      if (Plugins.isExternalMedia(uri)) {
        Playback.instance.open([(await YoutubeApi.getTrack(uri.toString()))!]);
      } else {
        Playback.instance.open([
          Track(
            uri: uri,
            trackName: uri.toString(),
            albumName: kUnknownAlbum,
            trackNumber: 1,
            albumArtistName: kUnknownArtist,
            trackArtistNames: [kUnknownArtist],
            year: '${DateTime.now().year}',
            timeAdded: DateTime.now(),
            duration: Duration.zero,
            bitrate: 0,
          )
        ]);
      }
    }
  }
}
