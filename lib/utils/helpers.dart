/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:media_library/media_library.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

/// A bunch of helper methods for decoding & parsing model objects from JSON.
class Helpers {
  /// Parses [Map<String, String>] metadata result from [Tagger] class of
  /// `package:media_engine` to typed [Track] object from `package:media_library`.
  ///
  static Track parseTaggerMetadata(dynamic json) => Track(
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
        trackNumber: int.tryParse(json['track']?.split('/')?.first ?? '1') ?? 1,
        discNumber: int.tryParse(json['disc']?.split('/')?.first ?? '1') ?? 1,
        albumArtistName: [null, ''].contains(json['album_artist'])
            ? kUnknownArtist
            : json['album_artist'],
        trackArtistNames:
            Utils.splitArtistsTag(json['artist']) ?? <String>[kUnknownArtist],
        year:
            '${json['year'] ?? Utils.splitDateTag(json['date']) ?? kUnknownYear}',
        timeAdded: () {
          try {
            final resource = Uri.parse(json['uri']);
            // Network [Uri]s.
            if (resource.isScheme('HTTP') ||
                resource.isScheme('HTTPS') ||
                resource.isScheme('FTP') ||
                resource.isScheme('RSTP')) {
              return DateTime.now();
            }
            // [File] [Uri]s. Internally checks for [File] existence.
            final result = File(resource.toFilePath()).lastModifiedSync_();
            return result!;
          } catch (exception, stacktrace) {
            print(exception);
            print(stacktrace);
          }
          return DateTime.now();
        }(),
        duration: Duration(
            milliseconds: int.tryParse(json['duration'] ?? '0')! ~/ 1000),
        bitrate: int.tryParse(json['bitrate'] ?? '0')! ~/ 1000,
        genre: json['genre'] ?? kUnknownGenre,
      );

  static Track parseWebTrack(dynamic json) => Track(
        uri: Uri.parse(json['uri']),
        trackName: json['trackName'],
        albumName: json['albumName'] ?? kUnknownAlbum,
        trackNumber: json['trackNumber'] ?? 1,
        discNumber: json['discNumber'] ?? 1,
        albumArtistName: json['albumArtistName'] ?? kUnknownArtist,
        trackArtistNames: json['trackArtistNames'] ?? [kUnknownArtist],
        year: json['year'] ?? kUnknownYear,
        timeAdded: DateTime.now(),
        duration: Duration(milliseconds: json['duration'] ?? 0),
        bitrate: null,
        genre: kUnknownGenre,
      );

  static Track parseWebVideo(dynamic json) => Track(
        uri: Uri.parse(json['uri']),
        trackName: json['videoName'],
        albumName: json['albumName'] ?? kUnknownAlbum,
        trackNumber: json['trackNumber'] ?? 1,
        discNumber: json['discNumber'] ?? 1,
        albumArtistName: json['channelName'] ?? kUnknownArtist,
        trackArtistNames: [json['channelName'] ?? kUnknownArtist],
        year: json['year'] ?? kUnknownYear,
        timeAdded: DateTime.now(),
        duration: Duration(milliseconds: json['duration'] ?? 0),
        bitrate: null,
        genre: kUnknownGenre,
      );
}
