import 'package:collection/collection.dart';

/// {@template playable}
///
/// Playable
/// --------
///
/// {@endtemplate}
class Playable {
  /// Uri.
  final String uri;

  /// Title.
  final String title;

  /// Subtitle.
  final List<String> subtitle;

  /// Description.
  final List<String> description;

  /// {@macro playable}
  const Playable({
    required this.uri,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  Playable copyWith({
    String? uri,
    String? title,
    List<String>? subtitle,
    List<String>? description,
  }) {
    return Playable(
      uri: uri ?? this.uri,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playable && uri == other.uri && title == other.title && const ListEquality().equals(subtitle, other.subtitle) && const ListEquality().equals(description, other.description);

  @override
  int get hashCode => Object.hash(
        uri,
        title,
        const ListEquality().hash(subtitle),
        const ListEquality().hash(description),
      );

  @override
  String toString() => 'Playable(uri: $uri, title: $title, subtitle: $subtitle, description: $description)';

  Map<String, dynamic> toJson() => {
        'uri': uri.toString(),
        'title': title,
        'subtitle': subtitle,
        'description': description,
      };

  factory Playable.fromJson(dynamic json) => Playable(
        uri: json['uri'],
        title: json['title'],
        subtitle: List<String>.from(json['subtitle']),
        description: List<String>.from(json['description']),
      );
}
