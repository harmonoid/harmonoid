import 'dart:io';
import 'dart:typed_data';
import 'package:dart_tags/dart_tags.dart';

Collection collection;

class Track {
  
  final String trackName;
  final String albumName;
  final String trackNumber;
  final String year;
  final List<String> artistNames;
  final File file;
  final int albumArtId;

  Track({this.trackName, this.albumName, this.trackNumber, this.year, this.artistNames, this.albumArtId, this.file});
}


class Album {

  final String albumName;
  final String year;
  final List<String> artistNames;
  final int albumArtId;
  List<Track> tracks = <Track>[];

  Album({this.albumName, this.year, this.artistNames, this.albumArtId});
}


class Artist {
  final String artistName;
  List<Album> albums = <Album>[];
  List<Track> tracks = <Track>[];

  Artist({this.artistName});
}


enum SearchFilter {
  album,
  track,
  artist,
}


class Collection {

  final Directory directory;

  Collection({this.directory});

  List<Album> albums = <Album>[];
  List<Track> tracks = <Track>[];
  List<Artist> artists = <Artist>[];

  Future<Collection> refresh() async {
    List<String> foundAlbums = <String>[];
    List<String> foundArtists = <String>[];

    for (FileSystemEntity object in this.directory.listSync()) {
      if (object is File && object.path.split('.').last.toUpperCase() == 'MP3') {
        List<Tag> fileTags = await TagProcessor().getTagsFromByteArray(
          object.readAsBytes(),
          [TagType.id3v2]
        );

        String year = fileTags[0].tags['year'] == null ? null : fileTags[0].tags['year'];
        List<String> artistNames = fileTags[0].tags['artist'] == null ? ['Unknown Artist'] : fileTags[0].tags['artist'].split('/');
        String trackNumber = fileTags[0].tags['track'] == null ? '0' : fileTags[0].tags['track'].split('/')[0];
        String albumName = fileTags[0].tags['album'] == null ? 'Unknown Album' : fileTags[0].tags['album'];
        String trackName = fileTags[0].tags['title'];

        if (!foundAlbums.contains(albumName)) {
          foundAlbums.add(albumName);
          if (fileTags[0].tags['picture'] == null) {
            this.albumArts.add(null);
          }
          else {
            this.albumArts.add(fileTags[0].tags['picture'][fileTags[0].tags['picture'].keys.first].imageData);
          };
          this.albums.add(
            new Album(
              albumName: albumName,
              albumArtId: foundAlbums.indexOf(albumName),
              year: year,
              artistNames: artistNames,
            )..tracks.add(
              new Track(
                albumName: albumName,
                year: year,
                artistNames: artistNames,
                trackName: trackName,
                trackNumber: trackNumber,
                file: object.absolute,
              ),
            ),
          );
        }

        else if (foundAlbums.contains(albumName)) {
          this.albums[foundAlbums.indexOf(albumName)].tracks.add(
            new Track(
              albumName: albumName,
              albumArtId: foundAlbums.indexOf(albumName),
              year: year,
              artistNames: artistNames,
              trackName: trackName,
              trackNumber: trackNumber,
              file: object.absolute,
            ),
          );
          for (String artistName in artistNames) {
            if (!this.albums[foundAlbums.indexOf(albumName)].artistNames.contains(artistName)) {
              this.albums[foundAlbums.indexOf(albumName)].artistNames.add(artistName);
            }
          }
        }

        for (String artistName in artistNames) {
          if (!foundArtists.contains(artistName)) {
            foundArtists.add(artistName);
            this.artists.add(
              new Artist(
                artistName: artistName,
              )..tracks.add(
                new Track(
                  albumName: albumName,
                  albumArtId: foundAlbums.indexOf(albumName),
                  year: year,
                  artistNames: artistNames,
                  trackName: trackName,
                  trackNumber: trackNumber,
                  file: object.absolute,
                ),
              ),
            );
          }
          else if (foundArtists.contains(artistName)) {
            this.artists[foundArtists.indexOf(artistName)].tracks.add(
              new Track(
                albumName: albumName,
                albumArtId: foundAlbums.indexOf(albumName),
                year: year,
                artistNames: artistNames,
                trackName: trackName,
                trackNumber: trackNumber,
                file: object.absolute,
              ),
            );
          }
        }

        this.tracks.add(
          new Track(
            albumName: albumName,
            albumArtId: foundAlbums.indexOf(albumName),
            year: year,
            artistNames: artistNames,
            trackName: trackName,
            trackNumber: trackNumber,
            file: object.absolute,
          ),
        );
      }
    }

    for (Album album in this.albums) {
      if (album.artistNames != null) {
        for (String artist in album.artistNames)  {
          if (this.artists[foundArtists.indexOf(artist)].albums == null) this.artists[foundArtists.indexOf(artist)].albums = <Album>[];
          this.artists[foundArtists.indexOf(artist)].albums.add(album);
        }
      }
      else if (album.artistNames == null) {
        this.artists[foundArtists.indexOf(null)].albums.add(album);
      };
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

  Uint8List getAlbumArt(int albumArtId) => Uint8List.fromList(this.albumArts[albumArtId]);

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

      await object.file.delete();

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
        await track.file.delete();
      }
      
    }
  }

  List<List<int>> albumArts = <List<int>>[];
}
