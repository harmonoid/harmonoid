/// {@template lyric}
///
/// Lyric
/// -----
///
/// {@endtemplate}
class Lyric {
  /// Timestamp.
  final int timestamp;

  /// Text.
  final String text;

  /// {@macro lyric}
  const Lyric({
    required this.timestamp,
    required this.text,
  });

  Lyric copyWith({
    int? timestamp,
    String? text,
  }) {
    return Lyric(
      timestamp: timestamp ?? this.timestamp,
      text: text ?? this.text,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Lyric && timestamp == other.timestamp && text == other.text;

  @override
  int get hashCode => Object.hash(
        timestamp,
        text,
      );

  @override
  String toString() => 'Lyric(timestamp: $timestamp, text: $text)';

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'text': text,
      };

  factory Lyric.fromJson(dynamic json) => Lyric(
        timestamp: json['timestamp'],
        text: json['text'],
      );
}
