import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_accent_color.freezed.dart';
part 'theme_accent_color.g.dart';

@freezed
abstract class ThemeAccentColor with _$ThemeAccentColor {
  const factory ThemeAccentColor({
    required int light,
    required int dark,
  }) = _ThemeAccentColor;

  factory ThemeAccentColor.fromJson(Map<String, dynamic> json) => _$ThemeAccentColorFromJson(json);
}
