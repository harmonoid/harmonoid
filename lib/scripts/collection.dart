import 'dart:convert';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:path/path.dart' as path;
import 'package:dart_tags/dart_tags.dart';

Collection collection;

class Track {
  final String trackName;
  final String albumName;
  final String trackNumber;
  final String year;
  final List<dynamic> artistNames;
  final String filePath;
  final int albumArtId;

  Map<String, dynamic> toDictionary() {
    return {
      'type': 'Track',
      'trackName': this.trackName,
      'albumName': this.albumName,
      'trackNumber': this.trackNumber,
      'year': this.year,
      'artistNames': this.artistNames,
      'filePath' : this.filePath,
      'albumArtId': this.albumArtId,
    };
  }

  Track({this.trackName, this.albumName, this.trackNumber, this.year, this.artistNames, this.albumArtId, this.filePath});
}


class Album {
  final String albumName;
  final String year;
  final List<dynamic> artistNames;
  final int albumArtId;
  List<Track> tracks = <Track>[];

  Map<String, dynamic> toDictionary() {
    List<dynamic> tracks = <dynamic>[];    
    for (Track track in this.tracks) {
      tracks.add(track.toDictionary());
    }
    return {
      'type': 'Album',
      'albumName': this.albumName,
      'year': this.year,
      'artistNames': this.artistNames,
      'albumArtId': this.albumArtId,
      'tracks': tracks,
    };
  }

  Album({this.albumName, this.year, this.artistNames, this.albumArtId});
}


class Artist {
  final String artistName;
  List<Album> albums = <Album>[];
  List<Track> tracks = <Track>[];

  Map<String, dynamic> toDictionary() {
    List<dynamic> tracks = <dynamic>[];    
    for (Track track in this.tracks) {
      tracks.add(track.toDictionary());
    }
    List<dynamic> albums = <dynamic>[];    
    for (Album album in this.albums) {
      albums.add(album.toDictionary());
    }
    return {
      'type': 'Artist',
      'artistNames': this.artistName,
      'albums': albums,
      'tracks': tracks,
    };
  }

  Artist({this.artistName});
}


class Playlist {
  final String playlistName;
  final int playlistId;
  List<Track> tracks = <Track>[];

  Map<String, dynamic> toDictionary() {
    List<dynamic> tracks = <dynamic>[];
    for (Track track in this.tracks) {
      tracks.add(track.toDictionary());
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

  Future<Collection> refresh() async {
    for (FileSystemEntity fileSystemEntity in this.cacheDirectory.listSync()) {
      await fileSystemEntity.delete();
    }
    
    this.albums.clear();
    this.tracks.clear();
    this.artists.clear();

    this._foundAlbums.clear();
    this._foundArtists.clear();

    for (FileSystemEntity object in this.collectionDirectory.listSync()) {
      if (object is File && object.path.split('.').last.toUpperCase() == 'MP3') {
        List<Tag> fileTags = await TagProcessor().getTagsFromByteArray(
          object.readAsBytes(),
          [TagType.id3v2]
        );

        String year = fileTags[0].tags['TDRC'] ?? fileTags[0].tags['year'] ?? 'Unknown Year';
        List<String> artistNames = fileTags[0].tags['artist'] == null ? ['Unknown Artist'] : fileTags[0].tags['artist'].split('/');
        String trackNumber = fileTags[0].tags['track'] == null ? '1' : fileTags[0].tags['track'].split('/')[0];
        String albumName = fileTags[0].tags['album'] ?? 'Unknown Album';
        String trackName = fileTags[0].tags['title'];
        String filePath = object.path;

        void albumArtMethod() async {
          if (fileTags[0].tags['picture'] == null) {
            this._albumArts.add(null);
          }
          else {
            File albumArtFile = new File(path.join(this.cacheDirectory.path, 'albumArt${this._foundAlbums.indexOf(albumName)}.png'));
            await albumArtFile.writeAsBytes(fileTags[0].tags['picture'][fileTags[0].tags['picture'].keys.first].imageData);
            this._albumArts.add(albumArtFile);
          }
        }

        await this._arrange(trackName, albumName, year, trackNumber, artistNames, albumArtMethod, filePath);
      }
    }

    for (Album album in this.albums) {
      if (album.artistNames != null) {
        for (String artist in album.artistNames)  {
          if (this.artists[this._foundArtists.indexOf(artist)].albums == null) this.artists[this._foundArtists.indexOf(artist)].albums = <Album>[];
          this.artists[this._foundArtists.indexOf(artist)].albums.add(album);
        }
      }
      else if (album.artistNames == null) {
        this.artists[this._foundArtists.indexOf(null)].albums.add(album);
      }
    }

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
    if (trackFile != null) {
      List<Tag> fileTags = await TagProcessor().getTagsFromByteArray(
        trackFile.readAsBytes(),
        [TagType.id3v2]
      );

      String year = fileTags[0].tags['TDRC'] ?? fileTags[0].tags['year'] ?? 'Unknown Year';
      List<String> artistNames = fileTags[0].tags['artist'] == null ? ['Unknown Artist'] : fileTags[0].tags['artist'].split('/');
      String trackNumber = fileTags[0].tags['track'] == null ? '1' : fileTags[0].tags['track'].split('/')[0];
      String albumName = fileTags[0].tags['album'] ?? 'Unknown Album';
      String trackName = fileTags[0].tags['title'];
      String filePath = trackFile.path;

      void albumArtMethod() async {
        if (fileTags[0].tags['picture'] == null) {
          this._albumArts.add(null);
        }
        else {
          File albumArtFile = new File(path.join(this.cacheDirectory.path, 'albumArt${this._foundAlbums.indexOf(albumName)}.png'));
          await albumArtFile.writeAsBytes(fileTags[0].tags['picture'][fileTags[0].tags['picture'].keys.first].imageData);
          this._albumArts.add(albumArtFile);
        }
      }

      await this._arrange(trackName, albumName, year, trackNumber, artistNames, albumArtMethod, filePath);
    }
  }

  Future<void> delete(Object object) async {

    if (object is Track) {
      for (int index = 0; index < this.tracks.length; index++) {
        if (object.trackName == this.tracks[index].trackName) {
          this.tracks.removeAt(index);
          break;
        }
      }
      for (Album album in this.albums) {
        if (object.albumName == album.albumName) {
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
      for (String artistName in object.artistNames) {
        for (Artist artist in this.artists) {
          if (artistName == artist.artistName) {
            for (int index = 0; index < artist.tracks.length; index++) {
              if (object.trackName == artist.tracks[index].trackName) {
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
                if (object.albumName == album.albumName) {
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

      await File(object.filePath).delete();

    }
    else if (object is Album) {
      for (int index = 0; index < this.albums.length; index++) {
        if (object.albumName == this.albums[index].albumName) {
          this.albums.removeAt(index);
          break;
        }
      }
      for (int index = 0; index < this.tracks.length; index++) {
        List<Track> updatedTracks = <Track>[];
        for (Track track in this.tracks) {
          if (object.albumName != track.albumName) {
            updatedTracks.add(track);
          }
        }
        this.tracks = updatedTracks;
      }
      for (String artistName in object.artistNames) {
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

      for (Track track in object.tracks) {
        await File(track.filePath).delete();
      }
      
    }

    this.saveToCache();
  }

  Future<void> saveToCache() async {
   JsonEncoder encoder = JsonEncoder.withIndent('    ');
    List<Map<String, dynamic>> tracks = <Map<String, dynamic>>[];
    collection.tracks.forEach((element) => tracks.add(element.toDictionary()));

    await File(path.join(this.cacheDirectory.path, 'collectionMusic.json')).writeAsString(encoder.convert({'tracks': tracks}));
  }

  Future<Collection> getFromCache() async {

    this.albums.clear();
    this.tracks.clear();
    this.artists.clear();

    this._foundAlbums.clear();
    this._foundArtists.clear();

    if (!await File(path.join(this.cacheDirectory.path, 'collectionMusic.json')).exists()) {
      if (this.collectionDirectory.listSync().length != 0) await this.refresh();
      await this.saveToCache();
    }
    else {
      Map<String, dynamic> collection = convert.jsonDecode(await File(path.join(this.cacheDirectory.path, 'collectionMusic.json')).readAsString());

      for (Map<String, dynamic> track in collection['tracks']) {
        String year = track['year'];
        List<dynamic> artistNames = track['artistNames'];
        String trackNumber = track['trackNumber'];
        String albumName = track['albumName'];
        String trackName = track['trackName'];
        String filePath = track['filePath'];

        void albumArtMethod() async {
          this._albumArts.add(
            File(path.join(this.cacheDirectory.path, 'albumArt${track['albumArtId']}.png')),
          );
        }

        await this._arrange(trackName, albumName, year, trackNumber, artistNames, albumArtMethod, filePath);
      }
    }
    await this.playlistsGetFromCache();
    return this;
  }

  Future<void> _arrange(String trackName, String albumName, String year, String trackNumber, List<dynamic> artistNames, Function albumArtMethod, String filePath) async {
    
    if (!this._foundAlbums.contains(albumName)) {
      this._foundAlbums.add(albumName);
      await albumArtMethod();
      this.albums.add(
        new Album(
          albumName: albumName,
          albumArtId: this._foundAlbums.indexOf(albumName),
          year: year,
          artistNames: artistNames,
        )..tracks.add(
          new Track(
            albumName: albumName,
            year: year,
            artistNames: artistNames,
            trackName: trackName,
            trackNumber: trackNumber,
            filePath: filePath,
          ),
        ),
      );
    }

    else if (this._foundAlbums.contains(albumName)) {
      this.albums[this._foundAlbums.indexOf(albumName)].tracks.add(
        new Track(
          albumName: albumName,
          albumArtId: this._foundAlbums.indexOf(albumName),
          year: year,
          artistNames: artistNames,
          trackName: trackName,
          trackNumber: trackNumber,
          filePath: filePath,
        ),
      );
      for (String artistName in artistNames) {
        if (!this.albums[this._foundAlbums.indexOf(albumName)].artistNames.contains(artistName)) {
          this.albums[this._foundAlbums.indexOf(albumName)].artistNames.add(artistName);
        }
      }
    }

    for (String artistName in artistNames) {
      if (!this._foundArtists.contains(artistName)) {
        this._foundArtists.add(artistName);
        this.artists.add(
          new Artist(
            artistName: artistName,
          )..tracks.add(
            new Track(
              albumName: albumName,
              albumArtId: this._foundAlbums.indexOf(albumName),
              year: year,
              artistNames: artistNames,
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
            albumArtId: this._foundAlbums.indexOf(albumName),
            year: year,
            artistNames: artistNames,
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
        albumArtId: this._foundAlbums.indexOf(albumName),
        year: year,
        artistNames: artistNames,
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
      playlists.add(playlist.toDictionary());
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
            artistNames: track['artistNames'],
            albumArtId: track['albumArtId'],
            filePath: track['filePath'],
          ));
        }
      }
    }
  }
  
  List<File> _albumArts = <File>[];
  List<String> _foundAlbums = <String>[];
  List<String> _foundArtists = <String>[];
}
