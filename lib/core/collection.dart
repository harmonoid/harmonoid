/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:media_library/media_library.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:media_kit_tag_reader/media_kit_tag_reader.dart';

import 'package:harmonoid/utils/storage_retriever.dart';

/// Collection
/// ----------
///
/// Primary music library handler & indexer of Harmonoid.
///
class Collection extends MediaLibrary with ChangeNotifier {
  /// [Collection] object instance. Must call [Collection.initialize].
  static late Collection instance;

  /// Platform independent tag reader from `package:media_kit_tag_reader` for parsing & reading metadata from music files.
  final TagReader reader = TagReader();

  /// Initializes the [Collection] singleton instance for usage.
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
    required Set<AlbumHashCodeParameter> albumHashCodeParameters,
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
        albumHashCodeParameters: albumHashCodeParameters,
      ),
    );
    // Create the unknown album art file if it doesn't exist.
    // Likely only relevant for the first-time launch.
    if (!await instance.unknownAlbumArt.exists_()) {
      final data = await rootBundle.load(kUnknownAlbumArtAssets);
      await instance.unknownAlbumArt.create_();
      await instance.unknownAlbumArt.write_(data.buffer.asUint8List());
    }
  }

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
    required super.albumHashCodeParameters,
  });

  /// Overriden [notify] to get notified about updates & redraw UI using [notifyListeners] from [ChangeNotifier]s.
  @override
  void notify() {
    notifyListeners();
  }

  @override
  // ignore: must_call_super
  Future<void> dispose() async {
    reader.dispose();
  }

  /// Overriden [parse] to implement platform-specific metadata retrieval.
  /// This is Flutter specific & dependent on native platform-channel method calls.
  ///
  /// [waitUntilAlbumArtIsSaved] only works on Android.
  ///
  @override
  Future<dynamic> parse(
    Uri uri,
    Directory albumArtDirectory, {
    Duration? timeout,
  }) async {
    debugPrint(uri.toString());
    timeout ??= const Duration(seconds: 1);
    final result = await reader.parse(
      uri.toString(),
      albumArtDirectory: albumArtDirectory,
      timeout: timeout,
    );
    debugPrint(result.toString());
    return result;
  }

  /// Must be overridden by the subclass to implement the actual delete operation on Android.
  ///
  /// Modern Android versions i.e. 10 or higher enforce Scoped Storage, which means File I/O is very restricted.
  /// In order to delete any [File]s, the user must grant approval to the app each time.
  /// One other point to note is that deletion of only media files is possible through `MediaStore` API.
  ///
  /// In Harmonoid's source code, this is done using:
  /// * `MediaStore.createDeleteRequest` on Android 11 or higher.
  /// * `RecoverableSecurityException` and `ContentResolver.delete` on Android 10.
  /// * Simply using `java.io.File.delete` on Android 9 or lower. Good old days.
  ///
  /// This method is internally called by [delete] method to perform the actual delete operation & get result as `true` or `false`.
  /// If the result is `true` i.e. user approval is granted, then the [delete] method will continue & update the [MediaLibrary] accordingly.
  ///
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

  File get unknownAlbumArt {
    return File(
      join(
        cacheDirectory.path,
        kAlbumArtsDirectoryName,
        kUnknownAlbumArtStorage,
      ),
    );
  }

  static const String kUnknownAlbumArtAssets =
      'assets/images/default_album_art.png';
  static const String kUnknownAlbumArtStorage = 'UnknownAlbum.PNG';
}
