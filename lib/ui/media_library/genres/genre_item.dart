import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/ui/media_library/genres/constants.dart';
import 'package:harmonoid/utils/constants.dart';

class GenreItem extends StatelessWidget {
  final Genre genre;
  final double width;
  final double height;
  GenreItem({
    super.key,
    required this.genre,
    required this.width,
    required this.height,
  });

  late final title = genre.genre.isNotEmpty ? genre.genre : kDefaultGenre;

  @override
  Widget build(BuildContext context) {
    final color = kGenreColors[genre.genre.hashCode % kGenreColors.length];
    return Hero(
      tag: genre,
      child: Card(
        margin: EdgeInsets.zero,
        color: color,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // TODO:
          },
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
