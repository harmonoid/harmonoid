/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

part of 'media.dart';

class Album extends Media {
  String albumName;
  String year;
  String albumArtistName;
  final tracks = <Track>[];

  @override
  Map<String, dynamic> toJson() => {
        'albumName': albumName,
        'year': year,
        'albumArtistName': albumArtistName,
        'tracks': tracks.map((track) => track.toJson()).toList(),
      };

  factory Album.fromJson(dynamic json) => Album(
        albumName: json['albumName'] ?? kUnknownAlbum,
        year: json['year'] ?? kUnknownYear,
        albumArtistName: json['albumArtistName'] ?? kUnknownArtist,
      )..tracks.addAll(
          json['tracks'] != null
              ? (json['tracks'] as List).map((e) => Track.fromJson(e))
              : [],
        );

  Album({
    required this.albumName,
    required this.year,
    required this.albumArtistName,
  });

  @override
  bool operator ==(Object media) {
    if (media is Album) {
      return media.albumName == albumName &&
          media.albumArtistName == albumArtistName &&
          media.year == year;
    }
    throw FormatException();
  }

  @override
  int get hashCode =>
      albumName.hashCode ^ albumArtistName.hashCode ^ year.hashCode;

  DateTime get timeAdded => tracks.reduce((value, element) {
        if (element.timeAdded.millisecondsSinceEpoch >
            value.timeAdded.millisecondsSinceEpoch) return value;
        return element;
      }).timeAdded;
}
