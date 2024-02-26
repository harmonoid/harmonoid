import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:media_library/media_library.dart' as _ show MediaLibrary;
import 'package:tag_reader/tag_reader.dart';

import 'package:harmonoid/mappers/tags.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';

/// {@template media_library}
///
/// MediaLibrary
/// ------------
/// Application's media library to cache, index, manage & retrieve album artists, albums, artists, genres, tracks & playlists.
///
/// {@endtemplate}
class MediaLibrary extends _.MediaLibrary with ChangeNotifier {
  /// Singleton instance.
  static late final MediaLibrary instance;

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro media_library}
  MediaLibrary._({
    required super.directories,
    required super.cache,
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
    required Set<Directory> directories,
    required Directory cache,
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
    instance = MediaLibrary._(
      directories: directories,
      cache: cache,
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
    await instance.refresh(
      insert: false,
      delete: false,
    );
  }

  /// Progress: Current.
  int? current;

  /// Progress: Total.
  int total = 0;

  /// Progress: Done.
  bool done = true;

  /// Progress: Callback.
  void progress(int? current, int total, bool done) {
    this.current = current;
    this.total = total;
    this.done = done;
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
    return tags.toTrack();
  }

  /// Disposes the [instance]. Releases allocated resources back to the system.
  @override
  void dispose() {
    super.dispose();
    _tagReader.dispose();
  }

  /// Tag reader.
  final TagReader _tagReader = TagReader();
}
