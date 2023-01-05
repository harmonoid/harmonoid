/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:media_library/media_library.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import 'package:harmonoid/interface/modern_layout/modern_collection/modern_track.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';

// List<Track> defaultSelectedTracksList = [];

class CustomTracksListModern extends StatefulWidget {
  final List<Track> tracksList;
  const CustomTracksListModern({super.key, required this.tracksList});

  @override
  State<CustomTracksListModern> createState() => _CustomTracksListModernState();
}

class _CustomTracksListModernState extends State<CustomTracksListModern> {
  final controller = ScrollController();
  bool isSelectedTracksMenuMinimized = true;
  bool isSelectedTracksExpanded = false;
  List<Track> selectedTracks = [];

  @override
  Widget build(BuildContext context) {
    Widget selectedTracksMenuRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              selectedTracks = [];
              isSelectedTracksMenuMinimized = true;
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
              if (!isSelectedTracksMenuMinimized)
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
        isSelectedTracksMenuMinimized
            ? Icon(Broken.arrow_up_3)
            : Icon(Broken.arrow_down_2)
      ],
    );

    return widget.tracksList.isNotEmpty
        ? Stack(
            children: [
              DraggableScrollbar.semicircle(
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
                  final track = widget.tracksList[index.clamp(
                    0,
                    widget.tracksList.length - 1,
                  )];
                  switch (Collection.instance.tracksSort) {
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
                          style: Theme.of(context).textTheme.headlineMedium,
                        );
                      }
                    case TracksSort.year:
                      {
                        return Text(
                          '${track.year}',
                          style: Theme.of(context).textTheme.headlineMedium,
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
                  itemExtent: Configuration.instance.trackListTileHeight + 8,
                  padding: EdgeInsets.only(
                    top: kMobileSearchBarHeightModern + tileMargin / 8,
                    bottom: Configuration.instance.stickyMiniplayer
                        ? kMobileNowPlayingBarHeight
                        : kMobileBottomPaddingStickyMiniplayer,
                  ),
                  children: widget.tracksList
                      .asMap()
                      .entries
                      .map(
                        (track) => GestureDetector(
                          onLongPress: () {
                            setState(() {
                              if (selectedTracks.contains(track.value)) {
                                selectedTracks.remove(track.value);
                              } else {
                                selectedTracks.add(track.value);
                              }
                            });
                          },
                          child: Configuration.instance
                                  .addLibraryToPlaylistWhenPlayingFromTracksTab
                              ? TrackTileModern(
                                  index: track.key,
                                  track: track.value,
                                  onPressed: selectedTracks.length > 0
                                      ? () {
                                          setState(() {
                                            if (selectedTracks
                                                .contains(track.value)) {
                                              selectedTracks
                                                  .remove(track.value);
                                            } else {
                                              selectedTracks.add(track.value);
                                            }
                                          });
                                        }
                                      : null,
                                  selectedColor:
                                      selectedTracks.contains(track.value)
                                          ? Theme.of(context)
                                              .listTileTheme
                                              .selectedColor
                                          : null)
                              : TrackTileModern(
                                  index: 0,
                                  track: track.value,
                                  group: [
                                    track.value,
                                  ],
                                  onPressed: selectedTracks.length > 0
                                      ? () {
                                          setState(() {
                                            if (selectedTracks
                                                .contains(track.value)) {
                                              selectedTracks
                                                  .remove(track.value);
                                            } else {
                                              selectedTracks.add(track.value);
                                            }
                                          });
                                        }
                                      : null,
                                  selectedColor: selectedTracks
                                          .contains(track.value)
                                      ? Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Color.fromARGB(255, 222, 222, 222)
                                          : Color.fromARGB(255, 33, 33, 33)
                                      : null),
                        ),
                      )
                      .toList(),
                ),
              ),
              if (selectedTracks.length > 0)
                Positioned(
                  bottom: kMobileNowPlayingBarHeight +
                      kMobileBottomPaddingStickyMiniplayer,
                  child: Center(
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
                                isSelectedTracksMenuMinimized =
                                    !isSelectedTracksMenuMinimized;
                              });
                            },
                            onTapDown: (value) {
                              setState(() {
                                isSelectedTracksExpanded = true;
                              });
                            },
                            onTapUp: (value) {
                              setState(() {
                                isSelectedTracksExpanded = false;
                              });
                            },
                            onTapCancel: () {
                              isSelectedTracksExpanded =
                                  !isSelectedTracksExpanded;
                            },
                            // dragging upwards or downwards
                            onPanEnd: (details) {
                              if (details.velocity.pixelsPerSecond.dy < 0) {
                                setState(() {
                                  isSelectedTracksMenuMinimized = false;
                                });
                              } else if (details.velocity.pixelsPerSecond.dy >
                                  0) {
                                setState(() {
                                  isSelectedTracksMenuMinimized = true;
                                });
                              }
                            },
                            child: AnimatedContainer(
                              clipBehavior: Clip.antiAlias,
                              duration: Duration(seconds: 1),
                              curve: Curves.fastLinearToSlowEaseIn,
                              height: isSelectedTracksMenuMinimized
                                  ? isSelectedTracksExpanded
                                      ? 80
                                      : 85
                                  : isSelectedTracksExpanded
                                      ? 425
                                      : 430,
                              width: isSelectedTracksExpanded ? 375 : 380,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(15),
                              child: isSelectedTracksMenuMinimized
                                  ? FittedBox(child: selectedTracksMenuRow)
                                  : Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        FittedBox(child: selectedTracksMenuRow),
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
                                                  key: ValueKey(
                                                      selectedTracks[i].uri),
                                                  builder: (context) =>
                                                      Dismissible(
                                                    key: ValueKey(
                                                        selectedTracks[i].uri),
                                                    onDismissed: (direction) {
                                                      setState(() {
                                                        selectedTracks
                                                            .removeAt(i);
                                                      });
                                                    },
                                                    child: TrackTileModern(
                                                      displayRightDragHandler:
                                                          true,
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
                                                        selectedTracks[i]
                                                            .trackName,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayMedium
                                                            ?.copyWith(
                                                              color: i <
                                                                      Playback
                                                                          .instance
                                                                          .index
                                                                  ? Theme.of(
                                                                          context)
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                  ),
                ),
            ],
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
          );
  }
}
