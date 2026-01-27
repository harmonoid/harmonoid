import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:safe_local_storage/file_system.dart';
import 'package:tag_reader/tag_reader.dart';
import 'package:tag_writer/tag_writer.dart';

PlatformTagReader? platformTagReaderFactoryImpl(TagReaderConfiguration configuration) {
  return TagWriter2TagReader(configuration: configuration);
}

class TagWriter2TagReader extends PlatformTagReader {
  TagWriter2TagReader({required super.configuration});

  @override
  Future<Tags> serialize(String uri, Map<String, String> metadata) async {
    String? title;
    String? album;
    String? albumArtist;
    int? discNumber;
    int? trackNumber;
    int? albumLength;
    int? year;
    String? lyrics;
    DateTime? timestamp;
    Set<String>? artists;
    Set<String>? genres;

    try {
      title ??= metadata['TITLE'];
    } catch (_) {}
    try {
      title ??= basename(uri);
    } catch (_) {}
    try {
      title ??= uri.split('/').last;
    } catch (_) {}

    try {
      album ??= metadata['ALBUM'];
    } catch (_) {}

    try {
      albumArtist ??= metadata['ALBUMARTIST'];
      albumArtist ??= splitTagValue(metadata['ARTIST']).firstOrNull;

      // Some files are using separators in the album artist tag as well.
      // Simply join them all together, separated by commas.
      albumArtist = splitTagValue(albumArtist).join(', ');
    } catch (_) {}

    try {
      discNumber ??= parseInteger(metadata['DISCNUMBER']);
    } catch (_) {}

    try {
      trackNumber ??= parseInteger(metadata['TRACKNUMBER']);
    } catch (_) {}

    try {
      final track = metadata['TRACKNUMBER'];
      if (track != null && track.contains('/')) {
        albumLength ??= parseInteger(track.split('/').last);
      }
    } catch (_) {}

    try {
      year ??= parseInteger(splitDateTagValue(splitTagValue(metadata['DATE']).lastOrNull));
    } catch (_) {}

    try {
      lyrics ??= metadata['LYRICS'];
    } catch (_) {}

    try {
      final instance = Uri.parse(uri);
      if (instance.isScheme('FILE')) {
        timestamp ??= await File(instance.toFilePath()).lastModified_();
      }
    } catch (_) {}
    try {
      final f = File(uri);
      if (await f.exists_()) {
        timestamp ??= await f.lastModified_();
      }
    } catch (_) {}

    artists = splitTagValue(metadata['ARTISTS'] ?? metadata['ARTIST']);
    genres = splitTagValue(metadata['GENRE']);

    title ??= uri;
    album ??= '';
    albumArtist ??= '';
    discNumber ??= 0;
    trackNumber ??= 0;
    albumLength ??= 0;
    year ??= 0;
    lyrics ??= '';
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
      duration: 0,
      bitrate: 0,
      timestamp: timestamp,
      artists: artists,
      genres: genres,
    );
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<Map<String, String>> metadata(String uri, {File? cover, Duration timeout = kDefaultTimeout}) async {
    final metadata = <String, String>{};

    TagWriter? writer;

    try {
      writer = TagWriter(uri);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    if (writer == null) {
      return metadata;
    }

    try {
      final properties = await writer.getProperties();
      for (final entry in properties.entries) {
        final k = entry.key;
        final v = entry.value.where((e) => e.isNotEmpty).join(';');
        if (v.isNotEmpty) {
          metadata[k] = v;
        }
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    try {
      if (cover != null) {
        await writer.saveCover(cover.path);
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    try {
      await writer.dispose();
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    return metadata;
  }
}
