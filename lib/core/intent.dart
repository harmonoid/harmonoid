import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_library/media_library.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uri_parser/uri_parser.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/mappers/file.dart';
import 'package:harmonoid/core/media_player/models/playable.dart';
import 'package:harmonoid/core/media_player/models/playback_state.dart';
import 'package:harmonoid/utils/actions.dart';

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
    if (Platform.isAndroid || Platform.isIOS) {
      _intentControllerMethodChannel.setMethodCallHandler((call) async {
        debugPrint('Intent: _: Arguments: ${call.arguments}');
        debugPrint('Intent: _: Notify invoked: ${instance._notifyInvoked}');
        // Skip calls from platform channel until [notify] has been invoked at least once.
        // This case happens only for the very first call i.e. Flutter engine didn't start yet & native code invoked a method through the platform channel.
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

  /// Notifies to play the externally opened resource (after restoring the playback state).
  Future<void> notify({
    PlaybackState? playbackState,
    void Function()? onPlaybackStateRestore = intentNotifyOnPlaybackStateRestore,
  }) {
    return _notifyLock.synchronized(() async {
      _notifyInvoked = true;

      // Android/iOS: Attempt to refresh the resource.
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          final result = await _intentControllerMethodChannel.invokeMethod('~');
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
      if (_current != null && _resource != null && _current == _resource) {
        debugPrint('Intent: play: Skip: $_resource.');
        return;
      } else {
        debugPrint('Intent: play: Play: $_resource.');
      }
      _current = _resource;

      // Restore the playback state.
      if (!_mediaPlayerPlaybackStateRestored && playbackState != null) {
        _mediaPlayerPlaybackStateRestored = true;
        try {
          await MediaPlayer.instance.setPlaybackState(
            playbackState,
            onOpen: _current == null ? intentNotifyOnPlaybackStateRestore : null,
          );
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
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
    void Function()? onMediaPlayerOpen = intentPlayOnMediaPlayerOpen,
  }) async {
    _playInvoked = true;
    return _playLock.synchronized(
      () async {
        _playInvoked = false;
        final parser = URIParser(uri);

        // HACK: Use I/O to determine the correct type.
        if (parser.type == URIType.file || parser.type == URIType.directory) {
          final path = parser.file?.path ?? parser.directory?.path;
          if (path != null) {
            switch (await FS.type_(path)) {
              case FileSystemEntityType.file:
                parser.type = URIType.file;
                parser.file = File(path);
                parser.directory = null;
                break;
              case FileSystemEntityType.directory:
                parser.type = URIType.directory;
                parser.file = null;
                parser.directory = Directory(path);
                break;
              default:
                break;
            }
          }
        }

        switch (parser.type) {
          case URIType.file:
            {
              final playable = parser.file!.toPlayable();
              try {
                await MediaPlayer.instance.open([playable], onOpen: onMediaPlayerOpen);
              } catch (exception, stacktrace) {
                debugPrint(exception.toString());
                debugPrint(stacktrace.toString());
              }
              break;
            }
          case URIType.directory:
            {
              final contents = await parser.directory!.list_(predicate: (e) => kDefaultSupportedFileTypes.contains(e.extension));
              for (int i = 0; i < contents.length; i++) {
                // Return prematurely if the method has been invoked again.
                if (_playInvoked) return;
                final playable = contents[i].toPlayable();
                try {
                  if (i == 0) {
                    await MediaPlayer.instance.open([playable], onOpen: onMediaPlayerOpen);
                    await Future.delayed(const Duration(seconds: 1), MediaPlayer.instance.disablePlayerPlaylistUpdates);
                  } else {
                    await MediaPlayer.instance.add([playable]);
                  }
                } catch (exception, stacktrace) {
                  debugPrint(exception.toString());
                  debugPrint(stacktrace.toString());
                }
              }
              await MediaPlayer.instance.enablePlayerPlaylistUpdates();
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
                onOpen: onMediaPlayerOpen,
              );
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
  final MethodChannel _intentControllerMethodChannel = const MethodChannel('com.alexmercerind.harmonoid/intent_controller');
}
