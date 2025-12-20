// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'track_search_result.freezed.dart';
part 'track_search_result.g.dart';

@freezed
abstract class TrackSearchResult with _$TrackSearchResult {
  const factory TrackSearchResult({
    @JsonKey(name: 'TITLE') required String title,
    @JsonKey(name: 'ARTIST') required String artist,
    @JsonKey(name: 'ALBUM') required String album,
    @JsonKey(name: 'ALBUMARTIST') required String albumArtist,
    @JsonKey(name: 'DATE') required String date,
    @JsonKey(name: 'GENRE') required String genre,
    @JsonKey(name: 'TRACKNUMBER') required String trackNumber,
    @JsonKey(name: 'DISCNUMBER') required String discNumber,
    @JsonKey(name: 'COMMENT') required String comment,
    @JsonKey(name: 'LYRICS') required String lyrics,
    @JsonKey(name: 'COVER') required String cover,
  }) = _TrackSearchResult;

  factory TrackSearchResult.fromJson(Map<String, dynamic> json) => _$TrackSearchResultFromJson(json);
}
