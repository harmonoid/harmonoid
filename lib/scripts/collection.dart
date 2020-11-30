import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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


enum SearchFilter {
  album,
  track,
  artist,
}


class Collection {

  final Directory collectionDirectory;
  final Directory cacheDirectory;

  Collection({this.collectionDirectory, this.cacheDirectory}) {

    if (!this.collectionDirectory.existsSync()) this.collectionDirectory.createSync();
    if (!this.cacheDirectory.existsSync()) this.cacheDirectory.createSync();
  }

  List<Album> albums = <Album>[];
  List<Track> tracks = <Track>[];
  List<Artist> artists = <Artist>[];

  Future<Collection> refresh() async {

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

        void albumArtMethod() {
          if (fileTags[0].tags['picture'] == null) {
            this._albumArts.add(null);
          }
          else {
            this._albumArts.add(fileTags[0].tags['picture'][fileTags[0].tags['picture'].keys.first].imageData);
          }
        }

        this._arrange(trackName, albumName, year, trackNumber, artistNames, albumArtMethod, filePath);
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

  Future<List<dynamic>> search(String query, SearchFilter filter) async {

    List<dynamic> result = <dynamic>[];
    if (filter == SearchFilter.album) {
      for (Album album in this.albums) {
        if (album.albumName.contains(query)) {
          result.add(album);
        }
      }
    }
    else if (filter == SearchFilter.track) {
      for (Track track in this.tracks) {
        if (track.trackName.contains(query)) {
          result.add(track);
        }
      }
    }
    else if (filter == SearchFilter.artist) {
      for (Artist artist in this.artists) {
        if (artist.artistName.contains(query)) {
          result.add(artist);
        }
      }
    }
    return result;
  }

  Uint8List getAlbumArt(int albumArtId) => Uint8List.fromList(this._albumArts[albumArtId]);

  Future<void> add({Object object, Uint8List albumArtBytes, File trackFile}) async {
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

      void albumArtMethod() {
        if (fileTags[0].tags['picture'] == null) {
          this._albumArts.add(null);
        }
        else {
          this._albumArts.add(fileTags[0].tags['picture'][fileTags[0].tags['picture'].keys.first].imageData);
        }
      }

      this._arrange(trackName, albumName, year, trackNumber, artistNames, albumArtMethod, filePath);
    }
    else if (object is Track) {
      void albumArtMethod() {
        this._albumArts.add(albumArtBytes.toList());
      }
      this._arrange(
        object.trackName,
        object.albumName,
        object.year,
        object.trackNumber,
        object.artistNames,
        albumArtMethod,
        object.filePath
      );
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
            for (int index = 0; index < artist.albums.length; index++) {
              if (object.albumName == artist.albums[index].albumName) {
                artist.albums.removeAt(index);
                if (artist.albums.length == 0) this.artists.remove(artist);
                break;
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

    this.cacheDirectory..deleteSync(recursive: true)..createSync(recursive: true);

    JsonEncoder encoder = JsonEncoder.withIndent('    ');

    List<Map<String, dynamic>> tracks = <Map<String, dynamic>>[];
    collection.tracks.forEach((element) => tracks.add(element.toDictionary()));

    for (int index = 0; index < this._albumArts.length; index++) {
      await File(path.join(this.cacheDirectory.path, 'albumArt$index.png')).writeAsBytes(this._albumArts[index]);
    }

    await File(path.join(this.cacheDirectory.path, 'cache.json')).writeAsString(encoder.convert({'tracks': tracks}));
  }

  Future<Collection> getFromCache() async {

    this.albums.clear();
    this.tracks.clear();
    this.artists.clear();

    this._foundAlbums.clear();
    this._foundArtists.clear();

    if (!await File(path.join(this.cacheDirectory.path, 'cache.json')).exists()) {
      if (this.collectionDirectory.listSync().length != 0) await this.refresh();
      await this.saveToCache();
    }

    Map<String, dynamic> collection = convert.jsonDecode(await File(path.join(this.cacheDirectory.path, 'cache.json')).readAsString());

    for (Map<String, dynamic> track in collection['tracks']) {
      String year = track['year'];
      List<dynamic> artistNames = track['artistNames'];
      String trackNumber = track['trackNumber'];
      String albumName = track['albumName'];
      String trackName = track['trackName'];
      String filePath = track['filePath'];

      void albumArtMethod() {
        this._albumArts.add(
          File(path.join(this.cacheDirectory.path, 'albumArt${track['albumArtId']}.png')).readAsBytesSync().toList(),
        );
      }

      this._arrange(trackName, albumName, year, trackNumber, artistNames, albumArtMethod, filePath);
    }

    return this;
  }

  void _arrange(String trackName, String albumName, String year, String trackNumber, List<dynamic> artistNames, Function albumArtMethod, String filePath) {
    
    if (!this._foundAlbums.contains(albumName)) {
      this._foundAlbums.add(albumName);
      albumArtMethod();
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
  
  List<List<int>> _albumArts = <List<int>>[];
  List<String> _foundAlbums = <String>[];
  List<String> _foundArtists = <String>[];
}
