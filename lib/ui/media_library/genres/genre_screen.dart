import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

class GenreScreen extends StatefulWidget {
  final Genre genre;
  final List<Track> tracks;
  final List<Color>? palette;
  const GenreScreen({super.key, required this.genre, required this.tracks, this.palette});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
