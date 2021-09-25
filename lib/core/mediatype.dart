import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:harmonoid/core/configuration.dart';

abstract class MediaType {
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
  int? bitrate;
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
    else if (File(path.join(path.dirname(this.filePath!), 'Folder.jpg'))
        .existsSync())
      return File(path.join(path.dirname(this.filePath!), 'Folder.jpg'));
    else
      return File(path.join(configuration.cacheDirectory!.path, 'albumArts',
          'defaultAlbumArt' + '.PNG'));
  }

  @override
  Map<String, dynamic> toMap() {
    var artists = ['Unknown Artist'];
    if (this.trackArtistNames != null) {
      if (this.trackArtistNames!.isNotEmpty) {
        if (this.trackArtistNames!.first.isNotEmpty) {
          artists = this.trackArtistNames!;
        }
      }
    }
    return {
      'trackName': this.trackName,
      'albumName': this.albumName,
      'trackNumber': this.trackNumber,
      'year': this.year,
      'albumArtistName': (this.albumArtistName?.isEmpty ?? true)
          ? 'Unknown Artist'
          : this.albumArtistName,
      'trackArtistNames': artists,
      'filePath': this.filePath,
      'trackDuration': this.trackDuration,
      'bitrate': this.bitrate,
      'networkAlbumArt': this.networkAlbumArt,
      'trackId': this.trackId,
      'albumId': this.albumId,
    };
  }

  static Track fromMap(Map<String, dynamic> map) => Track(
        trackName: map['trackName'],
        albumName: ![null, ''].contains(map['albumName'])
            ? map['albumName']
            : 'Unknown Album',
        trackNumber: map['trackNumber'],
        year: map['year'],
        albumArtistName: map['albumArtistName'] ?? 'Unknown Artist',
        trackArtistNames:
            (map['trackArtistNames'] ?? <String>['Unknown Artist'])
                .cast<String>(),
        filePath: map['filePath'],
        networkAlbumArt: map['networkAlbumArt'],
        trackDuration: map['trackDuration'],
        bitrate: map['bitrate'],
        trackId: map['trackId'],
        albumId: map['albumId'],
      );

  @override
  int compareTo(dynamic track) {
    int result = -1;
    if (track is Track) {
      result = this.trackName!.compareTo(track.trackName!);
    }
    return result;
  }

  Track({
    this.trackName,
    this.albumName,
    this.trackNumber,
    this.year,
    this.albumArtistName,
    this.trackArtistNames,
    this.filePath,
    this.networkAlbumArt,
    this.trackDuration,
    this.bitrate,
    this.trackId,
    this.albumId,
  });
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
    else if (File(
            path.join(path.dirname(this.tracks.first.filePath!), 'Folder.jpg'))
        .existsSync())
      return File(
          path.join(path.dirname(this.tracks.first.filePath!), 'Folder.jpg'));
    else
      return File(path.join(configuration.cacheDirectory!.path, 'albumArts',
          'defaultAlbumArt' + '.PNG'));
  }

  @override
  Map<String, dynamic> toMap() => {
        'albumName': this.albumName,
        'year': this.year,
        'albumArtistName': this.albumArtistName,
        'tracks': this
            .tracks
            .map(
              (track) => track.toMap(),
            )
            .toList(),
        'networkAlbumArt': this.networkAlbumArt,
        'albumId': this.albumId,
      };

  static Album fromMap(Map<String, dynamic> map) => Album(
        albumName: map['albumName'] ?? 'Unknown Album',
        year: map['year'],
        albumArtistName: map['albumArtistName'] ?? 'Unknown Artist',
        networkAlbumArt: map['networkAlbumArt'],
        albumId: map['albumId'],
      );

  Album({
    this.albumName,
    this.year,
    this.albumArtistName,
    this.networkAlbumArt,
    this.albumId,
  });

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

  @override
  Map<String, dynamic> toMap() => {
        'artistName': this.artistName,
        'albums': this
            .albums
            .map(
              (album) => album.toMap(),
            )
            .toList(),
        'tracks': this
            .tracks
            .map(
              (track) => track.toMap(),
            )
            .toList(),
      };

  static Artist fromMap(Map<String, dynamic> artistMap) => Artist(
        artistName: artistMap['artistName'],
      );

  @override
  int compareTo(dynamic artist) {
    int result = -1;
    if (artist is Artist) {
      result = this.artistName!.compareTo(artist.artistName!);
    }
    return result;
  }

  Artist({
    this.artistName,
  });
}

class Playlist extends MediaType {
  String? playlistName;
  int? playlistId;
  List<Track> tracks = <Track>[];

  @override
  Map<String, dynamic> toMap() => {
        'playlistName': this.playlistName,
        'playlistId': this.playlistId,
        'tracks': this
            .tracks
            .map(
              (track) => track.toMap(),
            )
            .toList(),
      };

  Playlist({
    this.playlistName,
    this.playlistId,
  });
}
