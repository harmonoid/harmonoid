/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// MetadataRetriever
/// -----------------
///
/// This utility class is used to retrieve metadata & tags from [File]s, [Uri]s & other sources.
/// All the methods in this class are thread-safe.
///
/// The [metadata] method returns the metadata tags, along with basic information like duration, bitrate etc.
/// The [format] method returns the bitrate, sample rate & channel count of the media file.
///
class MetadataRetriever {
  /// [MetadataRetriever] singleton instance.
  static final MetadataRetriever instance = MetadataRetriever._();

  MetadataRetriever._();

  /// Extracts the metadata tags, along with basic information like duration, bitrate etc.
  ///
  /// * [coverDirectory] is the directory where the cover art will be extracted.
  /// * [timeout] may be passed to prevent any dead-lock. Defaults to `const Duration(seconds: 1)`.
  /// * [waitUntilAlbumArtIsSaved] specifies whether to wait until the cover art is saved to the disk.
  ///   This can result in additional delay in the execution of the method.
  ///
  /// The resulting [AndroidMediaMetadata] object only contains [uri] as a key in case of any error.
  ///
  Future<AndroidMediaMetadata> metadata(
    Uri uri,
    Directory coverDirectory, {
    Duration? timeout,
    bool waitUntilAlbumArtIsSaved = false,
  }) async {
    try {
      final result = await _channel.invokeMethod(
        'metadata',
        {
          'uri': uri.toString(),
          'coverDirectory': coverDirectory.path,
          'waitUntilAlbumArtIsSaved': waitUntilAlbumArtIsSaved,
        },
      ).timeout(
        timeout ?? const Duration(seconds: 1),
      );
      return AndroidMediaMetadata.fromJson(result);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      return AndroidMediaMetadata(
        uri: uri.toString(),
      );
    }
  }

  /// Gives the audio bitrate, sample rate & channel count of a media [File].
  ///
  Future<AndroidMediaFormat> format(Uri uri) async {
    try {
      final result = await _channel.invokeMethod(
        'format',
        {
          'uri': uri.toString(),
        },
      );
      debugPrint(result.toString());
      return AndroidMediaFormat.fromJson(result);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      return AndroidMediaFormat();
    }
  }

  static const MethodChannel _channel =
      MethodChannel('com.alexmercerind.harmonoid.MetadataRetriever');

  static int? _parseInteger(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    } else if (value is String) {
      try {
        try {
          return int.parse(value);
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
          return int.parse(value.split('/').first);
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }
    return null;
  }
}

/// The metadata extracted from the media resource in object format.
/// Just a model class.
///
/// This is returned by [MetadataRetriever.metadata].
///
class AndroidMediaMetadata {
  final String? trackName;
  final String? trackArtistNames;
  final String? albumName;
  final String? albumArtistName;
  final int? trackNumber;
  final int? discNumber;
  final int? albumLength;
  final int? year;
  final String? genre;
  final String? authorName;
  final String? writerName;
  final String? mimeType;
  final int? duration;
  final int? bitrate;
  final String? uri;

  const AndroidMediaMetadata({
    this.trackName,
    this.trackArtistNames,
    this.albumName,
    this.albumArtistName,
    this.trackNumber,
    this.discNumber,
    this.albumLength,
    this.year,
    this.genre,
    this.authorName,
    this.writerName,
    this.mimeType,
    this.duration,
    this.bitrate,
    this.uri,
  });

  factory AndroidMediaMetadata.fromJson(dynamic map) => AndroidMediaMetadata(
        trackName: map['trackName'],
        trackArtistNames: map['trackArtistNames'],
        albumName: map['albumName'],
        albumArtistName: map['albumArtistName'],
        trackNumber: MetadataRetriever._parseInteger(map['trackNumber']),
        discNumber: MetadataRetriever._parseInteger(map['discNumber']),
        albumLength: MetadataRetriever._parseInteger(map['albumLength']),
        year: MetadataRetriever._parseInteger(map['year']),
        genre: map['genre'],
        authorName: map['authorName'],
        writerName: map['writerName'],
        mimeType: map['mimeType'],
        duration: MetadataRetriever._parseInteger(map['duration']),
        bitrate: MetadataRetriever._parseInteger(map['bitrate']),
        uri: map['uri'],
      );

  Map<String, dynamic> toJson() => {
        'trackName': trackName,
        'trackArtistNames': trackArtistNames,
        'albumName': albumName,
        'albumArtistName': albumArtistName,
        'trackNumber': trackNumber,
        'discNumber': discNumber,
        'albumLength': albumLength,
        'year': year,
        'genre': genre,
        'authorName': authorName,
        'writerName': writerName,
        'mimeType': mimeType,
        'duration': duration,
        'bitrate': bitrate,
        'uri': uri,
      };

  @override
  String toString() =>
      'AndroidMediaMetadata(trackName: $trackName, trackArtistNames: $trackArtistNames, albumName: $albumName, albumArtistName: $albumArtistName, trackNumber: $trackNumber, discNumber: $discNumber, albumLength: $albumLength, year: $year, genre: $genre, authorName: $authorName, writerName: $writerName, mimeType: $mimeType, duration: $duration, bitrate: $bitrate, uri: $uri)';
}

/// The format extracted from the media resource in object format.
/// Just a model class.
///
/// This is returned by [MetadataRetriever.format].
class AndroidMediaFormat {
  final int? bitrate;
  final int? sampleRate;
  final int? channelCount;
  final String? extension;

  const AndroidMediaFormat({
    this.bitrate,
    this.sampleRate,
    this.channelCount,
    this.extension,
  });

  factory AndroidMediaFormat.fromJson(dynamic map) => AndroidMediaFormat(
        bitrate: MetadataRetriever._parseInteger(
          map['bitrate'],
        ),
        sampleRate: MetadataRetriever._parseInteger(
          map['sampleRate'],
        ),
        channelCount: MetadataRetriever._parseInteger(
          map['channelCount'],
        ),
        extension: map['extension'],
      );

  Map<String, dynamic> toJson() => {
        'bitrate': bitrate,
        'sampleRate': sampleRate,
        'channelCount': channelCount,
        'extension': extension,
      };

  @override
  String toString() =>
      'AndroidMediaFormat(bitrate: $bitrate, sampleRate: $sampleRate, channelCount: $channelCount, extension: $extension)';
}
