import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

class AlbumPathExtra {
  final Album album;
  final List<Track> tracks;
  final List<Color>? palette;

  const AlbumPathExtra({
    required this.album,
    required this.tracks,
    required this.palette,
  });
}
