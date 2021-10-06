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
import 'package:path/path.dart' as path;

import 'package:harmonoid/core/configuration.dart';

/// Media
/// -----
///
abstract class Media with Comparable {
  @override
  int compareTo(dynamic track) => -1;

  Map<String, dynamic> toMap();
}

/// Track
/// -----
///
class Track extends Media {
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
  int? timeAdded;
  dynamic extras;
  File get albumArt {
    var albumArt = File(path.join(
      configuration.cacheDirectory!.path,
      'AlbumArts',
      this.albumArtBasename,
    ));
    if (albumArt.existsSync())
      return albumArt;
    else if (File(path.join(path.dirname(this.filePath!), 'cover.jpg'))
        .existsSync())
      return File(path.join(path.dirname(this.filePath!), 'cover.jpg'));
    else if (File(path.join(path.dirname(this.filePath!), 'Folder.jpg'))
        .existsSync())
      return File(path.join(path.dirname(this.filePath!), 'Folder.jpg'));
    else
      return File(path.join(
          configuration.cacheDirectory!.path, 'AlbumArts', 'UnknownAlbum.PNG'));
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
      'timeAdded': this.timeAdded,
    };
  }

  factory Track.fromMap(Map<String, dynamic> map) => Track(
        trackName: [null, ''].contains(map['trackName'])
            ? path.basename(map['filePath'])
            : map['trackName'],
        albumName: [null, ''].contains(map['albumName'])
            ? 'Unknown Album'
            : map['albumName'],
        trackNumber: map['trackNumber'],
        year: map['year'],
        albumArtistName: [null, ''].contains(map['albumArtistName'])
            ? 'Unknown Artist'
            : map['albumArtistName'],
        trackArtistNames:
            (map['trackArtistNames'] ?? <String>['Unknown Artist'])
                .cast<String>(),
        filePath: map['filePath'],
        networkAlbumArt: map['networkAlbumArt'],
        trackDuration: map['trackDuration'],
        bitrate: map['bitrate'],
        trackId: map['trackId'],
        albumId: map['albumId'],
        timeAdded: map.containsKey('filePath') &&
                !(map['filePath']?.startsWith('http') ?? true) &&
                File(map['filePath']).existsSync()
            ? File(map['filePath']).lastModifiedSync().millisecondsSinceEpoch
            : 0,
      );

  @override
  int compareTo(dynamic track) {
    if (track is Track) {
      return this.trackName!.compareTo(track.trackName!).abs() +
          this.albumArtistName!.compareTo(track.albumArtistName!).abs();
    }
    return -1;
  }

  String get albumArtBasename =>
      '${this.albumName}${this.albumArtistName}'
          .replaceAll(RegExp(r'[\\/:*?""<>| ]'), '') +
      '.PNG';

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
    this.timeAdded,
  });
}

/// Album
/// -----
///
class Album extends Media {
  String? albumName;
  int? year;
  String? albumArtistName;
  List<Track> tracks = <Track>[];
  String? networkAlbumArt;
  String? albumId;
  File get albumArt {
    var albumArt = File(path.join(
      configuration.cacheDirectory!.path,
      'AlbumArts',
      this.albumArtBasename,
    ));
    if (albumArt.existsSync())
      return albumArt;
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
      return File(path.join(
          configuration.cacheDirectory!.path, 'AlbumArts', 'UnknownAlbum.PNG'));
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

  int get timeAdded =>
      this.tracks.reduce((value, element) {
        if ((element.timeAdded ?? 0) > (value.timeAdded ?? 0)) return value;
        return element;
      }).timeAdded ??
      0;

  factory Album.fromMap(Map<String, dynamic> map) => Album(
        albumName: map['albumName'] ?? 'Unknown Album',
        year: map['year'],
        albumArtistName: map['albumArtistName'] ?? 'Unknown Artist',
        networkAlbumArt: map['networkAlbumArt'],
        albumId: map['albumId'],
      );

  String get albumArtBasename =>
      '${this.albumName}${this.albumArtistName}'
          .replaceAll(RegExp(r'[\\/:*?""<>| ]'), '') +
      '.PNG';

  Album({
    this.albumName,
    this.year,
    this.albumArtistName,
    this.networkAlbumArt,
    this.albumId,
  });

  @override
  int compareTo(dynamic album) {
    if (album is Album) {
      return this.albumName!.compareTo(album.albumName!).abs() +
          this.albumArtistName!.compareTo(album.albumArtistName!).abs();
    }
    return -1;
  }
}

/// Artist
/// ------
///
class Artist extends Media {
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

  int get timeAdded =>
      this.tracks.reduce((value, element) {
        if ((element.timeAdded ?? 0) > (value.timeAdded ?? 0)) return value;
        return element;
      }).timeAdded ??
      0;

  factory Artist.fromMap(Map<String, dynamic> artistMap) => Artist(
        artistName: artistMap['artistName'],
      );

  @override
  int compareTo(dynamic artist) {
    if (artist is Artist) {
      return this.artistName!.compareTo(artist.artistName!);
    }
    return -1;
  }

  Artist({
    this.artistName,
  });
}

/// Playlist
/// --------
///
class Playlist extends Media {
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
