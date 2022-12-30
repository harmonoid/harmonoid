/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/constants/language.dart';

import 'package:harmonoid/web/utils/widgets.dart';

class PlaylistTab extends StatelessWidget {
  final TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: CustomListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              top: isDesktop
                  ? 20.0
                  : kMobileSearchBarHeight +
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
              ...Collection.instance.playlists
                  .map(
                    (e) => PlaylistTile(
                      playlist: e,
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

class PlaylistThumbnail extends StatelessWidget {
  final LinkedHashSet<Track> tracks;
  final double width;
  final double? height;
  final bool encircle;
  final bool mini;
  const PlaylistThumbnail({
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
          borderRadius: BorderRadius.circular(width / 2),
        ),
        child: Padding(
          padding: EdgeInsets.all(mini ? 4.0 : 8.0),
          child: ClipOval(
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
    final tracks = this.tracks.take(3).toList();
    if (tracks.length > 2) {
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
          Icons.music_note,
          color: Theme.of(context).primaryColor,
          size: width / 2,
        ),
      );
    }
  }
}

class PlaylistTile extends StatefulWidget {
  final bool enableTrailingButton;
  final Playlist playlist;
  final void Function()? onTap;

  PlaylistTile({
    Key? key,
    required this.playlist,
    this.enableTrailingButton: false,
    this.onTap,
  }) : super(key: key);

  @override
  PlaylistTileState createState() => PlaylistTileState();
}

class PlaylistTileState extends State<PlaylistTile> {
  bool reactToSecondaryPress = false;

  List<PopupMenuItem<int>> get items => [
        PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          value: 0,
          child: ListTile(
            leading: Icon(
              Platform.isWindows ? FluentIcons.delete_16_regular : Icons.delete,
            ),
            title: Text(
              Language.instance.DELETE,
              style:
                  isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
            ),
          ),
        ),
        PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          value: 1,
          child: ListTile(
            leading: Icon(
              Platform.isWindows
                  ? FluentIcons.rename_16_regular
                  : Icons.text_format,
            ),
            title: Text(
              Language.instance.RENAME,
              style:
                  isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
            ),
          ),
        ),
        if (!isDesktop && !MobileNowPlayingController.instance.isHidden)
          PopupMenuItem<int>(
            padding: EdgeInsets.zero,
            child: SizedBox(height: kMobileNowPlayingBarHeight),
          ),
      ];

  Future<void> handleSelection(int? result) async {
    switch (result) {
      case 0:
        {
          await showDialog(
            context: context,
            builder: (subContext) => AlertDialog(
              title: Text(
                Language.instance.COLLECTION_PLAYLIST_DELETE_DIALOG_HEADER,
              ),
              content: Text(
                Language.instance.COLLECTION_PLAYLIST_DELETE_DIALOG_BODY
                    .replaceAll(
                  'NAME',
                  '${widget.playlist.name}',
                ),
                style: Theme.of(subContext).textTheme.displaySmall,
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await Collection.instance.playlistDelete(widget.playlist);
                    Navigator.of(subContext).pop();
                  },
                  child: Text(Language.instance.YES),
                ),
                TextButton(
                  onPressed: Navigator.of(subContext).pop,
                  child: Text(Language.instance.NO),
                ),
              ],
            ),
          );
          break;
        }
      case 1:
        {
          if (isDesktop) {
            String rename = widget.playlist.name;
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  Language.instance.RENAME,
                ),
                content: Container(
                  height: 40.0,
                  width: 280.0,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
                  padding: EdgeInsets.only(top: 2.0),
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        HotKeys.instance.disableSpaceHotKey();
                      } else {
                        HotKeys.instance.enableSpaceHotKey();
                      }
                    },
                    child: TextFormField(
                      initialValue: widget.playlist.name,
                      autofocus: true,
                      cursorWidth: 1.0,
                      onChanged: (value) => rename = value,
                      onFieldSubmitted: (String value) async {
                        if (value.isNotEmpty && value != widget.playlist.name) {
                          widget.playlist.name = value;
                          Collection.instance.playlistsSaveToCache();
                          Navigator.of(context).maybePop();
                          setState(() {});
                        }
                      },
                      textAlignVertical: TextAlignVertical.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: inputDecoration(
                        context,
                        Language.instance.PLAYLISTS_TEXT_FIELD_LABEL,
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
                      if (rename.isNotEmpty && rename != widget.playlist.name) {
                        widget.playlist.name = rename;
                        Collection.instance.playlistsSaveToCache();
                        Navigator.of(context).maybePop();
                        setState(() {});
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
          if (isMobile) {
            await Navigator.of(context).maybePop();
            String input = '';
            final GlobalKey<FormState> formKey = GlobalKey<FormState>();
            await showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              elevation: kDefaultHeavyElevation,
              useRootNavigator: true,
              builder: (context) => StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4.0),
                        Form(
                          key: formKey,
                          child: TextFormField(
                            initialValue: widget.playlist.name,
                            autofocus: true,
                            autocorrect: false,
                            onChanged: (value) => input = value,
                            keyboardType: TextInputType.url,
                            textCapitalization: TextCapitalization.none,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (value) async {
                              if (value.isNotEmpty &&
                                  value != widget.playlist.name) {
                                widget.playlist.name = value;
                                Collection.instance.playlistsSaveToCache();
                                Navigator.of(context).maybePop();
                                setState(() {});
                              }
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(
                                12,
                                30,
                                12,
                                6,
                              ),
                              hintText:
                                  Language.instance.PLAYLISTS_TEXT_FIELD_LABEL,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color!
                                      .withOpacity(0.4),
                                  width: 1.8,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color!
                                      .withOpacity(0.4),
                                  width: 1.8,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.8,
                                ),
                              ),
                              errorStyle: TextStyle(height: 0.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (input.isNotEmpty &&
                                input != widget.playlist.name) {
                              widget.playlist.name = input;
                              Collection.instance.playlistsSaveToCache();
                              Navigator.of(context).maybePop();
                              setState(() {});
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          child: Text(
                            Language.instance.RENAME.toUpperCase(),
                            style: const TextStyle(
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          break;
        }
      default:
        break;
    }
  }

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
        await handleSelection(result);
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
                      child: PlaylistScreen(
                        playlist: widget.playlist,
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
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: items
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
                  await handleSelection(result);
                },
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
                            Language.instance.N_TRACKS.replaceAll(
                              'N',
                              '${widget.playlist.tracks.length}',
                            ),
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
                          onPressed: () async {
                            int? result;
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) => Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: items
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
                            await handleSelection(result);
                          },
                          icon: Icon(Icons.more_vert),
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
                          onSelected: (result) => handleSelection(result),
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
  int? hovered;
  bool reactToSecondaryPress = false;
  bool detailsVisible = false;
  bool detailsLoaded = false;
  ScrollController controller = ScrollController(initialScrollOffset: 96.0);
  ScrollPhysics? physics = NeverScrollableScrollPhysics();

  @override
  void initState() {
    super.initState();
    if (isDesktop && widget.playlist.tracks.isNotEmpty) {
      Timer(
        Duration(milliseconds: 300),
        () {
          if (widget.palette == null) {
            PaletteGenerator.fromImageProvider(
                    getAlbumArt(widget.playlist.tracks.last, small: true))
                .then((palette) {
              setState(() {
                if (palette.colors != null) {
                  color = palette.colors!.first;
                  secondary = palette.colors!.last;
                }
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
              physics = null;
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
    const mobileSliverLabelHeight = 108.0;
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
    final tracks = widget.playlist.tracks.toList();
    return Consumer<Collection>(
      builder: (context, collection, _) {
        return isDesktop
            ? TweenAnimationBuilder(
                tween: ColorTween(
                  begin: Theme.of(context).appBarTheme.backgroundColor,
                  end: color == null
                      ? Theme.of(context).appBarTheme.backgroundColor
                      : color!,
                ),
                curve: Curves.easeOut,
                duration: Duration(milliseconds: 400),
                builder: (context, color, _) => Scaffold(
                  backgroundColor: color as Color? ?? Colors.transparent,
                  body: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          margin: const EdgeInsets.only(
                              top: kDesktopNowPlayingBarHeight),
                          height: MediaQuery.of(context).size.height -
                              kDesktopNowPlayingBarHeight,
                          width: MediaQuery.of(context).size.width,
                        ),
                        DesktopAppBar(
                          height: MediaQuery.of(context).size.height / 3,
                          elevation: 4.0,
                          color: color ?? Colors.transparent,
                        ),
                        Container(
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
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: AspectRatio(
                                              aspectRatio: 1.0,
                                              child: Hero(
                                                tag:
                                                    'playlist_art_${widget.playlist.name}',
                                                child: PlaylistThumbnail(
                                                  tracks:
                                                      widget.playlist.tracks,
                                                  width: dimension,
                                                  mini: false,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                                const SizedBox(
                                  width: 16.0,
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
                                                    {
                                                          kHistoryPlaylist:
                                                              Language.instance
                                                                  .HISTORY,
                                                          kLikedSongsPlaylist:
                                                              Language.instance
                                                                  .LIKED_SONGS,
                                                        }[widget.playlist.id] ??
                                                        widget.playlist.name
                                                            .overflow,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayLarge
                                                        ?.copyWith(
                                                            fontSize: 24.0),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Text(
                                                    '${Language.instance.TRACK}: ${widget.playlist.tracks.length}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                        [
                                                          ...widget
                                                              .playlist.tracks,
                                                          if (Configuration
                                                              .instance
                                                              .seamlessPlayback)
                                                            ...[
                                                              ...Collection
                                                                  .instance
                                                                  .tracks
                                                            ]..shuffle()
                                                        ],
                                                      );
                                                    },
                                                    mini: true,
                                                    child: Icon(
                                                      Icons.play_arrow,
                                                    ),
                                                    tooltip: Language
                                                        .instance.PLAY_NOW,
                                                  ),
                                                  SizedBox(
                                                    width: 8.0,
                                                  ),
                                                  FloatingActionButton(
                                                    heroTag: 'shuffle',
                                                    onPressed: () {
                                                      Playback.instance.open([
                                                        ...widget
                                                            .playlist.tracks,
                                                      ]..shuffle());
                                                    },
                                                    mini: true,
                                                    child: Icon(
                                                      Icons.shuffle,
                                                    ),
                                                    tooltip: Language
                                                        .instance.SHUFFLE,
                                                  ),
                                                  SizedBox(
                                                    width: 8.0,
                                                  ),
                                                  FloatingActionButton(
                                                    heroTag:
                                                        'add_to_now_playing',
                                                    onPressed: () {
                                                      Playback.instance.open(
                                                        tracks,
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
                                          builder: (context, constraints) =>
                                              Column(
                                            children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 64.0,
                                                        height: 56.0,
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 8.0),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          '#',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .displayMedium,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          height: 56.0,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 8.0),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            Language.instance
                                                                .TRACK_SINGLE,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayMedium,
                                                          ),
                                                        ),
                                                        flex: 3,
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          height: 56.0,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 8.0),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            Language.instance
                                                                .ARTIST,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayMedium,
                                                          ),
                                                        ),
                                                        flex: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  Divider(height: 1.0),
                                                ] +
                                                tracks
                                                    .asMap()
                                                    .entries
                                                    .map(
                                                      (track) => MouseRegion(
                                                        onEnter: (e) {
                                                          setState(() {
                                                            hovered = track.key;
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
                                                          onPointerUp:
                                                              (e) async {
                                                            if (!reactToSecondaryPress)
                                                              return;
                                                            await showMenu(
                                                              elevation: 4.0,
                                                              context: context,
                                                              position:
                                                                  RelativeRect
                                                                      .fromLTRB(
                                                                e.position.dx,
                                                                e.position.dy,
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                              ),
                                                              items: [
                                                                PopupMenuItem<
                                                                    int>(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  onTap:
                                                                      () async {
                                                                    Collection
                                                                        .instance
                                                                        .playlistRemoveTrack(
                                                                            widget.playlist,
                                                                            track.value);
                                                                  },
                                                                  value: 4,
                                                                  child:
                                                                      ListTile(
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
                                                                          ? Theme.of(context)
                                                                              .textTheme
                                                                              .headlineMedium
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                          child: Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: InkWell(
                                                              onTap: () {
                                                                Playback
                                                                    .instance
                                                                    .open(
                                                                  [
                                                                    ...widget
                                                                        .playlist
                                                                        .tracks,
                                                                    if (Configuration
                                                                        .instance
                                                                        .seamlessPlayback)
                                                                      ...[
                                                                        ...Collection
                                                                            .instance
                                                                            .tracks
                                                                      ]..shuffle()
                                                                  ],
                                                                  index:
                                                                      track.key,
                                                                );
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: 64.0,
                                                                    height:
                                                                        48.0,
                                                                    padding: EdgeInsets.only(
                                                                        right:
                                                                            8.0),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: hovered ==
                                                                            track.key
                                                                        ? IconButton(
                                                                            onPressed:
                                                                                () {
                                                                              Playback.instance.open(
                                                                                tracks,
                                                                                index: track.key,
                                                                              );
                                                                            },
                                                                            icon:
                                                                                Icon(Icons.play_arrow),
                                                                            splashRadius:
                                                                                20.0,
                                                                          )
                                                                        : Text(
                                                                            '${track.key + 1}',
                                                                            style:
                                                                                Theme.of(context).textTheme.headlineMedium,
                                                                          ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          48.0,
                                                                      padding: EdgeInsets.only(
                                                                          right:
                                                                              8.0),
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        track
                                                                            .value
                                                                            .trackName,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .headlineMedium,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                    flex: 3,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          48.0,
                                                                      padding: EdgeInsets.only(
                                                                          right:
                                                                              8.0),
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        track
                                                                            .value
                                                                            .albumArtistName,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .headlineMedium,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
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
                      ],
                    ),
                  ),
                ),
              )
            : Scaffold(
                body: NowPlayingBarScrollHideNotifier(
                  child: CustomScrollView(
                    controller: controller,
                    physics: physics,
                    slivers: [
                      SliverAppBar(
                        systemOverlayStyle: SystemUiOverlayStyle(
                          statusBarColor: Colors.transparent,
                          statusBarIconBrightness: detailsVisible
                              ? Brightness.light
                              : (color?.computeLuminance() ??
                                          (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? 0.0
                                              : 1.0)) <
                                      0.5
                                  ? Brightness.light
                                  : Brightness.dark,
                        ),
                        expandedHeight: mobileSliverExpandedHeight,
                        pinned: true,
                        leading: IconButton(
                          onPressed: Navigator.of(context).maybePop,
                          icon: IconButton(
                            onPressed: Navigator.of(context).maybePop,
                            icon: Icon(
                              Icons.arrow_back,
                              color: detailsVisible
                                  ? Theme.of(context)
                                      .extension<IconColors>()
                                      ?.appBarDarkIconColor
                                  : [
                                      Theme.of(context)
                                          .extension<IconColors>()
                                          ?.appBarLightIconColor,
                                      Theme.of(context)
                                          .extension<IconColors>()
                                          ?.appBarDarkIconColor,
                                    ][(color?.computeLuminance() ??
                                              (Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? 0.0
                                                  : 1.0)) >
                                          0.5
                                      ? 0
                                      : 1],
                            ),
                            iconSize: 24.0,
                            splashRadius: 20.0,
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
                              {
                                    kHistoryPlaylist: Language.instance.HISTORY,
                                    kLikedSongsPlaylist:
                                        Language.instance.LIKED_SONGS,
                                  }[widget.playlist.id] ??
                                  widget.playlist.name.overflow,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: [
                                      Color(0xFF212121),
                                      Colors.white,
                                    ][(color?.computeLuminance() ??
                                                (Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? 0.0
                                                    : 1.0)) >
                                            0.5
                                        ? 0
                                        : 1],
                                  ),
                            ),
                          ),
                        ),
                        backgroundColor: color,
                        flexibleSpace: Stack(
                          children: [
                            FlexibleSpaceBar(
                              background: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          color:
                                              Theme.of(context).cardTheme.color,
                                        ),
                                      ),
                                      Container(
                                        height: mobileSliverContentHeight,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: PlaylistThumbnail(
                                          tracks: widget.playlist.tracks,
                                          height: mobileSliverContentHeight,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          mini: false,
                                          encircle: false,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: mobileSliverContentHeight,
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
                                      child: Container(
                                        color: color,
                                        height: mobileSliverLabelHeight,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              {
                                                    kHistoryPlaylist: Language
                                                        .instance.HISTORY,
                                                    kLikedSongsPlaylist:
                                                        Language.instance
                                                            .LIKED_SONGS,
                                                  }[widget.playlist.id] ??
                                                  widget.playlist.name.overflow,
                                              style:
                                                  Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        color: [
                                                          Color(0xFF212121),
                                                          Colors.white,
                                                        ][(color?.computeLuminance() ??
                                                                    (Theme.of(context).brightness ==
                                                                            Brightness.dark
                                                                        ? 0.0
                                                                        : 1.0)) >
                                                                0.5
                                                            ? 0
                                                            : 1],
                                                        fontSize: 24.0,
                                                      ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              Language.instance.N_TRACKS
                                                  .replaceAll(
                                                'N',
                                                '${widget.playlist.tracks.length}',
                                              ),
                                              style:
                                                  Theme.of(context)
                                                      .textTheme
                                                      .displayMedium
                                                      ?.copyWith(
                                                        color: [
                                                          Color(0xFF363636),
                                                          Color(0xFFD9D9D9),
                                                        ][(color?.computeLuminance() ??
                                                                    (Theme.of(context).brightness ==
                                                                            Brightness.dark
                                                                        ? 0.0
                                                                        : 1.0)) >
                                                                0.5
                                                            ? 0
                                                            : 1],
                                                        fontSize: 16.0,
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
                            Positioned(
                              top: mobileSliverFABYPos,
                              right: 16.0 + 64.0,
                              child: TweenAnimationBuilder(
                                curve: Curves.easeOut,
                                tween: Tween<double>(
                                    begin: 0.0,
                                    end: detailsVisible ? 1.0 : 0.0),
                                duration: Duration(milliseconds: 200),
                                builder: (context, value, _) => Transform.scale(
                                  scale: value as double,
                                  child: Transform.rotate(
                                    angle: value * pi + pi,
                                    child: FloatingActionButton(
                                      heroTag: 'play_now',
                                      backgroundColor: secondary,
                                      foregroundColor: [
                                        Colors.white,
                                        Color(0xFF212121)
                                      ][(secondary?.computeLuminance() ?? 0.0) >
                                              0.5
                                          ? 1
                                          : 0],
                                      child: Icon(Icons.play_arrow),
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
                                    end: detailsVisible ? 1.0 : 0.0),
                                duration: Duration(milliseconds: 200),
                                builder: (context, value, _) => Transform.scale(
                                  scale: value as double,
                                  child: Transform.rotate(
                                    angle: value * pi + pi,
                                    child: FloatingActionButton(
                                      heroTag: 'shuffle',
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
                                        Playback.instance.open(
                                          [...widget.playlist.tracks]
                                            ..shuffle(),
                                        );
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
                          top: 12.0,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final subtitle = [
                              if (!tracks[i].hasNoAvailableAlbum)
                                tracks[i].albumName.overflow,
                              if (!tracks[i].hasNoAvailableArtists)
                                tracks[i].trackArtistNames.take(2).join(', ')
                            ].join(' • ');
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Playback.instance.open(
                                  [
                                    ...tracks,
                                    if (Configuration.instance.seamlessPlayback)
                                      ...[...Collection.instance.tracks]
                                        ..shuffle()
                                  ],
                                  index: i,
                                ),
                                onLongPress: () async {
                                  showDialog(
                                    context: context,
                                    builder: (subContext) => AlertDialog(
                                      title: Text(
                                        Language.instance.REMOVE,
                                      ),
                                      content: Text(
                                        Language.instance
                                            .COLLECTION_TRACK_PLAYLIST_REMOVE_DIALOG_BODY
                                            .replaceAll(
                                              'TRACK_NAME',
                                              tracks[i].trackName,
                                            )
                                            .replaceAll('PLAYLIST_NAME',
                                                widget.playlist.name),
                                        style: Theme.of(subContext)
                                            .textTheme
                                            .displaySmall,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            await Collection.instance
                                                .playlistRemoveTrack(
                                              widget.playlist,
                                              tracks[i],
                                            );

                                            Navigator.of(subContext).pop();
                                            setState(() {});
                                          },
                                          child: Text(Language.instance.YES),
                                        ),
                                        TextButton(
                                          onPressed:
                                              Navigator.of(subContext).pop,
                                          child: Text(Language.instance.NO),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 64.0,
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4.0),
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
                                              (i + 1).toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall
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
                                                  tracks[i].trackName.overflow,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium,
                                                ),
                                                if (subtitle.isNotEmpty) ...[
                                                  const SizedBox(
                                                    height: 2.0,
                                                  ),
                                                  Text(
                                                    subtitle,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall,
                                                  ),
                                                ],
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
                                                showDialog(
                                                  context: context,
                                                  builder: (subContext) =>
                                                      AlertDialog(
                                                    title: Text(
                                                      Language.instance.REMOVE,
                                                    ),
                                                    content: Text(
                                                      Language.instance
                                                          .COLLECTION_TRACK_PLAYLIST_REMOVE_DIALOG_BODY
                                                          .replaceAll(
                                                            'TRACK_NAME',
                                                            tracks[i].trackName,
                                                          )
                                                          .replaceAll(
                                                              'PLAYLIST_NAME',
                                                              widget.playlist
                                                                  .name),
                                                      style:
                                                          Theme.of(subContext)
                                                              .textTheme
                                                              .displaySmall,
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () async {
                                                          await Collection
                                                              .instance
                                                              .playlistRemoveTrack(
                                                            widget.playlist,
                                                            tracks[i],
                                                          );

                                                          Navigator.of(
                                                                  subContext)
                                                              .pop();
                                                          setState(() {});
                                                        },
                                                        child: Text(Language
                                                            .instance.YES),
                                                      ),
                                                      TextButton(
                                                        onPressed: Navigator.of(
                                                                subContext)
                                                            .pop,
                                                        child: Text(Language
                                                            .instance.NO),
                                                      ),
                                                    ],
                                                  ),
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
                            );
                          },
                          childCount: tracks.length,
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
                ),
              );
      },
    );
  }
}
