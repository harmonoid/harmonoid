/// {@template localization_data}
///
/// LocalizationData
/// ----------------
///
/// {@endtemplate}
class LocalizationData {
  /// Code.
  /// e.g. `en_US`.
  final String code;

  /// Name.
  /// e.g. `English (United States)`.
  final String name;

  /// Country.
  /// e.g. `United States`.
  final String country;

  /// {@macro language_data}
  const LocalizationData({
    required this.code,
    required this.name,
    required this.country,
  });

  @override
  int get hashCode => code.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocalizationData && other.code == code;
  }

  factory LocalizationData.fromJson(dynamic json) => LocalizationData(
        code: json['code'],
        name: json['name'],
        country: json['country'],
      );

  Map<String, String> toJson() => {
        'code': code,
        'name': name,
        'country': country,
      };
}
