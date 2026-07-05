import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/mappers/image_provider.dart';
import 'package:harmonoid/core/media_player/models/media_player_state.dart';
import 'package:harmonoid/core/media_player/models/loop.dart';
import 'package:harmonoid/core/media_player/models/playable.dart';
import 'package:harmonoid/utils/rendering.dart';

/// {@template audio_service_mixin}
///
/// AudioServiceMixin
/// -----------------
/// package:audio_service mixin for [MediaPlayer].
///
/// {@endtemplate}
final class AudioServiceMixin implements MediaPlayerMixin {
  static const String kAndroidNotificationChannelId = 'com.alexmercerind.harmonoid';
  static const String kAndroidNotificationChannelName = 'Harmonoid';
  static const String kAndroidNotificationIcon = 'drawable/ic_stat_music_note';

  static bool get supported => Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  AudioServiceMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    try {
      final instance = await AudioService.init(
        builder: () => _AudioServiceImpl(_player),
        config: const AudioServiceConfig(
          androidNotificationChannelId: kAndroidNotificationChannelId,
          androidNotificationChannelName: kAndroidNotificationChannelName,
          androidNotificationIcon: kAndroidNotificationIcon,
          androidNotificationClickStartsActivity: true,
          androidStopForegroundOnPause: false,
        ),
      );

      _instance = instance;
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  @override
  Future<void> dispose() async {
    await _instance?.stop();
  }

  @override
  Future<void> resetFlags() async {
    _flagPlayable = null;
    _flagIndex = null;
    _flagRate = null;
    _flagShuffle = null;
    _flagLoop = null;
    _flagPosition = null;
    _flagDuration = null;
    _flagPlaying = null;
    _flagCompleted = null;
  }

  @override
  Future<void> notifyState(MediaPlayerState state) {
    return _lock.synchronized(() async {
      final current = _player.current;
      if (_flagIndex != state.index || _flagPlayable != current) {
        _flagIndex = state.index;
        _flagPlayable = current;
        final image = cover(uri: current.uri);
        final artUri = await image.toUri();
        _mediaItem = _mediaItem.copyWith(
          id: current.uri,
          title: current.title,
          artist: current.subtitle.join(', '),
          artUri: artUri,
          displayTitle: current.title,
          displaySubtitle: current.subtitle.join(', '),
        );
        _instance?.mediaItem.add(_mediaItem);

        _playbackState = _playbackState.copyWith(
          queueIndex: state.index,
          processingState: AudioProcessingState.ready,
          playing: state.playing,
          controls: [
            MediaControl.skipToPrevious,
            if (state.playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
          ],
        );
        _instance?.playbackState.add(_playbackState);
      }

      if (_flagRate != state.rate) {
        _flagRate = state.rate;
        _playbackState = _playbackState.copyWith(speed: state.rate);
        _instance?.playbackState.add(_playbackState);
      }

      if (_flagShuffle != state.shuffle) {
        _flagShuffle = state.shuffle;
        _playbackState = _playbackState.copyWith(
          shuffleMode: switch (state.shuffle) {
            true => AudioServiceShuffleMode.all,
            false => AudioServiceShuffleMode.none,
          },
        );
        _instance?.playbackState.add(_playbackState);
      }

      if (_flagLoop != state.loop) {
        _flagLoop = state.loop;
        _playbackState = _playbackState.copyWith(
          repeatMode: switch (state.loop) {
            Loop.off => AudioServiceRepeatMode.none,
            Loop.one => AudioServiceRepeatMode.one,
            Loop.all => AudioServiceRepeatMode.all,
          },
        );
        _instance?.playbackState.add(_playbackState);
      }

      if (_flagPosition == null || (state.position - _flagPosition!).abs() > const Duration(seconds: 1)) {
        _flagPosition = state.position;
        _playbackState = _playbackState.copyWith(updatePosition: state.position);
        _instance?.playbackState.add(_playbackState);
      }

      if (_flagDuration != state.duration && state.duration > Duration.zero) {
        _flagDuration = state.duration;
        _mediaItem = _mediaItem.copyWith(duration: state.duration);
        _instance?.mediaItem.add(_mediaItem);
      }

      if (_flagPlaying != state.playing) {
        _flagPlaying = state.playing;
        _playbackState = _playbackState.copyWith(
          processingState: AudioProcessingState.ready,
          playing: state.playing,
          controls: [
            MediaControl.skipToPrevious,
            if (state.playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.stop,
            MediaAction.pause,
            MediaAction.play,
            MediaAction.skipToPrevious,
            MediaAction.skipToNext,
            MediaAction.seek,
            MediaAction.setRepeatMode,
            MediaAction.setShuffleMode,
            MediaAction.setSpeed,
          },
        );
        _instance?.playbackState.add(_playbackState);
      }

      if (_flagCompleted != state.completed) {
        _flagCompleted = state.completed;
        if (state.completed) {
          _playbackState = _playbackState.copyWith(processingState: AudioProcessingState.completed);
          _instance?.playbackState.add(_playbackState);
        }
      }
    });
  }

  final MediaPlayer _player;

  _AudioServiceImpl? _instance;
  final Lock _lock = Lock();

  Playable? _flagPlayable;
  int? _flagIndex;
  double? _flagRate;
  bool? _flagShuffle;
  Loop? _flagLoop;
  Duration? _flagPosition;
  Duration? _flagDuration;
  bool? _flagPlaying;
  bool? _flagCompleted;

  MediaItem _mediaItem = const MediaItem(id: '~', title: '~');
  PlaybackState _playbackState = PlaybackState();
}

class _AudioServiceImpl extends BaseAudioHandler with QueueHandler, SeekHandler {
  final MediaPlayer _instance;

  _AudioServiceImpl(this._instance);

  @override
  Future<void> play() => _instance.play().then(
    (_) => playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
        playing: true,
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.pause,
          MediaControl.skipToNext,
        ],
      ),
    ),
  );

  @override
  Future<void> pause() => _instance.pause().then(
    (_) => playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
        playing: false,
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
        ],
      ),
    ),
  );

  @override
  Future<void> stop() => _instance.pause();

  @override
  Future<void> skipToPrevious() => _instance.previous();

  @override
  Future<void> skipToNext() => _instance.next();

  @override
  Future<void> skipToQueueItem(int i) => _instance.jump(i);

  @override
  Future<void> seek(Duration position) => _instance.seek(position);

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) => _instance.setShuffle(switch (shuffleMode) {
    AudioServiceShuffleMode.none => false,
    AudioServiceShuffleMode.all => true,
    AudioServiceShuffleMode.group => true,
  });

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) => _instance.setLoop(switch (repeatMode) {
    AudioServiceRepeatMode.none => Loop.off,
    AudioServiceRepeatMode.one => Loop.one,
    AudioServiceRepeatMode.all => Loop.all,
    AudioServiceRepeatMode.group => Loop.all,
  });

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    playbackState.add(PlaybackState());
  }
}
