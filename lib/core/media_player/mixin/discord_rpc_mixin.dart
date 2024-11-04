import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/api/activity_set.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/base_media_player.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/rendering.dart';

/// {@template discord_rpc_mixin}
///
/// DiscordRpcMixin
/// ---------------
/// package:flutter_discord_rpc mixin for [BaseMediaPlayer].
///
/// {@endtemplate}
mixin DiscordRpcMixin implements BaseMediaPlayer {
  static const String kApplicationId = '881480706545573918';
  static const String kDefaultLargeImage = 'cover_default';
  static const String kPauseSmallImage = 'pause';
  static const String kPlaySmallImage = 'play';

  static bool get supported => (Platform.isLinux || Platform.isMacOS || Platform.isWindows) && Configuration.instance.discordRpc;

  Future<void> ensureInitializedDiscordRpc() async {
    if (!supported) return;

    await FlutterDiscordRPC.initialize(kApplicationId);
    final instance = FlutterDiscordRPC.instance..connect();

    _instanceDiscordRpc = instance;

    addListener(_listenerDiscordRpc);
  }

  Future<void> disposeDiscordRpc() async {
    if (!supported) return;
    _instanceDiscordRpc = null;
  }

  void resetFlagsDiscordRpc() {
    _flagPlayableDiscordRpc = null;
  }

  void _listenerDiscordRpc() {
    _lockDiscordRpc.synchronized(() async {
      bool notify = false;

      if (_flagPlayableDiscordRpc != current) {
        _flagPlayableDiscordRpc = current;
        notify = true;
        try {
          final deviceId = Configuration.instance.identifier;
          final image = cover(uri: current.uri);
          _largeImageDiscordRpc = switch (image) {
            AsyncFileImage() => await ActivitySet.instance.call(deviceId, current, await image.file),
            FileImage() => await ActivitySet.instance.call(deviceId, current, image.file),
            NetworkImage() => image.url,
            _ => null,
          }!;
        } catch (_) {
          _largeImageDiscordRpc = kDefaultLargeImage;
        }
      }
      if (_flagPlayingDiscordRpc != state.playing) {
        _flagPlayingDiscordRpc = state.playing;
        notify = true;
      }
      if (((_flagPositionDiscordRpc ?? Duration.zero) - state.position).abs() > const Duration(seconds: 10)) {
        _flagPositionDiscordRpc = state.position;
        notify = true;
      }

      if (notify) {
        await _instanceDiscordRpc?.setActivity(
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
              largeImage: _largeImageDiscordRpc,
              smallImage: state.playing ? kPlaySmallImage : kPauseSmallImage,
              largeText: state.getAudioFormatLabel().ellipsis(128).nullIfBlank(),
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

  FlutterDiscordRPC? _instanceDiscordRpc;
  final Lock _lockDiscordRpc = Lock();

  Playable? _flagPlayableDiscordRpc;
  bool? _flagPlayingDiscordRpc;
  Duration? _flagPositionDiscordRpc;

  String? _largeImageDiscordRpc;
}
