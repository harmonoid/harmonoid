import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/ui/media_library/genres/constants.dart';
import 'package:harmonoid/ui/media_library/genres/genre_screen.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/open_container.dart';
import 'package:harmonoid/utils/rendering.dart';

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
  late final color = kGenreColors[genre.genre.hashCode % kGenreColors.length];

  Future<void> navigate(BuildContext context) async {
    final tracks = await MediaLibrary.instance.tracksFromGenre(genre);

    await precacheImage(cover(item: genre), context);

    await context.push(
      '/$kMediaLibraryPath/$kGenrePath',
      extra: GenrePathExtra(
        genre: genre,
        tracks: tracks,
        palette: palette,
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Hero(
      tag: genre,
      child: Card(
        margin: EdgeInsets.zero,
        color: color,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            navigate(context);
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

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    if (width > height) {
      return SizedBox(
        height: height,
        child: InkWell(
          onTap: () {
            navigate(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Divider(height: 1.0),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    color: color,
                    width: height - 1.0,
                    height: height - 1.0,
                    alignment: Alignment.center,
                    child: Text(
                      title[0],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Hero(
      tag: genre,
      child: OpenContainer(
        navigatorKey: rootNavigatorKey,
        transitionDuration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
        closedColor: color,
        closedShape: Theme.of(context).cardTheme.shape ?? const RoundedRectangleBorder(),
        closedElevation: Theme.of(context).cardTheme.elevation ?? 0.0,
        openColor: color,
        openElevation: Theme.of(context).cardTheme.elevation ?? 0.0,
        clipBehavior: Clip.antiAlias,
        closedBuilder: (context, action) => InkWell(
          onTap: () async {
            tracks = await MediaLibrary.instance.tracksFromGenre(genre);

            await precacheImage(cover(item: genre), context);

            action();
          },
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: (() {
                if (width > 128.0) {
                  return Theme.of(context).textTheme.titleLarge;
                }
                if (width > 84.0) {
                  return Theme.of(context).textTheme.titleMedium;
                }
                return Theme.of(context).textTheme.titleSmall;
              }())
                  ?.copyWith(color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
            ),
          ),
        ),
        openBuilder: (context, action) => GenreScreen(
          genre: genre,
          tracks: tracks!,
          palette: palette,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    return throw UnimplementedError();
  }

  static List<Track>? tracks;
  static List<Color>? palette = [Colors.white, Color.lerp(Colors.white, Colors.black, 0.54)!];
}
