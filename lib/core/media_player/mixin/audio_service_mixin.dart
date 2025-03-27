import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/base_media_player.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/mappers/image_provider.dart';
import 'package:harmonoid/mappers/media_player_state.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/utils/rendering.dart';

/// {@template audio_service_mixin}
///
/// AudioServiceMixin
/// -----------------
/// package:audio_service mixin for [BaseMediaPlayer].
///
/// {@endtemplate}
mixin AudioServiceMixin implements BaseMediaPlayer {
  static const String kAndroidNotificationChannelId = 'com.alexmercerind.harmonoid';
  static const String kAndroidNotificationChannelName = 'Harmonoid';
  static const String kAndroidNotificationIcon = 'drawable/ic_stat_music_note';

  static bool get supported => Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  Future<void> ensureInitializedAudioService() async {
    if (!supported) return;

    final instance = await AudioService.init(
      builder: () => _AudioServiceImpl(this),
      config: const AudioServiceConfig(
        androidNotificationChannelId: kAndroidNotificationChannelId,
        androidNotificationChannelName: kAndroidNotificationChannelName,
        androidNotificationIcon: kAndroidNotificationIcon,
        androidNotificationClickStartsActivity: true,
        androidNotificationOngoing: true,
      ),
    );

    _instanceAudioService = instance;

    addListener(_listenerAudioService);
  }

  Future<void> disposeAudioService() async {
    if (!supported) return;

    await _instanceAudioService?.stop();
  }

  void resetFlagsAudioService() {
    _flagPlayableAudioService = null;
    _flagIndexAudioService = null;
    _flagRateAudioService = null;
    _flagShuffleAudioService = null;
    _flagLoopAudioService = null;
    _flagPositionAudioService = null;
    _flagDurationAudioService = null;
    _flagPlayingAudioService = null;
    _flagCompletedAudioService = null;
  }

  void _listenerAudioService() {
    _lockAudioService.synchronized(() async {
      if (_flagIndexAudioService != state.index || _flagPlayableAudioService != current) {
        _flagIndexAudioService = state.index;
        _flagPlayableAudioService = current;
        final image = cover(uri: current.uri);
        final artUri = await image.toUri();
        _mediaItemAudioService = _mediaItemAudioService.copyWith(
          id: current.uri,
          title: current.title,
          artist: current.subtitle.join(', '),
          artUri: artUri,
          displayTitle: current.title,
          displaySubtitle: current.subtitle.join(', '),
        );
        _instanceAudioService?.mediaItem.add(_mediaItemAudioService);

        _playbackStateAudioService = _playbackStateAudioService.copyWith(
          queueIndex: state.index,
          processingState: AudioProcessingState.ready,
        );
        _instanceAudioService?.playbackState.add(_playbackStateAudioService);
      }

      if (_flagRateAudioService != state.rate) {
        _flagRateAudioService = state.rate;
        _playbackStateAudioService = _playbackStateAudioService.copyWith(speed: state.rate);
        _instanceAudioService?.playbackState.add(_playbackStateAudioService);
      }

      if (_flagShuffleAudioService != state.shuffle) {
        _flagShuffleAudioService = state.shuffle;
        _playbackStateAudioService = _playbackStateAudioService.copyWith(
          shuffleMode: switch (state.shuffle) {
            true => AudioServiceShuffleMode.all,
            false => AudioServiceShuffleMode.none,
          },
        );
        _instanceAudioService?.playbackState.add(_playbackStateAudioService);
      }

      if (_flagLoopAudioService != state.loop) {
        _flagLoopAudioService = state.loop;
        _playbackStateAudioService = _playbackStateAudioService.copyWith(
          repeatMode: switch (state.loop) {
            Loop.off => AudioServiceRepeatMode.none,
            Loop.one => AudioServiceRepeatMode.one,
            Loop.all => AudioServiceRepeatMode.all,
          },
        );
        _instanceAudioService?.playbackState.add(_playbackStateAudioService);
      }

      if (_flagPositionAudioService != state.position) {
        _flagPositionAudioService = state.position;
        _playbackStateAudioService = _playbackStateAudioService.copyWith(updatePosition: state.position);
        _instanceAudioService?.playbackState.add(_playbackStateAudioService);
      }

      if (_flagDurationAudioService != state.duration && state.duration > Duration.zero) {
        _flagDurationAudioService = state.duration;
        _mediaItemAudioService = _mediaItemAudioService.copyWith(duration: state.duration);
        _instanceAudioService?.mediaItem.add(_mediaItemAudioService);
      }

      if (_flagPlayingAudioService != state.playing) {
        _flagPlayingAudioService = state.playing;
        _playbackStateAudioService = _playbackStateAudioService.copyWith(
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
        _instanceAudioService?.playbackState.add(_playbackStateAudioService);
      }

      if (_flagCompletedAudioService != state.completed) {
        _flagCompletedAudioService = state.completed;
        _playbackStateAudioService = _playbackStateAudioService.copyWith(
          processingState: AudioProcessingState.completed,
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.play,
            MediaControl.skipToNext,
          ],
        );
        _instanceAudioService?.playbackState.add(_playbackStateAudioService);
      }
    });
  }

  _AudioServiceImpl? _instanceAudioService;
  final Lock _lockAudioService = Lock();

  Playable? _flagPlayableAudioService;
  int? _flagIndexAudioService;
  double? _flagRateAudioService;
  bool? _flagShuffleAudioService;
  Loop? _flagLoopAudioService;
  Duration? _flagPositionAudioService;
  Duration? _flagDurationAudioService;
  bool? _flagPlayingAudioService;
  bool? _flagCompletedAudioService;

  MediaItem _mediaItemAudioService = const MediaItem(id: '~', title: '~');
  PlaybackState _playbackStateAudioService = PlaybackState();
}

class _AudioServiceImpl extends BaseAudioHandler with QueueHandler, SeekHandler {
  final BaseMediaPlayer _instance;

  _AudioServiceImpl(this._instance);

  @override
  Future<void> play() => _instance.play();

  @override
  Future<void> pause() => _instance.pause();

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
    await Configuration.instance.set(mediaPlayerPlaybackState: MediaPlayer.instance.state.toPlaybackState());
    playbackState.add(PlaybackState());
  }
}
