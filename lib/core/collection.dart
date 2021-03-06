import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import 'package:media_metadata_retriever/media_metadata_retriever.dart';

import 'package:harmonoid/utils/methods.dart';
import 'package:harmonoid/core/mediatype.dart';
export 'package:harmonoid/core/mediatype.dart';



enum CollectionSort {
  dateAdded,
  aToZ,
}


const List<String> SUPPORTED_FILE_TYPES = [
  'OGG',
  'OGA',
  'AAC',
  'M4A',
  'MP3',
  'WMA',
  'WAV',
  'FLAC',
  'OPUS',
];


class Collection extends ChangeNotifier {

  static Collection get() => _collection; 

  static Future<void> init({@required Directory collectionDirectory, @required Directory cacheDirectory}) async {
    _collection = new Collection();
    await _collection.setDirectories(
      collectionDirectory: collectionDirectory,
      cacheDirectory: cacheDirectory,
    );
  }

  Directory collectionDirectory;
  Directory cacheDirectory;
  List<Album> albums = <Album>[];
  List<Track> tracks = <Track>[];
  List<Artist> artists = <Artist>[];
  List<Playlist> playlists = <Playlist>[];
  Album lastAlbum;
  Track lastTrack;
  Artist lastArtist;

  Future<void> setDirectories({@required Directory collectionDirectory, @required Directory cacheDirectory, void Function(int, int, bool) onProgress}) async {
    _collection.collectionDirectory = collectionDirectory;
    _collection.cacheDirectory = cacheDirectory;
    if (!await _collection.collectionDirectory.exists()) await _collection.collectionDirectory.create(recursive: true);
    if (!await Directory(path.join(_collection.cacheDirectory.path, 'albumArts')).exists()) {
      await Directory(path.join(_collection.cacheDirectory.path, 'albumArts')).create(recursive: true);
      await new File(
        path.join(cacheDirectory.path, 'albumArts', 'defaultAlbumArt' + '.PNG'),
      ).writeAsBytes((await rootBundle.load('assets/images/collection-album.jpg')).buffer.asUint8List());
    }
    await _collection.refresh(onProgress: onProgress);
    this.notifyListeners();
  }

  Future<List<MediaType>> search(String query, {dynamic mode}) async {
    if (query == '') return <MediaType>[];

    List<MediaType> result = <MediaType>[];
    if (mode is Album || mode == null) {
      for (Album album in this.albums) {
        if (album.albumName.toLowerCase().contains(query.toLowerCase())) {
          result.add(album);
        }
      }
    }
    if (mode is Track || mode == null) {
      for (Track track in this.tracks) {
        if (track.trackName.toLowerCase().contains(query.toLowerCase())) {
          result.add(track);
        }
      }
    }
    if (mode is Artist || mode == null) {
      for (Artist artist in this.artists) {
        if (artist.artistName.toLowerCase().contains(query.toLowerCase())) {
          result.add(artist);
        }
      }
    }
    return result;
  }

  Future<void> add({File file}) async {
    bool isAlreadyPresent = false;
    for (Track track in this.tracks) {
      if (track.filePath == file.path) {
        isAlreadyPresent = true;
        break;
      }
    }
    if (Methods.isFileSupported(file) && !isAlreadyPresent) {
      try {
        MediaMetadataRetriever retriever = new MediaMetadataRetriever();
        await retriever.setFile(file);
        Track track = Track.fromMap((await retriever.metadata).toMap());
        track.filePath = file.path;
        if (track.trackName == 'Unknown Track') {
          track.trackName = path.basename(file.path).split('.').first;
        }
        Future<void> albumArtMethod() async {
          if (retriever.albumArt == null) {
            this._albumArts.add(null);
          }
          else {
            File albumArtFile = new File(path.join(this.cacheDirectory.path, 'albumArts', '${track.albumArtistName}_${track.albumName}'.replaceAll(new RegExp(r'[^\s\w]'), ' ') + '.PNG'));
            await albumArtFile.writeAsBytes(retriever.albumArt);
            this._albumArts.add(albumArtFile);
          }
        }
        await this._arrange(track, albumArtMethod);
      }
      catch (exception) {}
    }
    if (this.tracks.isNotEmpty) {
      this.lastAlbum = this.albums.last;
      this.lastTrack = this.tracks.last;
      this.lastArtist = this.artists.last;
    }
    this.notifyListeners();
    await this.saveToCache();
  }

  Future<void> delete(MediaType object) async {
    if (object is Track) {
      for (int index = 0; index < this.tracks.length; index++) {
        if (object.trackName == this.tracks[index].trackName && object.trackNumber == this.tracks[index].trackNumber) {
          this.tracks.removeAt(index);
          break;
        }
      }
      for (Album album in this.albums) {
        if (object.albumName == album.albumName && object.albumArtistName == album.albumArtistName) {
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
      for (String artistName in object.trackArtistNames) {
        for (Artist artist in this.artists) {
          if (artistName == artist.artistName) {
            for (int index = 0; index < artist.tracks.length; index++) {
              if (object.trackName == artist.tracks[index].trackName && object.trackNumber == artist.tracks[index].trackNumber) {
                artist.tracks.removeAt(index);
                break;
              }
            }
            if (artist.tracks.length == 0) {
              this.artists.remove(artist);
              break;
            }
            else {
              for (Album album in artist.albums) {
                if (object.albumName == album.albumName && object.albumArtistName == album.albumArtistName) {
                  for (int index = 0; index < album.tracks.length; index++) {
                    if (object.trackName == album.tracks[index].trackName) {
                      album.tracks.removeAt(index);
                      if (artist.albums.length == 0) this.artists.remove(artist);
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
          if (object.trackName == track.trackName && object.trackNumber == track.trackNumber) {
            this.playlistRemoveTrack(playlist, track);
            break;
          }
        }
      }
      if (await File(object.filePath).exists()) {
        await File(object.filePath).delete();
      }
    }
    else if (object is Album) {
      for (int index = 0; index < this.albums.length; index++) {
        if (object.albumName == this.albums[index].albumName && object.albumArtistName == this.albums[index].albumArtistName) {
          this.albums.removeAt(index);
          break;
        }
      }
      for (int index = 0; index < this.tracks.length; index++) {
        List<Track> updatedTracks = <Track>[];
        for (Track track in this.tracks) {
          if (object.albumName != track.albumName && object.albumArtistName != track.albumArtistName) {
            updatedTracks.add(track);
          }
        }
        this.tracks = updatedTracks;
      }
      // ignore: todo
      /* TODO: Fix delete method to remove Album from Artist.
      for (String artistName in object.trackArtistNames) {
        for (Artist artist in this.artists) {
          if (artistName == artist.artistName) {
            List<Track> updatedTracks = <Track>[];
            for (Track track in artist.tracks) {
              if (object.albumName != track.albumName) {
                updatedTracks.add(track);
              }
            }
            artist.tracks = updatedTracks;
            if (artist.tracks.length == 0) {
              this.artists.remove(artist);
              break;
            }
            else {
              for (int index = 0; index < artist.albums.length; index++) {
              if (object.albumName == artist.albums[index].albumName) {
                artist.albums.removeAt(index);
                if (artist.albums.length == 0) this.artists.remove(artist);
                break;
              }
            }
            }
            break;
          }
        }
      }
      */
      for (Track track in object.tracks) {
        if (await File(track.filePath).exists()) {
          await File(track.filePath).delete();
        }
      }
    }
    if (this.tracks.isNotEmpty) {
      this.lastAlbum = this.albums.last;
      this.lastTrack = this.tracks.last;
      this.lastArtist = this.artists.last;
    }
    this.notifyListeners();
    await this.saveToCache();
  }

  Future<void> saveToCache() async {
    convert.JsonEncoder encoder = convert.JsonEncoder.withIndent('    ');
    List<Map<String, dynamic>> tracks = <Map<String, dynamic>>[];
    this.tracks.forEach((element) => tracks.add(element.toMap()));
    await File(path.join(this.cacheDirectory.path, 'collection.JSON')).writeAsString(encoder.convert({'tracks': tracks}));
  }

  Future<void> refresh({void Function(int completed, int total, bool isCompleted) onProgress}) async {
    this.albums = <Album>[];
    this.tracks = <Track>[];
    this.artists = <Artist>[];
    this._foundAlbums = <List<String>>[];
    this._foundArtists = <String>[];
    if (!await File(path.join(this.cacheDirectory.path, 'collection.JSON')).exists()) {
      await this.index();
      onProgress?.call(0, 0, true);
    }
    else {
      Map<String, dynamic> collection = convert.jsonDecode(await File(path.join(this.cacheDirectory.path, 'collection.JSON')).readAsString());
      for (Map<String, dynamic> trackMap in collection['tracks']) {
        Track track = Track.fromMap(trackMap);
        Future<void> albumArtMethod() async {}
        await this._arrange(track, albumArtMethod);
      }
      List<File> collectionDirectoryContent = <File>[];
      for (FileSystemEntity object in this.collectionDirectory.listSync(recursive: true)) {
        if (Methods.isFileSupported(object) && object is File) {
          collectionDirectoryContent.add(object);
        }
      }
      if (collectionDirectoryContent.length != this.tracks.length) {
        collectionDirectoryContent.asMap().forEach((int index, FileSystemEntity file) async {
          bool isTrackAdded = false;
          for (Track track in this.tracks) {
            if (track.filePath == file.path) {
              isTrackAdded = true;
              break;
            }
          }
          if (!isTrackAdded) {
            await this.add(
              file: file as File,
            );
          }
          onProgress?.call(index + 1, collectionDirectoryContent.length, true);
        });
      }
      onProgress?.call(collectionDirectoryContent.length, collectionDirectoryContent.length, true);
    }
    if (this.tracks.isNotEmpty) {
      this.lastAlbum = this.albums.last;
      this.lastTrack = this.tracks.last;
      this.lastArtist = this.artists.last;
    }
    await this.playlistsGetFromCache();
    this.notifyListeners();
  }

  Future<void> sort({CollectionSort type: CollectionSort.dateAdded, void Function() onCompleted}) async {
    if (type == CollectionSort.aToZ) {
      for (int index = 0; index < this.albums.length; index++) {
        for (int subIndex = 0; subIndex < this.albums.length - index - 1; subIndex++) {
          if (this.albums[subIndex].albumName.compareTo(this.albums[subIndex+1].albumName) > 0) {
            Album swapAlbum = this.albums[subIndex];
            this.albums[subIndex] = this.albums[subIndex+1];
            this.albums[subIndex+1] = swapAlbum;
          }
        }
      }
      for (int index = 0; index <this. tracks.length; index++) {
        for (int subIndex = 0; subIndex < this.tracks.length - index - 1; subIndex++) {
          if (this.tracks[subIndex].trackName.compareTo(this.tracks[subIndex+1].trackName) > 0) {
            Track swapTrack = this.tracks[subIndex];
            this.tracks[subIndex] = this.tracks[subIndex+1];
            this.tracks[subIndex+1] = swapTrack;
          }
        }
      }
    }
    else if (type == CollectionSort.dateAdded) {
      await this.refresh();
    }
    this.notifyListeners();
    onCompleted?.call();
  }

  Future<void> index({void Function(int completed, int total, bool isCompleted) onProgress}) async {
    if (await File(path.join(this.cacheDirectory.path, 'collection.JSON')).exists()) {
      await File(path.join(this.cacheDirectory.path, 'collection.JSON')).delete();
    }
    this.albums = <Album>[];
    this.tracks = <Track>[];
    this.artists = <Artist>[];
    this.playlists = <Playlist>[];
    this._foundAlbums = <List<String>>[];
    this._foundArtists = <String>[];
    List<FileSystemEntity> directory = this.collectionDirectory.listSync(recursive: true);
    for (int index = 0; index < directory.length; index++) {
      FileSystemEntity object = directory[index];
      if (Methods.isFileSupported(object)) {
        try {
          MediaMetadataRetriever retriever = new MediaMetadataRetriever();
          await retriever.setFile(object);
          Track track = Track.fromMap((await retriever.metadata).toMap());
          if (track.trackName == 'Unknown Track') {
            track.trackName = path.basename(object.path).split('.').first;
          }
          track.filePath = object.path;
          Future<void> albumArtMethod() async {
            if (retriever.albumArt == null) {
              this._albumArts.add(
                new File(
                  path.join(
                    this.cacheDirectory.path, 'albumArts', 'defaultAlbumArt' + '.PNG',
                  ),
                ),
              );
            }
            else {
              File albumArtFile = new File(path.join(this.cacheDirectory.path, 'albumArts', '${track.albumArtistName}_${track.albumName}'.replaceAll(new RegExp(r'[^\s\w]'), ' ') + '.PNG'));
              await albumArtFile.writeAsBytes(retriever.albumArt);
              this._albumArts.add(albumArtFile);
            }
          }
          await this._arrange(track, albumArtMethod);
        }
        catch (exception) {}
      }
      onProgress?.call(index + 1, directory.length, true);
    }
    /* TODO: Fix List<Album> in Artists after deprecating trackArtistNames field in Album.
    for (Album album in this.albums) {
      for (String artist in album.trackArtistNames)  {
        if (this.artists[this._foundArtists.indexOf(artist)].albums == null)
          this.artists[this._foundArtists.indexOf(artist)].albums = <Album>[];
        this.artists[this._foundArtists.indexOf(artist)].albums.add(album);
      }
    }
    */
    if (this.tracks.isNotEmpty) {
      this.lastAlbum = this.albums.last;
      this.lastTrack = this.tracks.last;
      this.lastArtist = this.artists.last;
    }
    await this.saveToCache();
    onProgress?.call(directory.length, directory.length, true);
    await this.playlistsGetFromCache();
  }

  Future<void> playlistAdd(Playlist playlist) async {
    if (this.playlists.length == 0) {
      this.playlists.add(new Playlist(playlistName: playlist.playlistName, playlistId: 0));
    }
    else {
      this.playlists.add(new Playlist(playlistName: playlist.playlistName, playlistId: this.playlists.last.playlistId + 1));
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
          if (this.playlists[index].tracks[trackIndex].trackName == track.trackName && this.playlists[index].tracks[trackIndex].albumName == track.albumName) {
            this.playlists[index].tracks.removeAt(trackIndex);
            break;
          }
        }
        break;
      }
    }
    await this.playlistsSaveToCache();
  }
  
  Future<void> playlistsSaveToCache() async {
    List<Map<String, dynamic>> playlists = <Map<String, dynamic>>[];
    for (Playlist playlist in this.playlists) {
      playlists.add(playlist.toMap());
    }
    File playlistFile = File(path.join(this.cacheDirectory.path, 'playlists.JSON'));
    await playlistFile.writeAsString(convert.JsonEncoder.withIndent('    ').convert({'playlists': playlists}));
  }

  Future<void> playlistsGetFromCache() async {
    this.playlists = <Playlist>[];
    File playlistFile = File(path.join(this.cacheDirectory.path, 'playlists.JSON'));
    if (!await playlistFile.exists()) await this.playlistsSaveToCache();
    else {
      List<dynamic> playlists = convert.jsonDecode(await playlistFile.readAsString())['playlists'];
      for (dynamic playlist in playlists) {
        this.playlists.add(new Playlist(
          playlistName: playlist['playlistName'],
          playlistId: playlist['playlistId'],
        ));
        for (dynamic track in playlist['tracks']) {
          this.playlists.last.tracks.add(new Track(
            trackName: track['trackName'],
            albumName: track['albumName'],
            trackNumber: track['trackNumber'],
            year: track['year'],
            trackArtistNames: track['trackArtistNames'],
            filePath: track['filePath'],
          ));
        }
      }
    }
    this.notifyListeners();
  }
  
  Future<void> _arrange(Track track, Future<void> Function() albumArtMethod) async {
    if (!Methods.binaryContains(this._foundAlbums, [track.albumName, track.albumArtistName])) {
      this._foundAlbums.add([track.albumName, track.albumArtistName]);
      await albumArtMethod();
      this.albums.add(
        new Album(
          albumName: track.albumName,
          year: track.year,
          albumArtistName: track.albumArtistName,
        )..tracks.add(
          new Track(
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
    }
    else if (Methods.binaryContains(this._foundAlbums, [track.albumName, track.albumArtistName])) {
      this.albums[Methods.binaryIndexOf(this._foundAlbums, [track.albumName, track.albumArtistName])].tracks.add(
        new Track(
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
    for (String artistName in track.trackArtistNames) {
      if (!this._foundArtists.contains(artistName)) {
        this._foundArtists.add(artistName);
        this.artists.add(
          new Artist(
            artistName: artistName,
          )..tracks.add(
            new Track(
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
      }
      else if (this._foundArtists.contains(artistName)) {
        this.artists[this._foundArtists.indexOf(artistName)].tracks.add(
          new Track(
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
    this.tracks.add(
      new Track(
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

  List<File> _albumArts = <File>[];
  List<List<String>> _foundAlbums = <List<String>>[];
  List<String> _foundArtists = <String>[];
}


Collection _collection;
