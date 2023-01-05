/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:desktop/desktop.dart' as desktop;
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/interface/collection/artist.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/constants/language.dart';

class TrackTab extends StatefulWidget {
  TrackTab({Key? key}) : super(key: key);

  @override
  _TrackTabState createState() => _TrackTabState();
}

class _TrackTabState extends State<TrackTab> {
  double _lastOffset = 0.0;
  final hover = ValueNotifier<bool>(true);
  final controller = ScrollController();

  void listener() {
    if (this.controller.offset > _lastOffset) {
      this.hover.value = false;
    } else if (this.controller.offset < _lastOffset) {
      this.hover.value = true;
    }
    _lastOffset = this.controller.offset;
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => isDesktop
          ? collection.tracks.isNotEmpty
              ? desktop.ListTableTheme(
                  data: desktop.ListTableThemeData(
                    borderColor: Theme.of(context).dividerTheme.color,
                    highlightColor: Theme.of(context)
                            .dividerTheme
                            .color
                            ?.withOpacity(0.4) ??
                        Theme.of(context).dividerColor.withOpacity(0.4),
                    hoverColor: Theme.of(context)
                            .dividerTheme
                            .color
                            ?.withOpacity(0.2) ??
                        Theme.of(context).dividerColor.withOpacity(0.4),
                    borderHighlightColor: Theme.of(context).primaryColor,
                    borderIndicatorColor: Theme.of(context).primaryColor,
                    borderHoverColor: Theme.of(context).primaryColor,
                  ),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      desktop.ListTable(
                        controller: controller,
                        onPressed: (i, _) {
                          if (Configuration.instance
                              .addLibraryToPlaylistWhenPlayingFromTracksTab) {
                            Playback.instance.open(
                              collection.tracks,
                              index: i,
                            );
                          } else {
                            Playback.instance.open(
                              [
                                collection.tracks[i],
                              ],
                              index: 0,
                            );
                          }
                        },
                        onSecondaryPress: (index, position) async {
                          final result = await showMenu(
                            context: context,
                            constraints: BoxConstraints(
                              maxWidth: double.infinity,
                            ),
                            position: RelativeRect.fromLTRB(
                              position.left,
                              position.top,
                              MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.width,
                            ),
                            items: trackPopupMenuItems(
                              collection.tracks[index],
                              context,
                            ),
                          );
                          await trackPopupMenuHandle(
                            context,
                            collection.tracks[index],
                            result,
                          );
                        },
                        colCount: 5,
                        headerColumnBorder: BorderSide(
                          color: Theme.of(context).dividerTheme.color ??
                              Theme.of(context).dividerColor,
                          width: 1.0,
                        ),
                        tableBorder: desktop.TableBorder(
                          verticalInside: BorderSide(
                            color: Theme.of(context).dividerTheme.color ??
                                Theme.of(context).dividerColor,
                          ),
                          top: BorderSide(
                            color: Theme.of(context).dividerTheme.color ??
                                Theme.of(context).dividerColor,
                          ),
                        ),
                        itemCount: collection.tracks.length,
                        itemExtent: 32.0,
                        colFraction: {
                          0: 0.04,
                          1: 0.36,
                          4: 0.12,
                        },
                        tableHeaderBuilder: (context, index, constraints) =>
                            Container(
                          alignment: Alignment.center,
                          child: Transform.translate(
                            offset: Offset(4.0, 0.0),
                            child: Text(
                              [
                                '#',
                                Language.instance.TRACK_SINGLE,
                                Language.instance.ARTIST,
                                Language.instance.ALBUM_SINGLE,
                                Language.instance.YEAR
                              ][index],
                              style: Theme.of(context).textTheme.displayMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        tableRowBuilder:
                            (context, index, property, constraints) =>
                                Container(
                          constraints: constraints,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          alignment: property == 0
                              ? Alignment.center
                              : Alignment.centerLeft,
                          child: () {
                            if ([0, 1, 4].contains(property)) {
                              return Text(
                                [
                                  '${collection.tracks[index].trackNumber}',
                                  collection.tracks[index].trackName,
                                  collection.tracks[index].trackArtistNames
                                      .join(', '),
                                  collection.tracks[index].albumName,
                                  collection.tracks[index].year.toString(),
                                ][property],
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              );
                            } else if (property == 2) {
                              final elements = <TextSpan>[];
                              collection.tracks[index].trackArtistNames
                                  .map(
                                (e) => TextSpan(
                                  text: e,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Playback.instance
                                              .interceptPositionChangeRebuilds =
                                          true;
                                      navigatorKey.currentState?.push(
                                        PageRouteBuilder(
                                          pageBuilder: ((context, animation,
                                                  secondaryAnimation) =>
                                              FadeThroughTransition(
                                                animation: animation,
                                                secondaryAnimation:
                                                    secondaryAnimation,
                                                child: ArtistScreen(
                                                  artist: Collection
                                                      .instance.artistsSet
                                                      .lookup(Artist(
                                                          artistName: e))!,
                                                ),
                                              )),
                                        ),
                                      );
                                      Timer(const Duration(milliseconds: 400),
                                          () {
                                        Playback.instance
                                                .interceptPositionChangeRebuilds =
                                            false;
                                      });
                                    },
                                ),
                              )
                                  .forEach((element) {
                                elements.add(element);
                                elements.add(TextSpan(text: ', '));
                              });
                              elements.removeLast();
                              return HyperLink(
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                                text: TextSpan(
                                  children: elements,
                                ),
                              );
                            } else if (property == 3) {
                              return HyperLink(
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: collection.tracks[index].albumName,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Playback.instance
                                                  .interceptPositionChangeRebuilds =
                                              true;
                                          navigatorKey.currentState?.push(
                                            PageRouteBuilder(
                                              pageBuilder: ((context, animation,
                                                      secondaryAnimation) =>
                                                  FadeThroughTransition(
                                                    animation: animation,
                                                    secondaryAnimation:
                                                        secondaryAnimation,
                                                    child: AlbumScreen(
                                                      album: Collection
                                                          .instance.albumsSet
                                                          .lookup(
                                                        Album(
                                                          albumName: collection
                                                              .tracks[index]
                                                              .albumName,
                                                          year: collection
                                                              .tracks[index]
                                                              .year,
                                                          albumArtistName:
                                                              collection
                                                                  .tracks[index]
                                                                  .albumArtistName,
                                                          albumHashCodeParameters:
                                                              Collection
                                                                  .instance
                                                                  .albumHashCodeParameters,
                                                        ),
                                                      )!,
                                                    ),
                                                  )),
                                            ),
                                          );
                                          Timer(
                                              const Duration(milliseconds: 400),
                                              () {
                                            Playback.instance
                                                    .interceptPositionChangeRebuilds =
                                                false;
                                          });
                                        },
                                    ),
                                  ],
                                ),
                              );
                            }
                          }(),
                        ),
                      ),
                      SortBar(
                        tab: 1,
                        fixed: false,
                        hover: hover,
                      ),
                    ],
                  ),
                )
              : Center(
                  child: ExceptionWidget(
                    title: Language.instance.NO_COLLECTION_TITLE,
                    subtitle: Language.instance.NO_COLLECTION_SUBTITLE,
                  ),
                )
          : Consumer<Collection>(
              builder: (context, collection, _) => collection.tracks.isNotEmpty
                  ? DraggableScrollbar.semicircle(
                      heightScrollThumb: 56.0,
                      labelConstraints: BoxConstraints.tightFor(
                        width: 120.0,
                        height: 32.0,
                      ),
                      labelTextBuilder: (offset) {
                        final index = (offset -
                                (kMobileSearchBarHeight +
                                    2 * tileMargin +
                                    MediaQuery.of(context).padding.top)) ~/
                            kMobileTrackTileHeight;
                        final track = collection.tracks[index.clamp(
                          0,
                          collection.tracks.length - 1,
                        )];
                        switch (collection.tracksSort) {
                          case TracksSort.aToZ:
                            {
                              return Text(
                                track.trackName[0].toUpperCase(),
                                style: Theme.of(context).textTheme.displayLarge,
                              );
                            }
                          case TracksSort.dateAdded:
                            {
                              return Text(
                                '${track.timeAdded.label}',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              );
                            }
                          case TracksSort.year:
                            {
                              return Text(
                                '${track.year}',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              );
                            }
                          default:
                            return Text(
                              '',
                              style: Theme.of(context).textTheme.headlineMedium,
                            );
                        }
                      },
                      backgroundColor: Theme.of(context).cardTheme.color ??
                          Theme.of(context).cardColor,
                      controller: controller,
                      child: ListView(
                        controller: controller,
                        itemExtent: kMobileTrackTileHeight,
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top +
                              kMobileSearchBarHeight +
                              2 * tileMargin,
                          bottom: Configuration.instance.stickyMiniplayer
                              ? kMobileNowPlayingBarHeight
                              : kMobileBottomPaddingStickyMiniplayer,
                        ),
                        children: collection.tracks
                            .asMap()
                            .entries
                            .map(
                              (track) => Configuration.instance
                                      .addLibraryToPlaylistWhenPlayingFromTracksTab
                                  ? TrackTile(
                                      index: track.key,
                                      track: track.value,
                                    )
                                  : TrackTile(
                                      index: 0,
                                      track: track.value,
                                      group: [
                                        track.value,
                                      ],
                                    ),
                            )
                            .toList(),
                      ),
                    )
                  : Container(
                      // padding: EdgeInsets.only(
                      //   top: MediaQuery.of(context).padding.top +
                      //       kMobileSearchBarHeight +
                      //       2 * tileMargin,
                      // ),
                      child: Center(
                        child: ExceptionWidget(
                          title: Language.instance.NO_COLLECTION_TITLE,
                          subtitle: Language.instance.NO_COLLECTION_SUBTITLE,
                        ),
                      ),
                    ),
            ),
    );
  }
}

class TrackTile extends StatefulWidget {
  final Track track;
  final int index;
  final void Function()? onPressed;
  final Widget? leading;
  final List<Track>? group;
  final Widget? title;
  final Widget? subtitle;
  final bool disableSeparator;
  final bool disableContextMenu;
  const TrackTile({
    Key? key,
    required this.track,
    this.index = 0,
    this.onPressed,
    this.leading,
    this.group,
    this.title,
    this.subtitle,
    this.disableSeparator = false,
    this.disableContextMenu = false,
  });

  TrackTileState createState() => TrackTileState();
}

class TrackTileState extends State<TrackTile> {
  bool hovered = false;
  bool reactToSecondaryPress = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group ?? Collection.instance.tracks;
    final subtitle = [
      if (!widget.track.hasNoAvailableAlbum) widget.track.albumName.overflow,
      if (!widget.track.hasNoAvailableArtists)
        widget.track.trackArtistNames.take(2).join(', ')
    ].join(' • ');
    return isDesktop
        ? MouseRegion(
            onEnter: (e) {
              setState(() {
                hovered = true;
              });
            },
            onExit: (e) {
              setState(() {
                hovered = false;
              });
            },
            child: Listener(
              onPointerDown: (e) {
                reactToSecondaryPress = e.kind == PointerDeviceKind.mouse &&
                    e.buttons == kSecondaryMouseButton;
              },
              onPointerUp: (e) async {
                if (widget.disableContextMenu) return;
                if (!reactToSecondaryPress) return;
                var result = await showMenu(
                  context: context,
                  constraints: BoxConstraints(
                    maxWidth: double.infinity,
                  ),
                  position: RelativeRect.fromLTRB(
                    e.position.dx,
                    e.position.dy,
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.width,
                  ),
                  items: trackPopupMenuItems(
                    widget.track,
                    context,
                  ),
                );
                await trackPopupMenuHandle(
                  context,
                  widget.track,
                  result,
                  // Only used in [SearchTab].
                  recursivelyPopNavigatorOnDeleteIf: () => true,
                );
              },
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (widget.onPressed != null) {
                      widget.onPressed?.call();
                      return;
                    }
                    Playback.instance.open(
                      group,
                      index: widget.index,
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 64.0,
                        height: 48.0,
                        padding: EdgeInsets.only(right: 8.0),
                        alignment: Alignment.center,
                        child: hovered
                            ? IconButton(
                                onPressed: () {
                                  if (widget.onPressed != null) {
                                    widget.onPressed?.call();
                                    return;
                                  }
                                  Playback.instance.open(
                                    group,
                                    index: widget.index,
                                  );
                                },
                                icon: Icon(Icons.play_arrow),
                                splashRadius: 20.0,
                              )
                            : widget.leading ??
                                Text(
                                  '${widget.track.trackNumber}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                      ),
                      Expanded(
                        child: Container(
                          height: 48.0,
                          padding: EdgeInsets.only(right: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.track.trackName,
                            style: Theme.of(context).textTheme.headlineMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 48.0,
                          padding: EdgeInsets.only(right: 16.0),
                          alignment: Alignment.centerLeft,
                          child: () {
                            final elements = <TextSpan>[];
                            widget.track.trackArtistNames
                                .map(
                              (e) => TextSpan(
                                text: e,
                                recognizer: widget.track.uri.isScheme('FILE')
                                    ? (TapGestureRecognizer()
                                      ..onTap = () {
                                        DesktopNowPlayingController.instance
                                            .hide();
                                        navigatorKey.currentState?.push(
                                          PageRouteBuilder(
                                            pageBuilder: ((context, animation,
                                                    secondaryAnimation) =>
                                                FadeThroughTransition(
                                                  animation: animation,
                                                  secondaryAnimation:
                                                      secondaryAnimation,
                                                  child: ArtistScreen(
                                                    artist: Collection
                                                        .instance.artistsSet
                                                        .lookup(Artist(
                                                            artistName: e))!,
                                                  ),
                                                )),
                                          ),
                                        );
                                      })
                                    : null,
                              ),
                            )
                                .forEach((element) {
                              elements.add(element);
                              elements.add(TextSpan(text: ', '));
                            });
                            elements.removeLast();
                            return HyperLink(
                              style: Theme.of(context).textTheme.headlineMedium,
                              text: TextSpan(
                                children: elements,
                              ),
                            );
                          }(),
                        ),
                      ),
                      if (!widget.disableContextMenu)
                        Container(
                          height: 48.0,
                          width: 120.0,
                          padding: EdgeInsets.only(right: 32.0),
                          alignment: Alignment.centerRight,
                          child: Text(
                            widget.track.year.toString(),
                            style: Theme.of(context).textTheme.headlineMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (!widget.disableContextMenu)
                        Container(
                          width: 64.0,
                          height: 56.0,
                          alignment: Alignment.center,
                          child: ContextMenuButton<int>(
                            onSelected: (result) {
                              trackPopupMenuHandle(
                                context,
                                widget.track,
                                result,
                                // Only used in [SearchTab].
                                recursivelyPopNavigatorOnDeleteIf: () => true,
                              );
                            },
                            color: Theme.of(context).iconTheme.color,
                            itemBuilder: (_) => trackPopupMenuItems(
                              widget.track,
                              context,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed ??
                  () => Playback.instance.open(
                        group,
                        index: widget.index,
                      ),
              onLongPress: widget.disableContextMenu ? null : _showBottomSheet,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!widget.disableSeparator)
                    const Divider(
                      height: 1.0,
                      thickness: 1.0,
                      indent: 80.0,
                    ),
                  Container(
                    height: 64.0,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 12.0),
                        widget.leading ??
                            ExtendedImage(
                              image: getAlbumArt(widget.track, small: true),
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
                              widget.title ??
                                  Text(
                                    widget.track.trackName.overflow,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(
                                  height: 2.0,
                                ),
                                widget.subtitle!
                              ] else if (subtitle.isNotEmpty) ...[
                                const SizedBox(
                                  height: 2.0,
                                ),
                                Text(
                                  subtitle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        if (!widget.disableContextMenu)
                          Container(
                            width: 64.0,
                            height: 64.0,
                            alignment: Alignment.center,
                            child: IconButton(
                              onPressed: _showBottomSheet,
                              icon: Icon(Icons.more_vert),
                              iconSize: 24.0,
                              splashRadius: 20.0,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void _showBottomSheet() async {
    int? result;
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: trackPopupMenuItems(widget.track, context).map((item) {
            return PopupMenuItem<int>(
              value: item.value,
              onTap: () {
                result = item.value;
              },
              child: item.child,
            );
          }).toList(),
        ),
      ),
    );
    await trackPopupMenuHandle(
      context,
      widget.track,
      result,
      // Only used in [SearchTab].
      recursivelyPopNavigatorOnDeleteIf: () => true,
    );
  }
}
