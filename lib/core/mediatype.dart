import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:harmonoid/core/configuration.dart';

abstract class MediaType {
  String? type;
  Map<String, dynamic> toMap();
}

class Track extends MediaType with Comparable {
  String? trackName;
  String? albumName;
  int? trackNumber;
  int? year;
  String? albumArtistName;
  List<String>? trackArtistNames;
  String? filePath;
  String? networkAlbumArt;
  int? trackDuration;
  String? trackId;
  String? albumId;
  dynamic extras;
  File get albumArt {
    File albumArtFile = File(path.join(
        configuration.cacheDirectory!.path,
        'albumArts',
        '${this.albumArtistName}_${this.albumName}'
                .replaceAll(RegExp(r'[^\s\w]'), ' ') +
            '.PNG'));
    if (albumArtFile.existsSync())
      return albumArtFile;
    else if (File(path.join(path.dirname(this.filePath!), 'cover.jpg'))
        .existsSync())
      return File(path.join(path.dirname(this.filePath!), 'cover.jpg'));
    else
      return File(path.join(configuration.cacheDirectory!.path, 'albumArts',
          'defaultAlbumArt' + '.PNG'));
  }

  String? type = 'Track';

  @override
  Map<String, dynamic> toMap() {
    return {
      'trackName': this.trackName,
      'albumName': this.albumName,
      'trackNumber': this.trackNumber,
      'year': this.year,
      'albumArtistName': this.albumArtistName,
      'trackArtistNames': this.trackArtistNames ?? <dynamic>['Unknown Artist'],
      'filePath': this.filePath,
      'networkAlbumArt': this.networkAlbumArt,
      'trackDuration': this.trackDuration,
      'trackId': this.trackId,
      'albumId': this.albumId,
      'type': this.type,
    };
  }

  static Track? fromMap(Map<String, dynamic>? trackMap) {
    if (trackMap == null) return null;
    bool isNotNullOrEmpty(dynamic data) {
      if (data == '' || data == null) return false;
      return true;
    }

    return Track(
      trackName: isNotNullOrEmpty(trackMap['trackName'])
          ? trackMap['trackName']
          : 'Unknown Track',
      albumName: isNotNullOrEmpty(trackMap['albumName'])
          ? trackMap['albumName']
          : 'Unknown Album',
      trackNumber: trackMap['trackNumber'],
      year: trackMap['year'],
      albumArtistName: trackMap['albumArtistName'] ?? 'Unknown Artist',
      trackArtistNames:
          ((trackMap['trackArtistNames'] ?? <String>['Unknown Artist']) as List)
              .cast<String>(),
      filePath: trackMap['filePath'],
      networkAlbumArt: trackMap['networkAlbumArt'],
      trackDuration: trackMap['trackDuration'],
      trackId: trackMap['trackId'],
      albumId: trackMap['albumId'],
    );
  }

  @override
  int compareTo(dynamic track) {
    int result = -1;
    if (track is Track) {
      result = this.trackName!.compareTo(track.trackName!);
    }
    return result;
  }

  Track(
      {this.trackName,
      this.albumName,
      this.trackNumber,
      this.year,
      this.albumArtistName,
      this.trackArtistNames,
      this.filePath,
      this.networkAlbumArt,
      this.trackDuration,
      this.trackId,
      this.albumId});
}

class Album extends MediaType with Comparable {
  String? albumName;
  int? year;
  String? albumArtistName;
  List<Track> tracks = <Track>[];
  String? networkAlbumArt;
  String? albumId;
  File get albumArt {
    File albumArtFile = File(path.join(
        configuration.cacheDirectory!.path,
        'albumArts',
        '${this.albumArtistName}_${this.albumName}'
                .replaceAll(RegExp(r'[^\s\w]'), ' ') +
            '.PNG'));
    if (albumArtFile.existsSync())
      return albumArtFile;
    else if (File(
            path.join(path.dirname(this.tracks.first.filePath!), 'cover.jpg'))
        .existsSync())
      return File(
          path.join(path.dirname(this.tracks.first.filePath!), 'cover.jpg'));
    else
      return File(path.join(configuration.cacheDirectory!.path, 'albumArts',
          'defaultAlbumArt' + '.PNG'));
  }

  String? type = 'Album';

  @override
  Map<String, dynamic> toMap() {
    List<dynamic> tracks = <dynamic>[];
    for (Track track in this.tracks) {
      tracks.add(track.toMap());
    }
    return {
      'albumName': this.albumName,
      'year': this.year,
      'albumArtistName': this.albumArtistName,
      'tracks': this.tracks,
      'networkAlbumArt': this.networkAlbumArt,
      'albumId': this.albumId,
      'type': this.type,
    };
  }

  static Album fromMap(Map<String, dynamic> albumMap) {
    return Album(
        albumName: albumMap['albumName'] ?? 'Unknown Album',
        year: albumMap['year'],
        albumArtistName: albumMap['albumArtistName'] ?? 'Unknown Artist',
        networkAlbumArt: albumMap['networkAlbumArt'],
        albumId: albumMap['albumId']);
  }

  Album(
      {this.albumName,
      this.year,
      this.albumArtistName,
      this.networkAlbumArt,
      this.albumId});

  @override
  int compareTo(dynamic album) {
    int result = -1;
    if (album is Album) {
      result = this.albumName!.compareTo(album.albumName!);
    }
    return result;
  }
}

class Artist extends MediaType with Comparable {
  String? artistName;
  List<Album> albums = <Album>[];
  List<Track> tracks = <Track>[];
  String? type = 'Artist';

  @override
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
      'type': this.type,
    };
  }

  static Artist fromMap(Map<String, dynamic> artistMap) {
    return Artist(
      artistName: artistMap['artistName'],
    );
  }

  @override
  int compareTo(dynamic artist) {
    int result = -1;
    if (artist is Artist) {
      result = this.artistName!.compareTo(artist.artistName!);
    }
    return result;
  }

  Artist({this.artistName});
}

class Playlist extends MediaType {
  String? playlistName;
  int? playlistId;
  List<Track> tracks = <Track>[];
  String? type = 'Playlist';

  @override
  Map<String, dynamic> toMap() {
    List<dynamic> tracks = <dynamic>[];
    for (Track track in this.tracks) {
      tracks.add(track.toMap());
    }
    return {
      'playlistName': this.playlistName,
      'playlistId': this.playlistId,
      'tracks': tracks,
      'type': this.type,
    };
  }

  Playlist({this.playlistName, this.playlistId});
}

List<MediaType> mediaTypes = <MediaType>[
  Album(),
  Track(),
  Artist(),
];
