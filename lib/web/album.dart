/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:animations/animations.dart';
import 'package:window_plus/window_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:extended_image/extended_image.dart';
import 'package:media_library/media_library.dart' as media;

import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/web/utils/widgets.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/helpers.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/web/web.dart';
import 'package:harmonoid/web/track.dart';
import 'package:harmonoid/web/state/web.dart';

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
            await Future.wait([
              YTMClient.album(album),
              precacheImage(
                ExtendedNetworkImageProvider(album.thumbnails.values.last,
                    cache: true),
                context,
              ),
            ]);
          }
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: WebAlbumScreen(
                  album: album,
                ),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12.0 : 8.0,
                  ),
                  width: width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.albumName.overflow,
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontSize: isMobile ? 18.0 : null,
                                  fontWeight: isMobile ? FontWeight.w700 : null,
                                ),
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
                          style: isDesktop
                              ? Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontSize: 12.0,
                                  )
                              : Theme.of(context).textTheme.displaySmall,
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
            await Future.wait([
              YTMClient.album(album),
              precacheImage(
                ExtendedNetworkImageProvider(album.thumbnails.values.last,
                    cache: true),
                context,
              ),
            ]);
          }
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: WebAlbumScreen(
                  album: album,
                ),
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
                          style: Theme.of(context).textTheme.displayMedium,
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
                          style: Theme.of(context).textTheme.displaySmall,
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
  ScrollController controller =
      ScrollController(initialScrollOffset: isMobile ? 96.0 : 0.0);
  Color? secondary;
  int? hovered;
  bool reactToSecondaryPress = false;
  bool detailsVisible = false;
  bool detailsLoaded = false;
  bool detailsExpanded = false;
  ScrollPhysics? physics = NeverScrollableScrollPhysics();

  bool isDark(BuildContext context) =>
      (0.299 *
              (color?.red ??
                  (Theme.of(context).brightness == Brightness.dark
                      ? 0.0
                      : 255.0))) +
          (0.587 *
              (color?.green ??
                  (Theme.of(context).brightness == Brightness.dark
                      ? 0.0
                      : 255.0))) +
          (0.114 *
              (color?.blue ??
                  (Theme.of(context).brightness == Brightness.dark
                      ? 0.0
                      : 255.0))) <
      128.0;

  @override
  void initState() {
    super.initState();
    widget.album.tracks.sort(
        (first, second) => first.trackNumber.compareTo(second.trackNumber));
    if (isDesktop) {
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
    if (isMobile) {
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
            secondary = palette.colors!.last;
          }
        });
      });
      Timer(Duration(milliseconds: 100), () {
        this
            .controller
            .animateTo(
              0.0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) {
          Timer(Duration(milliseconds: 50), () {
            setState(() {
              detailsLoaded = true;
              physics = null;
            });
          });
        });
      });
      controller.addListener(() {
        if (controller.offset < 36.0) {
          if (!detailsVisible) {
            setState(() {
              detailsVisible = true;
            });
          }
        } else if (detailsVisible) {
          setState(() {
            detailsVisible = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const mobileSliverLabelHeight = 116.0;
    double mobileSliverContentHeight = MediaQuery.of(context).size.width;
    double mobileSliverExpandedHeight = mobileSliverContentHeight -
        MediaQuery.of(context).padding.top +
        mobileSliverLabelHeight;
    double mobileSliverFABYPos = mobileSliverContentHeight - 32.0;
    if (mobileSliverExpandedHeight >
        MediaQuery.of(context).size.height * 3 / 5) {
      mobileSliverExpandedHeight = MediaQuery.of(context).size.height * 3 / 5;
      mobileSliverContentHeight = mobileSliverExpandedHeight -
          mobileSliverLabelHeight +
          MediaQuery.of(context).padding.top;
      mobileSliverFABYPos = mobileSliverContentHeight - 32.0;
    }
    return isDesktop
        ? Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  CustomListView(
                    controller: controller,
                    padding: EdgeInsets.only(
                      top: WindowPlus.instance.captionHeight +
                          kDesktopAppBarHeight,
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
                        duration: Duration(
                          milliseconds: 300,
                        ),
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
                                                            widget
                                                                .album
                                                                .thumbnails
                                                                .values
                                                                .last,
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
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20.0),
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
                                                    .displayLarge
                                                    ?.copyWith(
                                                      fontSize: 24.0,
                                                      color: isDark(context)
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8.0),
                                              Text(
                                                '${widget.album.subtitle}\n${widget.album.secondSubtitle}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall
                                                    ?.copyWith(
                                                      color: isDark(context)
                                                          ? Colors.white70
                                                          : Colors.black87,
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
                                                  padding: EdgeInsets.only(
                                                      right: 8.0),
                                                  children: [
                                                    if (widget.album.description
                                                        .isNotEmpty)
                                                      ReadMoreText(
                                                        '${widget.album.description}',
                                                        trimLines: 6,
                                                        trimMode: TrimMode.Line,
                                                        trimExpandedText:
                                                            Language
                                                                .instance.LESS,
                                                        trimCollapsedText:
                                                            Language
                                                                .instance.MORE,
                                                        colorClickableText:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displaySmall
                                                            ?.copyWith(
                                                              color: isDark(
                                                                      context)
                                                                  ? Colors
                                                                      .white70
                                                                  : Colors
                                                                      .black87,
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
                                                    const SizedBox(
                                                        height: 12.0),
                                                    ButtonBar(
                                                      buttonPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8.0),
                                                      alignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        ElevatedButton.icon(
                                                          onPressed: () {
                                                            Web.instance.open(
                                                                widget.album
                                                                    .tracks);
                                                          },
                                                          style: ButtonStyle(
                                                            elevation:
                                                                MaterialStateProperty
                                                                    .all(0.0),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(isDark(
                                                                            context)
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black87),
                                                            padding: MaterialStateProperty
                                                                .all(EdgeInsets
                                                                    .all(12.0)),
                                                          ),
                                                          icon: Icon(
                                                            Icons.play_arrow,
                                                            color: !isDark(
                                                                    context)
                                                                ? Colors.white
                                                                : Colors
                                                                    .black87,
                                                          ),
                                                          label: Text(
                                                            Language.instance
                                                                .PLAY_NOW
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              color: !isDark(
                                                                      context)
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black87,
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
                                                                    .album
                                                                    .albumName,
                                                              )..tracks.addAll(widget
                                                                  .album.tracks
                                                                  .map((e) => Helpers
                                                                      .parseWebTrack(
                                                                          e.toJson()))),
                                                            );
                                                          },
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            // ignore: deprecated_member_use
                                                            primary:
                                                                Colors.white,
                                                            side: BorderSide(
                                                                color: isDark(
                                                                        context)
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black87),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    12.0),
                                                          ),
                                                          icon: Icon(
                                                            Icons.playlist_add,
                                                            color: isDark(
                                                                    context)
                                                                ? Colors.white
                                                                : Colors
                                                                    .black87,
                                                          ),
                                                          label: Text(
                                                            Language.instance
                                                                .SAVE_AS_PLAYLIST
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              color: isDark(
                                                                      context)
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black87,
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
                                                            primary:
                                                                Colors.white,
                                                            side: BorderSide(
                                                                color: isDark(
                                                                        context)
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black87),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    12.0),
                                                          ),
                                                          icon: Icon(
                                                            Icons.open_in_new,
                                                            color: isDark(
                                                                    context)
                                                                ? Colors.white
                                                                : Colors
                                                                    .black87,
                                                          ),
                                                          label: Text(
                                                            Language.instance
                                                                .OPEN_IN_BROWSER
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              color: isDark(
                                                                      context)
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black87,
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
                    duration: Duration(
                      milliseconds: 300,
                    ),
                    builder: (context, color, _) => Theme(
                      data: createTheme(
                        color: isDark(context)
                            ? kPrimaryDarkColor
                            : kPrimaryLightColor,
                        mode:
                            isDark(context) ? ThemeMode.dark : ThemeMode.light,
                      ),
                      child: DesktopAppBar(
                        elevation: elevation,
                        color: color as Color? ?? Colors.transparent,
                        child: Row(
                          children: [
                            Text(
                              elevation != 0.0 ? widget.album.albumName : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    color: isDark(context)
                                        ? Colors.white
                                        : Colors.black,
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
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            FadeThroughTransition(
                                          fillColor: Colors.transparent,
                                          animation: animation,
                                          secondaryAnimation:
                                              secondaryAnimation,
                                          child: Settings(),
                                        ),
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
                                              ?.appBarActionDarkIconColor
                                          : Theme.of(context)
                                              .extension<IconColors>()
                                              ?.appBarActionLightIconColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            body: Stack(
              children: [
                NowPlayingBarScrollHideNotifier(
                  child: CustomScrollView(
                    physics: physics,
                    controller: controller,
                    slivers: [
                      SliverAppBar(
                        systemOverlayStyle: SystemUiOverlayStyle(
                          statusBarColor: Colors.transparent,
                          statusBarIconBrightness: Brightness.light,
                        ),
                        expandedHeight: mobileSliverExpandedHeight,
                        pinned: true,
                        leading: IconButton(
                          onPressed: Navigator.of(context).maybePop,
                          icon: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context)
                                .extension<IconColors>()
                                ?.appBarDarkIconColor,
                          ),
                          iconSize: 24.0,
                          splashRadius: 20.0,
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      FadeThroughTransition(
                                          fillColor: Colors.transparent,
                                          animation: animation,
                                          secondaryAnimation:
                                              secondaryAnimation,
                                          child:
                                              FloatingSearchBarWebSearchScreen())));
                            },
                            icon: Icon(
                              Icons.search,
                              color: Theme.of(context)
                                  .extension<IconColors>()
                                  ?.appBarActionDarkIconColor,
                            ),
                            iconSize: 24.0,
                            splashRadius: 20.0,
                          ),
                          WebMobileAppBarOverflowButton(),
                          const SizedBox(width: 8.0),
                        ],
                        forceElevated: true,
                        title: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 1.0,
                            end: detailsVisible ? 0.0 : 1.0,
                          ),
                          duration: Duration(milliseconds: 200),
                          builder: (context, value, _) => Opacity(
                            opacity: value,
                            child: Text(
                              widget.album.albumName.overflow,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        backgroundColor: Colors.grey.shade900,
                        flexibleSpace: Stack(
                          children: [
                            FlexibleSpaceBar(
                              background: Column(
                                children: [
                                  Stack(
                                    children: [
                                      ExtendedImage.network(
                                        widget.album.thumbnails.values.last,
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: mobileSliverContentHeight,
                                        enableLoadState: true,
                                        enableMemoryCache: false,
                                        cache: true,
                                        loadStateChanged:
                                            (ExtendedImageState state) {
                                          return state.extendedImageLoadState ==
                                                  LoadState.completed
                                              ? TweenAnimationBuilder(
                                                  tween: Tween<double>(
                                                      begin: 0.0, end: 1.0),
                                                  duration: const Duration(
                                                      milliseconds: 800),
                                                  child: state.completedWidget,
                                                  builder:
                                                      (context, value, child) =>
                                                          Opacity(
                                                    opacity: value as double,
                                                    child:
                                                        state.completedWidget,
                                                  ),
                                                )
                                              : SizedBox.shrink();
                                        },
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.black26,
                                                Colors.transparent,
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              stops: [
                                                0.0,
                                                0.5,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                      begin: 1.0,
                                      end: detailsVisible ? 1.0 : 0.0,
                                    ),
                                    duration: Duration(milliseconds: 200),
                                    builder: (context, value, _) => Opacity(
                                      opacity: value,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (widget
                                              .album.description.isNotEmpty) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                    widget.album.albumName),
                                                contentPadding:
                                                    EdgeInsets.only(top: 20.0),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Divider(
                                                      height: 1.0,
                                                      thickness: 1.0,
                                                    ),
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxHeight: 360.0,
                                                      ),
                                                      child:
                                                          SingleChildScrollView(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 24.0,
                                                          vertical: 16.0,
                                                        ),
                                                        child: Text(
                                                          widget.album
                                                              .description,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .displaySmall,
                                                        ),
                                                      ),
                                                    ),
                                                    const Divider(
                                                      height: 1.0,
                                                      thickness: 1.0,
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        Navigator.of(context)
                                                            .pop,
                                                    child: Text(
                                                      Language.instance.OK,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          color: Colors.grey.shade900,
                                          height: mobileSliverLabelHeight,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.album.albumName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 24.0,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                widget.album.description,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall
                                                    ?.copyWith(
                                                      color: Colors.white70,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: mobileSliverFABYPos,
                              right: 16.0 + 64.0,
                              child: TweenAnimationBuilder(
                                curve: Curves.easeOut,
                                tween: Tween<double>(
                                    begin: 0.0,
                                    end: detailsVisible && secondary != null
                                        ? 1.0
                                        : 0.0),
                                duration: Duration(milliseconds: 200),
                                builder: (context, value, _) => Transform.scale(
                                  scale: value as double,
                                  child: Transform.rotate(
                                    angle: value * pi + pi,
                                    child: FloatingActionButton(
                                      heroTag: Random().nextInt(1 << 32),
                                      backgroundColor: secondary,
                                      foregroundColor: [
                                        Colors.white,
                                        Color(0xFF212121)
                                      ][(secondary?.computeLuminance() ?? 0.0) >
                                              0.5
                                          ? 1
                                          : 0],
                                      child: Icon(Icons.share),
                                      onPressed: () {
                                        Share.share(
                                            'https://music.youtube.com/browse/${widget.album.id}');
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: mobileSliverFABYPos,
                              right: 16.0,
                              child: TweenAnimationBuilder(
                                curve: Curves.easeOut,
                                tween: Tween<double>(
                                    begin: 0.0,
                                    end: detailsVisible && secondary != null
                                        ? 1.0
                                        : 0.0),
                                duration: Duration(milliseconds: 200),
                                builder: (context, value, _) => Transform.scale(
                                  scale: value as double,
                                  child: Transform.rotate(
                                    angle: value * pi + pi,
                                    child: FloatingActionButton(
                                      heroTag: Random().nextInt(1 << 32),
                                      backgroundColor: secondary,
                                      foregroundColor: [
                                        Colors.white,
                                        Color(0xFF212121)
                                      ][(secondary?.computeLuminance() ?? 0.0) >
                                              0.5
                                          ? 1
                                          : 0],
                                      child: Icon(Icons.shuffle),
                                      onPressed: () {
                                        Web.instance.open(widget.album.tracks);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.only(
                          top: 20.0,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          ...widget.album.tracks.map(
                            (e) => WebTrackTile(
                              track: e,
                              group: widget.album.tracks,
                            ),
                          ),
                        ]),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.only(
                          top: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
