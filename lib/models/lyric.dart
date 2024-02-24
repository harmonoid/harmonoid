/// {@template lyric}
///
/// Lyric
/// -----
///
/// {@endtemplate}
class Lyric {
  /// Time.
  final int time;

  /// Words.
  final String words;

  /// {@macro lyric}
  const Lyric({
    required this.time,
    required this.words,
  });

  Lyric copyWith({
    int? time,
    String? words,
  }) {
    return Lyric(
      time: time ?? this.time,
      words: words ?? this.words,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lyric && other.time == time && other.words == words;
  }

  @override
  int get hashCode => Object.hash(
        time,
        words,
      );

  @override
  String toString() => 'Lyric(time: $time, words: $words)';

  Map<String, dynamic> toJson() => {
        'time': time,
        'words': words,
      };

  factory Lyric.fromJson(dynamic json) => Lyric(
        time: json['time'],
        words: json['words'],
      );
}
