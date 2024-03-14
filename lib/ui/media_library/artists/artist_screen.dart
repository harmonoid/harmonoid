import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

class ArtistScreen extends StatefulWidget {
  final Artist artist;
  final List<Track> tracks;
  final List<Color>? palette;
  const ArtistScreen({super.key, required this.artist, required this.tracks, this.palette});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
