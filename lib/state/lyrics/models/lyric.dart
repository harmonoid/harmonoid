import 'package:freezed_annotation/freezed_annotation.dart';

part 'lyric.freezed.dart';
part 'lyric.g.dart';

@freezed
abstract class Lyric with _$Lyric {
  const factory Lyric({
    required int timestamp,
    required String text,
  }) = _Lyric;

  factory Lyric.fromJson(Map<String, dynamic> json) => _$LyricFromJson(json);
}
