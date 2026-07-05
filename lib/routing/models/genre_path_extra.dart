import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

class GenrePathExtra {
  final Genre genre;
  final List<Track> tracks;
  final List<Color>? palette;

  const GenrePathExtra({
    required this.genre,
    required this.tracks,
    required this.palette,
  });
}
