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
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

part of 'media.dart';

class Album extends Media {
  String albumName;
  String year;
  String albumArtistName;
  final tracks = <Track>[];

  @override
  Map<String, dynamic> toJson() => {
        'albumName': this.albumName,
        'year': this.year,
        'albumArtistName': this.albumArtistName,
        'tracks': this.tracks.map((track) => track.toJson()).toList(),
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
      return media.albumName == this.albumName &&
          media.albumArtistName == this.albumArtistName &&
          media.year == this.year;
    }
    throw FormatException();
  }

  @override
  int get hashCode =>
      this.albumName.hashCode ^
      this.albumArtistName.hashCode ^
      this.year.hashCode;

  DateTime get timeAdded => this.tracks.reduce((value, element) {
        if (element.timeAdded.millisecondsSinceEpoch >
            value.timeAdded.millisecondsSinceEpoch) return value;
        return element;
      }).timeAdded;
}
