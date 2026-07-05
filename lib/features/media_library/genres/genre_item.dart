import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/features/now_playing/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/features/media_library/genres/constants.dart';
import 'package:harmonoid/features/media_library/genres/genre_screen.dart';
import 'package:harmonoid/features/media_library/utils/rendering.dart';
import 'package:harmonoid/features/media_library/media_library_menus.dart';
import 'package:harmonoid/routing/router.dart';
import 'package:harmonoid/routing/models/genre_path_extra.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/features/media_library/utils/constants.dart';
import 'package:harmonoid/third_party/open_container.dart';
import 'package:harmonoid/utils/rendering.dart';

class GenreItem extends StatefulWidget {
  final Genre genre;
  final double width;
  final double height;

  const GenreItem({
    super.key,
    required this.genre,
    required this.width,
    required this.height,
  });

  @override
  State<GenreItem> createState() => _GenreItemState();
}

class _GenreItemState extends State<GenreItem> {
  String get _title => widget.genre.genre.isNotEmpty ? widget.genre.genre : kDefaultGenre;
  Color get _color => kGenreColors[widget.genre.genre.hashCode % kGenreColors.length];

  Future<void> navigate() async {
    final tracks = await context.read<MediaLibrary>().tracksFromGenre(widget.genre);

    try {
      await precacheImage(cover(item: widget.genre), context);
    } catch (_) {}

    await context.push(
      '/$kMediaLibraryPath/$kGenrePath',
      extra: GenrePathExtra(
        genre: widget.genre,
        tracks: tracks,
        palette: palette,
      ),
    );
  }

  Future<void> onSecondaryPress(BuildContext context, {RelativeRect? position}) async {
    tracks = await context.read<MediaLibrary>().tracksFromGenre(widget.genre);
    final tracksMenuProvider = TracksMenuProvider(context, tracks!);
    final result = await showMenuItems(context, await tracksMenuProvider.getPopupMenuItems(), position: position);
    await tracksMenuProvider.handlePopupMenuAction(result);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return ContextMenuListener(
      onSecondaryPress: (position) {
        onSecondaryPress(context, position: position);
      },
      child: Hero(
        tag: widget.genre,
        child: Card(
          margin: EdgeInsets.zero,
          color: _color,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: navigate,
            child: Container(
              width: widget.width,
              height: widget.height,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: AutoSizeText(
                _title,
                maxLines: 3,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                wrapWords: false,
              ),
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
                    color: _color,
                    width: widget.height - 1.0,
                    height: widget.height - 1.0,
                    alignment: Alignment.center,
                    child: Text(
                      _title[0],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
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

    return Hero(
      tag: widget.genre,
      child: OpenContainer(
        navigatorKey: homeNavigatorKey,
        transitionDuration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
        closedColor: _color,
        closedShape: Theme.of(context).cardTheme.shape ?? const RoundedRectangleBorder(),
        closedElevation: Theme.of(context).cardTheme.elevation ?? 0.0,
        openColor: _color,
        openElevation: Theme.of(context).cardTheme.elevation ?? 0.0,
        clipBehavior: Clip.antiAlias,
        onClosed: (data) {
          NowPlayingMobileNotifier.instance.showBottomNavigationBar();
        },
        closedBuilder: (context, action) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: onLongPress,
          child: InkWell(
            onTap: () async {
              if (transitionDuration == Duration.zero) {
                navigate();
                return;
              }

              tracks = await context.read<MediaLibrary>().tracksFromGenre(widget.genre);

              await precacheImage(cover(item: widget.genre), context);

              action();
              context.read<NowPlayingMobileNotifier>().hideBottomNavigationBar();
              mediaLibraryGenreOpenContainerBuildContext = null;
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AutoSizeText(
                _title,
                maxLines: 3,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                wrapWords: false,
                style: (() {
                  if (widget.width > 128.0) {
                    return Theme.of(context).textTheme.titleLarge;
                  }
                  if (widget.width > 84.0) {
                    return Theme.of(context).textTheme.titleMedium;
                  }
                  return Theme.of(context).textTheme.titleSmall;
                }())?.copyWith(color: _color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
              ),
            ),
          ),
        ),
        openBuilder: (context, action) {
          mediaLibraryGenreOpenContainerBuildContext = context;
          return GenreScreen(
            genre: widget.genre,
            tracks: tracks!,
            palette: palette,
          );
        },
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
