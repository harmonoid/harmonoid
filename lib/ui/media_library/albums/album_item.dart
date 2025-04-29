import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/extensions/album.dart';
import 'package:harmonoid/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/ui/media_library/albums/album_screen.dart';
import 'package:harmonoid/ui/media_library/media_library_flags.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/open_container.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class AlbumItem extends StatelessWidget {
  final Album album;
  final double width;
  final double height;

  const AlbumItem({
    super.key,
    required this.album,
    required this.width,
    required this.height,
  });

  Future<void> navigate() async {
    final tracks = await MediaLibrary.instance.tracksFromAlbum(album);

    List<Color>? palette;
    if (isMaterial2) {
      final result = await PaletteGenerator.fromImageProvider(cover(item: album, cacheWidth: 20));
      palette = result.colors?.toList();
    }

    try {
      await precacheImage(cover(item: album), rootNavigatorKey.currentContext!);
    } catch (_) {}

    await rootNavigatorKey.currentContext!.push(
      '/$kMediaLibraryPath/$kAlbumPath',
      extra: AlbumPathExtra(
        album: album,
        tracks: tracks,
        palette: palette,
      ),
    );
  }

  Future<void> onSecondaryPress(BuildContext context, {RelativeRect? position}) async {
    final result = await showMenuItems(context, albumPopupMenuItems(context, album), position: position);
    await albumPopupMenuHandle(context, album, result);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return ContextMenuListener(
      onSecondaryPress: (position) {
        onSecondaryPress(context, position: position);
      },
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: navigate,
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              children: [
                Hero(
                  tag: album,
                  child: SizedBox(
                    width: width,
                    height: width,
                    child: ScaleOnHover(
                      child: Image(
                        width: width,
                        height: width,
                        fit: BoxFit.cover,
                        image: cover(
                          item: album,
                          cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: width,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.displayTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (album.displaySubtitle.isNotEmpty)
                          Text(
                            album.displaySubtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
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
    void onLongPress() {
      onSecondaryPress(context);
    }

    if (width >= height) {
      return SizedBox(
        height: height,
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
                  Image(
                    width: height - 1.0,
                    height: height - 1.0,
                    image: cover(
                      item: album,
                      cacheWidth: (kMobileHeaderHeight * MediaQuery.of(context).devicePixelRatio).toInt(),
                    ),
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.displayTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (album.displaySubtitle.isNotEmpty)
                          Text(
                            album.displaySubtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
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

    return OpenContainer(
      navigatorKey: homeNavigatorKey,
      transitionDuration: transitionDuration,
      closedColor: Theme.of(context).cardTheme.color ?? Colors.transparent,
      closedShape: Theme.of(context).cardTheme.shape ?? const RoundedRectangleBorder(),
      closedElevation: Theme.of(context).cardTheme.elevation ?? 0.0,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      openShape: const RoundedRectangleBorder(),
      openElevation: Theme.of(context).cardTheme.elevation ?? 0.0,
      tappable: false,
      onClosed: (data) {
        NowPlayingMobileNotifier.instance.showBottomNavigationBar();
        mediaLibraryAlbumOpenContainerBuildContext = null;
      },
      closedBuilder: (context, action) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            if (transitionDuration == Duration.zero) {
              navigate();
              return;
            }

            tracks = await MediaLibrary.instance.tracksFromAlbum(album);

            if (isMaterial2) {
              final result = await PaletteGenerator.fromImageProvider(cover(item: album, cacheWidth: 20));
              palette = result.colors?.toList();
            }

            await precacheImage(cover(item: album), context);

            action();
            context.read<NowPlayingMobileNotifier>().hideBottomNavigationBar();
          },
          onLongPress: onLongPress,
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              children: [
                SizedBox(
                  width: width,
                  height: width,
                  child: Ink.image(
                    width: width,
                    height: width,
                    fit: BoxFit.cover,
                    image: cover(
                      item: album,
                      cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: width,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (height - width >= 56.0) ...[
                          Text(
                            album.displayTitle,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (album.displaySubtitle.isNotEmpty)
                            Text(
                              album.displaySubtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ] else if (height - width >= 32.0) ...[
                          Text(
                            album.displayTitle,
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      openBuilder: (context, _) {
        mediaLibraryAlbumOpenContainerBuildContext = context;
        return AlbumScreen(
          album: album,
          tracks: tracks!,
          palette: palette,
        );
      },
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
