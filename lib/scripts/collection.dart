import 'dart:convert';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:path/path.dart' as path;
import 'package:media_metadata_retriever/media_metadata_retriever.dart';


const List<String> SUPPORTED_FILE_TYPES = ['OGG', 'OGA', 'AAC', 'M4A', 'MP3', 'WMA', 'OPUS'];


Collection collection;


class Track {
  final String trackName;
  final String albumName;
  final int trackNumber;
  final int year;
  final String albumArtistName;
  final List<dynamic> trackArtistNames;
  final String filePath;
  final int albumArtId;
  final String albumArtHigh;
  final String albumArtMedium;
  final String albumArtLow;

  Map<String, dynamic> toMap() {
    return {
      'trackName': this.trackName,
      'albumName': this.albumName,
      'trackNumber': this.trackNumber,
      'year': this.year,
      'albumArtistName': this.albumArtistName,
      'trackArtistNames': this.trackArtistNames ?? <dynamic>[],
      'filePath' : this.filePath,
      'albumArtId': this.albumArtId,
      'albumArtHigh': this.albumArtHigh,
      'albumArtMedium': this.albumArtHigh,
      'albumArtLow': this.albumArtHigh,
    };
  }
  
  static Track fromMap(Map<String, dynamic> trackMap) {
    return new Track(
      trackName: trackMap['trackName'],
      albumName: trackMap['albumName'],
      trackNumber: trackMap['trackNumber'],
      year: trackMap['year'],
      albumArtistName: trackMap['albumArtistName'],
      trackArtistNames: trackMap['trackArtistNames'] ?? <dynamic>[],
      filePath: trackMap['filePath'],
      albumArtId: trackMap['albumArtId'],
      albumArtHigh: trackMap['albumArtHigh'],
      albumArtMedium: trackMap['albumArtMedium'],
      albumArtLow: trackMap['albumArtLow'],
    );
  }

  Track({this.trackName, this.albumName, this.trackNumber, this.year, this.albumArtistName, this.trackArtistNames, this.albumArtId, this.filePath, this.albumArtHigh, this.albumArtMedium, this.albumArtLow});
}


class Album {
  final String albumName;
  final int year;
  final String albumArtistName;
  final int albumArtId;
  List<Track> tracks = <Track>[];
  final String albumArtHigh;
  final String albumArtMedium;
  final String albumArtLow;

  Map<String, dynamic> toMap() {
    List<dynamic> tracks = <dynamic>[];    
    for (Track track in this.tracks) {
      tracks.add(track.toMap());
    }
    return {
      'albumName': this.albumName,
      'year': this.year,
      'albumArtistName': this.albumArtistName,
      'albumArtId': this.albumArtId,
      'tracks': this.tracks,
      'albumArtHigh': this.albumArtHigh,
      'albumArtMedium': this.albumArtHigh,
      'albumArtLow': this.albumArtHigh,
    };
  }

  static Album fromMap(Map<String, dynamic> albumMap) {
    return new Album(
      albumName: albumMap['albumName'],
      year: albumMap['year'],
      albumArtistName: albumMap['albumArtistName'],
      albumArtId: albumMap['albumArtId'],
      albumArtHigh: albumMap['albumArtHigh'],
      albumArtMedium: albumMap['albumArtMedium'],
      albumArtLow: albumMap['albumArtLow'],
    );
  }

  Album({this.albumName, this.year, this.albumArtistName, this.albumArtId, this.albumArtHigh, this.albumArtMedium, this.albumArtLow});
}

/* TODO: Update Artist according to new specs. */
class Artist {
  final String artistName;
  List<Album> albums = <Album>[];
  List<Track> tracks = <Track>[];

  Map<String, dynamic> toMap() {
    List<dynamic> tracks = <dynamic>[];    
    for (Track track in this.tracks) {
      tracks.add(track.toMap());
    }
    List<dynamic> albums = <dynamic>[];    
    for (Album album in this.albums) {
      albums.add(album.toMap());
    }
    return {
      'trackArtistNames': this.artistName,
      'albums': albums,
      'tracks': tracks,
    };
  }

  static Artist fromMap(Map<String, dynamic> artistMap) {
    return new Artist(
      artistName: artistMap['artistName'],
    );
  }

  Artist({this.artistName});
}


class Playlist {
  final String playlistName;
  final int playlistId;
  List<Track> tracks = <Track>[];

  Map<String, dynamic> toMap() {
    List<dynamic> tracks = <dynamic>[];
    for (Track track in this.tracks) {
      tracks.add(track.toMap());
    }
    return {
      'type': 'Playlist',
      'playlistName': this.playlistName,
      'playlistId': this.playlistId,
      'tracks': tracks,
    };
  }

  Playlist({this.playlistName, this.playlistId});
}


class Collection {
  final Directory collectionDirectory;
  final Directory cacheDirectory;

  Collection(this.collectionDirectory, this.cacheDirectory);

  static Future<void> init({collectionDirectory, cacheDirectory}) async {
    collection = new Collection(collectionDirectory, cacheDirectory);
    if (!await collection.collectionDirectory.exists()) await collection.collectionDirectory.create(recursive: true);
    if (!await collection.cacheDirectory.exists()) await collection.cacheDirectory.create(recursive: true);
  }

  List<Album> albums = <Album>[];
  List<Track> tracks = <Track>[];
  List<Artist> artists = <Artist>[];
  List<Playlist> playlists = <Playlist>[];

  Future<Collection> refresh({void Function(int completed, int total, bool isCompleted) callback}) async {
    if (await File(path.join(this.cacheDirectory.path, 'collectionMusic.json')).exists()) {
      await File(path.join(this.cacheDirectory.path, 'collectionMusic.json')).delete();
    }
    this.albums.clear();
    this.tracks.clear();
    this.artists.clear();
    this._foundAlbums.clear();
    this._foundArtists.clear();
    List<FileSystemEntity> directory = this.collectionDirectory.listSync();
    for (int index = 0; index < directory.length; index++) {
      FileSystemEntity object = directory[index];
      if (isSupported(object)) {
        MediaMetadataRetriever retriever = new MediaMetadataRetriever();
        await retriever.setFile(object);
        Metadata metadata = await retriever.metadata;
        String trackName = metadata.trackName ?? 'Unknown Track';
        String albumName = metadata.albumName ?? 'Unknown Album';
        List<dynamic> trackArtistNames = metadata.trackArtistNames ?? <dynamic>['Unknown Artist'];
        String albumArtistName = metadata.albumArtistName ?? 'Unknown Artist';
        int trackNumber = metadata.trackNumber;
        int year = metadata.year;
        String filePath = object.path;
        void albumArtMethod() async {
          if (retriever.albumArt == null) {
            this._albumArts.add(null);
          }
          else {
            File albumArtFile = new File(path.join(this.cacheDirectory.path, 'albumArt${binaryIndexOf(this._foundAlbums, [albumName, albumArtistName])}.png'));
            await albumArtFile.writeAsBytes(retriever.albumArt);
            this._albumArts.add(albumArtFile);
          }
        }
        await this._arrange(trackName, albumName, year, trackNumber, albumArtistName, trackArtistNames, albumArtMethod, filePath);
      }
      if (callback != null) callback(index + 1, directory.length, false);
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
    await this.saveToCache();
    if (callback != null) callback(directory.length, directory.length, true);
    return this;
  }

  Future<List<dynamic>> search(String query, {dynamic mode}) async {
    if (query == '') return <dynamic>[];

    List<dynamic> result = <dynamic>[];
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

  File getAlbumArt(int albumArtId) => new File(path.join(this.cacheDirectory.path, 'albumArt$albumArtId.png'));

  Future<void> add({File trackFile}) async {
    if (isSupported(trackFile)) {
      MediaMetadataRetriever retriever = new MediaMetadataRetriever();
      await retriever.setFile(trackFile);
      Metadata metadata = await retriever.metadata;
      String trackName = metadata.trackName ?? 'Unknown Track';
      String albumName = metadata.albumName ?? 'Unknown Album';
      List<dynamic> trackArtistNames = metadata.trackArtistNames ?? <dynamic>['Unknown Artist'];
      String albumArtistName = metadata.albumArtistName ?? 'Unknown Artist';
      int trackNumber = metadata.trackNumber;
      int year = metadata.year;
      String filePath = trackFile.path;
      void albumArtMethod() async {
        if (retriever.albumArt == null) {
          this._albumArts.add(null);
        }
        else {
          File albumArtFile = new File(path.join(this.cacheDirectory.path, 'albumArt${binaryIndexOf(this._foundAlbums, [albumName, albumArtistName])}.png'));
          await albumArtFile.writeAsBytes(retriever.albumArt);
          this._albumArts.add(albumArtFile);
        }
      }
      await this._arrange(trackName, albumName, year, trackNumber, albumArtistName, trackArtistNames, albumArtMethod, filePath);
    }
    await this.saveToCache();
  }

  Future<void> delete(Object object) async {
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
    this.saveToCache();
  }

  Future<void> saveToCache() async {
   JsonEncoder encoder = JsonEncoder.withIndent('    ');
    List<Map<String, dynamic>> tracks = <Map<String, dynamic>>[];
    collection.tracks.forEach((element) => tracks.add(element.toMap()));
    await File(path.join(this.cacheDirectory.path, 'collectionMusic.json')).writeAsString(encoder.convert({'tracks': tracks}));
  }

  Future<void> getFromCache() async {
    this.albums = <Album>[];
    this.tracks = <Track>[];
    this.artists = <Artist>[];
    this._foundAlbums = <List<String>>[];
    this._foundArtists = <String>[];
    if (!await File(path.join(this.cacheDirectory.path, 'collectionMusic.json')).exists()) {
      await this.refresh();
    }
    else {
      Map<String, dynamic> collection = convert.jsonDecode(await File(path.join(this.cacheDirectory.path, 'collectionMusic.json')).readAsString());
      for (Map<String, dynamic> track in collection['tracks']) {
        int trackNumber = track['trackNumber'];
        int year = track['year'];
        String albumArtistName = track['albumArtistName'] ?? 'Unknown Artist';
        List<dynamic> trackArtistNames = track['trackArtistNames'];
        String albumName = track['albumName'];
        String trackName = track['trackName'];
        String filePath = track['filePath'];
        void albumArtMethod() async {
          this._albumArts.add(
            File(path.join(this.cacheDirectory.path, 'albumArt${track['albumArtId']}.png')),
          );
        }
        await this._arrange(trackName, albumName, year, trackNumber, albumArtistName, trackArtistNames, albumArtMethod, filePath);
      }
      List<File> collectionDirectoryContent = <File>[];
      for (FileSystemEntity object in this.collectionDirectory.listSync()) {
        if (isSupported(object)) {
          collectionDirectoryContent.add(object);
        }
      }
      if (collectionDirectoryContent.length != this.tracks.length) {
        for (FileSystemEntity file in collectionDirectoryContent) {
          bool isTrackAdded = false;
          for (Track track in this.tracks) {
            if (track.filePath == file.path) {
              isTrackAdded = true;
              break;
            }
          }
          if (!isTrackAdded) {
            await this.add(
              trackFile: file as File,
            );
          }
        }
      }
      for (Track track in this.tracks) {
        if (!await File(track.filePath).exists()) {
          await File(track.filePath).delete();
        }
      }
    }
    await this.playlistsGetFromCache();
  }

  Future<void> _arrange(String trackName, String albumName, int year, int trackNumber, String albumArtistName, List<dynamic> trackArtistNames, Function albumArtMethod, String filePath) async {
    if (!binaryContains(this._foundAlbums, [albumName, albumArtistName])) {
      this._foundAlbums.add([albumName, albumArtistName]);
      await albumArtMethod();
      this.albums.add(
        new Album(
          albumName: albumName,
          albumArtId: binaryIndexOf(this._foundAlbums, [albumName, albumArtistName]),
          year: year,
          albumArtistName: albumArtistName,
        )..tracks.add(
          new Track(
            albumName: albumName,
            year: year,
            albumArtistName: albumArtistName,
            trackArtistNames: trackArtistNames,
            trackName: trackName,
            trackNumber: trackNumber,
            albumArtId: binaryIndexOf(this._foundAlbums, [albumName, albumArtistName]),
            filePath: filePath,
          ),
        ),
      );
    }
    else if (binaryContains(this._foundAlbums, [albumName, albumArtistName])) {
      this.albums[binaryIndexOf(this._foundAlbums, [albumName, albumArtistName])].tracks.add(
        new Track(
          albumName: albumName,
          albumArtId: binaryIndexOf(this._foundAlbums, [albumName, albumArtistName]),
          year: year,
          albumArtistName: albumArtistName,
          trackArtistNames: trackArtistNames,
          trackName: trackName,
          trackNumber: trackNumber,
          filePath: filePath,
        ),
      );
    }
    for (String artistName in trackArtistNames) {
      if (!this._foundArtists.contains(artistName)) {
        this._foundArtists.add(artistName);
        this.artists.add(
          new Artist(
            artistName: artistName,
          )..tracks.add(
            new Track(
              albumName: albumName,
              albumArtId: binaryIndexOf(this._foundAlbums, [albumName, albumArtistName]),
              year: year,
              albumArtistName: albumArtistName,
              trackArtistNames: trackArtistNames,
              trackName: trackName,
              trackNumber: trackNumber,
              filePath: filePath,
            ),
          ),
        );
      }
      else if (this._foundArtists.contains(artistName)) {
        this.artists[this._foundArtists.indexOf(artistName)].tracks.add(
          new Track(
            albumName: albumName,
            albumArtId: binaryIndexOf(this._foundAlbums, [albumName, albumArtistName]),
            year: year,
            albumArtistName: albumArtistName,
            trackArtistNames: trackArtistNames,
            trackName: trackName,
            trackNumber: trackNumber,
            filePath: filePath,
          ),
        );
      }
    }
    this.tracks.add(
      new Track(
        albumName: albumName,
        albumArtId: binaryIndexOf(this._foundAlbums, [albumName, albumArtistName]),
        year: year,
        albumArtistName: albumArtistName,
        trackArtistNames: trackArtistNames,
        trackName: trackName,
        trackNumber: trackNumber,
        filePath: filePath,
      ),
    );
  }

  Future<void> playlistAdd(Playlist playlist) async {
    if (this.playlists.length == 0) {
      this.playlists.add(new Playlist(playlistName: playlist.playlistName, playlistId: 0));
    }
    else {
      this.playlists.add(new Playlist(playlistName: playlist.playlistName, playlistId: this.playlists.last.playlistId + 1));
    }
    await this.playlistsSaveToCache();
  }

  Future<void> playlistRemove(Playlist playlist) async {
    for (int index = 0; index < this.playlists.length; index++) {
      if (this.playlists[index].playlistId == playlist.playlistId) {
        this.playlists.removeAt(index);
        break;
      }
    }
    await this.playlistsSaveToCache();
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
    File playlistFile = File(path.join(this.cacheDirectory.path, 'collectionPlaylists.json'));
    await playlistFile.writeAsString(JsonEncoder.withIndent('    ').convert({'playlists': playlists}));
  }

  Future<void> playlistsGetFromCache() async {
    File playlistFile = File(path.join(this.cacheDirectory.path, 'collectionPlaylists.json'));
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
            albumArtId: track['albumArtId'],
            filePath: track['filePath'],
          ));
        }
      }
    }
  }
  
  List<File> _albumArts = <File>[];
  List<List<String>> _foundAlbums = <List<String>>[];
  List<String> _foundArtists = <String>[];
}


int binaryIndexOf(List<List<String>> collectionList, List<String> keywordList) {
  int indexOfKeywordList = -1;
  for (int index = 0; index < collectionList.length; index++) {
    List<String> object = collectionList[index];
    if (object[0] == keywordList[0] && object[1] == keywordList[1]) {
      indexOfKeywordList = index;
      break;
    }
  }
  return indexOfKeywordList;
}


bool binaryContains(List<List<String>> collectionList, List<String> keywordList) => binaryIndexOf(collectionList, keywordList) != -1 ? true : false;


bool isSupported(FileSystemEntity file) {
  if (file is File && SUPPORTED_FILE_TYPES.contains(file.path.split('.').last.toUpperCase())) {
    return true;
  }
  else {
    return false;
  }
}
