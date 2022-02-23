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

class Playlist extends Media {
  String name;
  int id;
  final List<Track> tracks = <Track>[];

  @override
  Map<String, dynamic> toJson() => {
        'name': this.name,
        'id': this.id,
        'tracks': this.tracks.map((track) => track.toJson()).toList(),
      };

  factory Playlist.fromJson(dynamic json) => Playlist(
        id: json['id'],
        name: json['name'],
      )..tracks.addAll(json['tracks'] != null
          ? (json['tracks'] as List).map((e) => Track.fromJson(e))
          : []);

  Playlist({
    required this.name,
    required this.id,
  });
}
