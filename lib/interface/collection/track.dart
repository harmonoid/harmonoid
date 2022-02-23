/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///

import 'package:desktop/desktop.dart' as desktop;
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';

class TrackTab extends StatelessWidget {
  final controller = ScrollController();
  TrackTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => isDesktop
          ? collection.tracks.isNotEmpty
              ? desktop.ListTableTheme(
                  data: desktop.ListTableThemeData(
                    highlightColor:
                        Theme.of(context).dividerColor.withOpacity(0.4),
                    hoverColor: Theme.of(context).dividerColor.withOpacity(0.2),
                    borderHighlightColor:
                        Theme.of(context).colorScheme.secondary,
                    borderIndicatorColor:
                        Theme.of(context).colorScheme.secondary,
                    borderHoverColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: desktop.ListTable(
                    onPressed: (index, _) {
                      Playback.instance.open(
                        collection.tracks,
                        index: index,
                      );
                    },
                    onSecondaryPress: (index, position) async {
                      var result = await showMenu(
                        context: context,
                        position: RelativeRect.fromRect(
                          Offset(position.left, position.top) &
                              Size(228.0, 320.0),
                          Rect.fromLTWH(
                            0,
                            0,
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height,
                          ),
                        ),
                        items: trackPopupMenuItems(context),
                      );

                      await trackPopupMenuHandle(
                        context,
                        collection.tracks[index],
                        result,
                      );
                    },
                    colCount: 5,
                    headerColumnBorder: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 0.0,
                    ),
                    tableBorder: desktop.TableBorder(
                      verticalInside: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    itemCount: collection.tracks.length,
                    colFraction: {
                      0: 36.0 / MediaQuery.of(context).size.width,
                      1: 0.36,
                      4: 128.0 / MediaQuery.of(context).size.width,
                    },
                    tableHeaderBuilder: (context, index, constraints) =>
                        Container(
                      height: 36.0,
                      alignment: Alignment.center,
                      child: Text(
                        [
                          '#',
                          Language.instance.TRACK_SINGLE,
                          Language.instance.ARTIST,
                          Language.instance.ALBUM_SINGLE,
                          Language.instance.YEAR
                        ][index],
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                    tableRowBuilder: (context, index, property, constraints) =>
                        Container(
                      constraints: constraints,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                      alignment: property == 0
                          ? Alignment.center
                          : Alignment.centerLeft,
                      child: Text(
                        [
                          '${collection.tracks[index].trackNumber}',
                          collection.tracks[index].trackName,
                          collection.tracks[index].trackArtistNames.join(', '),
                          collection.tracks[index].albumName,
                          collection.tracks[index].year.toString(),
                        ][property],
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
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
                        switch (collection.collectionSortType) {
                          case CollectionSort.aToZ:
                            {
                              return Text(
                                track.trackName[0].toUpperCase(),
                                style: Theme.of(context).textTheme.headline1,
                              );
                            }
                          case CollectionSort.dateAdded:
                            {
                              return Text(
                                '${track.timeAdded.label}',
                                style: Theme.of(context).textTheme.headline4,
                              );
                            }
                          case CollectionSort.year:
                            {
                              return Text(
                                '${track.year}',
                                style: Theme.of(context).textTheme.headline4,
                              );
                            }
                          default:
                            return Text(
                              '',
                              style: Theme.of(context).textTheme.headline4,
                            );
                        }
                      },
                      backgroundColor: Theme.of(context).cardColor,
                      controller: controller,
                      child: ListView(
                        controller: controller,
                        itemExtent: kMobileTrackTileHeight,
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top +
                              kMobileSearchBarHeight +
                              2 * tileMargin,
                        ),
                        children: collection.tracks
                            .map((track) => TrackTile(
                                  track: track,
                                  index: collection.tracks.indexOf(track),
                                ))
                            .toList(),
                      ),
                    )
                  : Center(
                      child: ExceptionWidget(
                        title: Language.instance.NO_COLLECTION_TITLE,
                        subtitle: Language.instance.NO_COLLECTION_SUBTITLE,
                      ),
                    ),
            ),
    );
  }
}

class TrackTile extends StatefulWidget {
  final Track track;
  final int? index;
  final void Function()? onPressed;
  final Widget? leading;
  final List<Track>? group;
  final bool disableContextMenu;
  TrackTile({
    Key? key,
    required this.track,
    this.index,
    this.onPressed,
    this.leading,
    this.group,
    this.disableContextMenu = false,
  });

  TrackTileState createState() => TrackTileState();
}

class TrackTileState extends State<TrackTile> {
  bool hovered = false;
  bool reactToSecondaryPress = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => isDesktop
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
                    elevation: 4.0,
                    context: context,
                    position: RelativeRect.fromRect(
                      Offset(e.position.dx, e.position.dy) & Size(228.0, 320.0),
                      Rect.fromLTWH(
                        0,
                        0,
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height,
                      ),
                    ),
                    items: trackPopupMenuItems(
                      context,
                    ),
                  );
                  await trackPopupMenuHandle(
                    context,
                    widget.track,
                    result,
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
                        collection.tracks,
                        index: collection.tracks.indexOf(widget.track),
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
                                      collection.tracks,
                                      index: collection.tracks
                                          .indexOf(widget.track),
                                    );
                                  },
                                  icon: Icon(Icons.play_arrow),
                                  splashRadius: 20.0,
                                )
                              : widget.leading ??
                                  Text(
                                    '${widget.track.trackNumber}',
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                        ),
                        Expanded(
                          child: Container(
                            height: 48.0,
                            padding: EdgeInsets.only(right: 16.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.track.trackName,
                              style: Theme.of(context).textTheme.headline4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 48.0,
                            padding: EdgeInsets.only(right: 16.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.track.trackArtistNames.take(2).join(', '),
                              style: Theme.of(context).textTheme.headline4,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                              style: Theme.of(context).textTheme.headline4,
                              overflow: TextOverflow.ellipsis,
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
                onTap: () => Playback.instance.open(
                  widget.index == null
                      ? <Track>[widget.track]
                      : widget.group ?? collection.tracks,
                  index: widget.index ?? 0,
                ),
                onLongPress: _showBottomSheet,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Divider(
                      height: 1.0,
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
                              Image(
                                image: collection.getAlbumArt(widget.track),
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
                                  widget.track.trackName.overflow,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                                const SizedBox(
                                  height: 2.0,
                                ),
                                Text(
                                  widget.track.albumName.overflow +
                                      ' • ' +
                                      widget.track.trackArtistNames
                                          .take(2)
                                          .join(', '),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12.0),
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
            ),
    );
  }

  void _showBottomSheet() async {
    var result;
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: trackPopupMenuItems(context),
        ),
      ),
    );
    await trackPopupMenuHandle(
      context,
      widget.track,
      result,
      recursivelyPopNavigatorOnDeleteIf: () => true,
    );
  }
}
