import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/ui/media_library/artists/artist_screen.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/open_container.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class ArtistItem extends StatelessWidget {
  final Artist artist;
  final double width;
  final double height;
  ArtistItem({
    super.key,
    required this.artist,
    required this.width,
    required this.height,
  });

  late final title = artist.artist.isNotEmpty ? artist.artist : kDefaultArtist;

  Future<void> navigate() async {
    final tracks = await MediaLibrary.instance.tracksFromArtist(artist);

    List<Color>? palette;
    if (isMaterial2) {
      final result = await PaletteGenerator.fromImageProvider(cover(item: artist, cacheWidth: 20));
      palette = result.colors?.toList();
    }

    try {
      await precacheImage(cover(item: artist), rootNavigatorKey.currentContext!);
    } catch (_) {}

    await rootNavigatorKey.currentContext!.push(
      '/$kMediaLibraryPath/$kArtistPath',
      extra: ArtistPathExtra(
        artist: artist,
        tracks: tracks,
        palette: palette,
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          Hero(
            tag: artist,
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: const CircleBorder(),
              child: Container(
                width: width,
                height: width,
                padding: const EdgeInsets.all(4.0),
                child: ClipOval(
                  child: Material(
                    child: InkWell(
                      onTap: navigate,
                      child: ScaleOnHover(
                        child: Ink.image(
                          width: width,
                          height: width,
                          fit: BoxFit.cover,
                          image: cover(
                            item: artist,
                            cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: width,
              alignment: Alignment.center,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
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
          onTap: navigate,
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
                  Image(
                    width: height - 1.0,
                    height: height - 1.0,
                    image: cover(
                      item: artist,
                      cacheWidth: (kMobileHeaderHeight * MediaQuery.of(context).devicePixelRatio).toInt(),
                    ),
                    fit: BoxFit.cover,
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

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          OpenContainer(
            navigatorKey: homeNavigatorKey,
            transitionDuration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
            closedColor: Theme.of(context).cardTheme.color ?? Colors.transparent,
            closedShape: const CircleBorder(),
            closedElevation: Theme.of(context).cardTheme.elevation ?? 0.0,
            openElevation: Theme.of(context).cardTheme.elevation ?? 0.0,
            closedBuilder: (context, action) {
              return Stack(
                children: [
                  Container(
                    width: width,
                    height: width,
                    padding: const EdgeInsets.all(4.0),
                    child: ClipOval(
                      child: Image(
                        width: width,
                        height: width,
                        fit: BoxFit.cover,
                        image: cover(
                          item: artist,
                          cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          tracks = await MediaLibrary.instance.tracksFromArtist(artist);

                          if (isMaterial2) {
                            final result = await PaletteGenerator.fromImageProvider(cover(item: artist, cacheWidth: 20));
                            palette = result.colors?.toList();
                          }

                          await precacheImage(cover(item: artist), context);

                          action();
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            openBuilder: (context, _) => ArtistScreen(
              artist: artist,
              tracks: tracks!,
              palette: palette,
            ),
          ),
          Expanded(
            child: Container(
              width: width,
              alignment: Alignment.center,
              child: Text(
                title,
                style: height - width > 24.0 ? Theme.of(context).textTheme.titleSmall : Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
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
    throw UnimplementedError();
  }

  static List<Track>? tracks;
  static List<Color>? palette;
}
