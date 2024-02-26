import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:media_library/media_library.dart';
import 'package:path/path.dart';
import 'package:tag_reader/tag_reader.dart';

import 'package:harmonoid/models/android_media_format.dart';

/// {@template android_tag_reader}
///
/// MediaKitTagReader
/// -----------------
/// [`MediaMetadataRetriever`](https://developer.android.com/reference/android/media/MediaMetadataRetriever) implementation of [PlatformTagReader].
///
/// {@endtemplate}
class AndroidTagReader extends PlatformTagReader {
  AndroidTagReader({required super.configuration});

  @override
  Future<void> dispose() => throw UnimplementedError();

  @override
  Future<Map<String, String>> metadata(
    String uri, {
    File? cover,
    Duration timeout = const Duration(seconds: 2),
  }) async {
    try {
      final result = await _channel.invokeMethod(
        'metadata',
        {
          'uri': uri,
          'cover': cover,
        },
      ).timeout(timeout);
      return result;
    } catch (exception) {
      throw FormatException(exception.toString());
    }
  }

  @override
  Future<Tags> serialize(String uri, Map<String, String> metadata) async {
    final data = metadata.map((k, v) => MapEntry(k.toLowerCase(), v));

    String? title;
    String? album;
    String? albumArtist;
    int? discNumber;
    int? trackNumber;
    int? albumLength;
    int? year;
    String? lyrics;
    int? duration;
    int? bitrate;
    DateTime? timestamp;
    Set<String>? artists;
    Set<String>? genres;

    try {
      title ??= data['METADATA_KEY_TITLE'];
    } catch (_) {}
    try {
      title ??= basename(uri);
    } catch (_) {}
    try {
      title ??= uri.split('/').last;
    } catch (_) {}

    try {
      album ??= data['METADATA_KEY_ALBUM'];
    } catch (_) {}

    try {
      albumArtist ??= data['METADATA_KEY_ALBUMARTIST'];
    } catch (_) {}

    try {
      discNumber ??= parseInteger(data['METADATA_KEY_DISC_NUMBER']);
    } catch (_) {}

    try {
      trackNumber ??= parseInteger(data['METADATA_KEY_CD_TRACK_NUMBER']);
    } catch (_) {}

    try {
      if (data['METADATA_KEY_NUM_TRACKS'] is String) {
        albumLength ??= parseInteger(data['METADATA_KEY_NUM_TRACKS']);
      } else if (data['track'] is String) {
        if (data['METADATA_KEY_CD_TRACK_NUMBER']?.contains('/') ?? false) {
          albumLength = parseInteger(data['METADATA_KEY_CD_TRACK_NUMBER']?.split('/').last);
        }
      }
    } catch (_) {}

    try {
      year ??= parseInteger(data['METADATA_KEY_YEAR']);
      year ??= parseInteger(splitDateTagValue(data['METADATA_KEY_DATE']));
    } catch (_) {}

    try {
      // NOTE: Lyrics are not supported on Android.
    } catch (_) {}

    try {
      duration = parseInteger(data['METADATA_KEY_DURATION']);
    } catch (_) {}

    try {
      bitrate = parseInteger(data['METADATA_KEY_BITRATE']);
    } catch (_) {}

    try {
      final instance = Uri.parse(uri);
      if (instance.isScheme('FILE')) {
        timestamp ??= await File(instance.toFilePath()).lastModified_();
      }
    } catch (_) {}
    try {
      final instance = File(uri);
      if (await instance.exists()) {
        timestamp ??= await instance.lastModified_();
      }
    } catch (_) {}

    artists = splitTagValue(data['METADATA_KEY_ARTIST']);
    genres = splitTagValue(data['METADATA_KEY_GENRE']);

    title ??= uri;
    album ??= '';
    albumArtist ??= '';
    discNumber ??= 0;
    trackNumber ??= 0;
    albumLength ??= 0;
    year ??= 0;
    lyrics ??= '';
    duration ??= 0;
    bitrate ??= 0;
    timestamp ??= DateTime.now();

    return Tags(
      uri: uri,
      title: title,
      album: album,
      albumArtist: albumArtist,
      discNumber: discNumber,
      trackNumber: trackNumber,
      albumLength: albumLength,
      year: year,
      lyrics: lyrics,
      duration: duration,
      bitrate: bitrate,
      timestamp: timestamp,
      artists: artists,
      genres: genres,
    );
  }

  Future<AndroidMediaFormat> format(String uri) async {
    try {
      final result = await _channel.invokeMethod(
        'format',
        {
          'uri': uri,
        },
      );
      return AndroidMediaFormat(
        bitrate: result['bitrate'],
        sampleRate: result['sampleRate'],
        channelCount: result['channelCount'],
        extension: result['extension'],
      );
    } catch (_) {
      return const AndroidMediaFormat();
    }
  }

  final MethodChannel _channel = const MethodChannel('com.alexmercerind.harmonoid.AndroidStorageController');
}
