import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:harmonoid/utils/utils.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:harmonoid/core/mediatype.dart';

export 'package:harmonoid/core/mediatype.dart';

enum CollectionSort { dateAdded, aToZ }

enum CollectionOrder { ascending, descending }

const List<String> SUPPORTED_FILE_TYPES = [
  'OGG',
  'OGA',
  'OGX',
  'AAC',
  'M4A',
  'MP3',
  'WMA',
  'WAV',
  'FLAC',
  'OPUS'
];

/// This music sorting logic & class is part of [Harmonoid](https://github.com/harmonoid/harmonoid) project, and it
/// is written by [Hitesh Kumar Saini](https://github.com/alexmercerind).
/// This text can serve as an introduction to contributors.
/// This segment of code (including all the order code of this project) is available under GNU GPL v3.0 license.
///
/// The [Collection] class implements [ChangeNotifier], so as to support Provider state management.
///
/// Initially there was no caching system in collection, so only [Collection.index] method was used (which scans [File]s
/// present in the [Collection.collectionDirectories]). This method distributes the tracks into [Collection._albums],
/// [Collection._tracks] & [Collection._artists]. These private variables contain the tracks in date added order
/// (because `dart:io`'s file API is awesome).
///
/// The [Collection._arrange] method is called upon each [File] obtained from [Collection.collectionDirectories] & distributes into
/// [Collection._albums], [Collection._tracks] & [Collection._artists] & and handles majority of work.
/// Later [Collection.sort] method is used to sort contents of [Collection._albums], [Collection._tracks] & [Collection._artists] into public
/// [Collection.albums], [Collection.tracks] & [Collection.artists]. Which contains [MediaType] objects e.g. [Album], [Track] etc.
///
/// [Collection.delete] is a method which deletes a [MediaType], removes its [File] and updates all [Collection.albums], [Collection.tracks] & [Collection.artists].
///
/// Since, caching is implemented, so now only [Collection.refresh] used, which
/// - Detects for files in [Collection.collectionDirectories] and indexes them.
/// - Detects deleted files & removes them from collection.
/// - Reads existing cache.
/// - Saves the updated cache.
/// to generate the collection. Thus [Collection.index] should never be called now. If no cache exists (or is corrupted), then [Collection.refresh]
/// automatically calls [Collection.index] to generate collection for the first time.
///
/// The class also contains some playlist related methods at the end, which is also one of the available features.
///
class Collection extends ChangeNotifier {
  static Collection? get() => _collection;

  static Future<void> init(
      {required List<Directory> collectionDirectories,
      required Directory cacheDirectory,
      required CollectionSort collectionSortType}) async {
    _collection = Collection();
    _collection.collectionDirectories = collectionDirectories;
    _collection.cacheDirectory = cacheDirectory;
    _collection.collectionSortType = collectionSortType;
    for (Directory directory in collectionDirectories) {
      if (!await directory.exists()) await directory.create(recursive: true);
    }
    if (!await Directory(
            path.join(_collection.cacheDirectory.path, 'albumArts'))
        .exists()) {
      await Directory(path.join(_collection.cacheDirectory.path, 'albumArts'))
          .create(recursive: true);
      await File(
        path.join(cacheDirectory.path, 'albumArts', 'defaultAlbumArt' + '.PNG'),
      ).writeAsBytes(
          (await rootBundle.load('assets/images/collection-album.jpg'))
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

  Future<void> setDirectories(
      {required List<Directory>? collectionDirectories,
      required Directory? cacheDirectory,
      void Function(int, int, bool)? onProgress}) async {
    _collection.collectionDirectories = collectionDirectories!;
    _collection.cacheDirectory = cacheDirectory!;
    for (Directory directory in collectionDirectories) {
      if (!await directory.exists()) await directory.create(recursive: true);
    }
    if (!await Directory(
            path.join(_collection.cacheDirectory.path, 'albumArts'))
        .exists()) {
      await Directory(path.join(_collection.cacheDirectory.path, 'albumArts'))
          .create(recursive: true);
      await File(
        path.join(cacheDirectory.path, 'albumArts', 'defaultAlbumArt' + '.PNG'),
      ).writeAsBytes(
          (await rootBundle.load('assets/images/collection-album.jpg'))
              .buffer
              .asUint8List());
    }
    await _collection.refresh(onProgress: onProgress);
    this.notifyListeners();
  }

  Future<List<MediaType>> search(String query, {dynamic mode}) async {
    if (query == '') return <MediaType>[];

    List<MediaType> result = <MediaType>[];
    if (mode is Album || mode == null) {
      for (Album album in this._albums) {
        if (album.albumName!.toLowerCase().contains(query.toLowerCase())) {
          result.add(album);
        }
      }
    }
    if (mode is Track || mode == null) {
      for (Track track in this._tracks) {
        if (track.trackName!.toLowerCase().contains(query.toLowerCase())) {
          result.add(track);
        }
      }
    }
    if (mode is Artist || mode == null) {
      for (Artist artist in this._artists) {
        if (artist.artistName!.toLowerCase().contains(query.toLowerCase())) {
          result.add(artist);
        }
      }
    }
    return result;
  }

  Future<void> add({required File file}) async {
    bool isAlreadyPresent = false;
    for (Track track in this._tracks) {
      if (track.filePath == file.path) {
        isAlreadyPresent = true;
        break;
      }
    }
    if (file is File &&
        SUPPORTED_FILE_TYPES
            .contains(file.path.split('.').last.toUpperCase()) &&
        !isAlreadyPresent) {
      try {
        Metadata metadata = await MetadataRetriever.fromFile(file);
        Track track = Track.fromMap(metadata.toMap())!;
        track.filePath = file.path;
        if (track.trackName == 'Unknown Track') {
          track.trackName = path.basename(file.path).split('.').first;
        }
        Future<void> albumArtMethod() async {
          if (metadata.albumArt != null) {
            File albumArtFile = File(path.join(
                this.cacheDirectory.path,
                'albumArts',
                '${track.albumArtistName}_${track.albumName}'
                        .replaceAll(RegExp(r'[^\s\w]'), ' ') +
                    '.PNG'));
            await albumArtFile.writeAsBytes(metadata.albumArt!);
          }
        }

        await this._arrange(track, albumArtMethod);
        for (Album album in this._albums) {
          List<String> allAlbumArtistNames = <String>[];
          album.tracks.forEach((Track track) {
            track.trackArtistNames!.forEach((artistName) {
              if (!allAlbumArtistNames.contains(artistName))
                allAlbumArtistNames.add(artistName);
            });
          });
          for (String artistName in allAlbumArtistNames) {
            this
                ._artists[this._foundArtists.indexOf(artistName)]
                .albums
                .add(album);
          }
        }
      } catch (exception, stacktrace) {
        print(exception);
        print(stacktrace);
      }
    }
    await this.saveToCache();
    this.sort(type: this.collectionSortType);
    this.notifyListeners();
  }

  Future<void> delete(MediaType object) async {
    if (object is Track) {
      for (int index = 0; index < this._tracks.length; index++) {
        if (object.trackName == this._tracks[index].trackName &&
            object.trackNumber == this._tracks[index].trackNumber) {
          this._tracks.removeAt(index);
          break;
        }
      }
      for (Album album in this._albums) {
        if (object.albumName == album.albumName &&
            object.albumArtistName == album.albumArtistName) {
          for (int index = 0; index < album.tracks.length; index++) {
            if (object.trackName == album.tracks[index].trackName) {
              album.tracks.removeAt(index);
              break;
            }
          }
          if (album.tracks.length == 0) this._albums.remove(album);
          break;
        }
      }
      for (String artistName in object.trackArtistNames as Iterable<String>) {
        for (Artist artist in this._artists) {
          if (artistName == artist.artistName) {
            for (int index = 0; index < artist.tracks.length; index++) {
              if (object.trackName == artist.tracks[index].trackName &&
                  object.trackNumber == artist.tracks[index].trackNumber) {
                artist.tracks.removeAt(index);
                break;
              }
            }
            if (artist.tracks.length == 0) {
              this._artists.remove(artist);
              break;
            } else {
              for (Album album in artist.albums) {
                if (object.albumName == album.albumName &&
                    object.albumArtistName == album.albumArtistName) {
                  for (int index = 0; index < album.tracks.length; index++) {
                    if (object.trackName == album.tracks[index].trackName) {
                      album.tracks.removeAt(index);
                      if (artist.albums.length == 0)
                        this._artists.remove(artist);
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
      for (int index = 0; index < this._albums.length; index++) {
        if (object.albumName == this._albums[index].albumName &&
            object.albumArtistName == this._albums[index].albumArtistName) {
          this._albums.removeAt(index);
          break;
        }
      }
      for (int index = 0; index < this._tracks.length; index++) {
        List<Track> updatedTracks = <Track>[];
        for (Track track in this._tracks) {
          if (object.albumName != track.albumName &&
              object.albumArtistName != track.albumArtistName) {
            updatedTracks.add(track);
          }
        }
        this._tracks = updatedTracks;
      }
      for (Artist artist in this._artists) {
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
    await this.sort(type: this.collectionSortType);
    await this.saveToCache();
    this.notifyListeners();
  }

  Future<void> saveToCache() async {
    convert.JsonEncoder encoder = convert.JsonEncoder.withIndent('    ');
    List<Map<String, dynamic>> tracks = <Map<String, dynamic>>[];
    this._tracks.forEach((element) => tracks.add(element.toMap()));
    await File(path.join(this.cacheDirectory.path, 'collection.JSON'))
        .writeAsString(encoder.convert({'tracks': tracks}));
  }

  Future<void> refresh(
      {void Function(int completed, int total, bool isCompleted)? onProgress,
      bool respectChangedDirectories: false}) async {
    if (!await this.cacheDirectory.exists())
      await this.cacheDirectory.create(recursive: true);
    for (Directory directory in collectionDirectories) {
      if (!await directory.exists()) await directory.create(recursive: true);
    }
    this._albums = <Album>[];
    this._tracks = <Track>[];
    this._artists = <Artist>[];
    this._foundAlbums = <String>[];
    this._foundArtists = <String>[];
    if (!await File(path.join(this.cacheDirectory.path, 'collection.JSON'))
        .exists()) {
      this.index(onProgress: onProgress);
    } else {
      try {
        Map<String, dynamic> collection = convert.jsonDecode(
            await File(path.join(this.cacheDirectory.path, 'collection.JSON'))
                .readAsString());
        for (Map<String, dynamic> trackMap in collection['tracks']) {
          Track track = Track.fromMap(trackMap)!;
          bool presentInCollectionDirectories = true;
          if (await File(track.filePath!).exists() &&
              presentInCollectionDirectories) {
            await this._arrange(track, () async {});
          }
        }
        List<File> collectionDirectoriesContent = <File>[];
        for (Directory collectionDirectory in this.collectionDirectories) {
          for (FileSystemEntity object
              in collectionDirectory.listSync(recursive: true)) {
            if (object is File &&
                SUPPORTED_FILE_TYPES
                    .contains(object.path.split('.').last.toUpperCase())) {
              collectionDirectoriesContent.add(object);
            }
          }
        }
        if (collectionDirectoriesContent.length != this._tracks.length) {
          for (int index = 0;
              index < collectionDirectoriesContent.length;
              index++) {
            File file = collectionDirectoriesContent[index];
            bool isTrackAdded = false;
            for (Track track in this._tracks) {
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
            onProgress?.call(
                index + 1, collectionDirectoriesContent.length, false);
          }
        }
        for (Album album in this._albums) {
          List<String> allAlbumArtistNames = <String>[];
          album.tracks.forEach((Track track) {
            track.trackArtistNames!.forEach((artistName) {
              if (!allAlbumArtistNames.contains(artistName))
                allAlbumArtistNames.add(artistName);
            });
          });
          for (String artistName in allAlbumArtistNames) {
            this
                ._artists[this._foundArtists.indexOf(artistName)]
                .albums
                .add(album);
          }
        }
        onProgress?.call(collectionDirectoriesContent.length,
            collectionDirectoriesContent.length, true);
      } catch (exception, stacktrace) {
        print(exception);
        print(stacktrace);
        // Fallback collection regeneration from scratch in case the cache file appears to be corrupt due
        // to user exiting the application in middle of indexing or editing/saving the cache file.
        this.index(onProgress: onProgress);
      }
    }
    if (this._tracks.isNotEmpty) {
      this.lastAlbum = this._albums.last;
      this.lastTrack = this._tracks.last;
      this.lastArtist = this._artists.last;
    }
    await this.saveToCache();
    await this.playlistsGetFromCache();
    await this.sort(type: this.collectionSortType);
    this.notifyListeners();
  }

  Future<void> sort(
      {required CollectionSort type, void Function()? onCompleted}) async {
    this.collectionSortType = type;
    this.albums = <Album>[...this._albums];
    this.tracks = <Track>[...this._tracks];
    this.artists = <Artist>[...this._artists];
    if (type == CollectionSort.aToZ) {
      // Implemented Comparable to MediaType.
      // No longer using inefficient bubble sort.
      this.albums.sort();
      this.tracks.sort();
      this.artists.sort();
    } else if (type == CollectionSort.dateAdded) {
      this.albums = this.albums.reversed.toList();
      this.tracks = this.tracks.reversed.toList();
      this.artists = this.artists.reversed.toList();
      if (this.tracks.isNotEmpty) {
        this.albums.removeAt(0);
        this.tracks.removeAt(0);
        this.artists.removeAt(0);
      }
    }
    for (Album album in this.albums) {
      album.tracks.sort();
    }
    onCompleted?.call();
    this.notifyListeners();
  }

  Future<void> index(
      {void Function(int completed, int total, bool isCompleted)?
          onProgress}) async {
    this._albums = <Album>[];
    this._tracks = <Track>[];
    this._artists = <Artist>[];
    this.playlists = <Playlist>[];
    this._foundAlbums = <String>[];
    this._foundArtists = <String>[];
    List<FileSystemEntity> directory = [];
    for (Directory collectionDirectory in this.collectionDirectories)
      directory.addAll(collectionDirectory.listSync());
    for (int index = 0; index < directory.length; index++) {
      FileSystemEntity object = directory[index];
      if (object is File &&
          SUPPORTED_FILE_TYPES
              .contains(object.path.split('.').last.toUpperCase())) {
        try {
          Metadata metadata = await MetadataRetriever.fromFile(object);
          Track track = Track.fromMap(metadata.toMap())!;
          if (track.trackName == 'Unknown Track') {
            track.trackName = path.basename(object.path).split('.').first;
          }
          track.filePath = object.path;
          Future<void> albumArtMethod() async {
            if (metadata.albumArt != null) {
              File albumArtFile = File(path.join(
                  this.cacheDirectory.path,
                  'albumArts',
                  '${track.albumArtistName}_${track.albumName}'
                          .replaceAll(RegExp(r'[^\s\w]'), ' ') +
                      '.PNG'));
              await albumArtFile.writeAsBytes(metadata.albumArt!);
            }
          }

          await this._arrange(track, albumArtMethod);
        } catch (exception, stacktrace) {
          print(exception);
          print(stacktrace);
        }
      }
      onProgress?.call(index + 1, directory.length, true);
    }
    for (Album album in this._albums) {
      List<String> allAlbumArtistNames = <String>[];
      album.tracks.forEach((Track track) {
        track.trackArtistNames!.forEach((artistName) {
          if (!allAlbumArtistNames.contains(artistName))
            allAlbumArtistNames.add(artistName);
        });
      });
      for (String artistName in allAlbumArtistNames) {
        this._artists[this._foundArtists.indexOf(artistName)].albums.add(album);
      }
    }
    if (this._tracks.isNotEmpty) {
      this.lastAlbum = this._albums.last;
      this.lastTrack = this._tracks.last;
      this.lastArtist = this._artists.last;
    }
    await this.sort(type: this.collectionSortType);
    await this.saveToCache();
    onProgress?.call(directory.length, directory.length, true);
    await this.playlistsGetFromCache();
    this.notifyListeners();
  }

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

  Future<void> playlistAddTrack(Playlist playlist, Track track) async {
    for (int index = 0; index < this.playlists.length; index++) {
      if (this.playlists[index].playlistId == playlist.playlistId) {
        this.playlists[index].tracks.add(track);
        break;
      }
    }
    await this.playlistsSaveToCache();
  }

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

  Future<void> playlistsSaveToCache() async {
    List<Map<String, dynamic>> playlists = <Map<String, dynamic>>[];
    for (Playlist playlist in this.playlists) {
      playlists.add(playlist.toMap());
    }
    File playlistFile =
        File(path.join(this.cacheDirectory.path, 'playlists.JSON'));
    await playlistFile.writeAsString(convert.JsonEncoder.withIndent('    ')
        .convert({'playlists': playlists}));
  }

  Future<void> playlistsGetFromCache() async {
    this.playlists = <Playlist>[];
    File playlistFile =
        File(path.join(this.cacheDirectory.path, 'playlists.JSON'));
    if (!await playlistFile.exists())
      await this.playlistsSaveToCache();
    else {
      List<dynamic> playlists =
          convert.jsonDecode(await playlistFile.readAsString())['playlists'];
      for (dynamic playlist in playlists) {
        this.playlists.add(Playlist(
              playlistName: playlist['playlistName'],
              playlistId: playlist['playlistId'],
            ));
        for (dynamic track in playlist['tracks']) {
          this.playlists.last.tracks.add(Track.fromMap(track)!);
        }
      }
    }
    this.notifyListeners();
  }

  Future<void> _arrange(
      Track track, Future<void> Function() albumArtMethod) async {
    // TODO (alexmercerind): Prevent this additional O(n).
    // This is here because, for some reason (as of now) [File]s get doubly indexed due to some state management
    // bug (not in this class).
    if (this._tracks.contains(track)) return;
    if (!this._foundAlbums.contains(track.albumName)) {
      this._foundAlbums.add(track.albumName!);
      await albumArtMethod();
      this._albums.add(
            Album(
              albumName: track.albumName,
              year: track.year,
              albumArtistName: track.albumArtistName,
            )..tracks.add(
                Track(
                  albumName: track.albumName,
                  year: track.year,
                  albumArtistName: track.albumArtistName,
                  trackArtistNames: track.trackArtistNames,
                  trackName: track.trackName,
                  trackNumber: track.trackNumber,
                  filePath: track.filePath,
                ),
              ),
          );
    } else {
      this._albums[this._foundAlbums.indexOf(track.albumName!)].tracks.add(
            Track(
              albumName: track.albumName,
              year: track.year,
              albumArtistName: track.albumArtistName,
              trackArtistNames: track.trackArtistNames,
              trackName: track.trackName,
              trackNumber: track.trackNumber,
              filePath: track.filePath,
            ),
          );
    }
    for (String artistName in track.trackArtistNames as List<String>) {
      if (!this._foundArtists.contains(artistName)) {
        this._foundArtists.add(artistName);
        this._artists.add(
              Artist(
                artistName: artistName,
              )..tracks.add(
                  Track(
                    albumName: track.albumName,
                    year: track.year,
                    albumArtistName: track.albumArtistName,
                    trackArtistNames: track.trackArtistNames,
                    trackName: track.trackName,
                    trackNumber: track.trackNumber,
                    filePath: track.filePath,
                  ),
                ),
            );
      } else {
        this._artists[this._foundArtists.indexOf(artistName)].tracks.add(
              Track(
                albumName: track.albumName,
                year: track.year,
                albumArtistName: track.albumArtistName,
                trackArtistNames: track.trackArtistNames,
                trackName: track.trackName,
                trackNumber: track.trackNumber,
                filePath: track.filePath,
              ),
            );
      }
    }
    this._tracks.add(
          Track(
            albumName: track.albumName,
            year: track.year,
            albumArtistName: track.albumArtistName,
            trackArtistNames: track.trackArtistNames,
            trackName: track.trackName,
            trackNumber: track.trackNumber,
            filePath: track.filePath,
          ),
        );
  }

  List<Album> _albums = <Album>[];
  List<Track> _tracks = <Track>[];
  List<Artist> _artists = <Artist>[];
  List<String> _foundAlbums = <String>[];
  List<String> _foundArtists = <String>[];
}

late Collection _collection;
