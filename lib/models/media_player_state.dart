import 'package:collection/collection.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:media_kit/media_kit.dart' hide Playable;

/// {@template media_player_state}
///
/// MediaPlayerState
/// ----------------
/// [MediaPlayer]'s state.
///
/// {@endtemplate}
class MediaPlayerState {
  /// Index.
  final int index;

  /// Playables.
  final List<Playable> playables;

  /// Rate.
  final double rate;

  /// Pitch.
  final double pitch;

  /// Volume.
  final double volume;

  /// Shuffle.
  final bool shuffle;

  /// Loop.
  final Loop loop;

  /// Position.
  final Duration position;

  /// Duration.
  final Duration duration;

  /// Playing.
  final bool playing;

  /// Buffering.
  final bool buffering;

  /// Completed.
  final bool completed;

  /// Audio Bitrate.
  final double audioBitrate;

  /// Audio Params.
  final AudioParams audioParams;

  const MediaPlayerState({
    required this.index,
    required this.playables,
    required this.rate,
    required this.pitch,
    required this.volume,
    required this.shuffle,
    required this.loop,
    required this.position,
    required this.duration,
    required this.playing,
    required this.buffering,
    required this.completed,
    required this.audioBitrate,
    required this.audioParams,
  });

  /// Returns [MediaPlayerState] with default values.
  factory MediaPlayerState.defaults() => MediaPlayerState(
        index: _kDefaultIndex,
        playables: _kDefaultPlayables,
        rate: _kDefaultRate,
        pitch: _kDefaultPitch,
        volume: _kDefaultVolume,
        shuffle: _kDefaultShuffle,
        loop: _kDefaultLoop,
        position: _kDefaultPosition,
        duration: _kDefaultDuration,
        playing: _kDefaultPlaying,
        buffering: _kDefaultBuffering,
        completed: _kDefaultCompleted,
        audioBitrate: _kDefaultAudioBitrate,
        audioParams: _kDefaultAudioParams,
      );

  MediaPlayerState copyWith({
    int? index,
    List<Playable>? playables,
    double? rate,
    double? pitch,
    double? volume,
    bool? shuffle,
    Loop? loop,
    Duration? position,
    Duration? duration,
    bool? playing,
    bool? buffering,
    bool? completed,
    double? audioBitrate,
    AudioParams? audioParams,
  }) {
    return MediaPlayerState(
      index: index ?? this.index,
      playables: playables ?? this.playables,
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      shuffle: shuffle ?? this.shuffle,
      loop: loop ?? this.loop,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playing: playing ?? this.playing,
      buffering: buffering ?? this.buffering,
      completed: completed ?? this.completed,
      audioBitrate: audioBitrate ?? this.audioBitrate,
      audioParams: audioParams ?? this.audioParams,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaPlayerState &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          ListEquality().equals(playables, other.playables) &&
          rate == other.rate &&
          pitch == other.pitch &&
          volume == other.volume &&
          shuffle == other.shuffle &&
          loop == other.loop &&
          position == other.position &&
          duration == other.duration &&
          playing == other.playing &&
          buffering == other.buffering &&
          completed == other.completed &&
          audioBitrate == other.audioBitrate &&
          audioParams == other.audioParams;

  @override
  int get hashCode => Object.hash(
        index,
        ListEquality().hash(playables),
        rate,
        pitch,
        volume,
        shuffle,
        loop,
        position,
        duration,
        playing,
        buffering,
        completed,
        audioBitrate,
        audioParams,
      );

  @override
  String toString() => 'MediaPlayerState('
      'index: $index, '
      'playables: $playables, '
      'rate: $rate, '
      'pitch: $pitch, '
      'volume: $volume, '
      'shuffle: $shuffle, '
      'loop: $loop, '
      'position: $position, '
      'duration: $duration, '
      'playing: $playing, '
      'buffering: $buffering, '
      'completed: $completed, '
      'audioBitrate: $audioBitrate, '
      'audioParams: $audioParams'
      ')';

  static const _kDefaultIndex = 0;
  static const _kDefaultPlayables = <Playable>[];
  static const _kDefaultRate = 1.0;
  static const _kDefaultPitch = 1.0;
  static const _kDefaultVolume = 1.0;
  static const _kDefaultShuffle = false;
  static const _kDefaultLoop = Loop.off;
  static const _kDefaultPosition = Duration.zero;
  static const _kDefaultDuration = Duration.zero;
  static const _kDefaultPlaying = false;
  static const _kDefaultBuffering = false;
  static const _kDefaultCompleted = false;
  static const _kDefaultAudioBitrate = 0.0;
  static const _kDefaultAudioParams = AudioParams();
}
