/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:extended_image/extended_image.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/web/album.dart';
import 'package:harmonoid/web/state/web.dart';
import 'package:harmonoid/web/track.dart';
import 'package:harmonoid/web/video.dart';
import 'package:harmonoid/web/playlist.dart';
import 'package:harmonoid/web/utils/widgets.dart';
import 'package:harmonoid/web/web.dart';
import 'package:harmonoid/interface/settings/settings.dart';

class WebArtistLargeTile extends StatelessWidget {
  final double height;
  final double width;
  final Artist artist;
  const WebArtistLargeTile({
    Key? key,
    required this.height,
    required this.width,
    required this.artist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                width / 2.0,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: 'artist_art_${artist.id}',
                  child: ClipOval(
                    child: ExtendedImage(
                      image: ExtendedNetworkImageProvider(
                          artist.thumbnails.values.first),
                      height: width - 8.0,
                      width: width - 8.0,
                    ),
                  ),
                ),
                Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      width / 2.0,
                    ),
                  ),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      if (artist.data.isEmpty) {
                        await YTMClient.artist(artist);
                      }
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  FadeThroughTransition(
                            fillColor: Colors.transparent,
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            child: WebArtistScreen(
                              artist: artist,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: width,
                      width: width,
                      padding: EdgeInsets.all(4.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Text(
            artist.artistName.overflow,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class WebArtistTile extends StatelessWidget {
  final Artist artist;

  const WebArtistTile({
    Key? key,
    required this.artist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (artist.data.isEmpty) {
            await YTMClient.artist(artist);
          }
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: WebArtistScreen(
                  artist: artist,
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
                  Hero(
                    tag: 'artist_art_${artist.id}',
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: artist.thumbnails.isNotEmpty
                            ? ClipOval(
                                child: ExtendedImage(
                                  image: NetworkImage(
                                    artist.thumbnails.values.first,
                                  ),
                                  height: 52.0,
                                  width: 52.0,
                                ),
                              )
                            : SizedBox.square(
                                dimension: 52.0,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artist.artistName.overflow,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),
                        Text(
                          artist.subscribersCount,
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

class WebArtistScreen extends StatefulWidget {
  final Artist artist;
  WebArtistScreen({
    Key? key,
    required this.artist,
  }) : super(key: key);

  @override
  State<WebArtistScreen> createState() => _WebArtistScreenState();
}

class _WebArtistScreenState extends State<WebArtistScreen> {
  final ScrollController scrollController =
      ScrollController(initialScrollOffset: isMobile ? 96.0 : 0.0);
  bool appBarVisible = true;
  Color? color;
  Color? secondary;
  int? hovered;
  bool reactToSecondaryPress = false;
  bool detailsVisible = false;
  bool detailsLoaded = false;
  ScrollPhysics? physics = NeverScrollableScrollPhysics();

  @override
  void initState() {
    super.initState();
    if (isDesktop) {
      scrollController.addListener(() {
        if (scrollController.offset == 0.0 && !appBarVisible) {
          setState(() {
            appBarVisible = true;
          });
        } else if (appBarVisible) {
          setState(() {
            appBarVisible = false;
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
            widget.artist.thumbnails.values.first,
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
            .scrollController
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
      scrollController.addListener(() {
        if (scrollController.offset < 36.0) {
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
  Widget build(BuildContext context) {
    final elementsPerRow = (MediaQuery.of(context).size.width - tileMargin) ~/
        (kAlbumTileWidth + tileMargin);
    final double width = isMobile
        ? (MediaQuery.of(context).size.width -
                (elementsPerRow + 1) * tileMargin) /
            elementsPerRow *
            0.95
        : kAlbumTileWidth;
    final double height = isMobile
        ? width * kAlbumTileHeight / kAlbumTileWidth
        : kAlbumTileHeight;
    const mobileSliverLabelHeight = 116.0;
    double mobileSliverContentHeight = MediaQuery.of(context).size.width * 0.6;
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
            body: Stack(
              alignment: Alignment.topCenter,
              children: [
                NowPlayingBarScrollHideNotifier(
                  child: CustomListView(
                    controller: scrollController,
                    children: [
                      ExtendedImage.network(
                        widget.artist.coverUrl,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        enableLoadState: true,
                        enableMemoryCache: false,
                        cache: true,
                        loadStateChanged: (ExtendedImageState state) {
                          return Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              Positioned.fill(
                                child: state.extendedImageLoadState ==
                                        LoadState.completed
                                    ? TweenAnimationBuilder(
                                        tween:
                                            Tween<double>(begin: 0.0, end: 1.0),
                                        duration:
                                            const Duration(milliseconds: 800),
                                        child: state.completedWidget,
                                        builder: (context, value, child) =>
                                            Opacity(
                                          opacity: value as double,
                                          child: state.completedWidget,
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ),
                              Positioned.fill(
                                bottom: -12.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [0.35, 0.95],
                                      colors: [
                                        Theme.of(context)
                                            .scaffoldBackgroundColor
                                            .withOpacity(0.0),
                                        Theme.of(context)
                                            .scaffoldBackgroundColor,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 240.0,
                                  bottom: 16.0,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: isDesktop
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      widget.artist.artistName.overflow,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            fontSize: 56.0,
                                            fontWeight: isMobile
                                                ? FontWeight.w300
                                                : null,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      widget.artist.subscribersCount
                                          .split(' • ')
                                          .last
                                          .trim(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    ),
                                    const SizedBox(height: 8.0),
                                    ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: 580.0),
                                      child: ReadMoreText(
                                        widget.artist.description,
                                        trimLines: 4,
                                        trimMode: TrimMode.Line,
                                        trimExpandedText:
                                            Language.instance.LESS,
                                        trimCollapsedText:
                                            Language.instance.MORE,
                                        colorClickableText:
                                            Theme.of(context).primaryColor,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall,
                                        callback: (isTrimmed) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    Row(
                                      mainAxisAlignment: isDesktop
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Web.instance.open(widget.artist.data
                                                .entries.first.value.elements
                                                .cast<Track>());
                                          },
                                          style: ButtonStyle(
                                            elevation:
                                                MaterialStateProperty.all(0.0),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black87),
                                            padding: isDesktop
                                                ? MaterialStateProperty.all(
                                                    EdgeInsets.all(12.0))
                                                : null,
                                          ),
                                          icon: Icon(
                                            Icons.shuffle,
                                            color: !(Theme.of(context)
                                                        .brightness ==
                                                    Brightness.dark)
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                          label: Text(
                                            Language.instance.SHUFFLE
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: !(Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark)
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            if (isDesktop) {
                                              launchUrl(
                                                Uri.parse(
                                                    'https://music.youtube.com/browse/${widget.artist.id}'),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            } else {
                                              Share.share(
                                                  'https://music.youtube.com/browse/${widget.artist.id}');
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            // ignore: deprecated_member_use
                                            primary: Colors.white,
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black87),
                                            padding: isDesktop
                                                ? EdgeInsets.all(12.0)
                                                : null,
                                          ),
                                          icon: Icon(
                                            isDesktop
                                                ? Icons.open_in_new
                                                : Icons.share,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                          label: Text(
                                            isDesktop
                                                ? Language
                                                    .instance.OPEN_IN_BROWSER
                                                    .toUpperCase()
                                                : Language.instance.SHARE
                                                    .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      ...widget.artist.data.entries.map(
                        (e) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SubHeader(e.key),
                            if (e.value.elements.isNotEmpty &&
                                e.value.elements.first is Track)
                              ...e.value.elements.map(
                                (f) => Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 16.0 : 0.0),
                                  child: WebTrackTile(
                                    track: f as Track,
                                  ),
                                ),
                              ),
                            if (e.value.elements.isNotEmpty &&
                                e.value.elements.first is Album)
                              Container(
                                height: height + 8.0,
                                child: HorizontalList(
                                  padding: EdgeInsets.only(
                                    left: tileMargin,
                                    bottom: 8.0,
                                  ),
                                  children: e.value.elements
                                      .map(
                                        (f) => Padding(
                                          padding: EdgeInsets.only(
                                              right: tileMargin),
                                          child: WebAlbumLargeTile(
                                            album: f as Album,
                                            width: width,
                                            height: height,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            if (e.value.elements.isNotEmpty &&
                                e.value.elements.first is Video)
                              Container(
                                height: height + 8.0,
                                child: HorizontalList(
                                  padding: EdgeInsets.only(
                                    left: tileMargin,
                                    bottom: 8.0,
                                  ),
                                  children: e.value.elements
                                      .map(
                                        (f) => Padding(
                                          padding: EdgeInsets.only(
                                              right: tileMargin),
                                          child: WebVideoLargeTile(
                                            track:
                                                Track.fromWebVideo(f.toJson()),
                                            width: height * 16 / 9,
                                            height: height,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            if (e.value.elements.isNotEmpty &&
                                e.value.elements.first is Playlist)
                              Container(
                                height: height + 8.0,
                                child: HorizontalList(
                                  padding: EdgeInsets.only(
                                    left: tileMargin,
                                    bottom: 8.0,
                                  ),
                                  children: e.value.elements
                                      .map(
                                        (f) => Padding(
                                          padding: EdgeInsets.only(
                                              right: tileMargin),
                                          child: WebPlaylistLargeTile(
                                            playlist: f as Playlist,
                                            width: width,
                                            height: height,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            if (e.value.elements.isNotEmpty &&
                                e.value.elements.first is Artist)
                              Container(
                                height: width + 28.0 + 8.0,
                                child: HorizontalList(
                                  padding: EdgeInsets.only(
                                    left: tileMargin,
                                    bottom: 8.0,
                                  ),
                                  children: e.value.elements
                                      .map(
                                        (f) => Padding(
                                          padding: EdgeInsets.only(
                                              right: tileMargin),
                                          child: WebArtistLargeTile(
                                            artist: f as Artist,
                                            width: width,
                                            height: width + 28.0,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TweenAnimationBuilder<Color?>(
                  child: Row(
                    children: [
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
                                    secondaryAnimation: secondaryAnimation,
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
                                color: Theme.of(context)
                                    .appBarTheme
                                    .actionsIconTheme
                                    ?.color,
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
                  builder: (context, value, child) {
                    return isDesktop
                        ? DesktopAppBar(
                            color: value,
                            elevation: appBarVisible ? 0.0 : 4.0,
                            child: child,
                          )
                        : Container();
                  },
                  duration: Duration(milliseconds: 200),
                  tween: ColorTween(
                    begin: Colors.transparent,
                    end: appBarVisible
                        ? Colors.transparent
                        : Theme.of(context).appBarTheme.backgroundColor,
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            body: Stack(
              children: [
                NowPlayingBarScrollHideNotifier(
                  child: CustomScrollView(
                    physics: physics,
                    controller: scrollController,
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
                              widget.artist.artistName.overflow,
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
                                        widget.artist.coverUrl,
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
                                                1.0,
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
                                              .artist.description.isNotEmpty) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                    widget.artist.artistName),
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
                                                          widget.artist
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
                                                widget
                                                    .artist.artistName.overflow,
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
                                                [
                                                  if (widget
                                                      .artist.subscribersCount
                                                      .split(' • ')
                                                      .last
                                                      .trim()
                                                      .isNotEmpty)
                                                    widget
                                                        .artist.subscribersCount
                                                        .split(' • ')
                                                        .last
                                                        .trim(),
                                                  if (widget.artist.description
                                                      .isNotEmpty)
                                                    widget.artist.description,
                                                ].join(' • '),
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
                                            'https://music.youtube.com/browse/${widget.artist.id}');
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
                                        Web.instance.open(widget.artist.data
                                            .entries.first.value.elements
                                            .cast<Track>());
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
                          ...widget.artist.data.entries.map(
                            (e) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: isDesktop
                                      ? SubHeader(e.key)
                                      : Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.fromLTRB(
                                              0.0, 0, 0, 20.0),
                                          child: Text(
                                            e.key.toUpperCase(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall
                                                      ?.color,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                ),
                                if (e.value.elements.isNotEmpty &&
                                    e.value.elements.first is Track)
                                  ...e.value.elements.map(
                                    (f) => Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: isDesktop ? 16.0 : 0.0),
                                      child: WebTrackTile(
                                        track: f as Track,
                                      ),
                                    ),
                                  ),
                                if (e.value.elements.isNotEmpty &&
                                    e.value.elements.first is Album)
                                  Container(
                                    height: height + 8.0,
                                    child: HorizontalList(
                                      padding: EdgeInsets.only(
                                        left: tileMargin * 2.0,
                                        bottom: 8.0,
                                      ),
                                      children: e.value.elements
                                          .map(
                                            (f) => Padding(
                                              padding: EdgeInsets.only(
                                                right: tileMargin * 2.0,
                                              ),
                                              child: WebAlbumLargeTile(
                                                album: f as Album,
                                                width: width,
                                                height: height,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                if (e.value.elements.isNotEmpty &&
                                    e.value.elements.first is Video)
                                  Container(
                                    height: height * 0.8 + 8.0,
                                    child: HorizontalList(
                                      padding: EdgeInsets.only(
                                        left: tileMargin * 2.0,
                                        bottom: 8.0,
                                      ),
                                      children: e.value.elements
                                          .map(
                                            (f) => Padding(
                                              padding: EdgeInsets.only(
                                                right: tileMargin * 2.0,
                                              ),
                                              child: WebVideoLargeTile(
                                                track: Track.fromWebVideo(
                                                    f.toJson()),
                                                width: height * 0.8 * 16 / 9,
                                                height: height * 0.8,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                if (e.value.elements.isNotEmpty &&
                                    e.value.elements.first is Playlist)
                                  Container(
                                    height: height + 8.0,
                                    child: HorizontalList(
                                      padding: EdgeInsets.only(
                                        left: tileMargin * 2.0,
                                        bottom: 8.0,
                                      ),
                                      children: e.value.elements
                                          .map(
                                            (f) => Padding(
                                              padding: EdgeInsets.only(
                                                right: tileMargin * 2.0,
                                              ),
                                              child: WebPlaylistLargeTile(
                                                playlist: f as Playlist,
                                                width: width,
                                                height: height,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                if (e.value.elements.isNotEmpty &&
                                    e.value.elements.first is Artist)
                                  Container(
                                    height: width + 28.0 + 8.0,
                                    child: HorizontalList(
                                      padding: EdgeInsets.only(
                                        left: tileMargin * 2.0,
                                        bottom: 8.0,
                                      ),
                                      children: e.value.elements
                                          .map(
                                            (f) => Padding(
                                              padding: EdgeInsets.only(
                                                right: tileMargin * 2.0,
                                              ),
                                              child: WebArtistLargeTile(
                                                artist: f as Artist,
                                                width: width,
                                                height: width + 28.0,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                const SizedBox(height: 16.0),
                              ],
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
