/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:uri_parser/uri_parser.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:media_kit_tag_reader/media_kit_tag_reader.dart';

// SUMMARY: Implement Android specific [TagReader] here & give a platform independent [TagReader] interface to the rest of the app.

/// {@template android_tag_reader}
///
/// AndroidTagReader
/// ----------------
///
/// This utility class is used to retrieve metadata & tags from [File]s, [Uri]s & other sources. All the methods in this class are thread-safe.
///
/// The [parse] method returns the metadata tags, along with basic information like duration, bitrate etc.
/// The [format] method returns the bitrate, sample rate & channel count of the media file.
///
/// {@endtemplate}
class AndroidTagReader extends PlatformTagReader {
  /// [AndroidTagReader] singleton instance.
  static final AndroidTagReader instance = AndroidTagReader._();

  /// {@macro android_tag_reader}
  AndroidTagReader._() : super(configuration: const TagReaderConfiguration());

  /// Disposes the instance & releases allocated resources back to the system.
  @override
  FutureOr<void> dispose({int code = 0}) async {}

  /// Takes the media resource represented by a [uri] & returns platform specific metadata from it.
  ///
  /// This method is meant to be called internally by the [parse] method.
  /// However, public access is provided for advanced use-cases.
  ///
  /// Optionally, following arguments may be passed:
  /// * [albumArt] decides the [File] where the album art will be saved.
  /// * [albumArtDirectory] decides the [Directory] in which the album art will be saved.
  /// * [waitUntilAlbumArtIsSaved] decides whether to wait until the album art is saved.
  /// * [timeout] may be passed to set the timeout duration for the parsing operation.
  ///   Important for avoiding deadlocks.
  ///
  /// Throws [FormatException] if an invalid, corrupt or inexistent media [uri] is passed.
  ///
  Future<Map<String, String>> metadata(
    String uri, {
    File? albumArt,
    Directory? albumArtDirectory,
    bool waitUntilAlbumArtIsSaved = false,
    Duration timeout = const Duration(seconds: 1),
  }) async {
    // NOTE: [cover] is not implemented on Android.
    try {
      final result = await channel.invokeMethod(
        'metadata',
        {
          'uri': uri,
          'albumArtDirectory': albumArtDirectory?.path,
          'waitUntilAlbumArtIsSaved': waitUntilAlbumArtIsSaved,
        },
      ).timeout(timeout);
      return <String, String>{
        'uri': uri,
        ...Map<String, String>.from(result),
      };
    } catch (exception) {
      throw FormatException(exception.toString());
    }
  }

  /// Serializes the platform specific metadata into [Tags] model.
  @override
  Tags serialize(dynamic data) {
    assert(data['uri'] is String, 'URI cannot be null.');
    final String uri = data['uri'];
    final parser = URIParser(uri);
    String? trackName;
    int? albumLength;
    DateTime? timeAdded;
    // Present in JSON.
    if (data['METADATA_KEY_TITLE'] is String) {
      trackName = data['METADATA_KEY_TITLE'];
    }
    // Not present in JSON. Extract from [File] name or URI segment.
    else {
      switch (parser.type) {
        case URIType.file:
          trackName = basename(parser.file!.path);
          break;
        case URIType.network:
          trackName = parser.uri!.pathSegments.last;
          break;
        default:
          trackName = uri;
          break;
      }
    }
    // Present in JSON.
    if (data['METADATA_KEY_NUM_TRACKS'] is String) {
      albumLength = parseInteger(data['METADATA_KEY_NUM_TRACKS']);
    } else if (data['track'] is String) {
      if (data['METADATA_KEY_CD_TRACK_NUMBER'].contains('/')) {
        albumLength =
            parseInteger(data['METADATA_KEY_CD_TRACK_NUMBER'].split('/').last);
      }
    }

    // Not present in JSON. Access from file system.
    switch (parser.type) {
      case URIType.file:
        {
          timeAdded = parser.file!.lastModifiedSync_();
          break;
        }
      default:
        {
          timeAdded = DateTime.now();
          break;
        }
    }

    // Assign fallback values.
    trackName ??= uri;
    albumLength ??= 1;
    timeAdded ??= DateTime.now();

    return Tags(
      uri: parser.result,
      trackName: trackName,
      albumName: data['METADATA_KEY_ALBUM'],
      trackNumber: parseInteger(data['METADATA_KEY_CD_TRACK_NUMBER']),
      discNumber: parseInteger(data['METADATA_KEY_DISC_NUMBER']),
      albumLength: albumLength,
      albumArtistName: data['METADATA_KEY_ALBUMARTIST'],
      trackArtistNames: splitTagValue(data['METADATA_KEY_ARTIST']),
      authorNames: splitTagValue(data['METADATA_KEY_AUTHOR']),
      writerNames: splitTagValue(data['METADATA_KEY_WRITER']),
      year: splitDateTagValue(
        data['METADATA_KEY_YEAR'] ?? data['METADATA_KEY_DATE'],
      ),
      genres: splitTagValue(data['METADATA_KEY_GENRE']),
      // Not supported on Android.
      lyrics: null,
      timeAdded: timeAdded,
      duration: data['METADATA_KEY_DURATION'] == null
          ? null
          : Duration(
              milliseconds: parseInteger(data['METADATA_KEY_DURATION']) ?? 0,
            ),
      bitrate: parseInteger(data['METADATA_KEY_BITRATE']),
    );
  }

  /// Gives the audio bitrate, sample rate, channel count & extension of a media [File].
  Future<AndroidMediaFormat> format(Uri uri) async {
    try {
      final result = await channel.invokeMethod(
        'format',
        {
          'uri': uri.toString(),
        },
      );
      debugPrint(result.toString());
      return AndroidMediaFormat(
        bitrate: result['bitrate'],
        sampleRate: result['sampleRate'],
        channelCount: result['channelCount'],
        extension: result['extension'],
      );
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      return AndroidMediaFormat();
    }
  }

  static const MethodChannel channel =
      MethodChannel('com.alexmercerind.harmonoid.MetadataRetriever');
}

/// {@template android_media_metadata}
///
/// AndroidMediaMetadata
/// --------------------
///
/// Android specific information about the audio format of a music file saved locally.
/// This does not store any metadata tags but the audio-specific information.
///
/// {@endtemplate}
class AndroidMediaFormat {
  final int? bitrate;
  final int? sampleRate;
  final int? channelCount;
  final String? extension;

  /// {@macro android_media_metadata}
  const AndroidMediaFormat({
    this.bitrate,
    this.sampleRate,
    this.channelCount,
    this.extension,
  });
}
