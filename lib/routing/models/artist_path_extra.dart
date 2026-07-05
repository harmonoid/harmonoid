import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

class ArtistPathExtra {
  final Artist artist;
  final List<Track> tracks;
  final List<Album> albums;
  final List<Color>? palette;

  const ArtistPathExtra({
    required this.artist,
    required this.tracks,
    required this.albums,
    required this.palette,
  });
}
