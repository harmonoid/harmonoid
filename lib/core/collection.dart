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
import 'package:media_engine/media_engine.dart';
import 'package:media_library/media_library.dart' hide Media;
import 'package:safe_session_storage/safe_session_storage.dart';

import 'package:harmonoid/utils/tagger_client.dart';

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
    required super.minimumFileSize,
  }) {
    if (Platform.isWindows) {
      _tagger = Tagger(verbose: false);
    }
    if (Platform.isLinux) {
      _client = TaggerClient(verbose: false);
    }
  }

  static Future<void> initialize({
    required Set<Directory> collectionDirectories,
    required Directory cacheDirectory,
    required AlbumsSort albumsSort,
    required TracksSort tracksSort,
    required ArtistsSort artistsSort,
    required GenresSort genresSort,
    required OrderType albumsOrderType,
    required OrderType tracksOrderType,
    required OrderType artistsOrderType,
    required OrderType genresOrderType,
    required int minimumFileSize,
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
        minimumFileSize: minimumFileSize,
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
  Future<void> dispose() async {
    await _tagger?.dispose();
    await _client?.dispose();
  }

  /// Overriden [parse] to implement platform-specific metadata retrieval.
  /// This is Flutter specific & dependent on native platform-channel method calls.
  ///
  /// [waitUntilAlbumArtIsSaved] only works on Android.
  ///
  @override
  Future<dynamic> parse(
    Uri uri,
    Directory coverDirectory, {
    Duration? timeout,
    bool waitUntilAlbumArtIsSaved = false,
  }) async {
    if (Platform.isWindows) {
      assert(_tagger != null);
      final metadata = await _tagger!.parse(
        Media(uri.toString()),
        coverDirectory: coverDirectory,
        timeout: timeout ?? const Duration(seconds: 1),
      );
      debugPrint(metadata.toString());
      return Track.fromTagger(metadata);
    }
    if (Platform.isLinux) {
      assert(_client != null);
      final metadata = await _client!.parse(
        uri.toString(),
        coverDirectory: coverDirectory,
        timeout: timeout ?? const Duration(seconds: 1),
      );
      debugPrint(metadata.toString());
      return Track.fromTagger(metadata);
    }
    if (Platform.isAndroid) {
      try {
        final metadata = await _channel.invokeMethod(
          'parse',
          {
            'uri': uri.toString(),
            'coverDirectory': coverDirectory.path,
            'waitUntilAlbumArtIsSaved': waitUntilAlbumArtIsSaved,
          },
        ).timeout(timeout ?? const Duration(seconds: 1));
        return _AndroidMetadata.fromJson(metadata);
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
        return _AndroidMetadata(
          uri: uri.toString(),
        );
      }
    }
  }

  File get unknownAlbumArt => File(
        join(
          cacheDirectory.path,
          kAlbumArtsDirectoryName,
          _kUnknownAlbumArtFileName,
        ),
      );

  Tagger? _tagger;
  TaggerClient? _client;
  final MethodChannel _channel =
      const MethodChannel('com.alexmercerind.harmonoid.MetadataRetriever');

  static const String _kUnknownAlbumArtRootBundle =
      'assets/images/default_album_art.png';
  static const String _kUnknownAlbumArtFileName = 'UnknownAlbum.PNG';
}

class _AndroidMetadata {
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

  const _AndroidMetadata({
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

  factory _AndroidMetadata.fromJson(dynamic map) => _AndroidMetadata(
        trackName: map['trackName'],
        trackArtistNames: map['trackArtistNames'],
        albumName: map['albumName'],
        albumArtistName: map['albumArtistName'],
        trackNumber: _parseInteger(
          map['trackNumber'],
        ),
        albumLength: _parseInteger(
          map['albumLength'],
        ),
        year: _parseInteger(
          map['year'],
        ),
        genre: map['genre'],
        authorName: map['authorName'],
        writerName: map['writerName'],
        discNumber: _parseInteger(
          map['discNumber'],
        ),
        mimeType: map['mimeType'],
        duration: _parseInteger(
          map['duration'],
        ),
        bitrate: _parseInteger(
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
      '$_AndroidMetadata(trackName: $trackName, trackArtistNames: $trackArtistNames, albumName: $albumName, albumArtistName: $albumArtistName, trackNumber: $trackNumber, albumLength: $albumLength, year: $year, genre: $genre, authorName: $authorName, writerName: $writerName, discNumber: $discNumber, mimeType: $mimeType, duration: $duration, bitrate: $bitrate, uri: $uri)';

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
