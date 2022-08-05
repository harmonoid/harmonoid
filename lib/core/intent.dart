/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:libmpv/libmpv.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:synchronized/synchronized.dart';
import 'package:media_library/media_library.dart' hide Media;
import 'package:ytm_client/ytm_client.dart' hide Media, Track;
import 'package:safe_session_storage/safe_session_storage.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';

/// Intent
/// ------
///
/// Handles the opened audio [File] from File Explorer in [Harmonoid](https://github.com/harmonoid/harmonoid).
/// Primary purpose being to retrieve the path, saving metadata & playback of the possibly opened file.
///
class Intent {
  /// [Intent] object instance. Must call [Intent.initialize].
  static late Intent instance = Intent();

  Intent({
    this.file,
    this.directory,
  });

  /// Initializes the intent & checks for possibly opened [File].
  ///
  static Future<void> initialize({
    List<String> args: const [],
  }) async {
    if (isMobile) {
      instance = Intent();
      instance._channel.setMethodCallHandler((call) async {
        debugPrint(
          'Intent/channel.setMethodCallHandler: ${call.arguments.toString()}',
        );
        debugPrint(
          'Intent/_flutterSidedIntentPlayCalled: ${instance._flutterSidedIntentPlayCalled}',
        );
        if (!instance._flutterSidedIntentPlayCalled) {
          return;
        }
        // non `null`.
        if (call.arguments is String) {
          try {
            final uri = Uri.parse(call.arguments);
            instance.file =
                !uri.isScheme('FILE') ? null : File(uri.toFilePath());
            // synchronized.
            instance.play();
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
      });
    } else {
      if (args.isNotEmpty) {
        if (FS.typeSync_(args.first) == FileSystemEntityType.file) {
          instance = Intent(file: File(args.first));
        } else {
          instance = Intent(directory: Directory(args.first));
        }
      } else {
        instance = Intent();
      }
    }
  }

  /// Starts playing the possibly opened file & saves its metadata before doing it.
  /// If no file was opened, then load the last playing playlist from [AppState].
  ///
  Future<void> play() {
    return _lock.synchronized(() async {
      _flutterSidedIntentPlayCalled = true;
      // On Android specifically, we need to access the opened [File] through
      // the platform channel created inside the `MainActivity.java`.
      //
      // On Windows & Linux however, this is handled automatically by args
      // passed inside the main method. And, when the app is already opened &
      // a [File] is opened in the File Explorer, [ArgumentVectorHandler] comes
      // as a responsible to handle the opened [File] and plays it using [playUri].
      //
      if (Platform.isAndroid) {
        try {
          final result = await _channel.invokeMethod('');
          debugPrint('Intent.play/result: $result');
          if (result != null) {
            final uri = Uri.parse(result);
            file = !uri.isScheme('FILE') ? null : File(uri.toFilePath());
          }
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        debugPrint('Intent.play/file: $file');
        if (_file?.path == file?.path &&
            file?.path != null /* for allowing to reach the last else */) {
          debugPrint('Intent.play: Same file. No playback initiated.');
          return;
        }
        _file = file;
        if (_file != null) {
          debugPrint('Intent.play: New file. Playback initiated.');
        } else {
          debugPrint('Intent.play: No file. No playback initiated.');
        }
      }
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
          MobileNowPlayingController.instance.show();
        }
      }
      // Never invoked on mobile devices.
      else if (directory != null) {
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
                  MobileNowPlayingController.instance.show();
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
        try {
          if (!_startupAppStateLoaded) {
            await Playback.instance.loadAppState();
            if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
              // NOOP for desktop platforms.
            } else if (Platform.isAndroid || Platform.isIOS) {
              // Show the [MiniNowPlayingBar] if a playlist was opened during last running instance of the app.
              MobileNowPlayingController.instance.show();
            }
          }
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
      _startupAppStateLoaded = true;
    });
  }

  /// Identifies the object represented by the [uri].
  /// If it's recognized [Media] format, then metadata is saved & playback is started.
  /// Currently handles:
  ///
  /// * [Directory].
  /// * [File].
  /// * [Media] [Uri].
  /// * Web [Media] [Uri].
  ///
  Future<void> playUri(Uri uri) async {
    if (Plugins.isWebMedia(uri)) {
      await Playback.instance.open([
        Track.fromWebTrack((await YTMClient.player(uri.toString()))!.toJson())
      ]);
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        DesktopNowPlayingController.instance.maximize();
      } else if (Platform.isAndroid || Platform.isIOS) {
        MobileNowPlayingController.instance.show();
      }
    } else if (uri.isScheme('HTTP') ||
        uri.isScheme('HTTPS') ||
        uri.isScheme('FTP') ||
        uri.isScheme('RSTP')) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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
        DesktopNowPlayingController.instance.maximize();
      } else if (Platform.isAndroid || Platform.isIOS) {
        // TODO: Missing implementation for Android & iOS.
        MobileNowPlayingController.instance.show();
      }
    } else if (FS.typeSync_(uri.toFilePath()) == FileSystemEntityType.file) {
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
          MobileNowPlayingController.instance.show();
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
          MobileNowPlayingController.instance.show();
        }
      }
    } else if (FS.typeSync_(uri.toFilePath()) ==
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
                MobileNowPlayingController.instance.show();
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
                  MobileNowPlayingController.instance.show();
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

  /// The opened audio [File] from File Explorer.
  /// `null` if no [File] was opened.
  File? file;

  /// `Add to Harmonoid's Playlist` on Windows or Linux.
  final Directory? directory;

  /// `libmpv.dart` [Tagger] instance.
  /// Public for disposal upon application termination inside [WindowCloseHandler].
  final Tagger tagger = Tagger();

  /// [MethodChannel] used for retrieving the media [Uri] on Android specifically.
  final MethodChannel _channel =
      const MethodChannel('com.alexmercerind.harmonoid');

  /// Android specific.
  /// This boolean is used to identify whether the first [Intent.play] call is
  /// received through [CollectionScreen] or not.
  /// This is important to avoid the first redundant call through [_channel],
  /// because Flutter Engine isn't initialized at that point.
  /// However, future notifications of opened media files are notified through
  /// the [_channel], while the application is still running.
  bool _flutterSidedIntentPlayCalled = false;

  /// Handle [Playback.instance.loadAppState].
  /// When saving & laoding the app state, this prevents the app from loading
  /// the state of previously loaded media more than once.
  bool _startupAppStateLoaded = false;

  /// For mutual exclusion in [play] method.
  final Lock _lock = Lock();

  /// [File] which is currently in middle of playback after [play] was called.
  /// Used for redundant [play] calls, if same media was already playing.
  File? _file;
}
