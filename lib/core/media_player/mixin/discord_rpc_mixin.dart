// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';
import 'package:discord_social_sdk/discord_social_sdk.dart';
import 'package:flutter/foundation.dart';
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
/// package:discord_social_sdk mixin for [MediaPlayer].
///
/// {@endtemplate}
final class DiscordRpcMixin implements MediaPlayerMixin {
  static const int kApplicationId = 881480706545573918;
  static const String kApplicationName = 'Harmonoid';
  static const String kDefaultLargeImage = 'cover_default';
  static const String kPauseSmallImage = 'pause';
  static const String kPlaySmallImage = 'play';

  static bool get supported => Platform.isLinux || Platform.isMacOS || Platform.isWindows || Platform.isAndroid || Platform.isIOS;

  DiscordRpcMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    try {
      await _connect();
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  DiscordSocialClient get client => _client;

  @override
  Future<void> dispose() async {
    await _client.dispose();
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
    if (Configuration.instance.discordTokens.accessToken.isEmpty) {
      return Future.value();
    }

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
        try {
          await _client.updatePresence(
            DiscordActivity(
              name: kApplicationName,
              state: current.subtitle.take(2).join(', ').ellipsis(128).nullIfBlank(),
              details: current.title.ellipsis(128).nullIfBlank(),
              startTimestamp: state.playing ? DateTime.now().subtract(state.position) : null,
              endTimestamp: state.playing ? DateTime.now().subtract(state.position).add(state.duration) : null,
              largeImage: _largeImage,
              smallImage: state.playing ? kPlaySmallImage : kPauseSmallImage,
              largeText: current.description.join(' • ').ellipsis(128).nullIfBlank(),
              smallText: state.playing ? Localization.instance.PLAYING : Localization.instance.PAUSED,
              buttons: [
                DiscordButton(
                  label: Localization.instance.FIND,
                  url: 'https://www.google.com/search?q=${Uri.encodeComponent([current.title, ...current.subtitle.take(2)].where((e) => e.isNotEmpty).join(' '))}',
                ),
              ],
              type: DiscordActivityType.listening,
            ),
          );
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
    });
  }

  Future<void> _connect([bool retryWithRefresh = false]) async {
    if (Configuration.instance.discordTokens.accessToken.isEmpty) return;
    try {
      if (retryWithRefresh) {
        final tokens = await _client.refreshToken(refreshToken: Configuration.instance.discordTokens.refreshToken);
        await Configuration.instance.set(discordTokens: tokens);
      }
      await _client.updateToken(tokenType: Configuration.instance.discordTokens.tokenType, token: Configuration.instance.discordTokens.accessToken);
      await _client.connect();
    } catch (_) {
      try {
        _client.disconnect();
      } catch (_) {}
      if (!retryWithRefresh) {
        return _connect(true);
      }
      rethrow;
    }
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

  final DiscordSocialClient _client = DiscordSocialClient(kApplicationId, kDebugMode);
  final Lock _lock = Lock();

  Playable? _flagPlayable;
  bool? _flagPlaying;
  Duration? _flagPosition;

  String? _largeImage;
}
