class Lyric {
  final int time;
  final String words;

  Lyric({
    required this.time,
    required this.words,
  });

  Map<String, dynamic> toJson() => {
        'time': this.time,
        'words': this.words,
      };

  static Lyric fromJson(dynamic map) => Lyric(
        time: map['time'],
        words: map['words']?.replaceAll('\n', ' ')?.replaceAll('  ', ' '),
      );
}
