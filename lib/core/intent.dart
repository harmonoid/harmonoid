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
import 'package:libmpv/libmpv.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:ytm_client/ytm_client.dart' hide Media, Track;

import 'package:harmonoid/models/media.dart' hide Media;
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/file_system.dart';

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
  /// If no file was opened, then load the last playing playlist from [AppState].
  ///
  Future<void> play() async {
    final Tagger tagger = Tagger();
    if (file != null) {
      await Playback.instance.loadAppState(open: false);
      final metadata = <String, dynamic>{
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
        await Playback.instance.open([track]);
        DesktopNowPlayingController.instance.maximize();
      } else {
        final _metadata = await MetadataRetriever.fromUri(
          file!.uri,
          coverDirectory: Collection.instance.albumArtDirectory,
        );
        metadata.addAll(_metadata.toJson().cast());
        final track = Track.fromJson(metadata);
        await Playback.instance.open([track]);
        MobileNowPlayingController.instance.maximize();
      }
    } else if (directory != null) {
      await Playback.instance.loadAppState(open: false);
      bool playing = false;
      for (final file
          in await directory!.list_(extensions: kSupportedFileTypes)) {
        if (kSupportedFileTypes.contains(file.extension)) {
          final metadata = <String, dynamic>{
            'uri': file.uri.toString(),
          };
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
            try {
              metadata.addAll(await tagger.parse(
                Media(file.uri.toString()),
                coverDirectory: Collection.instance.albumArtDirectory,
              ));
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
            final track = Track.fromTagger(metadata);
            if (!playing) {
              await Playback.instance.open([track]);
              DesktopNowPlayingController.instance.maximize();
              playing = true;
            } else {
              Playback.instance.add([track]);
            }
          } else {
            try {
              final _metadata = await MetadataRetriever.fromUri(
                file.uri,
                coverDirectory: Collection.instance.albumArtDirectory,
              );
              metadata.addAll(_metadata.toJson().cast());
              final track = Track.fromJson(metadata);
              if (!playing) {
                await Playback.instance.open([track]);
                MobileNowPlayingController.instance.maximize();
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
    } else {
      await Playback.instance.loadAppState();
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // no-op for desktop platforms.
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Show the [MiniNowPlayingBar] if a playlist was opened during last running instance of the app.
        MobileNowPlayingController.instance.show();
      }
    }
  }

  /// Identifies the object represented by the [uri].
  /// If it's recognized [Media] format, then metadata is saved & playback is started.
  /// Currently handles:
  /// * [Directory]
  /// * [File]
  /// * [Media] [Uri]
  /// * Web [Media] [Uri]
  ///
  Future<void> playUri(Uri uri) async {
    if (Plugins.isWebMedia(uri)) {
      await Playback.instance.open([
        Track.fromWebTrack((await YTMClient.player(uri.toString()))!.toJson())
      ]);
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        DesktopNowPlayingController.instance.maximize();
      } else if (Platform.isAndroid || Platform.isIOS) {
        MobileNowPlayingController.instance.maximize();
      }
    } else if (uri.isScheme('HTTP') ||
        uri.isScheme('HTTPS') ||
        uri.isScheme('FTP') ||
        uri.isScheme('RSTP')) {
      final metadata = <String, dynamic>{
        'uri': uri.toString(),
      };
      metadata.addAll(
        await tagger.parse(
          Media(uri.toString()),
          coverDirectory: Collection.instance.albumArtDirectory,
        ),
      );
      final track = Track.fromTagger(metadata);
      await Playback.instance.open([track]);
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        DesktopNowPlayingController.instance.maximize();
      } else if (Platform.isAndroid || Platform.isIOS) {
        MobileNowPlayingController.instance.maximize();
      }
    } else if (FileSystemEntity.typeSync(uri.toFilePath()) ==
        FileSystemEntityType.file) {
      final metadata = <String, dynamic>{
        'uri': uri.toString(),
      };
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        try {
          metadata.addAll(
            await tagger.parse(
              Media(uri.toString()),
              coverDirectory: Collection.instance.albumArtDirectory,
            ),
          );
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        final track = Track.fromTagger(metadata);
        await Playback.instance.open([track]);
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          DesktopNowPlayingController.instance.maximize();
        } else if (Platform.isAndroid || Platform.isIOS) {
          MobileNowPlayingController.instance.maximize();
        }
      } else {
        final _metadata = await MetadataRetriever.fromUri(
          uri,
          coverDirectory: Collection.instance.albumArtDirectory,
        );
        metadata.addAll(_metadata.toJson().cast());
        final track = Track.fromJson(metadata);
        await Playback.instance.open([track]);
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          DesktopNowPlayingController.instance.maximize();
        } else if (Platform.isAndroid || Platform.isIOS) {
          MobileNowPlayingController.instance.maximize();
        }
      }
    } else if (FileSystemEntity.typeSync(uri.toFilePath()) ==
        FileSystemEntityType.directory) {
      bool playing = false;
      for (final file in await Directory(uri.toFilePath())
          .list_(extensions: kSupportedFileTypes)) {
        if (kSupportedFileTypes.contains(file.extension)) {
          final metadata = <String, dynamic>{
            'uri': file.uri.toString(),
          };
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
            try {
              metadata.addAll(await tagger.parse(
                Media(file.uri.toString()),
                coverDirectory: Collection.instance.albumArtDirectory,
              ));
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
            final track = Track.fromTagger(metadata);
            if (!playing) {
              await Playback.instance.open([track]);
              if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                DesktopNowPlayingController.instance.maximize();
              } else if (Platform.isAndroid || Platform.isIOS) {
                MobileNowPlayingController.instance.maximize();
              }
              playing = true;
            } else {
              Playback.instance.add([track]);
            }
          } else {
            try {
              final _metadata = await MetadataRetriever.fromUri(
                file.uri,
                coverDirectory: Collection.instance.albumArtDirectory,
              );
              metadata.addAll(_metadata.toJson().cast());
              final track = Track.fromJson(metadata);
              if (!playing) {
                await Playback.instance.open([track]);
                if (Platform.isWindows ||
                    Platform.isLinux ||
                    Platform.isMacOS) {
                  DesktopNowPlayingController.instance.maximize();
                } else if (Platform.isAndroid || Platform.isIOS) {
                  MobileNowPlayingController.instance.maximize();
                }
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
}
