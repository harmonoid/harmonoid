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
