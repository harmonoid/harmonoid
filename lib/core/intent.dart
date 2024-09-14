import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_library/media_library.dart' as _;
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uri_parser/uri_parser.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/models/playback_state.dart';
import 'package:harmonoid/utils/methods.dart';

/// {@template intent}
///
/// Intent
/// ------
/// Implementation to parse & play the externally opened resource e.g. file, directory or URI.
///
/// {@endtemplate}
class Intent {
  /// Singleton instance.
  static final Intent instance = Intent._();

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
  Future<void> notify({
    PlaybackState? playbackState,
    void Function() onPlaybackStateRestore = intentNotifyOnPlaybackStateRestore,
  }) {
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
          intentNotifyOnPlaybackStateRestore.call();
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
  Future<void> play(
    String uri, {
    void Function() onMediaPlayerOpen = intentPlayOnMediaPlayerOpen,
  }) async {
    _playInvoked = true;
    return _playLock.synchronized(
      () async {
        _playInvoked = false;
        final parser = URIParser(uri);
        switch (parser.type) {
          case URIType.file:
            {
              final playable = Playable(
                uri: uri,
                title: basename(uri),
                subtitle: [],
                description: [],
              );
              try {
                await MediaPlayer.instance.open(
                  [
                    playable,
                  ],
                );
                onMediaPlayerOpen.call();
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
                // Return prematurely if the method has been invoked again.
                if (_playInvoked) return;
                final file = contents[i];
                final playable = Playable(
                  uri: file.path,
                  title: basename(file.path),
                  subtitle: [],
                  description: [],
                );
                try {
                  if (i == 0) {
                    await MediaPlayer.instance.open(
                      [
                        playable,
                      ],
                    );
                    onMediaPlayerOpen.call();
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
              onMediaPlayerOpen.call();
              break;
            }
          default:
            break;
        }
      },
    );
  }

  /// Resource.
  String? _resource;

  /// Current.
  String? _current;

  /// Whether the playback state has been restored.
  bool _mediaPlayerPlaybackStateRestored = false;

  /// Whether [notify] has been invoked.
  bool _notifyInvoked = false;

  /// Mutual exclusion in [notify] invocations.
  final Lock _notifyLock = Lock();

  /// Whether [play] has been invoked.
  bool _playInvoked = false;

  /// Mutual exclusion in [play] invocations.
  final Lock _playLock = Lock();

  /// [MethodChannel] used to communicate with the native platform.
  final MethodChannel _channel = const MethodChannel('com.alexmercerind.harmonoid.IntentController');
}
