import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/features/now_playing/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/features/media_library/artists/artist_image.dart';
import 'package:harmonoid/features/media_library/artists/artist_screen.dart';
import 'package:harmonoid/features/media_library/utils/rendering.dart';
import 'package:harmonoid/features/media_library/media_library_menus.dart';
import 'package:harmonoid/features/media_library/utils/constants.dart';
import 'package:harmonoid/routing/router.dart';
import 'package:harmonoid/routing/models/artist_path_extra.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/third_party/open_container.dart';
import 'package:harmonoid/third_party/palette_generator.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class ArtistItem extends StatefulWidget {
  final Artist artist;
  final double width;
  final double height;
  const ArtistItem({
    super.key,
    required this.artist,
    required this.width,
    required this.height,
  });

  @override
  State<ArtistItem> createState() => _ArtistItemState();
}

class _ArtistItemState extends State<ArtistItem> {
  String get _title => widget.artist.artist.isNotEmpty ? widget.artist.artist : kDefaultArtist;

  Future<void> navigate() async {
    final tracks = await context.read<MediaLibrary>().tracksFromArtist(widget.artist);
    final albums = await context.read<MediaLibrary>().albumsFromArtist(widget.artist);

    List<Color>? palette;
    if (isMaterial2) {
      final result = await PaletteGenerator.fromImageProvider(cover(item: widget.artist, cacheWidth: 20));
      palette = result.colors?.toList();
    }

    try {
      await precacheImage(cover(item: widget.artist), context);
    } catch (_) {}

    await context.push(
      '/$kMediaLibraryPath/$kArtistPath',
      extra: ArtistPathExtra(
        artist: widget.artist,
        tracks: tracks,
        albums: albums,
        palette: palette,
      ),
    );
  }

  Future<void> onSecondaryPress(BuildContext context, {RelativeRect? position}) async {
    tracks = await context.read<MediaLibrary>().tracksFromArtist(widget.artist);
    final tracksMenuProvider = TracksMenuProvider(context, tracks!);
    final result = await showMenuItems(context, await tracksMenuProvider.getPopupMenuItems(), position: position);
    await tracksMenuProvider.handlePopupMenuAction(result);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return ContextMenuListener(
      onSecondaryPress: (position) {
        onSecondaryPress(context, position: position);
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Column(
          children: [
            Hero(
              tag: widget.artist,
              child: Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: const CircleBorder(),
                child: Container(
                  width: widget.width,
                  height: widget.width,
                  padding: const EdgeInsets.all(4.0),
                  child: ClipOval(
                    child: Material(
                      color: Theme.of(context).cardTheme.color,
                      child: InkWell(
                        onTap: navigate,
                        child: ScaleOnHover(
                          child: SizedBox(
                            width: widget.width,
                            height: widget.width,
                            child: ArtistImage(
                              artist: widget.artist,
                              cacheWidth: (widget.width * MediaQuery.of(context).devicePixelRatio).toInt(),
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
                width: widget.width,
                alignment: Alignment.center,
                child: Text(
                  _title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    void onLongPress() {
      onSecondaryPress(context);
    }

    if (widget.width > widget.height) {
      return SizedBox(
        height: widget.height,
        child: InkWell(
          onTap: navigate,
          onLongPress: onLongPress,
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
                    width: widget.height - 1.0,
                    height: widget.height - 1.0,
                    alignment: Alignment.center,
                    color: Theme.of(context).cardTheme.color,
                    child: ArtistImage(
                      artist: widget.artist,
                      cacheWidth: ((widget.height - 1.0) * MediaQuery.of(context).devicePixelRatio).toInt(),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Text(
                      _title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    onPressed: onLongPress,
                    splashRadius: 20.0,
                    icon: const Icon(Icons.more_vert),
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final transitionDuration = Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          OpenContainer(
            navigatorKey: homeNavigatorKey,
            transitionDuration: transitionDuration,
            closedColor: Theme.of(context).cardTheme.color ?? Colors.transparent,
            closedShape: const CircleBorder(),
            closedElevation: Theme.of(context).cardTheme.elevation ?? 0.0,
            openColor: Theme.of(context).scaffoldBackgroundColor,
            openShape: const RoundedRectangleBorder(),
            openElevation: Theme.of(context).cardTheme.elevation ?? 0.0,
            onClosed: (data) {
              NowPlayingMobileNotifier.instance.showBottomNavigationBar();
              mediaLibraryArtistOpenContainerBuildContext = null;
            },
            closedBuilder: (context, action) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: onLongPress,
                child: Stack(
                  children: [
                    SizedBox(
                      width: widget.width,
                      height: widget.width,
                      child: ArtistImage(
                        artist: widget.artist,
                        cacheWidth: (widget.width * MediaQuery.of(context).devicePixelRatio).toInt(),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            if (transitionDuration == Duration.zero) {
                              navigate();
                              return;
                            }

                            if (isMaterial2) {
                              final result = await PaletteGenerator.fromImageProvider(cover(item: widget.artist, cacheWidth: 20));
                              palette = result.colors?.toList();
                            }

                            tracks = await context.read<MediaLibrary>().tracksFromArtist(widget.artist);
                            albums = await context.read<MediaLibrary>().albumsFromArtist(widget.artist);

                            await precacheImage(cover(item: widget.artist), context);

                            action();
                            context.read<NowPlayingMobileNotifier>().hideBottomNavigationBar();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            openBuilder: (context, _) {
              mediaLibraryArtistOpenContainerBuildContext = context;
              return ArtistScreen(
                artist: widget.artist,
                tracks: tracks!,
                albums: albums!,
                palette: palette,
              );
            },
          ),
          Expanded(
            child: Container(
              width: widget.width,
              alignment: Alignment.center,
              child: Text(
                _title,
                style: widget.height - widget.width > 24.0 ? Theme.of(context).textTheme.titleSmall : Theme.of(context).textTheme.bodyLarge,
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
  static List<Album>? albums;
  static List<Color>? palette;
}
