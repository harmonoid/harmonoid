/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:media_library/media_library.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';

class TrackTabModern extends StatefulWidget {
  final List<Track>? tracks;
  final bool isReordable;
  final void Function(int, int)? onReorder;
  final Function()? onTrackTilePressed;
  final ScrollController? reorderableScrollController;
  final Widget? child;
  final Playlist? playlist;
  final EdgeInsets? padding;
  TrackTabModern(
      {Key? key,
      this.tracks,
      this.isReordable = false,
      this.onReorder,
      this.reorderableScrollController,
      this.onTrackTilePressed,
      this.child,
      this.playlist,
      this.padding})
      : super(key: key);

  @override
  _TrackTabModernState createState() => _TrackTabModernState();
}

class _TrackTabModernState extends State<TrackTabModern> {
  final controller = ScrollController();
  List<Track> selectedTracks = [];
  bool isMenuMinimized = true;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Widget defaultSelectedTracksListMenuRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              selectedTracks = [];
              isExpanded = true;
            });
          },
          icon: Icon(Broken.close_circle),
          splashRadius: 20.0,
        ),
        Container(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedTracks.length} Track${selectedTracks.length == 1 ? "" : "s"}',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(fontSize: 26.0),
              ),
              if (!isMenuMinimized)
                Text(
                  "  ${getTotalTracksDurationFormatted(tracks: selectedTracks)}",
                  style: Theme.of(context).textTheme.displayMedium,
                )
            ],
          ),
        ),
        SizedBox(
          width: 32,
        ),
        IconButton(
          onPressed: () => Playback.instance
              .insertAt(selectedTracks, Playback.instance.index + 1),
          tooltip: Language.instance.PLAY_NEXT,
          icon: Icon(Broken.next),
          splashRadius: 20.0,
        ),
        IconButton(
          onPressed: () => Playback.instance.add(selectedTracks),
          tooltip: Language.instance.PLAY_LAST,
          icon: Icon(
            Iconsax.play_add,
          ),
          splashRadius: 20.0,
        ),
        IconButton(
          onPressed: () {
            Playback.instance.open([
              ...selectedTracks,
              if (Configuration.instance.seamlessPlayback)
                ...[...Collection.instance.tracks]..shuffle(),
            ]);
          },
          tooltip: Language.instance.PLAY_ALL,
          icon: Icon(Broken.play_circle),
          splashRadius: 20.0,
        ),
        IconButton(
          onPressed: () {
            Playback.instance.open(
              [...selectedTracks]..shuffle(),
            );
          },
          tooltip: Language.instance.SHUFFLE,
          icon: Icon(Broken.shuffle),
          splashRadius: 20.0,
        ),
        IconButton(
          onPressed: () {
            showAddToPlaylistDialogModern(context, selectedTracks);
          },
          tooltip: Language.instance.PLAYLIST_ADD_DIALOG_TITLE,
          icon: Icon(Broken.music_playlist),
          splashRadius: 20.0,
        ),
        IconButton(
          onPressed: () {
            setState(() {
              selectedTracks = [];
              selectedTracks.addAll(Collection.instance.tracks);
            });
          },
          icon: Icon(Broken.category),
          splashRadius: 20.0,
        ),
        isMenuMinimized ? Icon(Broken.arrow_up_3) : Icon(Broken.arrow_down_2)
      ],
    );

    Widget trackWidgetToDisplay(MapEntry<int, Track> track) {
      return GestureDetector(
        key: ValueKey(track.key),
        onLongPress: () {
          setState(() {
            if (selectedTracks.contains(track.value)) {
              selectedTracks.remove(track.value);
            } else {
              selectedTracks.add(track.value);
            }
          });
        },
        child:
            Configuration.instance.addLibraryToPlaylistWhenPlayingFromTracksTab
                ? TrackTileModern(
                    playlist: widget.playlist,
                    index: track.key,
                    track: track.value,
                    onPressed: selectedTracks.length > 0
                        ? () {
                            setState(() {
                              if (selectedTracks.contains(track.value)) {
                                selectedTracks.remove(track.value);
                              } else {
                                selectedTracks.add(track.value);
                              }
                            });
                          }
                        : () {
                            Playback.instance.open(
                                widget.tracks ?? Collection.instance.tracks,
                                index: track.key);
                          },
                    selectedColor: selectedTracks.contains(track.value)
                        ? Theme.of(context).listTileTheme.selectedColor
                        : null)
                : TrackTileModern(
                    draggableThumbnail: widget.isReordable,
                    disableSeparator: true,
                    playlist: widget.playlist,
                    index: 0,
                    track: track.value,
                    group: [
                      track.value,
                    ],
                    onPressed: selectedTracks.length > 0
                        ? () {
                            setState(() {
                              if (selectedTracks.contains(track.value)) {
                                selectedTracks.remove(track.value);
                              } else {
                                selectedTracks.add(track.value);
                              }
                            });
                          }
                        : () {
                            Playback.instance.open(
                                widget.tracks ?? Collection.instance.tracks,
                                index: track.key);
                          },
                    selectedColor: selectedTracks.contains(track.value)
                        ? Theme.of(context).brightness == Brightness.light
                            ? Color.fromARGB(255, 222, 222, 222)
                            : Color.fromARGB(255, 33, 33, 33)
                        : null,
                  ),
      );
    }

    Widget selectedTracksPreviewContainer = AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: selectedTracks.length > 0
          ? Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMenuMinimized = !isMenuMinimized;
                        });
                      },
                      onTapDown: (value) {
                        setState(() {
                          isExpanded = true;
                        });
                      },
                      onTapUp: (value) {
                        setState(() {
                          isExpanded = false;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      // dragging upwards or downwards
                      onPanEnd: (details) {
                        if (details.velocity.pixelsPerSecond.dy < 0) {
                          setState(() {
                            isMenuMinimized = false;
                          });
                        } else if (details.velocity.pixelsPerSecond.dy > 0) {
                          setState(() {
                            isMenuMinimized = true;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        clipBehavior: Clip.antiAlias,
                        duration: Duration(seconds: 1),
                        curve: Curves.fastLinearToSlowEaseIn,
                        height: isMenuMinimized
                            ? isExpanded
                                ? 80
                                : 85
                            : isExpanded
                                ? 425
                                : 430,
                        width: isExpanded ? 375 : 380,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(15),
                        child: isMenuMinimized
                            ? FittedBox(child: defaultSelectedTracksListMenuRow)
                            : Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FittedBox(
                                      child: defaultSelectedTracksListMenuRow),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Expanded(
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: ReorderableListView.builder(
                                        onReorder: (oldIndex, newIndex) {
                                          setState(() {
                                            if (newIndex > oldIndex) {
                                              newIndex -= 1;
                                            }
                                            final item = selectedTracks
                                                .removeAt(oldIndex);

                                            selectedTracks.insert(
                                                newIndex, item);
                                          });
                                        },
                                        physics: BouncingScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        itemCount: selectedTracks.length,
                                        itemBuilder: (context, i) {
                                          return Builder(
                                            key:
                                                ValueKey(selectedTracks[i].uri),
                                            builder: (context) => Dismissible(
                                              key: ValueKey(
                                                  selectedTracks[i].uri),
                                              onDismissed: (direction) {
                                                setState(() {
                                                  selectedTracks.removeAt(i);
                                                });
                                              },
                                              child: TrackTileModern(
                                                displayRightDragHandler: true,
                                                track: selectedTracks[i],
                                                index: i,
                                                disableContextMenu: true,
                                                disableSeparator: true,
                                                onPressed: () {
                                                  Playback.instance.open(
                                                      selectedTracks,
                                                      index: i);
                                                },
                                                title: Text(
                                                  selectedTracks[i].trackName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium
                                                      ?.copyWith(
                                                        color: i <
                                                                Playback
                                                                    .instance
                                                                    .index
                                                            ? Theme.of(context)
                                                                .textTheme
                                                                .displaySmall
                                                                ?.color
                                                            : null,
                                                      ),
                                                ),
                                                subtitle: Text(
                                                  selectedTracks[i]
                                                      .trackArtistNames
                                                      .take(1)
                                                      .join(', '),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );

    return Stack(
      children: [
        widget.tracks != null
            ? ListView(
                shrinkWrap: true,
                controller: controller,
                padding: widget.padding ??
                    EdgeInsets.only(
                      top: kMobileSearchBarHeightModern + tileMargin / 8,
                      bottom: Configuration.instance.stickyMiniplayer
                          ? kMobileNowPlayingBarHeight
                          : kMobileBottomPaddingStickyMiniplayer,
                    ),
                children: widget.tracks!
                    .asMap()
                    .entries
                    .map((track) => trackWidgetToDisplay(track))
                    .toList(),
              )
            : Consumer<Collection>(
                builder: (context, collection, _) => collection
                        .tracks.isNotEmpty
                    ? DraggableScrollbar.semicircle(
                        heightScrollThumb: 56.0,
                        labelConstraints: BoxConstraints.tightFor(
                          width: 120.0,
                          height: 32.0,
                        ),
                        labelTextBuilder: (offset) {
                          final index = (offset -
                                  (kMobileSearchBarHeightModern +
                                      2 * tileMargin +
                                      MediaQuery.of(context).padding.top)) ~/
                              (Configuration.instance.trackListTileHeight + 8);
                          final track = collection.tracks[index.clamp(
                            0,
                            collection.tracks.length - 1,
                          )];
                          switch (collection.tracksSort) {
                            case TracksSort.aToZ:
                              {
                                return Text(
                                  track.trackName[0].toUpperCase(),
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                );
                              }
                            case TracksSort.dateAdded:
                              {
                                return Text(
                                  '${track.timeAdded.label}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                );
                              }
                            case TracksSort.year:
                              {
                                return Text(
                                  '${track.year}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                );
                              }
                            default:
                              return Text(
                                '',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              );
                          }
                        },
                        backgroundColor: Theme.of(context).cardTheme.color ??
                            Theme.of(context).cardColor,
                        controller: controller,
                        child: ListView(
                          controller: controller,
                          // itemExtent: Configuration.instance.trackListTileHeight + 8,
                          padding: widget.padding ??
                              EdgeInsets.only(
                                  top: 2.0,
                                  // bottom: Configuration.instance.stickyMiniplayer ? kMobileNowPlayingBarHeight : kMobileBottomPaddingStickyMiniplayer,
                                  bottom: selectedTracks.length > 0
                                      ? 85 +
                                          kMobileBottomPaddingStickyMiniplayer *
                                              2 +
                                          kMobileNowPlayingBarHeight
                                      : kMobileBottomPaddingStickyMiniplayer +
                                          kMobileNowPlayingBarHeight),
                          children: collection.tracks
                              .asMap()
                              .entries
                              .map((track) => trackWidgetToDisplay(track))
                              .toList(),
                        ),
                      )
                    : Container(
                        // padding: EdgeInsets.only(
                        //   top: MediaQuery.of(context).padding.top +
                        //       kMobileSearchBarHeightModern +
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
        Positioned(
            bottom: kMobileNowPlayingBarHeight +
                kMobileBottomPaddingStickyMiniplayer,
            child: selectedTracksPreviewContainer)
      ],
    );
  }
}

class TrackTileModern extends StatefulWidget {
  final Track track;
  final int index;
  final void Function()? onPressed;
  final Widget? leading;
  final List<Track>? group;
  final Widget? title;
  final Widget? subtitle;
  final Color? selectedColor;
  final bool disableSeparator;
  final Playlist? playlist;
  final bool disableContextMenu;
  final bool displayRightDragHandler;
  final bool draggableThumbnail;
  const TrackTileModern({
    Key? key,
    required this.track,
    this.index = 0,
    this.onPressed,
    this.leading,
    this.group,
    this.title,
    this.subtitle,
    this.playlist,
    this.selectedColor,
    this.disableSeparator = false,
    this.disableContextMenu = false,
    this.displayRightDragHandler = false,
    this.draggableThumbnail = false,
  });

  TrackTileModernState createState() => TrackTileModernState();
}

class TrackTileModernState extends State<TrackTileModern> {
  bool hovered = false;
  bool reactToSecondaryPress = false;
// Declare a ValueNotifier to store the selected items
  final ValueNotifier<List<Track>> selectedTracks = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    final group = widget.group ?? Collection.instance.tracks;

    String getChoosenTrackTileItem(String trackItemPlace) {
      final formatDate = DateFormat('${Configuration.instance.dateTimeFormat}');
      final formatClock = Configuration.instance.hourFormat12
          ? DateFormat('hh:mm aa')
          : DateFormat('HH:mm');
      String fileUri = path.prettyUri("${widget.track.uri}");
      String dateTimeAddedNotFormatted =
          "${widget.track.timeAdded.year}${widget.track.timeAdded.month.toString().padLeft(2, '0')}${widget.track.timeAdded.day.toString().padLeft(2, '0')}";
      // String clockTimeAddedNotFormatted =
      //     "${Configuration.instance.hourFormat12 ? formatClock.format(widget.track.timeAdded) : widget.track.timeAdded.hour.toString().padLeft(2, '0')}:${widget.track.timeAdded.minute.toString().padLeft(2, '0')}";
      String clockTimeAddedFormatted =
          "${formatClock.format(widget.track.timeAdded)}";

      String trackItemPlaceV = [
        if (trackItemPlace == "none") "",
        if (trackItemPlace == "trackName") widget.track.trackName.overflow,
        if (trackItemPlace == "artistNames")
          widget.track.trackArtistNames.take(2).join(', ').overflow,
        if (trackItemPlace == "albumName") widget.track.albumName.overflow,
        if (trackItemPlace == "albumArtistName")
          widget.track.albumArtistName.overflow,
        if (trackItemPlace == "genre") widget.track.genre.overflow,
        if (trackItemPlace == "duration")
          widget.track.duration?.label ?? Duration.zero.label,
        if (trackItemPlace == "year") getDateFormatted(widget.track.year),
        if (trackItemPlace == "trackNumber") widget.track.trackNumber,
        if (trackItemPlace == "discNumber") widget.track.discNumber,
        if (trackItemPlace == "filenamenoext")
          path.basenameWithoutExtension(fileUri),
        if (trackItemPlace == "extension")
          path.extension(fileUri).substring(1).overflow,
        if (trackItemPlace == "filename") path.basename(fileUri).overflow,
        if (trackItemPlace == "folder")
          // path.dirname(path.fromUri("${widget.track.uri}")),
          path.dirname(fileUri).split('/').last.overflow,
        if (trackItemPlace == "uri") fileUri.overflow,
        if (trackItemPlace == "bitrate")
          "${(widget.track.bitrate! / 1000).round()} kps",
        if (trackItemPlace == "timeAddedDate")
          formatDate.format(DateTime.parse(dateTimeAddedNotFormatted)),
        if (trackItemPlace == "timeAddedClock") clockTimeAddedFormatted,
        if (trackItemPlace == "timeAdded")
          "${formatDate.format(DateTime.parse(dateTimeAddedNotFormatted))}, $clockTimeAddedFormatted",
      ].join('');

      return trackItemPlaceV;
    }

    final subtitle = [
      if (!widget.track.hasNoAvailableArtists)
        widget.track.trackArtistNames.take(2).join(', '),
      if (!widget.track.hasNoAvailableAlbum) widget.track.albumName.overflow
    ].join(' • ');
    return Consumer<Playback>(
      builder: (context, playback, child) {
        bool isTrackCurrentlyPlaying = playback.tracks.isNotEmpty &&
            playback.tracks[playback.tracks.length != playback.tracks.length
                    ? 0
                    : playback.index] ==
                widget.track &&
            playback.index == widget.index;
        return Material(
          color: isTrackCurrentlyPlaying
              ? Color.alphaBlend(
                  widget.selectedColor?.withAlpha(200) ?? Colors.transparent,
                  NowPlayingColorPalette.instance.modernColor)
              : Color.alphaBlend(
                  widget.selectedColor ?? Colors.transparent,
                  Theme.of(context).cardTheme.color ?? Colors.transparent,
                ),
          child: InkWell(
            highlightColor: Color.fromARGB(60, 0, 0, 0),
            splashColor: Colors.transparent,
            onTap: widget.onPressed ??
                () async => isTrackCurrentlyPlaying
                    ? playback.playOrPause()
                    : await playback.open(
                        group,
                        index: widget.index,
                      ),
            // onLongPress:
            //     widget.disableContextMenu ? null : showTrackDialog,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!widget.disableSeparator)
                  Divider(
                    height: 1.0,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                Container(
                  height: Configuration.instance.trackListTileHeight,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 4.0),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 12.0),
                      Stack(
                        children: [
                          widget.leading ??
                              CustomTrackThumbnailModern(
                                scale: 1,
                                borderRadius: 8,
                                blur: 2,
                                media: widget.track,
                              ),
                          if (widget.draggableThumbnail)
                            ReorderableDragStartListener(
                              index: widget.index,
                              child: Container(
                                color: Colors.transparent,
                                height:
                                    Configuration.instance.trackListTileHeight,
                                width: Configuration
                                    .instance.trackThumbnailSizeinList,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // check if first row isnt empty
                            if (Configuration
                                        .instance.trackTileFirstRowFirstItem !=
                                    "none" ||
                                Configuration
                                        .instance.trackTileFirstRowSecondItem !=
                                    "none" ||
                                Configuration
                                        .instance.trackTileFirstRowThirdItem !=
                                    "none")
                              Text(
                                // widget.track.trackName.overflow,
                                [
                                  if (Configuration.instance
                                          .trackTileFirstRowFirstItem !=
                                      "none")
                                    getChoosenTrackTileItem(Configuration
                                        .instance.trackTileFirstRowFirstItem),
                                  if (Configuration.instance
                                          .trackTileFirstRowSecondItem !=
                                      "none")
                                    getChoosenTrackTileItem(Configuration
                                        .instance.trackTileFirstRowSecondItem),
                                  if (Configuration.instance
                                              .trackTileFirstRowThirdItem !=
                                          "none" &&
                                      Configuration.instance
                                          .trackTileDisplayThirdItemInRows)
                                    getChoosenTrackTileItem(Configuration
                                        .instance.trackTileFirstRowThirdItem)
                                ].join(
                                    ' ${Configuration.instance.trackTileSeparator} '),
                                overflow: TextOverflow.ellipsis,

                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      fontSize: Configuration
                                              .instance.trackListTileHeight *
                                          0.2,
                                      color: isTrackCurrentlyPlaying
                                          ? Colors.white.withAlpha(170)
                                          : null,
                                    ),
                              ),
                            // check if second row isnt empty
                            if (Configuration.instance.trackTileSecondRowFirstItem != "none" ||
                                Configuration.instance
                                        .trackTileSecondRowSecondItem !=
                                    "none" ||
                                Configuration
                                        .instance.trackTileSecondRowThirdItem !=
                                    "none")
                              Text(
                                [
                                  if (Configuration.instance
                                          .trackTileSecondRowFirstItem !=
                                      "none")
                                    getChoosenTrackTileItem(Configuration
                                        .instance.trackTileSecondRowFirstItem),
                                  if (Configuration.instance
                                          .trackTileSecondRowSecondItem !=
                                      "none")
                                    getChoosenTrackTileItem(Configuration
                                        .instance.trackTileSecondRowSecondItem),
                                  if (Configuration.instance
                                              .trackTileSecondRowThirdItem !=
                                          "none" &&
                                      Configuration.instance
                                          .trackTileDisplayThirdItemInRows)
                                    getChoosenTrackTileItem(Configuration
                                        .instance.trackTileSecondRowThirdItem)
                                ].join(
                                    ' ${Configuration.instance.trackTileSeparator} '),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                      fontSize: Configuration
                                              .instance.trackListTileHeight *
                                          0.18,
                                      fontWeight: FontWeight.w500,
                                      color: isTrackCurrentlyPlaying
                                          ? Colors.white.withAlpha(140)
                                          : null,
                                    ),
                              ),
                            // check if third row isnt empty
                            if (Configuration
                                    .instance.trackTileDisplayThirdRow &&
                                (Configuration
                                            .instance.trackTileThirdRowFirstItem !=
                                        "none" ||
                                    Configuration.instance
                                            .trackTileThirdRowSecondItem !=
                                        "none" ||
                                    Configuration.instance
                                            .trackTileThirdRowThirdItem !=
                                        "none"))
                              Text(
                                [
                                  if (Configuration.instance
                                          .trackTileThirdRowFirstItem !=
                                      "none")
                                    getChoosenTrackTileItem(Configuration
                                        .instance.trackTileThirdRowFirstItem),
                                  if (Configuration.instance
                                          .trackTileThirdRowSecondItem !=
                                      "none")
                                    getChoosenTrackTileItem(Configuration
                                        .instance.trackTileThirdRowSecondItem),
                                  if (Configuration.instance
                                              .trackTileThirdRowThirdItem !=
                                          "none" &&
                                      Configuration.instance
                                          .trackTileDisplayThirdItemInRows)
                                    getChoosenTrackTileItem(Configuration
                                        .instance.trackTileThirdRowThirdItem)
                                ].join(
                                    ' ${Configuration.instance.trackTileSeparator} '),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                      fontSize: Configuration
                                              .instance.trackListTileHeight *
                                          0.165,
                                      color: isTrackCurrentlyPlaying
                                          ? Colors.white.withAlpha(120)
                                          : null,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      if (Configuration.instance.trackTileRightFirstItem !=
                              "none" ||
                          Configuration.instance.trackTileRightSecondItem !=
                              "none")
                        const SizedBox(width: 12.0),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (Configuration.instance.trackTileRightFirstItem !=
                              "none")
                            Text(
                              getChoosenTrackTileItem(Configuration
                                  .instance.trackTileRightFirstItem),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                    fontSize: Configuration
                                            .instance.trackListTileHeight *
                                        0.18,
                                    fontWeight: FontWeight.w500,
                                    color: isTrackCurrentlyPlaying
                                        ? Colors.white.withAlpha(160)
                                        : null,
                                  ),
                            ),
                          if (Configuration.instance.trackTileRightFirstItem !=
                                  "none" &&
                              Configuration.instance.trackTileRightSecondItem !=
                                  "none")
                            const SizedBox(height: 4.0),
                          if (Configuration.instance.trackTileRightSecondItem !=
                              "none")
                            Text(
                              getChoosenTrackTileItem(Configuration
                                  .instance.trackTileRightSecondItem),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                    fontSize: Configuration
                                            .instance.trackListTileHeight *
                                        0.18,
                                    fontWeight: FontWeight.w500,
                                    color: isTrackCurrentlyPlaying
                                        ? Colors.white.withAlpha(160)
                                        : null,
                                  ),
                            ),
                        ],
                      ),
                      if (!widget.disableContextMenu)
                        Container(
                          width: 46.0,
                          alignment: Alignment.center,
                          child: FittedBox(
                            child: IconButton(
                              onPressed: () => showTrackDialog(
                                context,
                                widget.track,
                                widget.leading,
                                widget.playlist,
                              ),
                              icon: RotatedBox(
                                quarterTurns: 1,
                                child: Icon(
                                  Broken.more,
                                  size: 20,
                                ),
                              ),
                              color: isTrackCurrentlyPlaying
                                  ? Colors.white.withAlpha(160)
                                  : null,
                            ),
                          ),
                        ),
                      if (widget.displayRightDragHandler)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 12,
                            ),
                            ReorderableDragStartListener(
                              index: widget.index,
                              child: FittedBox(
                                child: Icon(
                                  Broken.menu_1,
                                  color: isTrackCurrentlyPlaying
                                      ? null
                                      : Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.color,
                                ),
                              ),
                            ),
                            Container(
                              width: 36.0,
                              alignment: Alignment.center,
                              child: FittedBox(
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: IconButton(
                                    onPressed: () => showTrackDialog(
                                        context,
                                        widget.track,
                                        widget.leading,
                                        widget.playlist),
                                    icon: Icon(
                                      Broken.more,
                                      size: 20,
                                      color: isTrackCurrentlyPlaying
                                          ? null
                                          : Theme.of(context)
                                              .textTheme
                                              .displayMedium
                                              ?.color,
                                    ),
                                  ),
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
        );
      },
    );
  }
}

Color changeColorSaturation(Color color) =>
    HSLColor.fromColor(color).withSaturation(0.22).toColor();

Color changeColorLightness(Color color) =>
    HSLColor.fromColor(color).withLightness(0.08).toColor();
