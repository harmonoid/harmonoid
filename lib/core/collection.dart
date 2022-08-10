/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:media_library/media_library.dart';
import 'package:safe_session_storage/safe_session_storage.dart';

/// Collection
/// ----------
///
/// Primary music collection generator & indexer of [Harmonoid](https://github.com/harmonoid/harmonoid).
///
class Collection extends MediaLibrary with ChangeNotifier {
  /// [Collection] object instance.
  /// Must call [Collection.initialize].
  static late Collection instance;

  Collection({
    required super.collectionDirectories,
    required super.cacheDirectory,
    required super.albumsSort,
    required super.tracksSort,
    required super.artistsSort,
    required super.genresSort,
    required super.albumsOrderType,
    required super.tracksOrderType,
    required super.artistsOrderType,
    required super.genresOrderType,
  });

  static Future<void> initialize({
    required List<Directory> collectionDirectories,
    required Directory cacheDirectory,
    required AlbumsSort albumsSort,
    required TracksSort tracksSort,
    required ArtistsSort artistsSort,
    required GenresSort genresSort,
    required OrderType albumsOrderType,
    required OrderType tracksOrderType,
    required OrderType artistsOrderType,
    required OrderType genresOrderType,
  }) async {
    instance = await MediaLibrary.register(
      Collection(
        collectionDirectories: collectionDirectories,
        cacheDirectory: cacheDirectory,
        albumsSort: albumsSort,
        tracksSort: tracksSort,
        artistsSort: artistsSort,
        genresSort: genresSort,
        albumsOrderType: albumsOrderType,
        tracksOrderType: tracksOrderType,
        artistsOrderType: artistsOrderType,
        genresOrderType: genresOrderType,
      ),
    );
    if (!await instance.unknownAlbumArt.exists_()) {
      await instance.unknownAlbumArt.create_();
      final data = await rootBundle.load(_kUnknownAlbumArtRootBundle);
      await instance.unknownAlbumArt.write_(data.buffer.asUint8List());
    }
  }

  /// Overriden [notify] to get notified about updates & redraw UI using [notifyListeners] from [ChangeNotifier]s.
  @override
  void notify() {
    notifyListeners();
  }

  @override
  // ignore: must_call_super
  Future<void> dispose() {
    /// Closes the internal [Tagger] instance.
    return close();
  }

  /// Overriden [retrievePlatformSpecificMetadataFromUri] to implement metadata retrieval for Android.
  /// This is Flutter specific & dependent on native platform-channel method calls.
  @override
  Future<dynamic> retrievePlatformSpecificMetadataFromUri(
    Uri uri,
    Directory coverDirectory, {
    // Not used by [MediaLibrary], specific to Harmonoid's source code.
    Duration? timeout,
    // Not used by [MediaLibrary], specific to Harmonoid's source code.
    bool waitUntilAlbumArtIsSaved = false,
  }) async {
    try {
      final metadata = await _kPlatformSpecificMetadataRetriever.invokeMethod(
        'MetadataRetriever',
        {
          'uri': uri.toString(),
          'coverDirectory': coverDirectory.path,
          'waitUntilAlbumArtIsSaved': waitUntilAlbumArtIsSaved,
        },
      ).timeout(timeout ?? const Duration(seconds: 2));
      return _PlatformSpecificMetadata.fromJson(metadata);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      return _PlatformSpecificMetadata(
        uri: uri.toString(),
      );
    }
  }

  File get unknownAlbumArt => File(
        join(
          cacheDirectory.path,
          kAlbumArtsDirectoryName,
          _kUnknownAlbumArtFileName,
        ),
      );

  static int? _parsePlatformSpecificMetadataResponseInteger(dynamic value) {
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

  static const MethodChannel _kPlatformSpecificMetadataRetriever =
      MethodChannel('com.alexmercerind.harmonoid.MetadataRetriever');
  static const String _kUnknownAlbumArtRootBundle =
      'assets/images/default_album_art.png';
  static const String _kUnknownAlbumArtFileName = 'UnknownAlbum.PNG';
}

class _PlatformSpecificMetadata {
  final String? trackName;
  final String? trackArtistNames;
  final String? albumName;
  final String? albumArtistName;
  final int? trackNumber;
  final int? albumLength;
  final int? year;
  final String? genre;
  final String? authorName;
  final String? writerName;
  final int? discNumber;
  final String? mimeType;
  final int? duration;
  final int? bitrate;
  final String? uri;

  const _PlatformSpecificMetadata({
    this.trackName,
    this.trackArtistNames,
    this.albumName,
    this.albumArtistName,
    this.trackNumber,
    this.albumLength,
    this.year,
    this.genre,
    this.authorName,
    this.writerName,
    this.discNumber,
    this.mimeType,
    this.duration,
    this.bitrate,
    this.uri,
  });

  factory _PlatformSpecificMetadata.fromJson(dynamic map) =>
      _PlatformSpecificMetadata(
        trackName: map['trackName'],
        trackArtistNames: map['trackArtistNames'],
        albumName: map['albumName'],
        albumArtistName: map['albumArtistName'],
        trackNumber: Collection._parsePlatformSpecificMetadataResponseInteger(
          map['trackNumber'],
        ),
        albumLength: Collection._parsePlatformSpecificMetadataResponseInteger(
          map['albumLength'],
        ),
        year: Collection._parsePlatformSpecificMetadataResponseInteger(
          map['year'],
        ),
        genre: map['genre'],
        authorName: map['authorName'],
        writerName: map['writerName'],
        discNumber: Collection._parsePlatformSpecificMetadataResponseInteger(
          map['discNumber'],
        ),
        mimeType: map['mimeType'],
        duration: Collection._parsePlatformSpecificMetadataResponseInteger(
          map['duration'],
        ),
        bitrate: Collection._parsePlatformSpecificMetadataResponseInteger(
          map['bitrate'],
        ),
        uri: map['uri'],
      );

  Map<String, dynamic> toJson() => {
        'trackName': trackName,
        'trackArtistNames': trackArtistNames,
        'albumName': albumName,
        'albumArtistName': albumArtistName,
        'trackNumber': trackNumber,
        'albumLength': albumLength,
        'year': year,
        'genre': genre,
        'authorName': authorName,
        'writerName': writerName,
        'discNumber': discNumber,
        'mimeType': mimeType,
        'duration': duration,
        'bitrate': bitrate,
        'uri': uri,
      };

  @override
  String toString() =>
      '$_PlatformSpecificMetadata(trackName: $trackName, trackArtistNames: $trackArtistNames, albumName: $albumName, albumArtistName: $albumArtistName, trackNumber: $trackNumber, albumLength: $albumLength, year: $year, genre: $genre, authorName: $authorName, writerName: $writerName, discNumber: $discNumber, mimeType: $mimeType, duration: $duration, bitrate: $bitrate, uri: $uri)';
}
