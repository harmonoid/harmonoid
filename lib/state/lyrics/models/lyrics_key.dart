import 'package:freezed_annotation/freezed_annotation.dart';

part 'lyrics_key.freezed.dart';
part 'lyrics_key.g.dart';

@freezed
abstract class LyricsKey with _$LyricsKey {
  const factory LyricsKey({
    required String track,
    required String artist,
    required int duration,
  }) = _LyricsKey;

  factory LyricsKey.fromJson(Map<String, dynamic> json) => _$LyricsKeyFromJson(json);
}
