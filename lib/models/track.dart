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
    };
  }

  /// Compatible with [MetadataRetriever] from `flutter_media_metadata`.
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
        trackArtistNames: json['trackArtistNames']?.cast<String>() ??
            <String>[kUnknownArtist],
        year: '${json['year'] ?? kUnknownYear}',
        timeAdded: () {
          final uri = Uri.parse(json['uri']);
          if (uri.isScheme('HTTP') || uri.isScheme('HTTPS')) {
            return DateTime.now();
          }
          if (File(uri.toFilePath()).existsSync()) {
            return File(uri.toFilePath()).lastModifiedSync();
          }
          return DateTime.now();
        }(),
        duration: Duration(milliseconds: json['duration'] ?? 0),
        bitrate: json['bitrate'],
      );

  /// Compatible with [Tagger] from `libmpv.dart`.
  factory Track.fromTagger(dynamic json) => Track(
        uri: Uri.parse(json['uri']),
        trackName: [null, ''].contains(json['title'])
            ? path.basename(Uri.parse(json['uri']).toFilePath())
            : json['title'],
        albumName:
            [null, ''].contains(json['album']) ? kUnknownAlbum : json['album'],
        trackNumber: int.parse(json['track']?.split('/')?.first ?? '1'),
        albumArtistName: [null, ''].contains(json['album_artist'])
            ? kUnknownArtist
            : json['album_artist'],
        trackArtistNames: json['artist']?.split('/')?.cast<String>() ??
            <String>[kUnknownArtist],
        year:
            '${json['year'] ?? json['date']?.split('-')?.first ?? kUnknownYear}',
        timeAdded: () {
          final uri = Uri.parse(json['uri']);
          if (uri.isScheme('HTTP') || uri.isScheme('HTTPS')) {
            return DateTime.now();
          }
          if (File(uri.toFilePath()).existsSync()) {
            return File(uri.toFilePath()).lastModifiedSync();
          }
          return DateTime.now();
        }(),
        duration: Duration(
            milliseconds: int.tryParse(json['duration'] ?? '0')! ~/ 1000),
        bitrate: int.tryParse(json['bitrate'] ?? '0')! ~/ 1000,
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
  });

  @override
  bool operator ==(Object media) {
    if (media is Track) {
      return media.trackName == trackName &&
          media.trackNumber == media.trackNumber &&
          media.albumArtistName == albumArtistName;
    }
    throw FormatException();
  }

  @override
  int get hashCode =>
      trackName.hashCode ^ trackNumber.hashCode ^ albumArtistName.hashCode;
}
