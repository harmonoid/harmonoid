import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' as media;
import 'package:url_launcher/url_launcher.dart';
import 'package:window_plus/window_plus.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:extended_image/extended_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

import 'package:harmonoid/web/track.dart';
import 'package:harmonoid/web/utils/widgets.dart';
import 'package:harmonoid/web/state/parser.dart';
import 'package:harmonoid/web/state/web.dart';

class WebPlaylistLargeTile extends StatelessWidget {
  final double width;
  final double height;
  final Playlist playlist;
  const WebPlaylistLargeTile({
    Key? key,
    required this.playlist,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () async {
          playlist.tracks = [];
          playlist.continuation = null;
          final thumbnails = playlist.thumbnails.values.toList();
          precacheImage(
            ExtendedNetworkImageProvider(thumbnails[thumbnails.length - 2],
                cache: true),
            context,
          );
          Navigator.of(context).push(
            MaterialRoute(
              builder: (context) => WebPlaylistScreen(
                playlist: playlist,
              ),
            ),
          );
        },
        child: Container(
          height: height,
          width: width,
          child: Column(
            children: [
              ClipRect(
                child: ScaleOnHover(
                  child: Hero(
                    tag: 'album_art_${playlist.id}',
                    child: ExtendedImage(
                      image: ExtendedNetworkImageProvider(
                        playlist.thumbnails.values.skip(1).first,
                        cache: true,
                      ),
                      fit: BoxFit.cover,
                      height: width,
                      width: width,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  width: width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name.overflow,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.left,
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
    );
  }
}

class WebPlaylistTile extends StatelessWidget {
  final Playlist playlist;
  const WebPlaylistTile({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          playlist.tracks = [];
          playlist.continuation = null;
          final thumbnails = playlist.thumbnails.values.toList();
          precacheImage(
            ExtendedNetworkImageProvider(thumbnails[thumbnails.length - 2],
                cache: true),
            context,
          );
          Navigator.of(context).push(
            MaterialRoute(
              builder: (context) => WebPlaylistScreen(
                playlist: playlist,
              ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 64.0,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 12.0),
                  ExtendedImage(
                    image: NetworkImage(
                      playlist.thumbnails.values.first,
                    ),
                    height: 56.0,
                    width: 56.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name.overflow,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          Language.instance.PLAYLIST_SINGLE,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  const SizedBox(width: 64.0, height: 64.0),
                ],
              ),
            ),
            const Divider(height: 1.0, indent: 80.0),
          ],
        ),
      ),
    );
  }
}

class WebPlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  const WebPlaylistScreen({
    Key? key,
    required this.playlist,
  }) : super(key: key);
  WebPlaylistScreenState createState() => WebPlaylistScreenState();
}

class WebPlaylistScreenState extends State<WebPlaylistScreen>
    with SingleTickerProviderStateMixin {
  Color? color;
  double elevation = 0.0;
  PagingController<int, Track?> pagingController =
      PagingController(firstPageKey: 0);
  int last = 0;
  ScrollController scrollController = ScrollController();
  Color? secondary;
  int? hovered;
  bool reactToSecondaryPress = false;
  bool detailsVisible = false;
  bool detailsLoaded = false;
  ScrollPhysics? physics = NeverScrollableScrollPhysics();

  bool isDark(BuildContext context) {
    final fallback =
        Theme.of(context).brightness == Brightness.dark ? 0.0 : 1.0;
    return (color?.computeLuminance() ?? fallback) < 0.5;
  }

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener((pageKey) async {
      if (pageKey == 0) {
        pagingController.appendPage([null], 1);
      } else {
        last = widget.playlist.tracks.length;
        await YTMClient.playlist(widget.playlist);
        widget.playlist.tracks.asMap().entries.forEach((element) {
          element.value.trackNumber = element.key + 1;
        });
        if (widget.playlist.continuation != '') {
          pagingController.appendPage(
            widget.playlist.tracks.skip(last).toList(),
            pageKey + 1,
          );
        } else {
          pagingController.appendLastPage(
            widget.playlist.tracks.skip(last).toList(),
          );
        }
      }
    });
    widget.playlist.tracks.sort(
      (first, second) => first.trackNumber.compareTo(second.trackNumber),
    );
    Timer(
      Duration(milliseconds: 300),
      () {
        PaletteGenerator.fromImageProvider(ExtendedNetworkImageProvider(
                widget.playlist.thumbnails.values.first))
            .then((palette) {
          setState(() {
            if (palette.colors != null) {
              color = palette.colors!.first;
            }
          });
        });
      },
    );
    scrollController.addListener(() {
      if (scrollController.offset.isZero) {
        setState(() {
          elevation = 0.0;
        });
      } else if (elevation == 0.0) {
        setState(() {
          elevation = 4.0;
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            PagedListView(
              scrollController: scrollController,
              pagingController: pagingController,
              padding: EdgeInsets.only(
                top: WindowPlus.instance.captionHeight + kDesktopAppBarHeight,
              ),
              builderDelegate: PagedChildBuilderDelegate<Track?>(
                newPageProgressIndicatorBuilder: (_) => Container(
                  height: 96.0,
                  child: Center(
                    child: const CircularProgressIndicator(),
                  ),
                ),
                firstPageProgressIndicatorBuilder: (_) => Center(
                  child: const CircularProgressIndicator(),
                ),
                itemBuilder: (context, track, pageKey) => pageKey == 0
                    ? TweenAnimationBuilder(
                        tween: ColorTween(
                          begin: Theme.of(context).appBarTheme.backgroundColor,
                          end: color == null
                              ? Theme.of(context).appBarTheme.backgroundColor
                              : color!,
                        ),
                        curve: Curves.easeOut,
                        duration: Theme.of(context)
                                .extension<AnimationDuration>()
                                ?.medium ??
                            Duration.zero,
                        builder: (context, color, _) => Transform.translate(
                          offset: Offset(0, -8.0),
                          child: Material(
                            color: color as Color? ?? Colors.transparent,
                            elevation: elevation == 0.0 ? 4.0 : 0.0,
                            borderRadius: BorderRadius.zero,
                            child: Container(
                              height: 312.0,
                              child: Row(
                                children: [
                                  const SizedBox(width: 56.0),
                                  Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: () {
                                      final thumbnails = widget
                                          .playlist.thumbnails.values
                                          .toList();
                                      return Hero(
                                        tag:
                                            'playlist_art_${widget.playlist.name}',
                                        child: Card(
                                          color: Colors.white,
                                          elevation: 4.0,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: ExtendedImage(
                                                  image:
                                                      ExtendedNetworkImageProvider(
                                                    thumbnails[
                                                        thumbnails.length - 2],
                                                    cache: true,
                                                  ),
                                                  height: 256.0,
                                                  width: 256.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }(),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.playlist.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  color: isDark(context)
                                                      ? Theme.of(context)
                                                          .extension<
                                                              TextColors>()
                                                          ?.darkPrimary
                                                      : Theme.of(context)
                                                          .extension<
                                                              TextColors>()
                                                          ?.lightPrimary,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 16.0),
                                          Row(
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  Web.instance.open(
                                                    widget.playlist.tracks,
                                                  );
                                                },
                                                style: ButtonStyle(
                                                  elevation:
                                                      MaterialStatePropertyAll(
                                                    0.0,
                                                  ),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    isDark(context)
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  padding:
                                                      MaterialStatePropertyAll(
                                                    const EdgeInsets.all(12.0),
                                                  ),
                                                ),
                                                icon: Icon(
                                                  Icons.play_arrow,
                                                  color: !isDark(context)
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                                label: Text(
                                                  label(
                                                    context,
                                                    Language.instance.PLAY_NOW,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: !isDark(context)
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8.0),
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  Collection.instance
                                                      .playlistCreate(
                                                    media.Playlist(
                                                      id: widget.playlist.name
                                                          .hashCode,
                                                      name:
                                                          widget.playlist.name,
                                                    )..tracks.addAll(
                                                        widget.playlist.tracks
                                                            .map(
                                                          (e) => Parser.track(
                                                            e,
                                                          ),
                                                        ),
                                                      ),
                                                  );
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  // ignore: deprecated_member_use
                                                  primary: Colors.white,
                                                  side: BorderSide(
                                                    color: isDark(context)
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    12.0,
                                                  ),
                                                ),
                                                icon: Icon(
                                                  Icons.playlist_add,
                                                  color: isDark(context)
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                                label: Text(
                                                  label(
                                                    context,
                                                    Language.instance
                                                        .SAVE_AS_PLAYLIST,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: isDark(context)
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8.0),
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  launchUrl(
                                                    Uri.parse(
                                                        'https://music.youtube.com/browse/${widget.playlist.id}'),
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  );
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  // ignore: deprecated_member_use
                                                  primary: Colors.white,
                                                  side: BorderSide(
                                                    color: isDark(context)
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  padding: EdgeInsets.all(12.0),
                                                ),
                                                icon: Icon(
                                                  Icons.open_in_new,
                                                  color: isDark(context)
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                                label: Text(
                                                  label(
                                                    context,
                                                    Language.instance
                                                        .OPEN_IN_BROWSER,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: isDark(context)
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 56.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : WebTrackTile(
                        track: track!,
                        group: widget.playlist.tracks,
                      ),
              ),
            ),
            TweenAnimationBuilder(
              tween: ColorTween(
                begin: Theme.of(context).appBarTheme.backgroundColor,
                end: color == null
                    ? Theme.of(context).appBarTheme.backgroundColor
                    : color!,
              ),
              curve: Curves.easeOut,
              duration:
                  Theme.of(context).extension<AnimationDuration>()?.medium ??
                      Duration.zero,
              builder: (context, color, _) => Theme(
                data: createM2Theme(
                  color: isDark(context)
                      ? kDefaultDarkPrimaryColorM2
                      : kDefaultLightPrimaryColorM2,
                  mode: isDark(context) ? ThemeMode.dark : ThemeMode.light,
                ),
                child: DesktopAppBar(
                  elevation: elevation,
                  color: color as Color? ?? Colors.transparent,
                  child: Row(
                    children: [
                      Text(
                        elevation != 0.0 ? widget.playlist.name : '',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isDark(context)
                                      ? Theme.of(context)
                                          .extension<TextColors>()
                                          ?.darkPrimary
                                      : Theme.of(context)
                                          .extension<TextColors>()
                                          ?.lightPrimary,
                                ),
                      ),
                      Spacer(),
                      WebSearchBar(),
                      SizedBox(
                        width: 8.0,
                      ),
                      Material(
                        color: Colors.transparent,
                        child: Tooltip(
                          message: Language.instance.SETTING,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialRoute(
                                  builder: (context) => Settings(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              child: Icon(
                                Icons.settings,
                                size: 20.0,
                                color: isDark(context)
                                    ? Theme.of(context)
                                        .extension<IconColors>()
                                        ?.appBarActionDark
                                    : Theme.of(context)
                                        .extension<IconColors>()
                                        ?.appBarActionLight,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
