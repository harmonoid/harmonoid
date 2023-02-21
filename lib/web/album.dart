import 'dart:async';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:window_plus/window_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:extended_image/extended_image.dart';
import 'package:media_library/media_library.dart' as media;

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/interface/settings/settings.dart';

import 'package:harmonoid/web/track.dart';
import 'package:harmonoid/web/state/web.dart';
import 'package:harmonoid/web/state/parser.dart';
import 'package:harmonoid/web/utils/widgets.dart';

import 'package:harmonoid/constants/language.dart';

class WebAlbumLargeTile extends StatelessWidget {
  final double width;
  final double height;
  final Album album;
  const WebAlbumLargeTile({
    Key? key,
    required this.album,
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
          if (album.tracks.isEmpty) {
            await Future.wait(
              [
                YTMClient.album(album),
                precacheImage(
                  ExtendedNetworkImageProvider(
                    album.thumbnails.values.last,
                    cache: true,
                  ),
                  context,
                ),
              ],
            );
          }
          Navigator.of(context).push(
            MaterialRoute(
              builder: (context) => WebAlbumScreen(
                album: album,
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
                    tag:
                        'album_art_${album.albumName}_${album.year}_${album.id}',
                    child: ExtendedImage(
                      image: ExtendedNetworkImageProvider(
                          album.thumbnails.values.skip(1).first,
                          cache: true),
                      fit: BoxFit.cover,
                      height: width,
                      width: width,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  width: width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.albumName.overflow,
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          [
                            if (album.albumArtistName.isNotEmpty)
                              album.albumArtistName.overflow,
                            if (album.year.isNotEmpty) album.year.overflow,
                          ].join(' • '),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
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

class WebAlbumTile extends StatelessWidget {
  final Album album;
  const WebAlbumTile({
    Key? key,
    required this.album,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (album.tracks.isEmpty) {
            await Future.wait(
              [
                YTMClient.album(album),
                precacheImage(
                  ExtendedNetworkImageProvider(
                    album.thumbnails.values.last,
                    cache: true,
                  ),
                  context,
                ),
              ],
            );
          }
          Navigator.of(context).push(
            MaterialRoute(
              builder: (context) => WebAlbumScreen(
                album: album,
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
                      album.thumbnails.values.first,
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
                          album.albumName.overflow,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),
                        Text(
                          [
                            Language.instance.ALBUM_SINGLE,
                            if (album.albumArtistName.isNotEmpty)
                              album.albumArtistName,
                            if (album.year.isNotEmpty) album.year
                          ].join(' • '),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Container(
                    width: 64.0,
                    height: 64.0,
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1.0,
              indent: 80.0,
            ),
          ],
        ),
      ),
    );
  }
}

class WebAlbumScreen extends StatefulWidget {
  final Album album;
  const WebAlbumScreen({
    Key? key,
    required this.album,
  }) : super(key: key);
  WebAlbumScreenState createState() => WebAlbumScreenState();
}

class WebAlbumScreenState extends State<WebAlbumScreen>
    with SingleTickerProviderStateMixin {
  Color? color;
  double elevation = 0.0;
  ScrollController controller = ScrollController();
  Color? secondary;
  int? hovered;
  bool reactToSecondaryPress = false;
  bool detailsVisible = false;
  bool detailsLoaded = false;
  bool detailsExpanded = false;
  ScrollPhysics? physics = NeverScrollableScrollPhysics();

  bool isDark(BuildContext context) {
    final fallback =
        Theme.of(context).brightness == Brightness.dark ? 0.0 : 1.0;
    return (color?.computeLuminance() ?? fallback) < 0.5;
  }

  @override
  void initState() {
    super.initState();
    widget.album.tracks.sort(
        (first, second) => first.trackNumber.compareTo(second.trackNumber));
    Timer(
      Duration(milliseconds: 300),
      () {
        PaletteGenerator.fromImageProvider(
          ResizeImage.resizeIfNeeded(
            100,
            100,
            ExtendedNetworkImageProvider(
              widget.album.thumbnails.values.first,
              cache: true,
            ),
          ),
        ).then((palette) {
          setState(() {
            if (palette.colors != null) {
              color = palette.colors!.first;
            }
          });
        });
      },
    );
    controller.addListener(() {
      if (controller.offset.isZero) {
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
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            CustomListView(
              controller: controller,
              padding: EdgeInsets.only(
                top: WindowPlus.instance.captionHeight + kDesktopAppBarHeight,
              ),
              children: [
                TweenAnimationBuilder(
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
                  builder: (context, color, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
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
                                  child: Hero(
                                    tag:
                                        'album_art_${widget.album.albumName}_${widget.album.year}_${widget.album.id}',
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
                                                      widget.album.thumbnails
                                                          .values.last,
                                                      cache: true),
                                              height: 256.0,
                                              width: 256.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                          widget.album.albumName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                color: isDark(context)
                                                    ? Theme.of(context)
                                                        .extension<TextColors>()
                                                        ?.darkPrimary
                                                    : Theme.of(context)
                                                        .extension<TextColors>()
                                                        ?.lightPrimary,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          '${widget.album.subtitle}\n${widget.album.secondSubtitle}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: isDark(context)
                                                    ? Theme.of(context)
                                                        .extension<TextColors>()
                                                        ?.darkSecondary
                                                    : Theme.of(context)
                                                        .extension<TextColors>()
                                                        ?.lightSecondary,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8.0),
                                        Expanded(
                                          child: CustomListView(
                                            physics: detailsExpanded
                                                ? null
                                                : NeverScrollableScrollPhysics(),
                                            padding:
                                                EdgeInsets.only(right: 8.0),
                                            children: [
                                              if (widget
                                                  .album.description.isNotEmpty)
                                                ReadMoreText(
                                                  '${widget.album.description}',
                                                  trimLines: 6,
                                                  trimMode: TrimMode.Line,
                                                  trimExpandedText:
                                                      Language.instance.LESS,
                                                  trimCollapsedText:
                                                      Language.instance.MORE,
                                                  colorClickableText:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: isDark(context)
                                                            ? Theme.of(context)
                                                                .extension<
                                                                    TextColors>()
                                                                ?.darkSecondary
                                                            : Theme.of(context)
                                                                .extension<
                                                                    TextColors>()
                                                                ?.lightSecondary,
                                                      ),
                                                  callback: (collapsed) {
                                                    debugPrint(
                                                      'collapsed: $collapsed',
                                                    );
                                                    setState(() {
                                                      detailsExpanded =
                                                          !collapsed;
                                                    });
                                                  },
                                                ),
                                              const SizedBox(height: 12.0),
                                              ButtonBar(
                                                buttonPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      Web.instance.open(
                                                          widget.album.tracks);
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
                                                        const EdgeInsets.all(
                                                          12.0,
                                                        ),
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
                                                        Language
                                                            .instance.PLAY_NOW,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: !isDark(context)
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  OutlinedButton.icon(
                                                    onPressed: () {
                                                      Collection.instance
                                                          .playlistCreate(
                                                        media.Playlist(
                                                          id: widget
                                                              .album
                                                              .albumName
                                                              .hashCode,
                                                          name: widget
                                                              .album.albumName,
                                                        )..tracks.addAll(
                                                            widget.album.tracks
                                                                .map(
                                                              (e) =>
                                                                  Parser.track(
                                                                e,
                                                              ),
                                                            ),
                                                          ),
                                                      );
                                                    },
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      // ignore: deprecated_member_use
                                                      primary: Colors.white,
                                                      side: BorderSide(
                                                        color: isDark(context)
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
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
                                                  OutlinedButton.icon(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            'https://music.youtube.com/browse/${widget.album.id}'),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      // ignore: deprecated_member_use
                                                      primary: Colors.white,
                                                      side: BorderSide(
                                                        color: isDark(context)
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                        12.0,
                                                      ),
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
                      ...widget.album.tracks.map(
                        (e) => WebTrackTile(
                          track: e,
                          group: widget.album.tracks,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                        elevation != 0.0 ? widget.album.albumName : '',
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
                      const SizedBox(width: 8.0),
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
                              alignment: Alignment.center,
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
