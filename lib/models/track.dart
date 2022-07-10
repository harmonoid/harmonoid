/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

part of 'media.dart';

class Track extends Media {
  Uri uri;
  String trackName;
  String albumName;
  int trackNumber;
  String albumArtistName;
  List<String> trackArtistNames;
  String year;
  String? genre;

  DateTime timeAdded;
  Duration? duration;
  int? bitrate;

  @override
  Map<String, dynamic> toJson() {
    return {
      'uri': uri.toString(),
      'trackName': trackName,
      'albumName': albumName,
      'trackNumber': trackNumber,
      'albumArtistName': albumArtistName,
      'trackArtistNames': trackArtistNames,
      'year': year,
      'timeAdded': timeAdded.millisecondsSinceEpoch,
      'duration': duration?.inMilliseconds,
      'bitrate': bitrate,
      'genre': genre,
    };
  }

  /// Compatible with [MetadataRetriever] from `package:flutter_media_metadata` & [toJson].
  factory Track.fromJson(dynamic json) => Track(
        uri: Uri.parse(json['uri']),
        trackName: [null, ''].contains(json['trackName'])
            ? path.basename(Uri.parse(json['uri']).toFilePath())
            : json['trackName'],
        albumName: [null, ''].contains(json['albumName'])
            ? kUnknownAlbum
            : json['albumName'],
        trackNumber: json['trackNumber'] ?? 1,
        albumArtistName: [null, ''].contains(json['albumArtistName'])
            ? kUnknownArtist
            : json['albumArtistName'],
        trackArtistNames:
            // [toJson] stores [trackArtistNames] as [List] of [String].
            json['trackArtistNames'] is List
                ? json['trackArtistNames'].cast<String>()
                // [MetadataRetriever] from `package:flutter_media_metadata` stores [trackArtistNames] as [String].
                // Split tag into individual artists before storing.
                : Tagger.splitArtists(json['trackArtistNames']) ??
                    <String>[kUnknownArtist],
        year: '${json['year'] ?? kUnknownYear}',
        timeAdded: () {
          final uri = Uri.parse(json['uri']);
          if (uri.isScheme('HTTP') || uri.isScheme('HTTPS')) {
            return DateTime.now();
          }
          if (File(uri.toFilePath()).existsSync_()) {
            return File(uri.toFilePath()).lastModifiedSync();
          }
          return DateTime.now();
        }(),
        duration: Duration(milliseconds: json['duration'] ?? 0),
        bitrate: json['bitrate'],
        genre: json['genre'],
      );

  /// Compatible with [Tagger] from `package:libmpv`.
  factory Track.fromTagger(dynamic json) => Track(
        uri: Uri.parse(json['uri']),
        trackName: [null, ''].contains(json['title'])
            ? () {
                if (Uri.parse(json['uri']).isScheme('FILE')) {
                  return path.basename(Uri.parse(json['uri']).toFilePath());
                } else {
                  String uri = Uri.parse(json['uri']).toString();
                  if (uri.endsWith('/')) {
                    uri = uri.substring(0, uri.length - 1);
                  }
                  return uri.split('/').last;
                }
              }()
            : json['title'],
        albumName:
            [null, ''].contains(json['album']) ? kUnknownAlbum : json['album'],
        trackNumber: int.parse(json['track']?.split('/')?.first ?? '1'),
        albumArtistName: [null, ''].contains(json['album_artist'])
            ? kUnknownArtist
            : json['album_artist'],
        trackArtistNames:
            Tagger.splitArtists(json['artist']) ?? <String>[kUnknownArtist],
        year:
            '${json['year'] ?? json['date']?.split('-')?.first ?? kUnknownYear}',
        timeAdded: () {
          final uri = Uri.parse(json['uri']);
          if (uri.isScheme('HTTP') || uri.isScheme('HTTPS')) {
            return DateTime.now();
          }
          if (File(uri.toFilePath()).existsSync_()) {
            return File(uri.toFilePath()).lastModifiedSync();
          }
          return DateTime.now();
        }(),
        duration: Duration(
            milliseconds: int.tryParse(json['duration'] ?? '0')! ~/ 1000),
        bitrate: int.tryParse(json['bitrate'] ?? '0')! ~/ 1000,
        genre: json['genre'],
      );

  factory Track.fromWebTrack(dynamic json) => Track(
        uri: Uri.parse(json['uri']),
        trackName: json['trackName'],
        albumName: json['albumName'] ?? kUnknownAlbum,
        trackNumber: json['trackNumber'] ?? 1,
        albumArtistName: json['albumArtistName'] ?? kUnknownArtist,
        trackArtistNames: json['trackArtistNames'] ?? [kUnknownArtist],
        year: json['year'] ?? '',
        timeAdded: DateTime.now(),
        duration: Duration(milliseconds: json['duration'] ?? 0),
        bitrate: null,
        genre: null,
      );

  factory Track.fromWebVideo(dynamic json) => Track(
        uri: Uri.parse(json['uri']),
        trackName: json['videoName'],
        albumName: json['albumName'] ?? kUnknownAlbum,
        trackNumber: 1,
        albumArtistName: json['channelName'] ?? kUnknownArtist,
        trackArtistNames: [json['channelName'] ?? kUnknownArtist],
        year: json['year'] ?? '',
        timeAdded: DateTime.now(),
        duration: Duration(milliseconds: json['duration'] ?? 0),
        bitrate: null,
        genre: null,
      );

  Track({
    required this.uri,
    required this.trackName,
    required this.albumName,
    required this.trackNumber,
    required this.albumArtistName,
    required this.trackArtistNames,
    required this.year,
    required this.timeAdded,
    required this.duration,
    required this.bitrate,
    required this.genre,
  });

  Track copyWith({
    Uri? uri,
    String? trackName,
    String? albumName,
    int? trackNumber,
    String? albumArtistName,
    List<String>? trackArtistNames,
    String? year,
    DateTime? timeAdded,
    Duration? duration,
    int? bitrate,
    String? genre,
  }) {
    return Track(
      uri: uri ?? this.uri,
      trackName: trackName ?? this.trackName,
      albumName: albumName ?? this.albumName,
      trackNumber: trackNumber ?? this.trackNumber,
      albumArtistName: albumArtistName ?? this.albumArtistName,
      trackArtistNames: trackArtistNames ?? this.trackArtistNames,
      year: year ?? this.year,
      timeAdded: timeAdded ?? this.timeAdded,
      duration: duration ?? this.duration,
      bitrate: bitrate ?? this.bitrate,
      genre: genre ?? this.genre,
    );
  }

  @override
  bool operator ==(Object media) {
    if (media is Track) {
      return media.uri.toString() == uri.toString();
    }
    throw FormatException();
  }

  @override
  int get hashCode => uri.toString().hashCode;
}
