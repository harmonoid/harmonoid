/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:uri_parser/uri_parser.dart';
import 'package:media_engine/media_engine.dart';
import 'package:synchronized/synchronized.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:media_library/media_library.dart' hide Media;
import 'package:ytm_client/ytm_client.dart' hide Media, Track;

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/helpers.dart';
import 'package:harmonoid/utils/tagger_client.dart';
import 'package:harmonoid/utils/metadata_retriever.dart';
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
    if (Platform.isWindows) {
      tagger = Tagger(verbose: false);
    }
    if (Platform.isLinux) {
      client = TaggerClient(verbose: false);
    }
  }

  /// Initializes the intent & checks for possibly opened [File].
  ///
  static Future<void> initialize({
    List<String> args: const [],
  }) async {
    // Retrieve the argument from the command line argument vector on Windows & Linux.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (args.isNotEmpty) {
        instance.argument = args.first;
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
  Future<void> playURI(
    String uri,
  ) async {
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
          final contents = await parser.directory!.list_(
            extensions: kSupportedFileTypes,
          );
          var playing = false;
          for (final file in contents) {
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
          break;
        }
      case URIType.network:
        {
          final uri = parser.uri!;
          // External network URIs.
          if (LibmpvPluginUtils.isSupported(uri)) {
            final response = await YTMClient.player(uri.toString());
            await Playback.instance.open(
              [
                Helpers.parseWebTrack(response!.toJson()),
              ],
            );
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
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopNowPlayingController.instance.maximize();
    } else if (Platform.isAndroid || Platform.isIOS) {
      MobileNowPlayingController.instance.show();
    }
  }

  /// Parses the metadata & saves cover art at local cache directory for the given [uri].
  Future<Track> parse(
    Uri uri, {
    Directory? coverDirectory,
    Duration? timeout,
  }) async {
    coverDirectory ??= Collection.instance.albumArtDirectory;
    timeout ??= const Duration(seconds: 1);
    debugPrint(uri.toString());
    // The finally extracted metadata must have the URI to the actual media resource, before parsing to the model.
    final result = <String, dynamic>{'uri': uri};
    // Windows.
    if (Platform.isWindows && tagger != null) {
      try {
        final metadata = await tagger!.parse(
          Media(uri.toString()),
          coverDirectory: coverDirectory,
          timeout: timeout,
        );
        result.addAll(metadata);
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      debugPrint(result.toString());
      return Helpers.parseTaggerMetadata(result);
    }
    // GNU/Linux.
    if (Platform.isLinux && client != null) {
      try {
        final metadata = await client!.parse(
          uri.toString(),
          coverDirectory: coverDirectory,
          timeout: timeout,
        );
        result.addAll(metadata);
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      debugPrint(result.toString());
      return Helpers.parseTaggerMetadata(result);
    }
    // Android.
    if (Platform.isAndroid) {
      try {
        final metadata = await MetadataRetriever.instance.metadata(
          uri,
          coverDirectory,
          timeout: timeout,
        );
        result.addAll(metadata.toJson());
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      debugPrint(result.toString());
      return Track.fromJson(result);
    }
    // Should never be reached.
    // No metadata could be extracted.
    debugPrint(result.toString());
    return Track.fromJson(result);
  }

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

  /// `libmpv.dart` [Tagger] instance.
  /// Public for disposal upon application termination inside [WindowLifecycle].
  Tagger? tagger;
  TaggerClient? client;

  /// [MethodChannel] used for retrieving the media [Uri] on Android specifically.
  ///
  final MethodChannel channel =
      const MethodChannel('com.alexmercerind.harmonoid.IntentRetriever');

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
