/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/hotkeys.dart';

class PlaylistTab extends StatelessWidget {
  final TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(builder: (context, collection, _) {
      final screen = CustomListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
        ),
        children: <Widget>[
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
                          .headline1
                          ?.copyWith(fontSize: 20.0),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2.0),
                    Text(Language.instance.PLAYLISTS_SUBHEADER),
                    const SizedBox(
                      height: 18.0,
                    ),
                    MaterialButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            contentPadding: const EdgeInsets.fromLTRB(
                                16.0, 16.0, 16.0, 8.0),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  Language.instance.CREATE,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      ?.copyWith(fontSize: 20.0),
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  Language.instance.CREATE_PLAYLIST_SUBHEADER,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                const SizedBox(
                                  height: 18.0,
                                ),
                                Container(
                                  height: 40.0,
                                  width: 280.0,
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
                                              .playlistAdd(value);
                                          _controller.clear();
                                          Navigator.of(context).maybePop();
                                        }
                                      },
                                      cursorColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.black
                                              : Colors.white,
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                      decoration: desktopInputDecoration(
                                        context,
                                        Language
                                            .instance.PLAYLISTS_TEXT_FIELD_HINT,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              MaterialButton(
                                child: Text(
                                  Language.instance.OK,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () async {
                                  if (_controller.text.isNotEmpty) {
                                    FocusScope.of(context).unfocus();
                                    await collection
                                        .playlistAdd(_controller.text);
                                    _controller.clear();
                                    Navigator.of(context).maybePop();
                                  }
                                },
                              ),
                              MaterialButton(
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
                      },
                      padding: EdgeInsets.zero,
                      child: Text(
                        Language.instance.CREATE_NEW_PLAYLIST,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    if (Collection.instance.playlists.isNotEmpty)
                      const SizedBox(
                        height: 16.0,
                      ),
                  ],
                ),
              ),
            ] +
            Collection.instance.playlists
                .map((Playlist playlist) => PlaylistTile(playlist: playlist))
                .toList(),
      );
      return Container(
        alignment: Alignment.topCenter,
        height: MediaQuery.of(context).size.height -
            (desktopTitleBarHeight + kDesktopAppBarHeight),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (Collection.instance.playlists.isNotEmpty)
              Expanded(
                child: screen,
              ),
            if (Collection.instance.playlists.isEmpty) screen,
            if (Collection.instance.playlists.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    Language.instance.NO_PLAYLISTS_FOUND,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class PlaylistThumbnail extends StatelessWidget {
  final List<Track> tracks;
  final double width;
  final bool encircle;
  final bool mini;
  const PlaylistThumbnail({
    Key? key,
    required this.tracks,
    required this.width,
    this.encircle = true,
    this.mini = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (encircle) {
      return Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(width / 2),
        ),
        child: Padding(
          padding: EdgeInsets.all(mini ? 4.0 : 8.0),
          child: ClipOval(
            child: _child(
              context,
              width - (mini ? 8.0 : 16.0),
              mini,
            ),
          ),
        ),
      );
    } else {
      return _child(
        context,
        width,
        mini,
      );
    }
  }

  Widget _child(BuildContext context, double width, bool mini) {
    if (tracks.length > 2) {
      return Container(
        height: width,
        width: width,
        child: Row(
          children: [
            Image(
              image: Collection.instance.getAlbumArt(tracks[tracks.length - 1]),
              height: width,
              width: width / 2 - (!mini ? 12.0 : 0.0),
              fit: BoxFit.cover,
            ),
            if (!mini) SizedBox(width: 8.0),
            Column(
              children: [
                Image(
                  image: Collection.instance
                      .getAlbumArt(tracks[tracks.length - 2]),
                  height: width / 2 - (!mini ? 12.0 : 0.0),
                  width: width / 2 - (!mini ? 4.0 : 0.0),
                  fit: BoxFit.cover,
                ),
                if (!mini) SizedBox(height: 8.0),
                Image(
                  image: Collection.instance
                      .getAlbumArt(tracks[tracks.length - 3]),
                  height: width / 2 - (!mini ? 4.0 : 0.0),
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
        height: width,
        width: width,
        child: Row(
          children: [
            Image(
              image: Collection.instance.getAlbumArt(tracks[tracks.length - 1]),
              height: width,
              width: width / 2 - (!mini ? 12.0 : 0.0),
              fit: BoxFit.cover,
            ),
            if (!mini) SizedBox(width: 8.0),
            Image(
              image: Collection.instance.getAlbumArt(tracks[tracks.length - 2]),
              height: width,
              width: width / 2 - (!mini ? 4.0 : 0.0),
              fit: BoxFit.cover,
            ),
          ],
        ),
      );
    } else if (tracks.length == 1) {
      return Image(
        image: Collection.instance.getAlbumArt(tracks[tracks.length - 1]),
        height: width,
        width: width,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        height: width,
        width: width,
        alignment: Alignment.center,
        child: Icon(
          Icons.music_note,
          color: Theme.of(context).primaryColor,
          size: width / 2,
        ),
      );
    }
  }
}

class PlaylistTile extends StatefulWidget {
  final Playlist playlist;
  final void Function()? onTap;

  PlaylistTile({
    Key? key,
    required this.playlist,
    this.onTap,
  }) : super(key: key);

  @override
  PlaylistTileState createState() => PlaylistTileState();
}

class PlaylistTileState extends State<PlaylistTile> {
  bool reactToSecondaryPress = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        reactToSecondaryPress = e.kind == PointerDeviceKind.mouse &&
            e.buttons == kSecondaryMouseButton;
      },
      onPointerUp: (e) async {
        if (!reactToSecondaryPress) return;
        if (widget.playlist.id < 0) return;
        final result = await showMenu(
          elevation: 4.0,
          context: context,
          position: RelativeRect.fromRect(
            Offset(e.position.dx, e.position.dy) & Size(164.0, 320.0),
            Rect.fromLTWH(
              0,
              0,
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
          ),
          items: [
            PopupMenuItem<int>(
              padding: EdgeInsets.zero,
              value: 0,
              child: ListTile(
                leading: Icon(Platform.isWindows
                    ? FluentIcons.delete_16_regular
                    : Icons.delete),
                title: Text(
                  Language.instance.DELETE,
                  style:
                      isDesktop ? Theme.of(context).textTheme.headline4 : null,
                ),
              ),
            ),
          ],
        );
        switch (result) {
          case 0:
            {
              showDialog(
                context: context,
                builder: (subContext) => AlertDialog(
                  title: Text(
                    Language.instance.COLLECTION_PLAYLIST_DELETE_DIALOG_HEADER,
                    style: Theme.of(subContext).textTheme.headline1,
                  ),
                  content: Text(
                    Language.instance.COLLECTION_PLAYLIST_DELETE_DIALOG_BODY
                        .replaceAll(
                      'NAME',
                      '${widget.playlist.name}',
                    ),
                    style: Theme.of(subContext).textTheme.headline3,
                  ),
                  actions: [
                    MaterialButton(
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () async {
                        await Collection.instance
                            .playlistRemove(widget.playlist);
                        Navigator.of(subContext).pop();
                      },
                      child: Text(Language.instance.YES),
                    ),
                    MaterialButton(
                      textColor: Theme.of(context).primaryColor,
                      onPressed: Navigator.of(subContext).pop,
                      child: Text(Language.instance.NO),
                    ),
                  ],
                ),
              );
              break;
            }
          default:
            break;
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap ??
              () async {
                Iterable<Color>? palette;
                if (isMobile && widget.playlist.tracks.isNotEmpty) {
                  final result = await PaletteGenerator.fromImageProvider(
                      Collection.instance
                          .getAlbumArt(widget.playlist.tracks.last));
                  palette = result.colors;
                }
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: PlaylistScreen(
                        playlist: widget.playlist,
                        palette: palette,
                      ),
                    ),
                  ),
                );
              },
          onLongPress: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Divider(
                height: 1.0,
                indent: isMobile ? 80.0 : null,
              ),
              Container(
                height: 64.0,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 12.0),
                    Container(
                      height: 56.0,
                      width: 56.0,
                      alignment: Alignment.center,
                      child: Hero(
                        tag: 'playlist_art_${widget.playlist.name}',
                        child: PlaylistThumbnail(
                          tracks: widget.playlist.tracks,
                          width: 48.0,
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
                            widget.playlist.name.overflow,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            Language.instance.N_TRACKS.replaceAll(
                              'N',
                              '${widget.playlist.tracks.length}',
                            ),
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
                      // child: IconButton(
                      //   onPressed: _showBottomSheet,
                      //   icon: Icon(Icons.more_vert),
                      //   iconSize: 24.0,
                      //   splashRadius: 20.0,
                      // ),
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

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  final Iterable<Color>? palette;

  const PlaylistScreen({
    Key? key,
    required this.playlist,
    this.palette,
  }) : super(key: key);
  PlaylistScreenState createState() => PlaylistScreenState();
}

class PlaylistScreenState extends State<PlaylistScreen>
    with SingleTickerProviderStateMixin {
  Color? color;
  Color? secondary;
  Track? hovered;
  bool reactToSecondaryPress = false;
  bool detailsVisible = false;
  bool detailsLoaded = false;
  ScrollController controller = ScrollController(initialScrollOffset: 96.0);

  @override
  void initState() {
    super.initState();
    if (isDesktop && widget.playlist.tracks.isNotEmpty) {
      Timer(
        Duration(milliseconds: 300),
        () {
          if (widget.palette == null) {
            PaletteGenerator.fromImageProvider(Collection.instance
                    .getAlbumArt(widget.playlist.tracks.last))
                .then((palette) {
              setState(() {
                color = palette.colors.first;
                secondary = palette.colors.last;
                detailsVisible = true;
              });
            });
          } else {
            setState(() {
              detailsVisible = true;
            });
          }
        },
      );
    }
    if (isMobile) {
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
            });
          });
        });
      });
      if (widget.palette != null) {
        color = widget.palette?.first;
        secondary = widget.palette?.last;
      }
      controller.addListener(() {
        if (controller.offset == 0.0) {
          setState(() {
            detailsVisible = true;
          });
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
    return isDesktop
        ? Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
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
                      milliseconds: 400,
                    ),
                    builder: (context, color, _) => DesktopAppBar(
                      height: MediaQuery.of(context).size.height / 3,
                      elevation: 4.0,
                      color: color as Color? ?? Colors.transparent,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height -
                        kDesktopNowPlayingBarHeight,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(top: 72.0),
                        constraints: BoxConstraints(
                          maxWidth: 1280.0,
                          maxHeight: 720.0,
                        ),
                        width: MediaQuery.of(context).size.width - 136.0,
                        height: MediaQuery.of(context).size.height - 192.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 6,
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                var dimension = min(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                );
                                return SizedBox.square(
                                  dimension: dimension,
                                  child: Hero(
                                    tag: 'playlist_art_${widget.playlist.name}',
                                    child: PlaylistThumbnail(
                                      tracks: widget.playlist.tracks,
                                      width: dimension,
                                      mini: false,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Expanded(
                              flex: 7,
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 4.0,
                                child: CustomListView(
                                  children: [
                                    Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        Container(
                                          height: 156.0,
                                          padding: EdgeInsets.all(16.0),
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                widget.playlist.name.overflow,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    ?.copyWith(fontSize: 24.0),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8.0),
                                              Text(
                                                '${Language.instance.TRACK}: ${widget.playlist.tracks.length}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              FloatingActionButton(
                                                heroTag: 'play_now',
                                                onPressed: () {
                                                  Playback.instance.open(
                                                    widget.playlist.tracks +
                                                        ([
                                                          ...Collection
                                                              .instance.tracks
                                                        ]..shuffle()),
                                                  );
                                                },
                                                mini: true,
                                                child: Icon(
                                                  Icons.play_arrow,
                                                ),
                                                tooltip:
                                                    Language.instance.PLAY_NOW,
                                              ),
                                              SizedBox(
                                                width: 8.0,
                                              ),
                                              FloatingActionButton(
                                                heroTag: 'add_to_now_playing',
                                                onPressed: () {
                                                  Playback.instance.open(
                                                    widget.playlist.tracks,
                                                  );
                                                },
                                                mini: true,
                                                child: Icon(
                                                  Icons.queue_music,
                                                ),
                                                tooltip: Language.instance
                                                    .ADD_TO_NOW_PLAYING,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 1.0,
                                    ),
                                    LayoutBuilder(
                                      builder: (context, constraints) => Column(
                                        children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 64.0,
                                                    height: 56.0,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      '#',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline2,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: 56.0,
                                                      padding: EdgeInsets.only(
                                                          right: 8.0),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        Language.instance
                                                            .TRACK_SINGLE,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline2,
                                                      ),
                                                    ),
                                                    flex: 3,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: 56.0,
                                                      padding: EdgeInsets.only(
                                                          right: 8.0),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        Language.instance
                                                            .ALBUM_SINGLE,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline2,
                                                      ),
                                                    ),
                                                    flex: 2,
                                                  ),
                                                ],
                                              ),
                                              Divider(height: 1.0),
                                            ] +
                                            widget.playlist.tracks
                                                .map(
                                                  (track) => MouseRegion(
                                                    onEnter: (e) {
                                                      setState(() {
                                                        hovered = track;
                                                      });
                                                    },
                                                    onExit: (e) {
                                                      setState(() {
                                                        hovered = null;
                                                      });
                                                    },
                                                    child: Listener(
                                                      onPointerDown: (e) {
                                                        reactToSecondaryPress = e
                                                                    .kind ==
                                                                PointerDeviceKind
                                                                    .mouse &&
                                                            e.buttons ==
                                                                kSecondaryMouseButton;
                                                      },
                                                      onPointerUp: (e) async {
                                                        if (!reactToSecondaryPress)
                                                          return;
                                                        await showMenu(
                                                          elevation: 4.0,
                                                          context: context,
                                                          position: RelativeRect
                                                              .fromRect(
                                                            Offset(
                                                                    e.position
                                                                        .dx,
                                                                    e.position
                                                                        .dy) &
                                                                Size(228.0,
                                                                    320.0),
                                                            Rect.fromLTWH(
                                                              0,
                                                              0,
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width,
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height,
                                                            ),
                                                          ),
                                                          items: [
                                                            PopupMenuItem<int>(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              onTap: () async {
                                                                Collection
                                                                    .instance
                                                                    .playlistRemoveTrack(
                                                                        widget
                                                                            .playlist,
                                                                        track);
                                                              },
                                                              value: 4,
                                                              child: ListTile(
                                                                leading: Icon(Platform.isWindows
                                                                    ? FluentIcons
                                                                        .delete_20_regular
                                                                    : Icons
                                                                        .delete),
                                                                title: Text(
                                                                  Language
                                                                      .instance
                                                                      .REMOVE_FROM_PLAYLIST,
                                                                  style: isDesktop
                                                                      ? Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .headline4
                                                                      : null,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          onTap: () {
                                                            Playback.instance
                                                                .open(
                                                              widget.playlist
                                                                      .tracks +
                                                                  ([
                                                                    ...Collection
                                                                        .instance
                                                                        .tracks
                                                                  ]..shuffle()),
                                                              index: widget
                                                                  .playlist
                                                                  .tracks
                                                                  .indexOf(
                                                                      track),
                                                            );
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width: 64.0,
                                                                height: 48.0,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            8.0),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: hovered ==
                                                                        track
                                                                    ? IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          Playback
                                                                              .instance
                                                                              .open(
                                                                            widget.playlist.tracks,
                                                                            index:
                                                                                widget.playlist.tracks.indexOf(track),
                                                                          );
                                                                        },
                                                                        icon: Icon(
                                                                            Icons.play_arrow),
                                                                        splashRadius:
                                                                            20.0,
                                                                      )
                                                                    : Text(
                                                                        '${track.trackNumber}',
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .headline4,
                                                                      ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 48.0,
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              8.0),
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    track
                                                                        .trackName,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                flex: 3,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 48.0,
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              8.0),
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    track
                                                                        .albumName,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                flex: 2,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
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
              ),
            ),
          )
        : Scaffold(
            body: Stack(
              children: [
                CustomScrollView(
                  controller: controller,
                  slivers: [
                    SliverAppBar(
                      expandedHeight: MediaQuery.of(context).size.width +
                          96.0 -
                          MediaQuery.of(context).padding.top,
                      pinned: true,
                      leading: IconButton(
                        onPressed: Navigator.of(context).maybePop,
                        icon: Icon(
                          Icons.arrow_back,
                        ),
                        iconSize: 24.0,
                        splashRadius: 20.0,
                      ),
                      forceElevated: true,
                      // actions: [
                      //  IconButton(
                      //    onPressed: () {},
                      //    icon: Icon(
                      //      Icons.favorite,
                      //    ),
                      //     iconSize: 24.0,
                      //     splashRadius: 20.0,
                      //   ),
                      // ],
                      title: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 1.0,
                          end: detailsVisible ? 0.0 : 1.0,
                        ),
                        duration: Duration(milliseconds: 200),
                        builder: (context, value, _) => Opacity(
                          opacity: value,
                          child: Text(
                            Language.instance.ARTIST_SINGLE,
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      backgroundColor: color,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.width,
                              width: MediaQuery.of(context).size.width,
                              child: LayoutBuilder(
                                builder: (context, constraints) => Hero(
                                  tag: 'playlist_art_${widget.playlist.name}',
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(min(
                                              constraints.maxHeight,
                                              constraints.maxWidth) -
                                          28.0),
                                    ),
                                    elevation: 4.0,
                                    margin: EdgeInsets.all(
                                      56.0,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: ClipOval(
                                        child: Image(
                                          image: Collection.instance
                                              .getAlbumArt(
                                                  widget.playlist.tracks.last),
                                          height: min(constraints.maxHeight,
                                                  constraints.maxWidth) -
                                              64.0,
                                          width: min(constraints.maxHeight,
                                                  constraints.maxWidth) -
                                              64.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 1.0,
                                end: detailsVisible ? 1.0 : 0.0,
                              ),
                              duration: Duration(milliseconds: 200),
                              builder: (context, value, _) => Opacity(
                                opacity: value,
                                child: Container(
                                  color: color,
                                  height: 96.0,
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.playlist.name.overflow,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(
                                              color: [
                                                Colors.white,
                                                Colors.black
                                              ][(color?.computeLuminance() ??
                                                          0.0) >
                                                      0.5
                                                  ? 1
                                                  : 0],
                                              fontSize: 24.0,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: 12.0,
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Playback.instance.open(
                              widget.playlist.tracks +
                                  ([...Collection.instance.tracks]..shuffle()),
                            ),
                            onLongPress: () async {
                              var result;
                              await showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: trackPopupMenuItems(context)
                                        .map(
                                          (item) => PopupMenuItem(
                                            child: item.child,
                                            onTap: () => result = item.value,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              );
                              await trackPopupMenuHandle(
                                context,
                                widget.playlist.tracks[i],
                                result,
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 64.0,
                                  alignment: Alignment.center,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 12.0),
                                      Container(
                                        height: 56.0,
                                        width: 56.0,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${widget.playlist.tracks[i].trackNumber}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3
                                              ?.copyWith(fontSize: 18.0),
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.playlist.tracks[i]
                                                  .trackName.overflow,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline2,
                                            ),
                                            const SizedBox(
                                              height: 2.0,
                                            ),
                                            Text(
                                              (widget.playlist.tracks[i]
                                                              .duration ??
                                                          Duration.zero)
                                                      .label +
                                                  ' • ' +
                                                  widget.playlist.tracks[i]
                                                      .albumName,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline3,
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
                                          onPressed: () async {
                                            var result;
                                            await showModalBottomSheet(
                                              context: context,
                                              builder: (context) => Container(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: trackPopupMenuItems(
                                                          context)
                                                      .map(
                                                        (item) => PopupMenuItem(
                                                          child: item.child,
                                                          onTap: () => result =
                                                              item.value,
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ),
                                            );
                                            await trackPopupMenuHandle(
                                              context,
                                              widget.playlist.tracks[i],
                                              result,
                                            );
                                          },
                                          icon: Icon(
                                            Icons.more_vert,
                                          ),
                                          iconSize: 24.0,
                                          splashRadius: 20.0,
                                        ),
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
                        ),
                        childCount: widget.playlist.tracks.length,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: 12.0 +
                            (detailsLoaded
                                ? 0.0
                                : MediaQuery.of(context).size.height),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width +
                      MediaQuery.of(context).padding.top -
                      64.0,
                  right: 16.0 + 64.0,
                  child: TweenAnimationBuilder(
                    curve: Curves.easeOut,
                    tween: Tween<double>(
                        begin: 0.0, end: detailsVisible ? 1.0 : 0.0),
                    duration: Duration(milliseconds: 200),
                    builder: (context, value, _) => Transform.scale(
                      scale: value as double,
                      child: Transform.rotate(
                        angle: value * pi + pi,
                        child: FloatingActionButton(
                          heroTag: 'play_now',
                          backgroundColor: secondary,
                          foregroundColor: [Colors.white, Colors.black][
                              (secondary?.computeLuminance() ?? 0.0) > 0.5
                                  ? 1
                                  : 0],
                          child: Icon(Icons.play_arrow),
                          onPressed: () {
                            Playback.instance.open(
                              widget.playlist.tracks +
                                  ([...Collection.instance.tracks]..shuffle()),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width +
                      MediaQuery.of(context).padding.top -
                      64.0,
                  right: 16.0,
                  child: TweenAnimationBuilder(
                    curve: Curves.easeOut,
                    tween: Tween<double>(
                        begin: 0.0, end: detailsVisible ? 1.0 : 0.0),
                    duration: Duration(milliseconds: 200),
                    builder: (context, value, _) => Transform.scale(
                      scale: value as double,
                      child: Transform.rotate(
                        angle: value * pi + pi,
                        child: FloatingActionButton(
                          heroTag: 'shuffle',
                          backgroundColor: secondary,
                          foregroundColor: [Colors.white, Colors.black][
                              (secondary?.computeLuminance() ?? 0.0) > 0.5
                                  ? 1
                                  : 0],
                          child: Icon(Icons.shuffle),
                          onPressed: () {
                            Playback.instance.open(
                              [...widget.playlist.tracks]..shuffle(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

extension on Duration {
  String get label {
    int minutes = inSeconds ~/ 60;
    String seconds = inSeconds - (minutes * 60) > 9
        ? '${inSeconds - (minutes * 60)}'
        : '0${inSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }
}
