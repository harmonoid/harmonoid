/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'package:harmonoid/core/media.dart';
export 'package:harmonoid/core/media.dart';

/// Collection
/// ----------
///
/// Primary music collection generator & indexer of Harmonoid (https://github.com/harmonoid/harmonoid).
///
class Collection extends ChangeNotifier {
  /// Initializes the music collection.
  ///
  /// Called before [runApp] & is non-blocking, [refresh] is used for indexing the music.
  ///
  static Future<void> initialize(
      {required List<Directory> collectionDirectories,
      required Directory cacheDirectory,
      required CollectionSort collectionSortType}) async {
    collection = Collection();
    collection.collectionDirectories = collectionDirectories;
    collection.cacheDirectory = cacheDirectory;
    collection.collectionSortType = collectionSortType;
    for (Directory directory in collectionDirectories) {
      if (!await directory.exists()) await directory.create(recursive: true);
    }
    if (!await Directory(path.join(collection.cacheDirectory.path, 'AlbumArts'))
        .exists()) {
      await Directory(path.join(collection.cacheDirectory.path, 'AlbumArts'))
          .create(recursive: true);
      await File(
              path.join(cacheDirectory.path, 'AlbumArts', 'UnknownAlbum.PNG'))
          .writeAsBytes(
              (await rootBundle.load('assets/images/default_album_art.jpg'))
                  .buffer
                  .asUint8List());
    }
  }

  late List<Directory> collectionDirectories;
  late Directory cacheDirectory;
  late CollectionSort collectionSortType;
  List<Playlist> playlists = <Playlist>[];
  List<Album> albums = <Album>[];
  List<Track> tracks = <Track>[];
  List<Artist> artists = <Artist>[];
  Album? lastAlbum;
  Track? lastTrack;
  Artist? lastArtist;

  /// Updates (or sets) the directories that are used for indexing of the music.
  ///
  Future<void> setDirectories(
      {required List<Directory>? collectionDirectories,
      required Directory? cacheDirectory,
      void Function(int, int, bool)? onProgress}) async {
    collection.collectionDirectories = collectionDirectories!;
    collection.cacheDirectory = cacheDirectory!;
    for (Directory directory in collectionDirectories) {
      if (!await directory.exists()) await directory.create(recursive: true);
    }
    if (!await Directory(path.join(collection.cacheDirectory.path, 'AlbumArts'))
        .exists()) {
      await Directory(path.join(collection.cacheDirectory.path, 'AlbumArts'))
          .create(recursive: true);
      await File(
        path.join(cacheDirectory.path, 'AlbumArts', 'UnknownAlbum.PNG'),
      ).writeAsBytes(
          (await rootBundle.load('assets/images/default_album_art.jpg'))
              .buffer
              .asUint8List());
    }
    await collection.refresh(onProgress: onProgress);
    this.notifyListeners();
  }

  /// Searches for a [Media] based upon a the passed [query].
  ///
  Future<List<Media>> search(String query, {Media? mode}) async {
    if (query.isEmpty) return <Media>[];

    List<Media> result = <Media>[];
    if (mode is Album || mode == null) {
      for (Album album in this.albums) {
        if (album.albumName!.toLowerCase().contains(query.toLowerCase())) {
          result.add(album);
        }
      }
    }
    if (mode is Track || mode == null) {
      for (Track track in this.tracks) {
        if (track.trackName!.toLowerCase().contains(query.toLowerCase())) {
          result.add(track);
        }
      }
    }
    if (mode is Artist || mode == null) {
      for (Artist artist in this.artists) {
        if (artist.artistName!.toLowerCase().contains(query.toLowerCase())) {
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
    for (Track track in this.tracks) {
      if (track.filePath == file.path) {
        isAlreadyPresent = true;
        break;
      }
    }
    if (supported_file_types.contains(file.extension) && !isAlreadyPresent) {
      try {
        var metadata = await MetadataRetriever.fromFile(file);
        var track = Track.fromMap(
            metadata.toMap()..putIfAbsent('filePath', () => file.path));
        this._arrange(
          track,
          () async {
            if (metadata.albumArt != null) {
              await File(path.join(
                this.cacheDirectory.path,
                'AlbumArts',
                track.albumArtBasename,
              )).writeAsBytes(metadata.albumArt!);
            }
          },
        );
        this._arrangeArtists();
      } catch (exception, stacktrace) {
        print(exception);
        print(stacktrace);
      }
    }
    await this.saveToCache();
    this.sort();
    this.notifyListeners();
  }

  /// Removes a [Media] i.e. [Album], [Track] or [Artist] from the music collection.
  ///
  /// Automatically updates other structures & models. Also deletes the respective files.
  ///
  Future<void> delete(Media object) async {
    if (object is Track) {
      for (int index = 0; index < this.tracks.length; index++) {
        if (object.trackName == this.tracks[index].trackName &&
            object.trackNumber == this.tracks[index].trackNumber) {
          this.tracks.removeAt(index);
          break;
        }
      }
      for (Album album in this.albums) {
        if (object.albumName == album.albumName &&
            object.albumArtistName == album.albumArtistName) {
          for (int index = 0; index < album.tracks.length; index++) {
            if (object.trackName == album.tracks[index].trackName) {
              album.tracks.removeAt(index);
              break;
            }
          }
          if (album.tracks.length == 0) this.albums.remove(album);
          break;
        }
      }
      for (String artistName in object.trackArtistNames as Iterable<String>) {
        for (Artist artist in this.artists) {
          if (artistName == artist.artistName) {
            for (int index = 0; index < artist.tracks.length; index++) {
              if (object.trackName == artist.tracks[index].trackName &&
                  object.trackNumber == artist.tracks[index].trackNumber) {
                artist.tracks.removeAt(index);
                break;
              }
            }
            if (artist.tracks.length == 0) {
              this.artists.remove(artist);
              break;
            } else {
              for (Album album in artist.albums) {
                if (object.albumName == album.albumName &&
                    object.albumArtistName == album.albumArtistName) {
                  for (int index = 0; index < album.tracks.length; index++) {
                    if (object.trackName == album.tracks[index].trackName) {
                      album.tracks.removeAt(index);
                      if (artist.albums.length == 0)
                        this.artists.remove(artist);
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
      for (Playlist playlist in this.playlists) {
        for (Track track in playlist.tracks) {
          if (object.trackName == track.trackName &&
              object.trackNumber == track.trackNumber) {
            this.playlistRemoveTrack(playlist, track);
            break;
          }
        }
      }
      if (await File(object.filePath!).exists()) {
        await File(object.filePath!).delete();
      }
    } else if (object is Album) {
      for (int index = 0; index < this.albums.length; index++) {
        if (object.albumName == this.albums[index].albumName &&
            object.albumArtistName == this.albums[index].albumArtistName) {
          this.albums.removeAt(index);
          break;
        }
      }
      for (int index = 0; index < this.tracks.length; index++) {
        List<Track> updatedTracks = <Track>[];
        for (Track track in this.tracks) {
          if (object.albumName != track.albumName &&
              object.albumArtistName != track.albumArtistName) {
            updatedTracks.add(track);
          }
        }
        this.tracks = updatedTracks;
      }
      for (Artist artist in this.artists) {
        for (Track track in artist.tracks) {
          List<Track> updatedTracks = <Track>[];
          if (object.albumName != track.albumName &&
              object.albumArtistName != track.albumArtistName) {
            updatedTracks.add(track);
          }
          artist.tracks = updatedTracks;
        }
        for (Album album in artist.albums) {
          if (object.albumName == album.albumName &&
              object.albumArtistName == album.albumArtistName) {
            artist.albums.remove(album);
            break;
          }
        }
      }
      for (Track track in object.tracks) {
        if (await File(track.filePath!).exists()) {
          await File(track.filePath!).delete();
        }
      }
    }
    if (this.tracks.isNotEmpty) {
      this.lastAlbum = this.albums.last;
      this.lastTrack = this.tracks.last;
      this.lastArtist = this.artists.last;
    }
    await this.sort();
    await this.saveToCache();
    this.notifyListeners();
  }

  /// Saves the currently visible music collection to the cache.
  ///
  Future<void> saveToCache() async {
    this.tracks.sort((first, second) =>
        (second.timeAdded ?? 0).compareTo(first.timeAdded ?? 0));

    await File(path.join(this.cacheDirectory.path, 'Collection.JSON'))
        .writeAsString(
      encoder.convert(
        {
          'tracks': this.tracks.map((track) => track.toMap()).toList(),
        },
      ),
    );
    this.sort();
  }

  /// Refreshes the music collection.
  ///
  /// Automatically calls [index] internally if no cache is found.
  /// Checks for newly added & deleted tracks to update the music collection.
  ///
  /// Non-blocking in nature. Sends progress updates to the optional callback parameter [onProgress].
  ///
  Future<void> refresh(
      {void Function(int completed, int total, bool isCompleted)?
          onProgress}) async {
    // For safety.
    if (!await this.cacheDirectory.exists())
      await this.cacheDirectory.create(recursive: true);
    for (Directory directory in collectionDirectories) {
      if (!await directory.exists()) await directory.create(recursive: true);
    }
    // Clear existing indexed music.
    this.albums = <Album>[];
    this.tracks = <Track>[];
    this.artists = <Artist>[];
    // Indexing from scratch if no cache exists.
    if (!await File(path.join(this.cacheDirectory.path, 'Collection.JSON'))
        .exists()) {
      this.index(onProgress: onProgress);
    }
    // Just check for newly added or deleted tracks if cache exists.
    else {
      try {
        // Index tracks already in the cache.
        var collection = convert.jsonDecode(
            await File(path.join(this.cacheDirectory.path, 'Collection.JSON'))
                .readAsString());
        for (var map in collection['tracks']) {
          var track = Track.fromMap(map);
          this._arrange(track, () async {});
        }
        this.notifyListeners();
        // Populate Check for newly added & deleted tracks in asynchronous suspension.
        () async {
          await this._arrangeArtists();
          // Remove deleted tracks.
          var buffer = [...this.tracks];
          for (var track in buffer) {
            if (!await File(track.filePath!).exists()) this.delete(track);
          }
          // Add newly added tracks.
          List<File> directory = <File>[];
          for (Directory collectionDirectory in this.collectionDirectories) {
            for (FileSystemEntity object
                in collectionDirectory.listSync(recursive: true)) {
              if (object is File &&
                  supported_file_types.contains(object.extension)) {
                directory.add(object);
              }
            }
          }
          directory.sort((first, second) =>
              first.lastModifiedSync().compareTo(second.lastModifiedSync()));
          for (int index = 0; index < directory.length; index++) {
            File file = directory[index];
            bool isTrackAdded = false;
            for (Track track in this.tracks) {
              if (track.filePath == file.path) {
                isTrackAdded = true;
                break;
              }
            }
            if (!isTrackAdded) {
              await this.add(
                file: file,
              );
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
        print(exception);
        print(stacktrace);
        await this.index(onProgress: onProgress);
      }
    }
    await this.saveToCache();
    await this.playlistsGetFromCache();
    await this.sort();
    this.notifyListeners();
  }

  /// Sorts the music collection contents based upon passed [type].
  ///
  Future<void> sort({CollectionSort? type}) async {
    if (type == null)
      type = this.collectionSortType;
    else
      this.collectionSortType = type;
    this.tracks.sort((first, second) =>
        (second.timeAdded ?? 0).compareTo(first.timeAdded ?? 0));
    this
        .albums
        .sort((first, second) => second.timeAdded.compareTo(first.timeAdded));
    this
        .artists
        .sort((first, second) => second.timeAdded.compareTo(first.timeAdded));
    if (this.tracks.isNotEmpty) {
      this.lastAlbum = this.albums.first;
      this.lastTrack = this.tracks.first;
      this.lastArtist = this.artists.first;
    }
    if (type == CollectionSort.aToZ) {
      this.tracks.sort(
          (first, second) => first.trackName!.compareTo(second.trackName!));
      this.albums.sort(
          (first, second) => first.albumName!.compareTo(second.albumName!));
      this.artists.sort(
          (first, second) => first.artistName!.compareTo(second.artistName!));
    }
    if (type == CollectionSort.year) {
      this.tracks.sort(
          (first, second) => (second.year ?? -1).compareTo(first.year ?? -1));
      this.albums.sort(
          (first, second) => (second.year ?? -1).compareTo(first.year ?? -1));
      this.artists.sort((first, second) => (second.tracks.last.year ?? -1)
          .compareTo(first.tracks.last.year ?? -1));
    }
    this.notifyListeners();
  }

  /// Indexes the music collection from scratch ignoring the cache.
  ///
  /// Deletes the cache file before proceeding.
  ///
  Future<void> index(
      {void Function(int completed, int total, bool isCompleted)?
          onProgress}) async {
    this.albums = <Album>[];
    this.tracks = <Track>[];
    this.artists = <Artist>[];
    this.playlists = <Playlist>[];
    var directory = <File>[];
    for (var collectionDirectory in this.collectionDirectories)
      directory.addAll((collectionDirectory.listSync()
            ..removeWhere((element) => !(element is File)))
          .cast());
    directory.sort((first, second) =>
        second.lastModifiedSync().compareTo(first.lastModifiedSync()));
    for (var index = 0; index < directory.length; index++) {
      var object = directory[index];
      if (supported_file_types.contains(object.extension)) {
        try {
          var metadata = await MetadataRetriever.fromFile(object);
          var track = Track.fromMap(
              metadata.toMap()..putIfAbsent('filePath', () => object.path));
          track.filePath = object.path;
          this._arrange(
            track,
            () async {
              if (metadata.albumArt != null) {
                await File(path.join(
                  this.cacheDirectory.path,
                  'AlbumArts',
                  track.albumArtBasename,
                )).writeAsBytes(metadata.albumArt!);
              }
            },
          );
        } catch (exception, stacktrace) {
          print(exception);
          print(stacktrace);
        }
      }
      try {
        onProgress?.call(index + 1, directory.length, true);
      } catch (exception) {}
    }
    this._arrangeArtists();
    await this.sort();
    await this.saveToCache();
    try {
      onProgress?.call(directory.length, directory.length, true);
    } catch (exception) {}
    await this.playlistsGetFromCache();
    this.notifyListeners();
  }

  /// Creates a new playlist in the collection.
  ///
  Future<void> playlistAdd(Playlist playlist) async {
    if (this.playlists.length == 0) {
      this
          .playlists
          .add(Playlist(playlistName: playlist.playlistName, playlistId: 0));
    } else {
      this.playlists.add(Playlist(
          playlistName: playlist.playlistName,
          playlistId: this.playlists.last.playlistId! + 1));
    }
    await this.playlistsSaveToCache();
    this.notifyListeners();
  }

  /// Removes a playlist from the collection.
  ///
  Future<void> playlistRemove(Playlist playlist) async {
    for (int index = 0; index < this.playlists.length; index++) {
      if (this.playlists[index].playlistId == playlist.playlistId) {
        this.playlists.removeAt(index);
        break;
      }
    }
    await this.playlistsSaveToCache();
    this.notifyListeners();
  }

  /// Adds a track to a playlist.
  ///
  Future<void> playlistAddTrack(Playlist playlist, Track track) async {
    for (int index = 0; index < this.playlists.length; index++) {
      if (this.playlists[index].playlistId == playlist.playlistId) {
        this.playlists[index].tracks.add(track);
        break;
      }
    }
    await this.playlistsSaveToCache();
    this.notifyListeners();
  }

  /// Removes a track from a playlist.
  ///
  Future<void> playlistRemoveTrack(Playlist playlist, Track track) async {
    for (int index = 0; index < this.playlists.length; index++) {
      if (this.playlists[index].playlistId == playlist.playlistId) {
        for (int trackIndex = 0; trackIndex < playlist.tracks.length; index++) {
          if (this.playlists[index].tracks[trackIndex].trackName ==
                  track.trackName &&
              this.playlists[index].tracks[trackIndex].albumName ==
                  track.albumName) {
            this.playlists[index].tracks.removeAt(trackIndex);
            break;
          }
        }
        break;
      }
    }
    await this.playlistsSaveToCache();
    this.notifyListeners();
  }

  /// Save playlists to the cache.
  ///
  Future<void> playlistsSaveToCache() async {
    await File(
      path.join(
        this.cacheDirectory.path,
        'Playlists.JSON',
      ),
    ).writeAsString(
      encoder.convert(
        {
          'playlists': playlists
              .map(
                (playlist) => playlist.toMap(),
              )
              .toList()
        },
      ),
    );
  }

  /// Gets all the playlists present in the cache.
  ///
  Future<void> playlistsGetFromCache() async {
    this.playlists = <Playlist>[];
    File playlistFile =
        File(path.join(this.cacheDirectory.path, 'Playlists.JSON'));
    if (!await playlistFile.exists())
      await this.playlistsSaveToCache();
    else {
      List<dynamic> playlists =
          convert.jsonDecode(await playlistFile.readAsString())['playlists'];
      for (dynamic playlist in playlists) {
        this.playlists.add(
              Playlist(
                playlistName: playlist['playlistName'],
                playlistId: playlist['playlistId'],
              ),
            );
        for (dynamic track in playlist['tracks']) {
          this.playlists.last.tracks.add(Track.fromMap(track));
        }
      }
    }
    this.notifyListeners();
  }

  /// Indexes a track into album & artist models.
  ///
  void _arrange(Track track, Future<void> Function() extractAlbumArt) async {
    if (this.tracks.includes(track)) return;
    if (!this.albums.includes(
          Album(
              albumName: track.albumName,
              albumArtistName: track.albumArtistName),
        )) {
      // Run as asynchronous suspension.
      extractAlbumArt();
      this.albums.add(
            Album(
              albumName: track.albumName,
              year: track.year,
              albumArtistName: track.albumArtistName,
            )..tracks.add(track),
          );
    } else {
      this
          .albums[this.albums.index(
                Album(
                    albumName: track.albumName,
                    albumArtistName: track.albumArtistName),
              )]
          .tracks
          .add(track);
    }
    for (String artistName in track.trackArtistNames!) {
      if (!this.artists.includes(Artist(artistName: artistName))) {
        this.artists.add(
              Artist(
                artistName: artistName,
              )..tracks.add(track),
            );
      } else {
        this
            .artists[this.artists.index(
                  Artist(artistName: artistName),
                )]
            .tracks
            .add(track);
      }
    }
    this.tracks.add(track);
    // Not necessarily correct. Just to keep the screen populated while indexing is in progress.
    if (this.tracks.isNotEmpty) {
      this.lastAlbum = this.albums.first;
      this.lastTrack = this.tracks.first;
      this.lastArtist = this.artists.first;
    }
  }

  /// Populates all the discovered artists' albums after running the [_arrange] loop.
  ///
  Future<void> _arrangeArtists() async {
    for (Album album in this.albums) {
      List<String> allAlbumArtistNames = <String>[];
      album.tracks.forEach((Track track) {
        track.trackArtistNames!.forEach((artistName) {
          if (!allAlbumArtistNames.contains(artistName))
            allAlbumArtistNames.add(artistName);
        });
      });
      for (String artistName in allAlbumArtistNames) {
        if (!this
            .artists[this.artists.index(Artist(artistName: artistName))]
            .albums
            .includes(album))
          this
              .artists[this.artists.index(Artist(artistName: artistName))]
              .albums
              .add(album);
      }
    }
    this.notifyListeners();
  }

  /// Redraws the collection.
  ///
  Future<void> redraw() async {
    await collection.sort();
    this.notifyListeners();
  }

  @override
  // ignore: must_call_super
  void dispose() {}
}

/// Types of sorts available.
///
enum CollectionSort { dateAdded, aToZ, year }

/// Types of orders available.
/// TODO (alexmercerind): Not yet exposed.
///
enum CollectionOrder { ascending, descending }

/// Supported file extensions.
/// Used for identifying the audio files during indexing the collection.
///
const List<String> supported_file_types = [
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

/// Returns extension of a particular file system entity like [File] or [Directory].
///
extension on FileSystemEntity {
  String get extension => this.path.split('.').last.toUpperCase();
}

/// Extension on List, local to the [Collection] class.
///
extension on List<Media> {
  /// Checks whether a [List<Media>] contains a particular [Media] by calling the overridden [Comparable.compareTo] method.
  /// An equivalent of [Iterable.contains].
  bool includes(Media media) => index(media) >= 0;

  /// Returns the index of a particular [Media] in [List<Media>] by calling the overridden [Comparable.compareTo] method.
  /// An equivalent of [List.indexOf].
  int index(Media media) {
    for (int index = 0; index < length; index++) {
      if (this[index].compareTo(media) == 0) {
        return index;
      }
    }
    return -1;
  }
}

/// Late initialized [Collection] ojbect instance.
late Collection collection;

/// Prettified JSON serialization.
const encoder = convert.JsonEncoder.withIndent('  ');
