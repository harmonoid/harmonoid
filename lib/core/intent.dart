/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:uri_parser/uri_parser.dart';
import 'package:synchronized/synchronized.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:media_library/media_library.dart' hide Media;
import 'package:ytm_client/ytm_client.dart' hide Media, Track;
import 'package:media_kit_tag_reader/media_kit_tag_reader.dart';
import 'package:external_media_provider/external_media_provider.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';

/// Intent
/// ------
///
/// Handles the opened audio [File] from File Explorer, command line, Android intent etc. in [Harmonoid](https://github.com/harmonoid/harmonoid).
/// Primary purpose being to retrieve the path / URI, saving metadata / artwork & playback of the possibly opened file.
///
class Intent {
  /// [Intent] object instance. Must call [Intent.initialize].
  static final Intent instance = Intent();

  Intent() {
    if (Platform.isAndroid) {
      channel.setMethodCallHandler((call) async {
        debugPrint(
          'Intent/channel.setMethodCallHandler: ${call.arguments.toString()}',
        );
        debugPrint(
          'Intent/_flutterSidedIntentPlayCalled: ${instance._flutterSidedIntentPlayCalled}',
        );
        // Prevent calls from Java/Kotlin side when Flutter side has already called [Intent.play].
        // This happens only for the very first call i.e. Flutter engine didn't start yet & Java/Kotlin sent update through the platform channel.
        if (!instance._flutterSidedIntentPlayCalled) {
          return;
        }
        if (call.arguments is String) {
          try {
            argument = call.arguments;
            // [play] is synchronized & has mutual exclusion.
            await play();
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
      });
    }
  }

  /// Initializes the intent & checks for possibly opened [File].
  ///
  static Future<void> initialize({List<String> args = const []}) async {
    // Retrieve the argument from the command line argument vector on Windows & Linux.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (args.isNotEmpty) {
        instance.argument = args.first;
      }
    }
  }

  /// Disposes the [instance]. Releases allocated resources back to the system.
  Future<void> dispose() async {
    await reader.dispose();
  }

  /// Starts playing the possibly opened file & saves its metadata before doing it.
  /// If no file was opened, then load the last playing playlist from [AppState].
  ///
  Future<void> play() {
    return _lock.synchronized(() async {
      _flutterSidedIntentPlayCalled = true;
      // On Android specifically, we need to access the opened [File] through
      // the platform channel created inside the `MainActivity.java`.
      if (Platform.isAndroid) {
        try {
          final result = await channel.invokeMethod('Intent.play');
          debugPrint('Intent.play/result: $result');
          if (result != null) {
            argument = result;
          }
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        debugPrint('Intent.play/argument: $argument');
        // `argument != null` for allowing to reach the last else.
        if (argument == _argument && argument != null) {
          debugPrint('Intent.play: Same argument. No playback initiated.');
          return;
        }
        _argument = argument;
        if (_argument != null) {
          debugPrint('Intent.play: New argument. Playback initiated.');
        } else {
          debugPrint('Intent.play: No argument. No playback initiated.');
        }
      }
      if (argument != null) {
        await Playback.instance.loadAppState(open: false);
        await Intent.instance.playURI(argument!);
      } else {
        try {
          if (!_startupAppStateLoaded) {
            // Load the last
            await Playback.instance.loadAppState();
            if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
              // NO;OP.
            } else if (Platform.isAndroid || Platform.isIOS) {
              // Display [MiniNowPlayingBar] with last loaded playlist.
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

  /// The URI opened externally by the user e.g. via File Explorer.
  ///
  /// It may be a:
  ///
  /// * [File] URI i.e. file://.
  /// * [Directory] URI i.e. file://.
  /// * External media URL http://, https://, ftp://, rstp:// etc.
  /// * A URL to some external service e.g. YouTube, SoundCloud, etc.
  ///
  Future<void> playURI(String uri) async {
    _playURIOperationID = Random().nextInt(1 << 32);
    return _playURIOperationLock.synchronized(
      () async {
        final parser = URIParser(uri);
        switch (parser.type) {
          case URIType.file:
            {
              final track = await parse(parser.file!.uri);
              try {
                await Playback.instance.open(
                  [
                    track,
                  ],
                );
              } catch (exception, stacktrace) {
                debugPrint(exception.toString());
                debugPrint(stacktrace.toString());
              }
              break;
            }
          case URIType.directory:
            {
              final id = _playURIOperationID;
              final contents = await parser.directory!.list_(
                predicate: (e) => kSupportedFileTypes.contains(e.extension),
              );
              bool playing = false;
              for (final file in contents) {
                if (id != _playURIOperationID) {
                  // A new call to [playURI] has been made.
                  // Preempt the current execution.
                  _playURIOperationID = -1;
                  return;
                }
                final track = await parse(file.uri);
                try {
                  if (!playing) {
                    await Playback.instance.open(
                      [
                        track,
                      ],
                    );
                    playing = true;
                  } else {
                    await Playback.instance.add(
                      [
                        track,
                      ],
                    );
                  }
                } catch (exception, stacktrace) {
                  debugPrint(exception.toString());
                  debugPrint(stacktrace.toString());
                }
              }
              _playURIOperationID = -1;
              break;
            }
          case URIType.network:
            {
              final uri = parser.uri!;
              // External network URIs.
              if (ExternalMedia.supported(uri)) {
                final response = await YTMClient.player(uri.toString());
                await Playback.instance
                    .open([Track.fromJson(response!.toJson())]);
              }
              // Direct network URIs. No metadata extraction.
              else {
                await Playback.instance.open(
                  [
                    Track.fromJson(
                      {
                        'uri': uri.toString(),
                      },
                    )
                  ],
                );
              }
              break;
            }
          default:
            break;
        }
        // TODO(@alexmercerind): Refactor this to be outside of this class. Tight coupling is bad.
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          DesktopNowPlayingController.instance.maximize();
        } else if (Platform.isAndroid || Platform.isIOS) {
          MobileNowPlayingController.instance.show();
        }
      },
    );
  }

  /// Notify [Intent] to fucking preempt the current [playURI] operation & stop iterating over the directory & parsing the [File]s.
  void preemptPlayURI() => _playURIOperationID = -1;

  /// Parses the metadata & saves cover art at local cache directory for the given [uri].
  Future<Track> parse(Uri uri) async {
    debugPrint(uri.toString());
    final result = await reader.parse(
      uri.toString(),
      albumArtDirectory: Collection.instance.albumArtDirectory,
      // Ensure that the album art is saved to storage before returning the result on Android.
      waitUntilAlbumArtIsSaved: true,
      timeout: const Duration(seconds: 1),
    );
    debugPrint(result.toString());
    return Track.fromJson(result.toJson());
  }

  /// [MethodChannel] used for retrieving the media [Uri] on Android specifically.
  ///
  final MethodChannel channel =
      const MethodChannel('com.alexmercerind.harmonoid.IntentRetriever');

  /// Platform independent tag reader from `package:media_kit_tag_reader` for parsing & reading metadata from music files.
  final TagReader reader = TagReader();

  /// The URI opened externally by the user e.g. via File Explorer.
  /// It may be a:
  /// * [File] URI i.e. file://.
  /// * [Directory] URI i.e. file://.
  /// * External media URL http://, https://, ftp://, rstp:// etc.
  /// * A URL to some external service e.g. YouTube, SoundCloud, etc.
  ///
  String? argument;

  /// For ignoring duplicate redundant calls on Android during application lifecycle changes.
  String? _argument;

  /// When opening a [Directory] with [playURI], the [Directory] is parsed recursively & all the files are added to queue in background.
  ///
  /// This value is used to stop the recursive parsing, in case a new [playURI] call is made.
  /// Preempting the current execution of [playURI] is important to avoid the app from loading the same [Directory] again & again.
  int _playURIOperationID = -1;
  final Lock _playURIOperationLock = Lock();

  /// Android specific.
  ///
  /// This boolean is used to identify whether the first [Intent.play] call is
  /// made after [WidgetsBinding.addPostFrameCallback].
  ///
  /// This is important to avoid the first redundant call through [channel],
  /// because Flutter Engine isn't initialized at that point. However, future
  /// notifications of opened media files are notified through the [channel],
  /// while the application is still running i.e. Flutter engine alive.
  ///
  bool _flutterSidedIntentPlayCalled = false;

  /// Handle [Playback.instance.loadAppState].
  /// When saving & laoding the app state, this prevents the app from loading
  /// the state of previously loaded media more than once.
  bool _startupAppStateLoaded = false;

  /// For mutual exclusion in [play] method.
  final Lock _lock = Lock();
}
