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
  int index;

  /// Playables.
  List<Playable> playables;

  /// Rate.
  double rate;

  /// Pitch.
  double pitch;

  /// Volume.
  double volume;

  /// Shuffle.
  bool shuffle;

  /// Loop.
  Loop loop;

  /// {@macro playback_state}
  PlaybackState({
    required this.index,
    required this.playables,
    required this.rate,
    required this.pitch,
    required this.volume,
    required this.shuffle,
    required this.loop,
  });

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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaybackState &&
        other.index == index &&
        other.playables == playables &&
        other.rate == rate &&
        other.pitch == pitch &&
        other.volume == volume &&
        other.shuffle == shuffle &&
        other.loop == loop;
  }

  @override
  int get hashCode => index.hashCode ^ playables.hashCode ^ rate.hashCode ^ pitch.hashCode ^ volume.hashCode ^ shuffle.hashCode ^ loop.hashCode;

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
}
