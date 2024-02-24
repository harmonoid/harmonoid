import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_library/media_library.dart' as _;
import 'package:synchronized/synchronized.dart';
import 'package:tag_reader/tag_reader.dart';
import 'package:uri_parser/uri_parser.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/mappers/tags.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/models/playback_state.dart';

/// {@template intent}
///
/// Intent
/// ------
/// Implementation to parse & play the externally opened resource e.g. file, directory or URI.
///
/// {@endtemplate}
class Intent {
  /// Singleton instance.
  static late final Intent instance = Intent._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro intent}
  Intent._() {
    if (Platform.isAndroid) {
      _channel.setMethodCallHandler((call) async {
        debugPrint('Intent: _: Arguments: ${call.arguments}');
        debugPrint('Intent: _: Notify invoked: ${instance._notifyInvoked}');
        // Skip calls from platform channel until [notify] has been invoked at least once.
        // This case happens only for the very first call i.e. Flutter engine didn't start yet & Kotlin invoked a method through the platform channel.
        if (!instance._notifyInvoked) {
          return;
        }
        if (call.arguments is String) {
          try {
            _resource = call.arguments;
            await notify();
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
      });
    }
  }

  /// Initializes the [instance].
  static Future<void> ensureInitialized({required List<String> args}) async {
    if (initialized) return;
    initialized = true;
    instance._resource = args.isEmpty ? null : args.first;
  }

  /// Notifies to [play] about externally opened resource.
  Future<void> notify({PlaybackState? playbackState, void Function(bool)? onPlaybackStateRestored}) {
    return _notifyLock.synchronized(() async {
      _notifyInvoked = true;

      // Android: Attempt to refresh the resource.
      try {
        if (Platform.isAndroid) {
          final result = await _channel.invokeMethod('resource');
          if (result != null) {
            _resource = result;
          }
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }

      debugPrint('Intent: play: Current: $_current');
      debugPrint('Intent: play: Resource: $_resource');

      // Skip the same resource.
      if (_current == _resource) {
        debugPrint('Intent: play: Skip: $_resource.');
        return;
      } else {
        debugPrint('Intent: play: Play: $_resource.');
      }
      _current = _resource;

      // Restore the playback state.
      try {
        if (!_mediaPlayerPlaybackStateRestored && playbackState != null) {
          _mediaPlayerPlaybackStateRestored = true;
          await MediaPlayer.instance.setPlaybackState(playbackState, play: _current == null);
          onPlaybackStateRestored?.call(true);
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }

      if (_current != null) {
        try {
          await Intent.instance.play(_current!);
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
    });
  }

  /// Plays the [uri].
  Future<void> play(String uri) async {
    return _playLock.synchronized(
      () async {
        _playInvoked = true;

        final parser = URIParser(uri);
        switch (parser.type) {
          case URIType.file:
            {
              final playable = await parse(parser.file!.path);
              try {
                await MediaPlayer.instance.open(
                  [
                    playable,
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
              final contents = await parser.directory!.list_(predicate: (e) => MediaLibrary.instance.supportedFileTypes.contains(e.extension));
              for (int i = 0; i < contents.length; i++) {
                if (!_playInvoked) {
                  return;
                }
                final file = contents[i];
                final playable = await parse(file.path);
                try {
                  if (i == 0) {
                    await MediaPlayer.instance.open(
                      [
                        playable,
                      ],
                    );
                  } else {
                    await MediaPlayer.instance.add(
                      [
                        playable,
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
              final uri = parser.uri!.toString();
              await MediaPlayer.instance.open(
                [
                  Playable(
                    uri: uri,
                    title: uri.split('/').last,
                    subtitle: [],
                    description: [],
                  ),
                ],
              );
              break;
            }
          default:
            break;
        }
        _playInvoked = false;
      },
    );
  }

  /// Invoked for performing the parsing operation on the given [uri].
  Future<Playable> parse(String uri) async {
    final tags = await _tagReader.parse(
      uri,
      cover: MediaLibrary.instance.coverFromUri(uri),
      timeout: MediaLibrary.instance.timeout,
    );
    return tags.toTrack().toPlayable();
  }

  /// Disposes the [instance]. Releases allocated resources back to the system.
  void dispose() {
    _tagReader.dispose();
  }

  /// Resource.
  String? _resource;

  /// Current.
  String? _current;

  bool _mediaPlayerPlaybackStateRestored = false;

  /// Whether [notify] has been invoked.
  bool _notifyInvoked = false;

  /// Mutual exclusion in [notify] invocations.
  final Lock _notifyLock = Lock();

  /// Whether [play] has been invoked.
  bool _playInvoked = false;

  /// Mutual exclusion in [play] invocations.
  final Lock _playLock = Lock();

  /// Tag reader.
  final TagReader _tagReader = TagReader();

  /// [MethodChannel] used to communicate with the native platform.
  final MethodChannel _channel = const MethodChannel('com.alexmercerind.harmonoid.IntentController');
}
