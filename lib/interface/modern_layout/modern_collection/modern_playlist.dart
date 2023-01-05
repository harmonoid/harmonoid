/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/interface/modern_layout/buttons_widgets/buttons.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_track.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/web/utils/widgets.dart';

class PlaylistTabModern extends StatelessWidget {
  final TextEditingController _controller = new TextEditingController();
  final ValueNotifier<int> index = ValueNotifier(
    Configuration.instance.libraryTab,
  );
  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          // floatingActionButton: ValueListenableBuilder(
          //   valueListenable: index,
          //   builder: (context, value, child) => AnimatedSwitcher(
          //     duration: const Duration(milliseconds: 200),
          //     reverseDuration: const Duration(milliseconds: 200),
          //     switchInCurve: Curves.easeInOut,
          //     switchOutCurve: Curves.easeInOut,
          //     transitionBuilder: (child, value) => FadeTransition(
          //       opacity: value,
          //       child: child,
          //     ),
          //     child: MiniNowPlayingBarRefreshCollectionButton(
          //       index: index,
          //     ),
          //   ),
          // ),
          body: CustomListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              top: isDesktop
                  ? 20.0
                  : kMobileSearchBarHeightModern +
                      2 * tileMargin +
                      MediaQuery.of(context).padding.top,
            ),
            children: <Widget>[
              if (isDesktop)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Language.instance.PLAYLIST,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(fontSize: 20.0),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 2.0),
                      Text(Language.instance.PLAYLISTS_SUBHEADER),
                      const SizedBox(
                        height: 16.0,
                      ),
                    ],
                  ),
                ),
              if (isDesktop)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Flex(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    direction: Axis.horizontal,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (isDesktop) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  Language.instance.CREATE_NEW_PLAYLIST,
                                ),
                                content: Container(
                                  height: 40.0,
                                  alignment: Alignment.center,
                                  margin:
                                      EdgeInsets.only(top: 0.0, bottom: 0.0),
                                  padding: EdgeInsets.only(top: 2.0),
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus) {
                                        HotKeys.instance.disableSpaceHotKey();
                                      } else {
                                        HotKeys.instance.enableSpaceHotKey();
                                      }
                                    },
                                    child: TextField(
                                      autofocus: true,
                                      controller: _controller,
                                      cursorWidth: 1.0,
                                      onSubmitted: (String value) async {
                                        if (value.isNotEmpty) {
                                          FocusScope.of(context).unfocus();
                                          await Collection.instance
                                              .playlistCreateFromName(value);
                                          _controller.clear();
                                          Navigator.of(context).maybePop();
                                        }
                                      },
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                      decoration: inputDecoration(
                                        context,
                                        Language
                                            .instance.PLAYLISTS_TEXT_FIELD_HINT,
                                      ),
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      Language.instance.OK,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (_controller.text.isNotEmpty) {
                                        FocusScope.of(context).unfocus();
                                        await collection.playlistCreateFromName(
                                            _controller.text);
                                        _controller.clear();
                                        Navigator.of(context).maybePop();
                                      }
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      Language.instance.CANCEL,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    onPressed: Navigator.of(context).maybePop,
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: Text(
                          Language.instance.CREATE.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      TextButton(
                        onPressed: () {
                          if (isDesktop) {
                            showDialog(
                              context: context,
                              builder: (context) => PlaylistImportDialog(),
                            );
                          }
                        },
                        child: Text(
                          Language.instance.IMPORT.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(
                height: 4.0,
              ),
              if (isDesktop)
                const SizedBox(
                  height: 16.0,
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 12.0,
                    ),
                    Expanded(
                      child: Text(
                        "${collection.playlists.length} ${Language.instance.PLAYLIST}",
                        style: Theme.of(context).textTheme.displayLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FittedBox(child: ImportPlaylistButton()),
                    SizedBox(
                      width: 8.0,
                    ),
                    FittedBox(child: CreatePlaylistButton()),
                  ],
                ),
              ),
              ...Collection.instance.playlists
                  .map(
                    (e) => PlaylistTileModern(
                      playlist: e,
                      playlistIndex:
                          Collection.instance.playlists.toList().indexOf(e),
                      enableTrailingButton: true,
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      },
    );
  }
}

class PlaylistThumbnailModern extends StatelessWidget {
  final LinkedHashSet<Track> tracks;
  final double width;
  final double? height;
  final bool encircle;
  final bool mini;
  const PlaylistThumbnailModern({
    Key? key,
    required this.tracks,
    required this.width,
    this.height,
    this.encircle = true,
    this.mini = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (encircle) {
      return Card(
        elevation:
            Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              16 * Configuration.instance.borderRadiusMultiplier),
        ),
        child: Padding(
          padding: EdgeInsets.all(mini ? 4.0 : 8.0),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    14 * Configuration.instance.borderRadiusMultiplier)),
            child: _child(
              context,
              width - (mini ? 8.0 : 16.0),
              (height ?? width) - (mini ? 8.0 : 16.0),
              mini,
            ),
          ),
        ),
      );
    } else {
      return _child(
        context,
        width,
        height ?? width,
        mini,
      );
    }
  }

  Widget _child(BuildContext context, double width, double height, bool mini) {
    final tracks = this.tracks.take(4).toList();
    if (tracks.length > 3) {
      return Container(
        height: height,
        width: width,
        child: Column(
          children: [
            Row(
              children: [
                ExtendedImage(
                  image: getAlbumArt(tracks[0], small: mini),
                  height: height / 2 - (!mini ? 4.0 : 0.0),
                  width: width / 2 - (!mini ? 4.0 : 0.0),
                  fit: BoxFit.cover,
                ),
                if (!mini) SizedBox(height: 8.0),
                ExtendedImage(
                  image: getAlbumArt(tracks[1], small: mini),
                  height: height / 2 - (!mini ? 4.0 : 0.0),
                  width: width / 2 - (!mini ? 4.0 : 0.0),
                  fit: BoxFit.cover,
                ),
              ],
            ),
            Row(
              children: [
                ExtendedImage(
                  image: getAlbumArt(tracks[2], small: mini),
                  height: height / 2 - (!mini ? 4.0 : 0.0),
                  width: width / 2 - (!mini ? 4.0 : 0.0),
                  fit: BoxFit.cover,
                ),
                if (!mini) SizedBox(height: 8.0),
                ExtendedImage(
                  image: getAlbumArt(tracks[3], small: mini),
                  height: height / 2 - (!mini ? 4.0 : 0.0),
                  width: width / 2 - (!mini ? 4.0 : 0.0),
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ],
        ),
      );
    } else if (tracks.length == 3) {
      return Container(
        height: height,
        width: width,
        child: Row(
          children: [
            ExtendedImage(
              image: getAlbumArt(tracks[0], small: mini),
              height: height,
              width: width / 2 - (!mini ? 4.0 : 0.0),
              fit: BoxFit.cover,
            ),
            if (!mini) SizedBox(width: 8.0),
            Column(
              children: [
                ExtendedImage(
                  image: getAlbumArt(tracks[1], small: mini),
                  height: height / 2 - (!mini ? 4.0 : 0.0),
                  width: width / 2 - (!mini ? 4.0 : 0.0),
                  fit: BoxFit.cover,
                ),
                if (!mini) SizedBox(height: 8.0),
                ExtendedImage(
                  image: getAlbumArt(tracks[2], small: mini),
                  height: height / 2 - (!mini ? 4.0 : 0.0),
                  width: width / 2 - (!mini ? 4.0 : 0.0),
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ],
        ),
      );
    } else if (tracks.length == 2) {
      return Container(
        height: height,
        width: width,
        child: Row(
          children: [
            ExtendedImage(
              image: getAlbumArt(tracks[0], small: mini),
              height: height,
              width: width / 2 - (!mini ? 4.0 : 0.0),
              fit: BoxFit.cover,
            ),
            if (!mini) SizedBox(width: 8.0),
            ExtendedImage(
              image: getAlbumArt(tracks[1], small: mini),
              height: height,
              width: width / 2 - (!mini ? 4.0 : 0.0),
              fit: BoxFit.cover,
            ),
          ],
        ),
      );
    } else if (tracks.length == 1) {
      return ExtendedImage(
        image: getAlbumArt(tracks[0], small: mini),
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        child: Icon(
          Broken.musicnote,
          color: Theme.of(context).primaryColor,
          size: width / 2,
        ),
      );
    }
  }
}

class PlaylistTileModern extends StatefulWidget {
  final bool enableTrailingButton;
  final Playlist playlist;
  final int playlistIndex;
  final void Function()? onTap;

  PlaylistTileModern({
    Key? key,
    required this.playlist,
    required this.playlistIndex,
    this.enableTrailingButton: false,
    this.onTap,
  }) : super(key: key);

  @override
  PlaylistTileModernState createState() => PlaylistTileModernState();
}

class PlaylistTileModernState extends State<PlaylistTileModern> {
  bool reactToSecondaryPress = false;

  List<PopupMenuItem<int>> get items => [
        PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          value: 0,
          child: ListTile(
            leading: Icon(Platform.isWindows
                ? FluentIcons.play_24_regular
                : Broken.play_circle),
            title: Text(
              Language.instance.PLAY,
              style:
                  isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
            ),
          ),
        ),
        PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          value: 1,
          child: ListTile(
            leading: Icon(Platform.isWindows
                ? FluentIcons.arrow_shuffle_24_regular
                : Broken.shuffle),
            title: Text(
              Language.instance.SHUFFLE,
              style:
                  isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
            ),
          ),
        ),
        PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          value: 5,
          child: ListTile(
            leading: Icon(Platform.isWindows
                ? FluentIcons.add_12_filled
                : Broken.music_playlist),
            title: Text(
              Language.instance.ADD_TO_PLAYLIST,
              style:
                  isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
            ),
          ),
        ),
        PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          value: 2,
          child: ListTile(
            leading: Icon(Platform.isWindows
                ? FluentIcons.delete_16_regular
                : Broken.music_square_remove),
            title: Text(
              Language.instance.DELETE,
              style:
                  isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
            ),
          ),
        ),
        PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          value: 6,
          child: ListTile(
            leading: Icon(
              Platform.isWindows ? FluentIcons.rename_16_regular : Broken.text,
            ),
            title: Text(
              Language.instance.RENAME,
              style:
                  isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
            ),
          ),
        ),
        PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          value: 4,
          child: ListTile(
            leading: Icon(
                Platform.isWindows ? FluentIcons.next_16_filled : Broken.next),
            title: Text(
              Language.instance.PLAY_NEXT,
              style:
                  isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
            ),
          ),
        ),
        PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          value: 3,
          child: ListTile(
            leading: Icon(Platform.isWindows
                ? FluentIcons.music_note_2_16_regular
                : Iconsax.play_add),
            title: Text(
              Language.instance.PLAY_LAST,
              style:
                  isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
            ),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        reactToSecondaryPress = e.kind == PointerDeviceKind.mouse &&
            e.buttons == kSecondaryMouseButton;
      },
      onPointerUp: (e) async {
        if (!reactToSecondaryPress) return;
        if (!widget.enableTrailingButton) return;
        if (widget.playlist.id < 0) return;
        final result = await showMenu(
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
          items: items,
        );
        await playlistPopupMenuHandleModern(context, widget.playlist, result);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap ??
              () async {
                Playback.instance.interceptPositionChangeRebuilds = true;
                Iterable<Color>? palette;
                // try {
                //   for (final track in widget.playlist.tracks.take(3)) {
                //     await precacheImage(
                //       getAlbumArt(
                //         track,
                //       ),
                //       context,
                //     );
                //   }
                // } catch (exception, stacktrace) {
                //   debugPrint(exception.toString());
                //   debugPrint(stacktrace.toString());
                // }
                try {
                  if (isMobile && widget.playlist.tracks.isNotEmpty) {
                    final result = await PaletteGenerator.fromImageProvider(
                      getAlbumArt(
                        widget.playlist.tracks.first,
                        small: true,
                      ),
                    );
                    palette = result.colors;
                  }
                  if (!Configuration.instance.stickyMiniplayer)
                    MobileNowPlayingController.instance.hide();
                } catch (exception, stacktrace) {
                  debugPrint(exception.toString());
                  debugPrint(stacktrace.toString());
                }
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: PlaylistScreenModern(
                        playlist: widget.playlist,
                        playlistIndex: widget.playlistIndex,
                        palette: palette,
                      ),
                    ),
                  ),
                );
                Timer(const Duration(milliseconds: 400), () {
                  Playback.instance.interceptPositionChangeRebuilds = false;
                });
              },
          onLongPress: widget.playlist.id < 0 ||
                  isDesktop ||
                  !widget.enableTrailingButton
              ? null
              : () async {
                  int? result;
                  showPlaylistDialog(
                      context, widget.playlist, widget.playlistIndex);
                  // await showModalBottomSheet(
                  //   isScrollControlled: true,
                  //   context: context,
                  //   builder: (context) => Container(
                  //     child: Column(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: items
                  //           .map(
                  //             (item) => PopupMenuItem(
                  //               child: item.child,
                  //               onTap: () => result = item.value,
                  //             ),
                  //           )
                  //           .toList(),
                  //     ),
                  //   ),
                  // );
                  // await playlistPopupMenuHandleModern(
                  //     context, widget.playlist, result);
                },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Divider(
              //   height: 1.0,
              //   thickness: 2,
              // ),
              Container(
                // height: 64.0,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 12.0),
                    Container(
                      // height: 56.0,
                      // width: 56.0,
                      alignment: Alignment.center,
                      child: Hero(
                        tag: 'playlist_art_${widget.playlist.name}',
                        child: PlaylistThumbnailModern(
                          tracks: widget.playlist.tracks,
                          width: 68.0,
                          mini: true,
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
                            {
                                  kHistoryPlaylist: Language.instance.HISTORY,
                                  kLikedSongsPlaylist:
                                      Language.instance.LIKED_SONGS,
                                }[widget.playlist.id] ??
                                widget.playlist.name.overflow,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  letterSpacing: isDesktop ? 0.2 : 0.0,
                                ),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            [
                              Language.instance.N_TRACKS.replaceAll(
                                'N',
                                '${widget.playlist.tracks.length}',
                              ),
                              // if (widget.playlist.tracks.length > 0)
                              //   getTotalTracksDurationFormatted(
                              //       tracks: widget.playlist.tracks.toList())
                            ].join(' • '),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    if (widget.playlist.id >= 0 &&
                        isMobile &&
                        widget.enableTrailingButton)
                      Container(
                        width: 64.0,
                        height: 64.0,
                        alignment: Alignment.center,
                        child: IconButton(
                          onPressed: () {
                            showPlaylistDialog(
                                context, widget.playlist, widget.playlistIndex);
                          },
                          icon: RotatedBox(
                            quarterTurns: 1,
                            child: Icon(Broken.more),
                          ),
                          iconSize: 24.0,
                          splashRadius: 20.0,
                        ),
                      )
                    else if (widget.playlist.id >= 0 &&
                        isDesktop &&
                        widget.enableTrailingButton)
                      Container(
                        width: 64.0,
                        height: 64.0,
                        alignment: Alignment.center,
                        child: ContextMenuButton<int>(
                          onSelected: (result) => playlistPopupMenuHandleModern(
                              context, widget.playlist, result),
                          color: Theme.of(context).iconTheme.color,
                          itemBuilder: (_) => items,
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
}

class PlaylistScreenModern extends StatefulWidget {
  final Playlist playlist;
  final int playlistIndex;
  final Iterable<Color>? palette;

  const PlaylistScreenModern({
    Key? key,
    required this.playlist,
    required this.playlistIndex,
    this.palette,
  }) : super(key: key);
  PlaylistScreenModernState createState() => PlaylistScreenModernState();
}

class PlaylistScreenModernState extends State<PlaylistScreenModern>
    with SingleTickerProviderStateMixin {
  ScrollController controller =
      ScrollController(/* initialScrollOffset: 96.0 */);
  ScrollPhysics? physics = NeverScrollableScrollPhysics();
  undoRemoveFromPlaylist(
      Playlist playlist, List<Track> tracks, int index) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color.alphaBlend(
            NowPlayingColorPalette.instance.modernColor.withAlpha(150),
            Theme.of(context).cardTheme.color!),
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              24 * Configuration.instance.borderRadiusMultiplier),
        ),
        dismissDirection: DismissDirection.up,
        margin: EdgeInsets.only(
          bottom: kMobileNowPlayingBarHeight,
          // bottom: MediaQuery.of(context).size.height - 200,
          right: 20,
          left: 20,
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              // width: 100,
              child: Text(
                'Undo Changes?',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
              ),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Color.alphaBlend(
                      NowPlayingColorPalette.instance.modernColor
                          .withAlpha(150),
                      Theme.of(context).colorScheme.primary),
                ),
              ),
              onPressed: () async {
                await Collection.instance
                    .playlistInsertTracks(playlist, tracks, index);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: Text(
                'Undo',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          ],
        ),
      ),
    );
  }

  bool isReordable = false;
  List<Track> selectedTracks = [];
  bool isMenuMinimized = true;
  bool isExpanded = false;
  ScrollController reorderableScrollController = ScrollController();
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

    Color currentTrackColor = NowPlayingColorPalette.instance.modernColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final brMultiplier = Configuration.instance.borderRadiusMultiplier;

    return Consumer<Collection>(
      builder: (context, collection, _) {
        final tracks =
            collection.playlists.toList()[widget.playlistIndex].tracks.toList();
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Broken.arrow_left_2),
            ),
            actions: [
              IconButton(
                tooltip: Language.instance.ADD_TO_NOW_PLAYING,
                onPressed: () => Playback.instance.add(tracks),
                icon: Icon(Broken.play_cricle),
              ),
              IconButton(
                tooltip:
                    !isReordable ? "Enable Reordering" : "Disable Reordering",
                onPressed: () => setState(() {
                  isReordable = !isReordable;
                }),
                icon: isReordable
                    ? Icon(Broken.forward_item)
                    : Icon(Broken.lock_1),
              ),
              MobileAppBarOverflowButtonModern(),
            ],
          ),
          body: NowPlayingBarScrollHideNotifier(
              child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(16.0 * brMultiplier),
                          ),
                          child: Hero(
                            tag: 'playlist_art_${widget.playlist.name}',
                            child: PlaylistThumbnailModern(
                              tracks: widget.playlist.tracks,
                              width: MediaQuery.of(context).size.width / 3,
                              encircle: false,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 18.0,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 14.0),
                                child: Text(
                                  {
                                        kHistoryPlaylist:
                                            Language.instance.HISTORY,
                                        kLikedSongsPlaylist:
                                            Language.instance.LIKED_SONGS,
                                      }[widget.playlist.id] ??
                                      widget.playlist.name.overflow,
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                ),
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 14.0),
                                child: Text(
                                  [
                                    Language.instance.N_TRACKS.replaceAll(
                                      'N',
                                      '${widget.playlist.tracks.length}',
                                    ),
                                    if (widget.playlist.tracks.length > 0)
                                      getTotalTracksDurationFormatted(
                                          tracks:
                                              widget.playlist.tracks.toList())
                                  ].join(' - '),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(fontSize: 14),
                                ),
                              ),
                              const SizedBox(
                                height: 18.0,
                              ),
                              Row(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceEvenly,
                                children: [
                                  Spacer(),
                                  FittedBox(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Playback.instance.open(
                                          [...widget.playlist.tracks]
                                            ..shuffle(),
                                        );
                                      },
                                      child: Icon(Broken.shuffle),
                                    ),
                                  ),
                                  Spacer(),
                                  FittedBox(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Playback.instance.open(
                                          [
                                            ...widget.playlist.tracks,
                                            if (Configuration
                                                .instance.seamlessPlayback)
                                              ...[...Collection.instance.tracks]
                                                ..shuffle()
                                          ],
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Broken.play),
                                          const SizedBox(
                                            width: 8.0,
                                          ),
                                          Text(Language.instance.PLAY_ALL),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: selectedTracks.length > 0
                              ? kMobileNowPlayingBarHeight +
                                  85 +
                                  kMobileBottomPaddingStickyMiniplayer * 2
                              : kMobileNowPlayingBarHeight +
                                  kMobileBottomPaddingStickyMiniplayer),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12)),
                      child: CupertinoScrollbar(
                        radius: Radius.circular(24.0 *
                            Configuration.instance.borderRadiusMultiplier),
                        thickness: 4.0,
                        child: ReorderableListView(
                          physics: BouncingScrollPhysics(),
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item =
                                  widget.playlist.tracks.toList()[oldIndex];
                              Collection.instance
                                  .playlistRemoveTrack(widget.playlist, item);
                              Collection.instance.playlistInsertTracks(
                                  widget.playlist, [item], newIndex);
                            });
                          },
                          children: tracks.asMap().entries.map(
                            (track) {
                              final index = track.key;
                              return Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction) async {
                                  await Collection.instance.playlistRemoveTrack(
                                    widget.playlist,
                                    tracks[index],
                                  );
                                  undoRemoveFromPlaylist(
                                      widget.playlist, [tracks[index]], index);
                                },
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        GestureDetector(
                                          key: ValueKey(index),
                                          onLongPress: () {
                                            if (!isReordable) {
                                              setState(() {
                                                if (selectedTracks
                                                    .contains(tracks[index])) {
                                                  selectedTracks
                                                      .remove(tracks[index]);
                                                } else {
                                                  selectedTracks
                                                      .add(tracks[index]);
                                                }
                                              });
                                            }
                                          },
                                          child: TrackTileModern(
                                            draggableThumbnail: isReordable,
                                            disableSeparator: true,
                                            playlist: widget.playlist,
                                            track: tracks[index],
                                            index: index,
                                            selectedColor: selectedTracks
                                                    .contains(tracks[index])
                                                ? Theme.of(context)
                                                    .listTileTheme
                                                    .selectedColor
                                                : null,
                                            onPressed: () {
                                              if (selectedTracks.length == 0) {
                                                Playback.instance.open([
                                                  ...widget.playlist.tracks,
                                                  if (Configuration.instance
                                                      .seamlessPlayback)
                                                    ...[
                                                      ...Collection
                                                          .instance.tracks
                                                    ]..shuffle()
                                                ], index: index);
                                              } else {
                                                setState(() {
                                                  if (selectedTracks.contains(
                                                      tracks[index])) {
                                                    selectedTracks
                                                        .remove(tracks[index]);
                                                  } else {
                                                    selectedTracks
                                                        .add(tracks[index]);
                                                  }
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        Builder(
                                          builder: (context) {
                                            List<Widget> containers =
                                                List.generate(
                                              3,
                                              (index) => Container(
                                                height: 1.5,
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onBackground
                                                        .withAlpha(60),
                                                    borderRadius:
                                                        BorderRadius.horizontal(
                                                            right:
                                                                Radius.circular(
                                                                    10))),
                                                margin:
                                                    EdgeInsets.only(top: 2.0),
                                                width: isReordable ? 8 : 2,
                                              ),
                                            );
                                            return Column(
                                              children: containers,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // CustomScrollView(
              //   controller: reorderableScrollController,
              //   physics: BouncingScrollPhysics(),
              //   slivers: [
              //     // Top Container holding image, info and buttons

              //     SliverToBoxAdapter(
              //       child: Container(
              //         alignment: Alignment.center,
              //         padding: EdgeInsets.all(24.0),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Container(
              //               clipBehavior: Clip.antiAlias,
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(16.0 * brMultiplier),
              //               ),
              //               child: Hero(
              //                 tag: 'playlist_art_${widget.playlist.name}',
              //                 child: PlaylistThumbnailModern(
              //                   tracks: widget.playlist.tracks,
              //                   width: MediaQuery.of(context).size.width / 3,
              //                   encircle: false,
              //                 ),
              //               ),
              //             ),
              //             const SizedBox(
              //               width: 18.0,
              //             ),
              //             Expanded(
              //               child: Column(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   SizedBox(
              //                     height: 18.0,
              //                   ),
              //                   Container(
              //                     padding: EdgeInsets.only(left: 14.0),
              //                     child: Text(
              //                       {
              //                             kHistoryPlaylist: Language.instance.HISTORY,
              //                             kLikedSongsPlaylist: Language.instance.LIKED_SONGS,
              //                           }[widget.playlist.id] ??
              //                           widget.playlist.name.overflow,
              //                       style: Theme.of(context).textTheme.displayLarge,
              //                     ),
              //                   ),
              //                   const SizedBox(
              //                     height: 2.0,
              //                   ),
              //                   Container(
              //                     padding: EdgeInsets.only(left: 14.0),
              //                     child: Text(
              //                       [
              //                         Language.instance.N_TRACKS.replaceAll(
              //                           'N',
              //                           '${widget.playlist.tracks.length}',
              //                         ),
              //                         if (widget.playlist.tracks.length > 0) getTotalTracksDurationFormatted(tracks: widget.playlist.tracks.toList())
              //                       ].join(' - '),
              //                       overflow: TextOverflow.ellipsis,
              //                       maxLines: 1,
              //                       style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14),
              //                     ),
              //                   ),
              //                   const SizedBox(
              //                     height: 18.0,
              //                   ),
              //                   Row(
              //                     // mainAxisAlignment:
              //                     //     MainAxisAlignment.spaceEvenly,
              //                     children: [
              //                       Spacer(),
              //                       FittedBox(
              //                         child: ElevatedButton(
              //                           onPressed: () {
              //                             Playback.instance.open(
              //                               [...widget.playlist.tracks]..shuffle(),
              //                             );
              //                           },
              //                           child: Icon(Broken.shuffle),
              //                         ),
              //                       ),
              //                       Spacer(),
              //                       FittedBox(
              //                         child: ElevatedButton(
              //                           onPressed: () {
              //                             Playback.instance.open(
              //                               [
              //                                 ...widget.playlist.tracks,
              //                                 if (Configuration.instance.seamlessPlayback) ...[...Collection.instance.tracks]..shuffle()
              //                               ],
              //                             );
              //                           },
              //                           child: Row(
              //                             children: [
              //                               Icon(Broken.play),
              //                               const SizedBox(
              //                                 width: 8.0,
              //                               ),
              //                               Text(Language.instance.PLAY_ALL),
              //                             ],
              //                           ),
              //                         ),
              //                       ),
              //                     ],
              //                   )
              //                 ],
              //               ),
              //             )
              //           ],
              //         ),
              //       ),
              //     ),

              //     SliverReorderableList(
              //       itemExtent: Configuration.instance.trackListTileHeight + 8.0,
              //       itemBuilder: (context, index) => Dismissible(
              //         key: UniqueKey(),
              //         onDismissed: (direction) async {
              //           await Collection.instance.playlistRemoveTrack(
              //             widget.playlist,
              //             tracks[index],
              //           );
              //           undoRemoveFromPlaylist(widget.playlist, [tracks[index]], index);
              //         },
              //         child: Column(
              //           children: [
              //             SizedBox(
              //               height: 4.0,
              //             ),
              //             Stack(
              //               alignment: Alignment.centerLeft,
              //               children: [
              //                 GestureDetector(
              //                   key: ValueKey(index),
              //                   onLongPress: () {
              //                     if (!isReordable) {
              //                       setState(() {
              //                         if (selectedTracks.contains(tracks[index])) {
              //                           selectedTracks.remove(tracks[index]);
              //                         } else {
              //                           selectedTracks.add(tracks[index]);
              //                         }
              //                       });
              //                     }
              //                   },
              //                   child: TrackTileModern(
              //                     draggableThumbnail: isReordable,
              //                     disableSeparator: true,
              //                     playlist: widget.playlist,
              //                     track: tracks[index],
              //                     index: index,
              //                     selectedColor: selectedTracks.contains(tracks[index]) ? Theme.of(context).listTileTheme.selectedColor : null,
              //                     onPressed: () {
              //                       if (selectedTracks.length == 0) {
              //                         Playback.instance.open([
              //                           ...widget.playlist.tracks,
              //                           if (Configuration.instance.seamlessPlayback) ...[...Collection.instance.tracks]..shuffle()
              //                         ], index: index);
              //                       } else {
              //                         setState(() {
              //                           if (selectedTracks.contains(tracks[index])) {
              //                             selectedTracks.remove(tracks[index]);
              //                           } else {
              //                             selectedTracks.add(tracks[index]);
              //                           }
              //                         });
              //                       }
              //                     },
              //                   ),
              //                 ),
              //                 Builder(
              //                   builder: (context) {
              //                     List<Widget> containers = List.generate(
              //                       3,
              //                       (index) => Container(
              //                         height: 1.5,
              //                         decoration: BoxDecoration(color: Theme.of(context).colorScheme.onBackground.withAlpha(60), borderRadius: BorderRadius.horizontal(right: Radius.circular(10))),
              //                         margin: EdgeInsets.only(top: 2.0),
              //                         width: isReordable ? 8 : 2,
              //                       ),
              //                     );
              //                     return Column(
              //                       children: containers,
              //                     );
              //                   },
              //                 ),
              //               ],
              //             ),
              //           ],
              //         ),
              //       ),
              //       itemCount: tracks.length,
              //       onReorder: (oldIndex, newIndex) {
              //         setState(() {
              //           if (newIndex > oldIndex) {
              //             newIndex -= 1;
              //           }
              //           final item = widget.playlist.tracks.toList()[oldIndex];
              //           Collection.instance.playlistRemoveTrack(widget.playlist, item);
              //           Collection.instance.playlistInsertTracks(widget.playlist, [item], newIndex);
              //         });
              //       },
              //     ),
              //     SliverPadding(
              //       padding: EdgeInsets.only(bottom: selectedTracks.length > 0 ? kMobileNowPlayingBarHeight + 85 + kMobileBottomPaddingStickyMiniplayer * 2 : kMobileNowPlayingBarHeight + kMobileBottomPaddingStickyMiniplayer),
              //     )
              //   ],
              // ),
              if (selectedTracks.length > 0)
                Positioned(
                    bottom: kMobileNowPlayingBarHeight +
                        kMobileBottomPaddingStickyMiniplayer,
                    child: selectedTracksPreviewContainer)
            ],
          )),
        );
      },
    );
  }
}
