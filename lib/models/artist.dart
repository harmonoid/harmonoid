/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///

part of 'media.dart';

class Artist extends Media {
  final String artistName;
  final tracks = <Track>[];
  final albums = <Album>[];

  @override
  Map<String, dynamic> toJson() => {
        'artistName': artistName,
        'albums': albums.map((album) => album.toJson()).toList(),
        'tracks': tracks.map((track) => track.toJson()).toList(),
      };

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
        artistName: json['artistName'] ?? kUnknownArtist,
      )
        ..tracks.addAll(
          json['tracks'] != null
              ? (json['tracks'] as List).map((e) => Track.fromJson(e))
              : [],
        )
        ..albums.addAll(
          json['tracks'] != null
              ? (json['tracks'] as List).map((e) => Album.fromJson(e))
              : [],
        );

  Artist({
    required this.artistName,
  });

  @override
  bool operator ==(Object media) {
    if (media is Artist) {
      return media.artistName == artistName;
    }
    throw FormatException();
  }

  @override
  int get hashCode => artistName.hashCode;

  DateTime get timeAdded => tracks.reduce((value, element) {
        if (element.timeAdded.millisecondsSinceEpoch >
            value.timeAdded.millisecondsSinceEpoch) return value;
        return element;
      }).timeAdded;
}
