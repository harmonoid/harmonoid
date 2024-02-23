/// {@template playable}
///
/// Playable
/// --------
///
/// {@endtemplate}
class Playable {
  /// Uri.
  final Uri uri;

  /// Title.
  final String title;

  /// Subtitle.
  final String subtitle;

  /// {@macro playable}
  Playable({
    required this.uri,
    required this.title,
    required this.subtitle,
  });

  Playable copyWith({
    Uri? uri,
    String? title,
    String? subtitle,
  }) {
    return Playable(
      uri: uri ?? this.uri,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playable && other.uri == uri && other.title == title && other.subtitle == subtitle;
  }

  @override
  int get hashCode => uri.hashCode ^ title.hashCode ^ subtitle.hashCode;

  Map<String, dynamic> toJson() => {
        'uri': uri.toString(),
        'title': title,
        'subtitle': subtitle,
      };

  factory Playable.fromJson(dynamic json) => Playable(
        uri: Uri.parse(json['uri']),
        title: json['title'],
        subtitle: json['subtitle'],
      );
}
