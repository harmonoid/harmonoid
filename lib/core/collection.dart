/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_library/media_library.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

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
  }

  /// Overriden [notify] to get notified about updates & redraw UI using [notifyListeners] from [ChangeNotifier]s.
  @override
  void notify() {
    notifyListeners();
  }

  /// Overriden [retrievePlatformSpecificMetadataFromUri] to implement metadata retrieval for Android.
  /// This is Flutter specific & dependent on native platform-channel method calls.
  @override
  Future<dynamic> retrievePlatformSpecificMetadataFromUri(
    Uri uri,
    Directory coverDirectory,
  ) =>
      MetadataRetriever.fromUri(
        uri,
        coverDirectory: coverDirectory,
      );

  @override
  // ignore: must_call_super
  Future<void> dispose() {
    /// Closes the internal [Tagger] instance.
    return close();
  }
}
