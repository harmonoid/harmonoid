/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
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
