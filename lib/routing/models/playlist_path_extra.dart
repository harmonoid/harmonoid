import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

class PlaylistPathExtra {
  final Playlist playlist;
  final List<PlaylistEntry> entries;
  final List<Color>? palette;

  const PlaylistPathExtra({
    required this.playlist,
    required this.entries,
    required this.palette,
  });
}
