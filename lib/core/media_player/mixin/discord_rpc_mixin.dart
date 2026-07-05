// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:safe_local_storage/file_system.dart';
import 'package:synchronized/synchronized.dart';
import 'package:media_kit/src/player/native/utils/temp_file.dart';

import 'package:harmonoid/core/media_player/mixin/api/activity_set.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/core/media_player/models/media_player_state.dart';
import 'package:harmonoid/core/media_player/models/playable.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/rendering.dart';

/// {@template discord_rpc_mixin}
///
/// DiscordRpcMixin
/// ---------------
/// package:flutter_discord_rpc mixin for [MediaPlayer].
///
/// {@endtemplate}
final class DiscordRpcMixin implements MediaPlayerMixin {
  static const String kApplicationId = '881480706545573918';
  static const String kDefaultLargeImage = 'cover_default';
  static const String kPauseSmallImage = 'pause';
  static const String kPlaySmallImage = 'play';

  static bool get supported => (Platform.isLinux || Platform.isMacOS || Platform.isWindows) && Configuration.instance.discordRpc;

  DiscordRpcMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    try {
      await FlutterDiscordRPC.initialize(kApplicationId);
      final instance = FlutterDiscordRPC.instance..connect();

      _instance = instance;
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  @override
  Future<void> dispose() async {
    _instance = null;
  }

  @override
  Future<void> resetFlags() async {
    _flagPlayable = null;
    _flagPlaying = null;
    _flagPosition = null;
    _largeImage = null;
  }

  @override
  Future<void> notifyState(MediaPlayerState state) {
    if (_instance?.isConnected != true) return Future.value();

    return _lock.synchronized(() async {
      final current = _player.current;
      bool notify = false;

      if (_flagPlayable != current) {
        _flagPlayable = current;
        notify = true;
        try {
          final image = cover(uri: current.uri);
          _largeImage = switch (image) {
            AsyncFileImage() => await _getFileUrl(current, image.getFile()),
            FileImage() => await _getFileUrl(current, image.file),
            NetworkImage() => image.url,
            _ => null,
          }!;
        } catch (_) {
          _largeImage = kDefaultLargeImage;
        }
      }
      if (_flagPlaying != state.playing) {
        _flagPlaying = state.playing;
        notify = true;
      }
      if (((_flagPosition ?? Duration.zero) - state.position).abs() > const Duration(seconds: 10)) {
        _flagPosition = state.position;
        notify = true;
      }

      if (notify) {
        await _instance?.setActivity(
          activity: RPCActivity(
            state: current.subtitle.take(2).join(', ').ellipsis(128).nullIfBlank(),
            details: current.title.ellipsis(128).nullIfBlank(),
            timestamps: state.playing
                ? RPCTimestamps(
                    start: DateTime.now().subtract(state.position).millisecondsSinceEpoch,
                    end: DateTime.now().subtract(state.position).add(state.duration).millisecondsSinceEpoch,
                  )
                : null,
            assets: RPCAssets(
              largeImage: _largeImage,
              smallImage: state.playing ? kPlaySmallImage : kPauseSmallImage,
              largeText: current.description.join(' • ').ellipsis(128).nullIfBlank(),
              smallText: state.playing ? Localization.instance.PLAYING : Localization.instance.PAUSED,
            ),
            buttons: [
              RPCButton(
                label: Localization.instance.FIND,
                url: 'https://www.google.com/search?q=${Uri.encodeComponent([current.title, ...current.subtitle.take(2)].where((e) => e.isNotEmpty).join(' '))}',
              ),
            ],
            activityType: ActivityType.listening,
          ),
        );
      }
    });
  }

  Future<String?> _getFileUrl(Playable playable, FutureOr<File?> inputFuture) async {
    final input = await inputFuture;

    if (input == null) return null;

    final output = await TempFile.create();
    final deviceId = Configuration.instance.identifier;
    final activitySet = ActivitySet();

    try {
      try {
        final cmd = img.Command()
          ..decodeImageFile(input.path)
          ..copyResize(width: 256)
          ..encodeJpg(quality: 85)
          ..writeToFile(output.path);

        await cmd.executeThread();

        return await activitySet(deviceId, playable, output);
      } catch (_) {
        return await activitySet(deviceId, playable, input);
      }
    } finally {
      await output.delete_();
    }
  }

  final MediaPlayer _player;

  FlutterDiscordRPC? _instance;
  final Lock _lock = Lock();

  Playable? _flagPlayable;
  bool? _flagPlaying;
  Duration? _flagPosition;

  String? _largeImage;
}
