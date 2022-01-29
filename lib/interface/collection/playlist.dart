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
                      language.PLAYLIST,
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          ?.copyWith(fontSize: 20.0),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2.0),
                    Text(language.PLAYLISTS_SUBHEADER),
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
                                  language.CREATE,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      ?.copyWith(fontSize: 20.0),
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  language.CREATE_PLAYLIST_SUBHEADER,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                const SizedBox(
                                  height: 18.0,
                                ),
                                Container(
                                  height: 42.0,
                                  width: 280.0,
                                  alignment: Alignment.center,
                                  margin:
                                      EdgeInsets.only(top: 0.0, bottom: 0.0),
                                  padding: EdgeInsets.only(top: 2.0),
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus) {
                                        HotKeys.disableSpaceHotKey();
                                      } else {
                                        HotKeys.enableSpaceHotKey();
                                      }
                                    },
                                    child: TextField(
                                      autofocus: true,
                                      controller: this._controller,
                                      cursorWidth: 1.0,
                                      onSubmitted: (String value) async {
                                        if (value.isNotEmpty) {
                                          FocusScope.of(context).unfocus();
                                          await collection.playlistAdd(
                                            Playlist(
                                              playlistName: value,
                                            ),
                                          );
                                          this._controller.clear();
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
                                      decoration: InputDecoration(
                                        hintText:
                                            language.PLAYLISTS_TEXT_FIELD_HINT,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .headline3
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.black
                                                      .withOpacity(0.6)
                                                  : Colors.white60,
                                            ),
                                        filled: true,
                                        fillColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Colors.white
                                                : Color(0xFF202020),
                                        hoverColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Colors.white
                                                : Color(0xFF202020),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.32),
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.32),
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              MaterialButton(
                                child: Text(
                                  language.OK,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () async {
                                  if (_controller.text.isNotEmpty) {
                                    FocusScope.of(context).unfocus();
                                    await collection.playlistAdd(
                                      Playlist(
                                        playlistName: _controller.text,
                                      ),
                                    );
                                    this._controller.clear();
                                    Navigator.of(context).maybePop();
                                  }
                                },
                              ),
                              MaterialButton(
                                child: Text(
                                  language.CANCEL,
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
                        language.CREATE_NEW_PLAYLIST,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    if (collection.playlists.isNotEmpty)
                      const SizedBox(
                        height: 16.0,
                      ),
                  ],
                ),
              ),
            ] +
            collection.playlists
                .map((Playlist playlist) => PlaylistTile(playlist: playlist))
                .toList(),
      );
      return Container(
        alignment: Alignment.topCenter,
        height: MediaQuery.of(context).size.height -
            (kDesktopTitleBarHeight + kDesktopAppBarHeight),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (collection.playlists.isNotEmpty)
              Expanded(
                child: screen,
              ),
            if (collection.playlists.isEmpty) screen,
            if (collection.playlists.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    language.NO_PLAYLISTS_FOUND,
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
          borderRadius: BorderRadius.circular(this.width / 2),
        ),
        child: Padding(
          padding: EdgeInsets.all(this.mini ? 4.0 : 8.0),
          child: ClipOval(
            child: _child(
              context,
              this.width - (this.mini ? 8.0 : 16.0),
              this.mini,
            ),
          ),
        ),
      );
    } else {
      return _child(
        context,
        this.width,
        this.mini,
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
            Image.file(
              tracks[tracks.length - 1].albumArt,
              height: width,
              width: width / 2 - (!mini ? 12.0 : 0.0),
              fit: BoxFit.cover,
            ),
            if (!mini) SizedBox(width: 8.0),
            Column(
              children: [
                Image.file(
                  tracks[tracks.length - 2].albumArt,
                  height: width / 2 - (!mini ? 12.0 : 0.0),
                  width: width / 2 - (!mini ? 4.0 : 0.0),
                  fit: BoxFit.cover,
                ),
                if (!mini) SizedBox(height: 8.0),
                Image.file(
                  tracks[tracks.length - 3].albumArt,
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
            Image.file(
              tracks[tracks.length - 1].albumArt,
              height: width,
              width: width / 2 - (!mini ? 12.0 : 0.0),
              fit: BoxFit.cover,
            ),
            if (!mini) SizedBox(width: 8.0),
            Image.file(
              tracks[tracks.length - 2].albumArt,
              height: width,
              width: width / 2 - (!mini ? 4.0 : 0.0),
              fit: BoxFit.cover,
            ),
          ],
        ),
      );
    } else if (tracks.length == 1) {
      return Image.file(
        tracks[tracks.length - 1].albumArt,
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
        if (widget.playlist.playlistId! < 0) return;
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
                  language.DELETE,
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
                    language.COLLECTION_PLAYLIST_DELETE_DIALOG_HEADER,
                    style: Theme.of(subContext).textTheme.headline1,
                  ),
                  content: Text(
                    language.COLLECTION_PLAYLIST_DELETE_DIALOG_BODY.replaceAll(
                      'NAME',
                      '${widget.playlist.playlistName}',
                    ),
                    style: Theme.of(subContext).textTheme.headline3,
                  ),
                  actions: [
                    MaterialButton(
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () async {
                        await collection.playlistRemove(widget.playlist);
                        Navigator.of(subContext).pop();
                      },
                      child: Text(language.YES),
                    ),
                    MaterialButton(
                      textColor: Theme.of(context).primaryColor,
                      onPressed: Navigator.of(subContext).pop,
                      child: Text(language.NO),
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
                      FileImage(widget.playlist.tracks.last.albumArt));
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
                        tag:
                            'playlist_art_${this.widget.playlist.playlistName}',
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
                            widget.playlist.playlistName!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            language.N_TRACKS.replaceAll(
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
                      //   onPressed: this._showBottomSheet,
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
            PaletteGenerator.fromImageProvider(
                    FileImage(widget.playlist.tracks.last.albumArt))
                .then((palette) {
              this.setState(() {
                this.color = palette.colors.first;
                this.secondary = palette.colors.last;
                this.detailsVisible = true;
              });
            });
          } else {
            this.setState(() {
              this.detailsVisible = true;
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
            this.setState(() {
              this.detailsLoaded = true;
            });
          });
        });
      });
      if (widget.palette != null) {
        this.color = widget.palette?.first;
        this.secondary = widget.palette?.last;
      }
      this.controller.addListener(() {
        if (this.controller.offset == 0.0) {
          this.setState(() {
            this.detailsVisible = true;
          });
        } else if (this.detailsVisible) {
          this.setState(() {
            this.detailsVisible = false;
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
                      end: this.color == null
                          ? Theme.of(context).appBarTheme.backgroundColor
                          : this.color!,
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
                                    tag:
                                        'playlist_art_${this.widget.playlist.playlistName}',
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
                                                widget.playlist.playlistName!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    ?.copyWith(fontSize: 24.0),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8.0),
                                              Text(
                                                '${language.TRACK}: ${widget.playlist.tracks.length}',
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
                                                  Playback.play(
                                                    index: 0,
                                                    tracks: widget
                                                            .playlist.tracks +
                                                        ([...collection.tracks]
                                                          ..shuffle()),
                                                  );
                                                },
                                                mini: true,
                                                child: Icon(
                                                  Icons.play_arrow,
                                                ),
                                                tooltip: language.PLAY_NOW,
                                              ),
                                              SizedBox(
                                                width: 8.0,
                                              ),
                                              FloatingActionButton(
                                                heroTag: 'add_to_now_playing',
                                                onPressed: () {
                                                  Playback.add(
                                                    widget.playlist.tracks,
                                                  );
                                                },
                                                mini: true,
                                                child: Icon(
                                                  Icons.queue_music,
                                                ),
                                                tooltip:
                                                    language.ADD_TO_NOW_PLAYING,
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
                                                        language.TRACK_SINGLE,
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
                                                        language.ALBUM_SINGLE,
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
                                                      this.setState(() {
                                                        hovered = track;
                                                      });
                                                    },
                                                    onExit: (e) {
                                                      this.setState(() {
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
                                                                collection
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
                                                                  language
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
                                                            Playback.play(
                                                              index: widget
                                                                  .playlist
                                                                  .tracks
                                                                  .indexOf(
                                                                      track),
                                                              tracks: widget
                                                                      .playlist
                                                                      .tracks +
                                                                  ([
                                                                    ...collection
                                                                        .tracks
                                                                  ]..shuffle()),
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
                                                                              .play(
                                                                            index:
                                                                                widget.playlist.tracks.indexOf(track),
                                                                            tracks:
                                                                                widget.playlist.tracks,
                                                                          );
                                                                        },
                                                                        icon: Icon(
                                                                            Icons.play_arrow),
                                                                        splashRadius:
                                                                            20.0,
                                                                      )
                                                                    : Text(
                                                                        '${track.trackNumber ?? 1}',
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
                                                                        .trackName!,
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
                                                                    track.albumName ??
                                                                        'Unknown Album',
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
                  controller: this.controller,
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
                            language.ARTIST_SINGLE,
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      backgroundColor: this.color,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.width,
                              width: MediaQuery.of(context).size.width,
                              child: LayoutBuilder(
                                builder: (context, constraints) => Hero(
                                  tag:
                                      'playlist_art_${widget.playlist.playlistName}',
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
                                        child: Image.file(
                                          widget.playlist.tracks.last.albumArt,
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
                                  color: this.color,
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
                                        widget.playlist.playlistName!.overflow,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(
                                              color: [
                                                Colors.white,
                                                Colors.black
                                              ][(this.color?.computeLuminance() ??
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
                            onTap: () => Playback.play(
                              index: i,
                              tracks: widget.playlist.tracks +
                                  ([...collection.tracks]..shuffle()),
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
                                          '${widget.playlist.tracks[i].trackNumber ?? 1}',
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
                                                  .trackName!.overflow,
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
                                              Duration(
                                                    milliseconds: widget
                                                            .playlist
                                                            .tracks[i]
                                                            .trackDuration ??
                                                        0,
                                                  ).label +
                                                  ' • ' +
                                                  widget.playlist.tracks[i]
                                                      .albumName!,
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
                            (this.detailsLoaded
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
                        begin: 0.0, end: this.detailsVisible ? 1.0 : 0.0),
                    duration: Duration(milliseconds: 200),
                    builder: (context, value, _) => Transform.scale(
                      scale: value as double,
                      child: Transform.rotate(
                        angle: value * pi + pi,
                        child: FloatingActionButton(
                          heroTag: 'play_now',
                          backgroundColor: this.secondary,
                          foregroundColor: [Colors.white, Colors.black][
                              (this.secondary?.computeLuminance() ?? 0.0) > 0.5
                                  ? 1
                                  : 0],
                          child: Icon(Icons.play_arrow),
                          onPressed: () {
                            Playback.play(
                              index: 0,
                              tracks: widget.playlist.tracks +
                                  ([...collection.tracks]..shuffle()),
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
                        begin: 0.0, end: this.detailsVisible ? 1.0 : 0.0),
                    duration: Duration(milliseconds: 200),
                    builder: (context, value, _) => Transform.scale(
                      scale: value as double,
                      child: Transform.rotate(
                        angle: value * pi + pi,
                        child: FloatingActionButton(
                          heroTag: 'shuffle',
                          backgroundColor: this.secondary,
                          foregroundColor: [Colors.white, Colors.black][
                              (this.secondary?.computeLuminance() ?? 0.0) > 0.5
                                  ? 1
                                  : 0],
                          child: Icon(Icons.shuffle),
                          onPressed: () {
                            Playback.play(
                              index: 0,
                              tracks: [...widget.playlist.tracks]..shuffle(),
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
