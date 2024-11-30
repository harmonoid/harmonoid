import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_library/media_library.dart' as _ show MediaLibrary;
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:tag_reader/tag_reader.dart';

import 'package:harmonoid/mappers/tags.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';

/// {@template media_library}
///
/// MediaLibrary
/// ------------
/// Implementation to cache, index, manage & retrieve album artists, albums, artists, genres, tracks & playlists.
///
/// {@endtemplate}
class MediaLibrary extends _.MediaLibrary with ChangeNotifier {
  /// Pool size for [PooledTagReader].
  static final int kPooledTagReaderSize = () {
    try {
      return Platform.numberOfProcessors.round().clamp(1, 4);
    } catch (_) {
      return 2;
    }
  }();

  /// Singleton instance.
  static late final MediaLibrary instance;

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro media_library}
  MediaLibrary._({
    required super.cache,
    required super.directories,
    required super.albumSortType,
    required super.artistSortType,
    required super.genreSortType,
    required super.trackSortType,
    required super.albumSortAscending,
    required super.artistSortAscending,
    required super.genreSortAscending,
    required super.trackSortAscending,
    required super.minimumFileSize,
    required super.albumGroupingParameters,
  });

  /// Initializes the [instance].
  static Future<void> ensureInitialized({
    required Directory cache,
    required Set<Directory> directories,
    required AlbumSortType albumSortType,
    required ArtistSortType artistSortType,
    required GenreSortType genreSortType,
    required TrackSortType trackSortType,
    required bool albumSortAscending,
    required bool artistSortAscending,
    required bool genreSortAscending,
    required bool trackSortAscending,
    required int minimumFileSize,
    required Set<AlbumGroupingParameter> albumGroupingParameters,
  }) async {
    if (initialized) return;
    initialized = true;

    // NOTE: Must create [cache] directory if it doesn't exist. SQLite will fuck up otherwise.
    if (!await cache.exists_()) {
      await cache.create_();
    }

    instance = MediaLibrary._(
      cache: cache,
      directories: directories,
      albumSortType: albumSortType,
      artistSortType: artistSortType,
      genreSortType: genreSortType,
      trackSortType: trackSortType,
      albumSortAscending: albumSortAscending,
      artistSortAscending: artistSortAscending,
      genreSortAscending: genreSortAscending,
      trackSortAscending: trackSortAscending,
      minimumFileSize: minimumFileSize,
      albumGroupingParameters: albumGroupingParameters,
    );
    // Populate the media library from the database.
    await instance.refresh(
      insert: false,
      delete: false,
    );
    if (instance.tracks.isEmpty) {
      // Look for updates from the file-system if the media library is empty.
      // This situation occurs for the first-time application launch.
      await instance.refresh();
    }
    await instance.playlists.refresh();
  }

  /// Invoked for performing the delete operation on Android.
  ///
  /// Modern Android i.e. API 29 or higher have stricter file policies.
  /// MediaStore is the only way to delete media files on Android.
  /// This is done using:
  ///
  /// * MediaStore.createDeleteRequest on API 30 or higher.
  /// * ContentResolver.delete & RecoverableSecurityException on API 29.
  /// * File.delete on API 28 or lower... Good old days.
  ///
  /// This method is internally invoked by [delete].
  ///
  /// If the result is true i.e. user approval is granted i.e. underlying [File](s) was deleted.
  @override
  Future<bool> androidDeleteDelegate(List<Track> tracks) async => AndroidStorageController.instance.delete(tracks.map((track) => File(track.uri)).toList());

  /// Removes specified [tracks] from the media library.
  @override
  Future<void> remove(List<Track> tracks, {bool delete = true}) async {
    if (_removeInvoked) return;
    _removeInvoked = true;
    await super.remove(tracks, delete: delete);
    _removeInvoked = false;
  }

  /// Invoked for notifying about changes in the media library.
  @override
  Future<void> notify() async => notifyListeners();

  /// Invoked for performing the parsing operation on the given [file].
  @override
  Future<Track> parse(String uri, File cover, Duration timeout) async {
    final tags = await _tagReader.parse(
      uri,
      cover: cover,
      timeout: timeout,
    );
    final result = tags.toTrack();
    debugPrint('MediaLibrary: parse: URI: $uri');
    debugPrint('MediaLibrary: parse: Tags: $tags');
    debugPrint('MediaLibrary: parse: Result: $result');
    return result;
  }

  /// Disposes the [instance]. Releases allocated resources back to the system.
  @override
  void dispose() {
    super.close();
    super.dispose();
    _tagReader.dispose();
  }

  /// Tag reader.
  final PooledTagReader _tagReader = PooledTagReader(size: kPooledTagReaderSize);

  /// Whether [remove] has been invoked.
  bool _removeInvoked = false;
}
