/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:collection';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:libmpv/libmpv.dart' hide Playlist, Media;
import 'package:path/path.dart' as path;
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'package:harmonoid/models/media.dart';

/// Collection
/// ----------
///
/// Primary music collection generator & indexer of [Harmonoid](https://github.com/harmonoid/harmonoid).
///
class Collection extends ChangeNotifier {
  /// [Collection] object instance. Must call [Collection.initialize].
  static late Collection instance = Collection();

  /// Initializes the music collection.
  ///
  /// Called before [runApp] & is non-blocking, [refresh] is used for indexing the music.
  ///
  static Future<void> initialize({
    required List<Directory> collectionDirectories,
    required Directory cacheDirectory,
    required CollectionSort collectionSortType,
    required CollectionOrder collectionOrderType,
  }) async {
    instance.collectionDirectories = collectionDirectories;
    instance.cacheDirectory = cacheDirectory;
    instance.collectionSortType = collectionSortType;
    instance.collectionOrderType = collectionOrderType;
    instance.albumArtDirectory = Directory(
        path.join(instance.cacheDirectory.path, kAlbumArtsDirectoryName));
    instance.unknownAlbumArt = File(path.join(cacheDirectory.path,
        kAlbumArtsDirectoryName, kUnknownAlbumArtFileName));
    for (Directory directory in collectionDirectories) {
      if (!await directory.exists()) await directory.create(recursive: true);
    }
    if (!await instance.unknownAlbumArt.exists()) {
      await instance.unknownAlbumArt.create(recursive: true);
      await instance.unknownAlbumArt.writeAsBytes(
          (await rootBundle.load(kUnknownAlbumArtRootBundle))
              .buffer
              .asUint8List());
    }
  }

  late List<Directory> collectionDirectories;
  late Directory cacheDirectory;
  late CollectionSort collectionSortType;
  late CollectionOrder collectionOrderType;
  late Directory albumArtDirectory;
  late File unknownAlbumArt;
  List<Playlist> playlists = <Playlist>[];
  List<Album> albums = <Album>[];
  List<Track> tracks = <Track>[];
  List<Artist> artists = <Artist>[];
  SplayTreeMap<AlbumArtist, List<Album>> albumArtists =
      SplayTreeMap<AlbumArtist, List<Album>>();

  /// Updates (or sets) the directories that are used for indexing of the music.
  ///
  Future<void> setDirectories({
    required List<Directory>? collectionDirectories,
    required Directory? cacheDirectory,
    void Function(int, int, bool)? onProgress,
  }) async {
    this.collectionDirectories = collectionDirectories!;
    this.cacheDirectory = cacheDirectory!;
    for (Directory directory in collectionDirectories) {
      if (!await directory.exists()) await directory.create(recursive: true);
    }
    if (!await unknownAlbumArt.exists()) {
      await unknownAlbumArt.create(recursive: true);
      await unknownAlbumArt.writeAsBytes(
          (await rootBundle.load(kUnknownAlbumArtRootBundle))
              .buffer
              .asUint8List());
    }
    await refresh(onProgress: onProgress);
    notifyListeners();
  }

  /// Searches for a [Media] based upon a the passed [query].
  ///
  List<Media> search(String query, {Media? mode, int? limit}) {
    if (query.isEmpty) return <Media>[];

    List<Media> result = <Media>[];
    if (mode is Album || mode == null) {
      for (Album album in albums) {
        if (album.albumName.toLowerCase().contains(query.toLowerCase())) {
          result.add(album);
        }
      }
    }
    if (mode is Track || mode == null) {
      for (Track track in tracks) {
        if (track.trackName.toLowerCase().contains(query.toLowerCase())) {
          result.add(track);
        }
      }
    }
    if (mode is Artist || mode == null) {
      for (Artist artist in artists) {
        if (artist.artistName.toLowerCase().contains(query.toLowerCase())) {
          result.add(artist);
        }
      }
    }
    return result;
  }

  /// Adds a new track to the music collection.
  ///
  /// Normally used when refreshing the music collection. Internally called by [refresh].
  ///
  Future<void> add({required File file}) async {
    bool isAlreadyPresent = false;
    for (final track in tracks) {
      if (track.uri.toFilePath() == file.uri.toFilePath()) {
        isAlreadyPresent = true;
        break;
      }
    }
    if (kSupportedFileTypes.contains(file.extension) && !isAlreadyPresent) {
      try {
        final metadata = <String, String>{
          'uri': file.uri.toString(),
        };
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          try {
            metadata.addAll(await tagger.parse(
              file.uri.toString(),
              coverDirectory: albumArtDirectory,
            ));
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
          final track = Track.fromTagger(metadata);
          _arrange(
            track,
            () {},
          );
        } else {
          final _metadata = await MetadataRetriever.fromFile(file);
          metadata.addAll(_metadata.toJson().cast());
          final track = Track.fromJson(metadata);
          _arrange(
            track,
            () async {
              if (_metadata.albumArt != null) {
                await File(path.join(
                  albumArtDirectory.path,
                  track.albumArtFileName,
                )).writeAsBytes(_metadata.albumArt!);
              }
            },
          );
        }
        _arrangeArtists();
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }
    await saveToCache();
    sort();
    notifyListeners();
  }

  /// Removes a [Media] i.e. [Album], [Track] or [Artist] from the music collection.
  ///
  /// Automatically updates other structures & models. Also deletes the respective files.
  ///
  Future<void> delete(Media object) async {
    if (object is Track) {
      for (int index = 0; index < tracks.length; index++) {
        if (object.trackName == tracks[index].trackName &&
            object.trackNumber == tracks[index].trackNumber) {
          tracks.removeAt(index);
          break;
        }
      }
      for (Album album in albums) {
        if (object.albumName == album.albumName &&
            object.albumArtistName == album.albumArtistName) {
          for (int index = 0; index < album.tracks.length; index++) {
            if (object.trackName == album.tracks[index].trackName) {
              album.tracks.removeAt(index);
              break;
            }
          }
          if (album.tracks.length == 0) albums.remove(album);
          break;
        }
      }
      for (String artistName in object.trackArtistNames) {
        for (Artist artist in artists) {
          if (artistName == artist.artistName) {
            for (int index = 0; index < artist.tracks.length; index++) {
              if (object.trackName == artist.tracks[index].trackName &&
                  object.trackNumber == artist.tracks[index].trackNumber) {
                artist.tracks.removeAt(index);
                break;
              }
            }
            if (artist.tracks.length == 0) {
              artists.remove(artist);
              break;
            } else {
              for (Album album in artist.albums) {
                if (object.albumName == album.albumName &&
                    object.albumArtistName == album.albumArtistName) {
                  for (int index = 0; index < album.tracks.length; index++) {
                    if (object.trackName == album.tracks[index].trackName) {
                      album.tracks.removeAt(index);
                      if (artist.albums.length == 0) artists.remove(artist);
                      break;
                    }
                  }
                  break;
                }
              }
            }
            break;
          }
        }
      }
      for (int i = 0;
          i < albumArtists[AlbumArtist(object.albumArtistName)]!.length;
          i++) {
        if (albumArtists[AlbumArtist(object.albumArtistName)]![i]
            .tracks
            .isEmpty) {
          albumArtists[AlbumArtist(object.albumArtistName)]!.removeAt(i);
          break;
        }
      }
      if (albumArtists[AlbumArtist(object.albumArtistName)]!.isEmpty) {
        albumArtists.remove(AlbumArtist(object.albumArtistName));
      }
      if (await File(object.uri.toFilePath()).exists()) {
        await File(object.uri.toFilePath()).delete();
      }
    } else if (object is Album) {
      for (int index = 0; index < albums.length; index++) {
        if (object.albumName == albums[index].albumName &&
            object.albumArtistName == albums[index].albumArtistName) {
          albums.removeAt(index);
          break;
        }
      }
      for (int index = 0; index < tracks.length; index++) {
        List<Track> _tracks = <Track>[];
        for (Track track in tracks) {
          if (object.albumName != track.albumName &&
              object.albumArtistName != track.albumArtistName) {
            _tracks.add(track);
          }
        }
        tracks = _tracks;
      }
      for (Artist artist in artists) {
        for (Track track in artist.tracks) {
          List<Track> _tracks = <Track>[];
          if (object.albumName != track.albumName &&
              object.albumArtistName != track.albumArtistName) {
            _tracks.add(track);
          }
          artist.tracks.clear();
          artist.tracks.addAll(_tracks);
        }
        for (Album album in artist.albums) {
          if (object.albumName == album.albumName &&
              object.albumArtistName == album.albumArtistName) {
            artist.albums.remove(album);
            break;
          }
        }
      }
      albumArtists[AlbumArtist(object.albumArtistName)]!.remove(object);
      if (albumArtists[AlbumArtist(object.albumArtistName)]!.isEmpty) {
        albumArtists.remove(AlbumArtist(object.albumArtistName));
      }
      for (Track track in object.tracks) {
        if (await File(track.uri.toFilePath()).exists()) {
          await File(track.uri.toFilePath()).delete();
        }
      }
    }
    await sort();
    await saveToCache();
    notifyListeners();
  }

  /// Saves the currently visible music collection to the cache.
  ///
  Future<void> saveToCache() async {
    tracks.sort((first, second) => second.timeAdded.millisecondsSinceEpoch
        .compareTo(first.timeAdded.millisecondsSinceEpoch));
    await File(path.join(cacheDirectory.path, kCollectionCacheFileName))
        .writeAsString(
      encoder.convert(
        {
          'tracks': tracks.map((track) => track.toJson()).toList(),
        },
      ),
    );
    sort();
  }

  /// Refreshes the music collection.
  ///
  /// Automatically calls [index] internally if no cache is found.
  /// Checks for newly added & deleted tracks to update the music collection.
  ///
  /// Non-blocking in nature. Sends progress updates to the optional callback parameter [onProgress].
  ///
  Future<void> refresh({
    void Function(int completed, int total, bool isCompleted)? onProgress,
  }) async {
    // For safety.
    if (!await cacheDirectory.exists())
      await cacheDirectory.create(recursive: true);
    for (Directory directory in collectionDirectories) {
      if (!await directory.exists()) await directory.create(recursive: true);
    }
    // Clear existing indexed music.
    albums = <Album>[];
    tracks = <Track>[];
    artists = <Artist>[];
    // Indexing from scratch if no cache exists.
    if (!await File(path.join(cacheDirectory.path, kCollectionCacheFileName))
        .exists()) {
      index(onProgress: onProgress);
    }
    // Just check for newly added or deleted tracks if cache exists.
    else {
      try {
        // Index tracks already in the cache.
        final collection = convert.jsonDecode(
            await File(path.join(cacheDirectory.path, kCollectionCacheFileName))
                .readAsString());
        for (final map in collection['tracks']) {
          final track = Track.fromJson(map);
          _arrange(track, () {});
        }
        await sort();
        // Populate Check for newly added & deleted tracks in asynchronous suspension.
        () async {
          await _arrangeArtists();
          // Remove deleted tracks.
          final buffer = [...tracks];
          for (final track in buffer) {
            if (!await File(track.uri.toFilePath()).exists()) delete(track);
          }
          // Add newly added tracks.
          List<File> directory = <File>[];
          for (Directory collectionDirectory in collectionDirectories) {
            for (FileSystemEntity object
                in collectionDirectory.listSync(recursive: true)) {
              if (object is File &&
                  kSupportedFileTypes.contains(object.extension)) {
                directory.add(object);
              }
            }
          }
          directory.sort((first, second) =>
              first.lastModifiedSync().compareTo(second.lastModifiedSync()));
          for (int index = 0; index < directory.length; index++) {
            File file = directory[index];
            bool isTrackAdded = false;
            for (Track track in tracks) {
              if (track.uri.toFilePath() == file.uri.toFilePath()) {
                isTrackAdded = true;
                break;
              }
            }
            if (!isTrackAdded) {
              await add(file: file);
            }
            try {
              onProgress?.call(index + 1, directory.length, false);
            } catch (exception) {}
          }
          try {
            onProgress?.call(directory.length, directory.length, true);
          } catch (exception) {}
        }();
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
        await index(onProgress: onProgress);
      }
    }
    await saveToCache();
    await playlistsGetFromCache();
    await sort();
    notifyListeners();
  }

  /// Sorts the music collection contents based upon passed [type].
  ///
  Future<void> sort({CollectionSort? type}) async {
    if (type == null) {
      type = collectionSortType;
    } else {
      collectionSortType = type;
    }
    tracks.sort((first, second) => (first.timeAdded.millisecondsSinceEpoch)
        .compareTo(second.timeAdded.millisecondsSinceEpoch));
    albums.sort((first, second) => first.timeAdded.compareTo(second.timeAdded));
    if (type == CollectionSort.aToZ ||
        type ==
            CollectionSort
                .artist /* Handled externally & applicable only for albums & other tabs fallback to `CollectionSort.aToZ */) {
      tracks.sort((first, second) => first.trackName
          .toLowerCase()
          .compareTo(second.trackName.toLowerCase()));
      albums.sort((first, second) => first.albumName
          .toLowerCase()
          .compareTo(second.albumName.toLowerCase()));
    }
    if (type == CollectionSort.year) {
      tracks.sort((first, second) => (int.tryParse(first.year) ?? -1)
          .compareTo(int.tryParse(second.year) ?? -1));
      albums.sort((first, second) => (int.tryParse(first.year) ?? -1)
          .compareTo(int.tryParse(second.year) ?? -1));
    }
    // Only `CollectionSort.aToZ` is available for [artists].
    artists.sort((first, second) => first.artistName
        .toLowerCase()
        .compareTo(second.artistName.toLowerCase()));
    if (collectionOrderType == CollectionOrder.descending) {
      tracks = tracks.reversed.toList();
      albums = albums.reversed.toList();
      artists = artists.reversed.toList();
    }
    notifyListeners();
  }

  /// Orders the music collection contents based upon passed [type].
  ///
  Future<void> order({CollectionOrder? type}) async {
    if (type != collectionOrderType && type != null) {
      tracks = tracks.reversed.toList();
      albums = albums.reversed.toList();
      artists = artists.reversed.toList();
      collectionOrderType = type;
    }
    notifyListeners();
  }

  /// Indexes the music collection from scratch clearing the existing cache.
  ///
  /// Deletes the cache file before proceeding.
  ///
  Future<void> index(
      {void Function(int completed, int total, bool isCompleted)?
          onProgress}) async {
    albums = <Album>[];
    tracks = <Track>[];
    artists = <Artist>[];
    playlists = <Playlist>[];
    final directory = <File>[];
    for (final collectionDirectory in collectionDirectories)
      directory.addAll((collectionDirectory.listSync(recursive: true)
            ..removeWhere((element) => !(element is File)))
          .cast());
    for (int index = 0; index < directory.length; index++) {
      final object = directory[index];
      if (kSupportedFileTypes.contains(object.extension)) {
        try {
          final metadata = <String, String>{
            'uri': object.uri.toString(),
          };
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
            try {
              metadata.addAll(await tagger.parse(
                object.uri.toString(),
                coverDirectory: albumArtDirectory,
              ));
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
            final track = Track.fromTagger(metadata);
            _arrange(
              track,
              () {},
            );
          } else {
            final _metadata = await MetadataRetriever.fromFile(object);
            metadata.addAll(_metadata.toJson().cast());
            final track = Track.fromJson(metadata);
            _arrange(
              track,
              () async {
                if (_metadata.albumArt != null) {
                  await File(path.join(
                    albumArtDirectory.path,
                    track.albumArtFileName,
                  )).writeAsBytes(_metadata.albumArt!);
                }
              },
            );
          }
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
      try {
        onProgress?.call(index + 1, directory.length, true);
      } catch (exception) {}
    }
    _arrangeArtists();
    await sort();
    await saveToCache();
    try {
      onProgress?.call(directory.length, directory.length, true);
    } catch (exception) {}
    await playlistsGetFromCache();
    notifyListeners();
  }

  ImageProvider getAlbumArt(Media media) {
    if (media is Track) {
      if (Plugins.isExternalMedia(media.uri)) {
        return NetworkImage(Plugins.artwork(media.uri));
      }
      final file = File(path.join(
        albumArtDirectory.path,
        media.albumArtFileName,
      ));
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        for (final name in kAlbumArtFileNames) {
          final file =
              File(path.join(path.basename(media.uri.toFilePath()), name));
          if (file.existsSync()) {
            return FileImage(file);
          }
        }
      }
    } else if (media is Album) {
      if (Plugins.isExternalMedia(media.tracks.first.uri)) {
        return NetworkImage(Plugins.artwork(media.tracks.first.uri));
      }
      final file = File(path.join(
        albumArtDirectory.path,
        media.tracks.first.albumArtFileName,
      ));
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        for (final name in kAlbumArtFileNames) {
          final file = File(path.join(
              path.basename(media.tracks.first.uri.toFilePath()), name));
          if (file.existsSync()) {
            return FileImage(file);
          }
        }
      }
    } else if (media is Artist) {
      if (Plugins.isExternalMedia(media.tracks.first.uri)) {
        return NetworkImage(Plugins.artwork(media.tracks.first.uri));
      }
      final file = File(path.join(
        albumArtDirectory.path,
        media.tracks.first.albumArtFileName,
      ));
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        for (final name in kAlbumArtFileNames) {
          final file = File(path.join(
              path.basename(media.tracks.first.uri.toFilePath()), name));
          if (file.existsSync()) {
            return FileImage(file);
          }
        }
      }
    }
    return FileImage(unknownAlbumArt);
  }

  /// Creates a new playlist in the collection.
  ///
  Future<void> playlistAdd(String playlist) async {
    if (playlists.length == 0) {
      playlists.add(Playlist(name: playlist, id: 0));
    } else {
      playlists.add(
        Playlist(name: playlist, id: playlists.last.id + 1),
      );
    }
    await playlistsSaveToCache();
    notifyListeners();
  }

  /// Removes a playlist from the collection.
  ///
  Future<void> playlistRemove(Playlist playlist) async {
    for (int index = 0; index < playlists.length; index++) {
      if (playlists[index].id == playlist.id) {
        playlists.removeAt(index);
        break;
      }
    }
    await playlistsSaveToCache();
    notifyListeners();
  }

  /// Adds a track to a playlist.
  ///
  Future<void> playlistAddTrack(Playlist playlist, Track track) async {
    for (int index = 0; index < playlists.length; index++) {
      if (playlists[index].id == playlist.id) {
        playlists[index].tracks.add(track);
        break;
      }
    }
    await playlistsSaveToCache();
    notifyListeners();
  }

  /// Removes a track from a playlist.
  ///
  Future<void> playlistRemoveTrack(Playlist playlist, Track track) async {
    for (int index = 0; index < playlists.length; index++) {
      if (playlists[index].id == playlist.id) {
        for (int trackIndex = 0; trackIndex < playlist.tracks.length; index++) {
          if (playlists[index].tracks[trackIndex].trackName ==
                  track.trackName &&
              playlists[index].tracks[trackIndex].albumName ==
                  track.albumName) {
            playlists[index].tracks.removeAt(trackIndex);
            break;
          }
        }
        break;
      }
    }
    await playlistsSaveToCache();
    notifyListeners();
  }

  /// Save playlists to the cache.
  ///
  Future<void> playlistsSaveToCache() async {
    await File(
      path.join(
        cacheDirectory.path,
        kPlaylistsCacheFileName,
      ),
    ).writeAsString(
      encoder.convert(
        {
          'playlists': playlists
              .map(
                (playlist) => playlist.toJson(),
              )
              .toList()
        },
      ),
    );
  }

  /// Gets all the playlists present in the cache.
  ///
  Future<void> playlistsGetFromCache() async {
    playlists = <Playlist>[];
    File playlistFile =
        File(path.join(cacheDirectory.path, kPlaylistsCacheFileName));
    // Keep playlist named "Liked Songs" persistently.
    if (!await playlistFile.exists()) {
      playlists = [
        Playlist(
          id: -1,
          name: 'Liked Songs',
        ),
      ];
      playlistsSaveToCache();
    } else {
      final json =
          convert.jsonDecode(await playlistFile.readAsString())['playlists'];
      for (final element in json) {
        playlists.add(Playlist.fromJson(element));
      }
    }
    notifyListeners();
  }

  /// Indexes a track into album & artist models.
  ///
  void _arrange(Track track, VoidCallback save) async {
    if (tracks.contains(track)) return;
    if (!albums.contains(
      Album(
        albumName: track.albumName,
        albumArtistName: track.albumArtistName,
        year: track.year,
      ),
    )) {
      // Run as asynchronous suspension.
      save();
      albums.add(
        Album(
          albumName: track.albumName,
          year: track.year,
          albumArtistName: track.albumArtistName,
        )..tracks.add(track),
      );
    } else {
      albums[albums.indexOf(
        Album(
          albumName: track.albumName,
          albumArtistName: track.albumArtistName,
          year: track.year,
        ),
      )]
          .tracks
          .add(track);
    }
    // A new album artist gets discovered.
    if (!albumArtists.containsKey(AlbumArtist(track.albumArtistName))) {
      // Create new [List] and append the new [Album] to its name.
      albumArtists[AlbumArtist(track.albumArtistName)] = [];
    }
    for (String artistName in track.trackArtistNames) {
      if (!artists.contains(Artist(artistName: artistName))) {
        artists.add(
          Artist(
            artistName: artistName,
          )..tracks.add(track),
        );
      } else {
        artists[artists.indexOf(
          Artist(artistName: artistName),
        )]
            .tracks
            .add(track);
      }
    }
    tracks.add(track);
  }

  /// Populates all the [albumArtists] & discovered artists' albums after running the [_arrange] loop.
  ///
  Future<void> _arrangeArtists() async {
    for (Album album in albums) {
      List<String> allAlbumArtistNames = <String>[];
      album.tracks.forEach((Track track) {
        track.trackArtistNames.forEach((artistName) {
          if (!allAlbumArtistNames.contains(artistName))
            allAlbumArtistNames.add(artistName);
        });
      });
      for (String artistName in allAlbumArtistNames) {
        if (!artists[artists.indexOf(Artist(artistName: artistName))]
            .albums
            .contains(album))
          artists[artists.indexOf(Artist(artistName: artistName))]
              .albums
              .add(album);
      }
      if (!albumArtists[AlbumArtist(album.albumArtistName)]!.contains(album)) {
        albumArtists[AlbumArtist(album.albumArtistName)]!.add(album);
      }
    }
    notifyListeners();
  }

  /// Redraws the collection.
  ///
  Future<void> redraw() async {
    await sort();
    // Explicitly populate so that [Artist] sort in [Album] tab doesn't present empty screen at the time of indexing.
    for (Album album in albums) {
      if (!albumArtists[AlbumArtist(album.albumArtistName)]!.contains(album)) {
        albumArtists[AlbumArtist(album.albumArtistName)]!.add(album);
      }
    }
    notifyListeners();
  }

  @override
  // ignore: must_call_super
  void dispose() {}
}

/// Types of sorts available.
///
enum CollectionSort {
  aToZ,
  dateAdded,
  year,

  /// A new sort which arranges the [AlbumScreen] & [ArtistScreen] with a sidebar that allows to view [Artist]s [Track]s from a specified artist.
  /// Currently exclusive to desktop.
  artist,
}

/// Types of orders available.
///
enum CollectionOrder { ascending, descending }

/// Supported file extensions.
/// Used for identifying the audio files during indexing the collection.
///
const List<String> kSupportedFileTypes = [
  'OGG',
  'OGA',
  'OGX',
  'AAC',
  'M4A',
  'MP3',
  'WMA',
  'WAV',
  'FLAC',
  'OPUS',
  'AIFF',
];

/// Album art files.
/// List of file names that are checked in [Track]'s [Directory] to use as fallback album art if one cannot be retrieved from the metadata.
///
const List<String> kAlbumArtFileNames = [
  'cover.jpg',
  'Folder.jpg',
];

/// Unknown album art from assets to write to the disk.
const String kUnknownAlbumArtRootBundle = 'assets/images/default_album_art.jpg';

/// Name of the sub directory inside [Collection.cacheDirectory] where retrieved album arts are saved.
const String kAlbumArtsDirectoryName = 'AlbumArts';

/// Cache file to store collection.
const String kCollectionCacheFileName = 'Collection.JSON';

/// Cache file to store playlists.
const String kPlaylistsCacheFileName = 'Playlists.JSON';

/// Name of the file to use as fallback when no album art is discovered.
const String kUnknownAlbumArtFileName = 'UnknownAlbum.PNG';

/// Returns extension of a particular file system entity like [File] or [Directory].
///
extension CollectionFileSystemEntityExtension on FileSystemEntity {
  String get extension => this.path.split('.').last.toUpperCase();
}

extension CollectionTrackExtension on Track {
  String get albumArtFileName =>
      '$albumName$albumArtistName'.replaceAll(RegExp(r'[\\/:*?""<>| ]'), '') +
      '.PNG';
}

/// `libdart` [Tagger] instance.
final Tagger tagger = Tagger();

/// Prettified JSON serialization.
const encoder = convert.JsonEncoder.withIndent('  ');
