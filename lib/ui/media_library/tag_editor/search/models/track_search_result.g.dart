// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrackSearchResult _$TrackSearchResultFromJson(Map<String, dynamic> json) =>
    _TrackSearchResult(
      title: json['TITLE'] as String,
      artist: json['ARTIST'] as String,
      album: json['ALBUM'] as String,
      albumArtist: json['ALBUMARTIST'] as String,
      date: json['DATE'] as String,
      genre: json['GENRE'] as String,
      trackNumber: json['TRACKNUMBER'] as String,
      discNumber: json['DISCNUMBER'] as String,
      comment: json['COMMENT'] as String,
      lyrics: json['LYRICS'] as String,
      cover: json['COVER'] as String,
    );

Map<String, dynamic> _$TrackSearchResultToJson(_TrackSearchResult instance) =>
    <String, dynamic>{
      'TITLE': instance.title,
      'ARTIST': instance.artist,
      'ALBUM': instance.album,
      'ALBUMARTIST': instance.albumArtist,
      'DATE': instance.date,
      'GENRE': instance.genre,
      'TRACKNUMBER': instance.trackNumber,
      'DISCNUMBER': instance.discNumber,
      'COMMENT': instance.comment,
      'LYRICS': instance.lyrics,
      'COVER': instance.cover,
    };
