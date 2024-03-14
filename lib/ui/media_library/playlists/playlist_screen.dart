import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  final List<Track> tracks;
  final List<Color>? palette;
  const PlaylistScreen({super.key, required this.playlist, required this.tracks, this.palette});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
