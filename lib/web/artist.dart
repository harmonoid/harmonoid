import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';

import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/interface/settings/settings.dart';

import 'package:harmonoid/web/utils/widgets.dart';
import 'package:harmonoid/web/state/web.dart';
import 'package:harmonoid/web/playlist.dart';
import 'package:harmonoid/web/album.dart';
import 'package:harmonoid/web/track.dart';
import 'package:harmonoid/web/video.dart';

import 'package:harmonoid/constants/language.dart';

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
                        MaterialRoute(
                          builder: (context) => WebArtistScreen(
                            artist: artist,
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
            style: Theme.of(context).textTheme.titleSmall,
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
            MaterialRoute(
              builder: (context) => WebArtistScreen(
                artist: artist,
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),
                        Text(
                          artist.subscribersCount,
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
  final ScrollController scrollController = ScrollController();
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

  @override
  Widget build(BuildContext context) {
    final double width = kAlbumTileWidth;
    final double height = kAlbumTileHeight;
    return Scaffold(
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
                              ? Stack(
                                  children: [
                                    const SizedBox.shrink(),
                                    Positioned.fill(
                                      child: TweenAnimationBuilder(
                                        tween: Tween<double>(
                                          begin: 0.0,
                                          end: 1.0,
                                        ),
                                        duration: Theme.of(context)
                                                .extension<AnimationDuration>()
                                                ?.medium ??
                                            Duration.zero,
                                        child: state.completedWidget,
                                        builder: (context, value, child) =>
                                            Opacity(
                                          opacity: value as double,
                                          child: state.completedWidget,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 72.0,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black87,
                                              Colors.transparent,
                                            ],
                                            stops: [
                                              0.0,
                                              0.3,
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                  Theme.of(context).scaffoldBackgroundColor,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                widget.artist.artistName.overflow,
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                widget.artist.subscribersCount
                                    .split(' • ')
                                    .last
                                    .trim(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8.0),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 580.0),
                                child: ReadMoreText(
                                  widget.artist.description,
                                  trimLines: 4,
                                  trimMode: TrimMode.Line,
                                  trimExpandedText: Language.instance.LESS,
                                  trimCollapsedText: Language.instance.MORE,
                                  colorClickableText:
                                      Theme.of(context).colorScheme.primary,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  callback: (isTrimmed) {
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Web.instance.open(
                                        widget.artist.data.entries.first.value
                                            .elements
                                            .cast<Track>(),
                                      );
                                    },
                                    style: ButtonStyle(
                                      elevation: MaterialStatePropertyAll(0.0),
                                      backgroundColor: MaterialStatePropertyAll(
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      padding: MaterialStatePropertyAll(
                                        const EdgeInsets.all(12.0),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.shuffle,
                                      color: !(Theme.of(context).brightness ==
                                              Brightness.dark)
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    label: Text(
                                      label(
                                        context,
                                        Language.instance.SHUFFLE,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: !(Theme.of(context).brightness ==
                                                Brightness.dark)
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
                                            'https://music.youtube.com/browse/${widget.artist.id}'),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      // ignore: deprecated_member_use
                                      primary: Colors.white,
                                      side: BorderSide(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      padding: const EdgeInsets.all(12.0),
                                    ),
                                    icon: Icon(
                                      Icons.open_in_new,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    label: Text(
                                      label(
                                        context,
                                        Language.instance.OPEN_IN_BROWSER,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
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
                              left: tileMargin(context),
                              bottom: 8.0,
                            ),
                            children: e.value.elements
                                .map(
                                  (f) => Padding(
                                    padding: EdgeInsets.only(
                                        right: tileMargin(context)),
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
                              left: tileMargin(context),
                              bottom: 8.0,
                            ),
                            children: e.value.elements
                                .map(
                                  (f) => Padding(
                                    padding: EdgeInsets.only(
                                        right: tileMargin(context)),
                                    child: WebVideoLargeTile(
                                      track: Track.fromWebVideo(f.toJson()),
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
                              left: tileMargin(context),
                              bottom: 8.0,
                            ),
                            children: e.value.elements
                                .map(
                                  (f) => Padding(
                                    padding: EdgeInsets.only(
                                        right: tileMargin(context)),
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
                              left: tileMargin(context),
                              bottom: 8.0,
                            ),
                            children: e.value.elements
                                .map(
                                  (f) => Padding(
                                    padding: EdgeInsets.only(
                                        right: tileMargin(context)),
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
                          color: Theme.of(context)
                              .extension<IconColors>()
                              ?.appBarActionDark,
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
              return DesktopAppBar(
                color: value,
                elevation: appBarVisible ? 0.0 : 4.0,
                child: child,
              );
            },
            duration: Theme.of(context).extension<AnimationDuration>()?.fast ??
                Duration.zero,
            tween: ColorTween(
              begin: Colors.transparent,
              end: appBarVisible
                  ? Colors.transparent
                  : Theme.of(context).appBarTheme.backgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
