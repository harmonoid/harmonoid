import 'package:collection/collection.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/models/playable.dart';

/// {@template playback_state}
///
/// PlaybackState
/// -------------
///
/// {@endtemplate}
class PlaybackState {
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

  /// {@macro playback_state}
  const PlaybackState({
    required this.index,
    required this.playables,
    required this.rate,
    required this.pitch,
    required this.volume,
    required this.shuffle,
    required this.loop,
  });

  /// Returns [PlaybackState] with default values.
  factory PlaybackState.defaults() => const PlaybackState(
        index: _kDefaultIndex,
        playables: _kDefaultPlayables,
        rate: _kDefaultRate,
        pitch: _kDefaultPitch,
        volume: _kDefaultVolume,
        shuffle: _kDefaultShuffle,
        loop: _kDefaultLoop,
      );

  PlaybackState copyWith({
    int? index,
    List<Playable>? playables,
    double? rate,
    double? pitch,
    double? volume,
    bool? shuffle,
    Loop? loop,
  }) {
    return PlaybackState(
      index: index ?? this.index,
      playables: playables ?? this.playables,
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      shuffle: shuffle ?? this.shuffle,
      loop: loop ?? this.loop,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackState &&
          index == other.index &&
          const ListEquality().equals(playables, other.playables) &&
          rate == other.rate &&
          pitch == other.pitch &&
          volume == other.volume &&
          shuffle == other.shuffle &&
          loop == other.loop;

  @override
  int get hashCode => Object.hash(
        index,
        const ListEquality().hash(playables),
        rate,
        pitch,
        volume,
        shuffle,
        loop,
      );

  @override
  String toString() => 'PlaybackState(index: $index, playables: $playables, rate: $rate, pitch: $pitch, volume: $volume, shuffle: $shuffle, loop: $loop)';

  Map<String, dynamic> toJson() => {
        'index': index,
        'playables': playables,
        'rate': rate,
        'pitch': pitch,
        'volume': volume,
        'shuffle': shuffle,
        'loop': loop.index,
      };

  factory PlaybackState.fromJson(dynamic map) => PlaybackState(
        index: map['index'],
        playables: List<Playable>.from(map['playables'].map((playable) => Playable.fromJson(playable))),
        rate: map['rate'],
        pitch: map['pitch'],
        volume: map['volume'],
        shuffle: map['shuffle'],
        loop: Loop.values[map['loop']],
      );

  static const _kDefaultIndex = 0;
  static const _kDefaultPlayables = <Playable>[];
  static const _kDefaultRate = 1.0;
  static const _kDefaultPitch = 1.0;
  static const _kDefaultVolume = 1.0;
  static const _kDefaultShuffle = false;
  static const _kDefaultLoop = Loop.off;
}
