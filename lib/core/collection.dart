/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:harmonoid/utils/metadata_retriever.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:media_engine/media_engine.dart' hide Media;
import 'package:media_engine/media_engine.dart' as engine;
import 'package:media_library/media_library.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/utils/tagger_client.dart';
import 'package:harmonoid/utils/storage_retriever.dart';

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
    debugPrint(uri.toString());
    if (Platform.isWindows) {
      assert(_tagger != null);
      final metadata = await _tagger!.parse(
        engine.Media(uri.toString()),
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
      return MetadataRetriever.instance.metadata(
        uri,
        coverDirectory,
        timeout: timeout,
        waitUntilAlbumArtIsSaved: waitUntilAlbumArtIsSaved,
      );
    }
  }

  /// This is because modern Android versions i.e. 10 or higher have stricter file access/management policies.
  /// `MediaStore` is the only way to delete files on Android.
  /// In source code, this is done using:
  ///
  /// - `MediaStore.createDeleteRequest` on Android 11 or higher.
  /// - `java.io.File.delete` on Android 10. Using `android:requestLegacyExternalStorage` on Android 10.
  /// - Simply using `java.io.File.delete` on Android 9 or lower. Good old days.
  ///
  /// This method is internally called by [delete] method to perform the actual delete operation & get result as `true` or `false`.
  ///
  /// If the result is `true` i.e. user approval is granted, then the [delete] method will continue & update the [MediaLibrary] accordingly.
  @override
  Future<bool> androidDeleteRequestDelegate(Media object) {
    if (object is Album) {
      return StorageRetriever.instance.delete(
        object.tracks.map((e) => File(e.uri.toFilePath())),
      );
    } else if (object is Track) {
      return StorageRetriever.instance.delete([File(object.uri.toFilePath())]);
    }
    return Future.value(false);
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

  static const String _kUnknownAlbumArtRootBundle =
      'assets/images/default_album_art.png';
  static const String _kUnknownAlbumArtFileName = 'UnknownAlbum.PNG';
}
