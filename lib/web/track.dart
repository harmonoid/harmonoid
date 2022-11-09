/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:extended_image/extended_image.dart';

import 'package:harmonoid/web/state/web.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/web/utils/rendering.dart';

class WebTrackLargeTile extends StatefulWidget {
  final double height;
  final double width;
  final Track track;
  final HashMap<String, Color>? colorKeys;

  const WebTrackLargeTile({
    Key? key,
    required this.track,
    required this.height,
    required this.width,
    this.colorKeys,
  }) : super(key: key);

  @override
  WebTrackLargeTileState createState() => WebTrackLargeTileState();
}

class WebTrackLargeTileState extends State<WebTrackLargeTile> {
  double scale = 1.0;
  Color? color;

  bool get isDark =>
      (0.299 * (color?.red ?? 256.0)) +
          (0.587 * (color?.green ?? 256.0)) +
          (0.114 * (color?.blue ?? 256.0)) <
      128.0;

  @override
  void initState() {
    super.initState();
    if (widget.colorKeys != null) {
      if (!widget.colorKeys!.containsKey(widget.track.uri.toString())) {
        if (isDesktop) {
          PaletteGenerator.fromImageProvider(ExtendedNetworkImageProvider(
                  widget.track.thumbnails.values.first,
                  cache: true))
              .then((palette) {
            setState(() {
              if (palette.colors != null) {
                widget.colorKeys![widget.track.uri.toString()] =
                    palette.colors!.first;
                color = palette.colors!.first;
              }
            });
          });
        }
      } else {
        color = widget.colorKeys![widget.track.uri.toString()];
      }
    }
  }

  Widget build(BuildContext context) {
    return isDesktop
        ? Card(
            color: color,
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            margin: EdgeInsets.zero,
            child: MouseRegion(
              onEnter: (e) => setState(() {
                scale = 1.1;
              }),
              onExit: (e) => setState(() {
                scale = 1.0;
              }),
              child: Container(
                height: widget.height,
                width: widget.width,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRect(
                          child: Hero(
                            tag: widget.track.hashCode,
                            child: TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 100),
                              tween: Tween<double>(begin: 1.0, end: scale),
                              builder: (BuildContext context, double value, _) {
                                return Transform.scale(
                                  scale: value,
                                  child: ExtendedImage(
                                    image: NetworkImage(
                                      widget.track.thumbnails[180] ??
                                          widget.track.thumbnails.values.first,
                                    ),
                                    fit: BoxFit.cover,
                                    width: widget.height,
                                    height: widget.height,
                                  ),
                                );
                              },
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
                              const SizedBox(height: 16.0),
                              Text(
                                widget.track.trackName.replaceFirst('(', '\n('),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      fontSize: 14.0,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.left,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '${widget.track.trackArtistNames.take(2).join(', ')}',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      fontSize: isDesktop ? 12.0 : null,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                widget.track.duration.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      fontSize: isDesktop ? 12.0 : null,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                              ),
                              const SizedBox(height: 16.0),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12.0),
                      ],
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Web.instance.open(widget.track);
                        },
                        onLongPress: () async {
                          int? result;
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) => Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: webTrackPopupMenuItems(context)
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
                          webTrackPopupMenuHandle(
                              context, widget.track, result);
                        },
                        child: Container(
                          width: widget.width,
                          height: widget.height,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4.0,
                      right: 4.0,
                      child: ContextMenuButton(
                        itemBuilder: (BuildContext context) =>
                            webTrackPopupMenuItems(
                          context,
                        ),
                        onSelected: (result) async {
                          webTrackPopupMenuHandle(
                              context, widget.track, result as int?);
                        },
                        icon: Icon(
                          Icons.more_vert,
                          size: 16.0,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            margin: EdgeInsets.zero,
            color: Theme.of(context).cardTheme.color,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Web.instance.open(widget.track);
                },
                onLongPress: () async {
                  int? result;
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: webTrackPopupMenuItems(context)
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
                  webTrackPopupMenuHandle(context, widget.track, result);
                },
                child: Container(
                  height: widget.height,
                  width: widget.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExtendedImage(
                        image: NetworkImage(
                          widget.track.thumbnails.values.skip(1).first,
                        ),
                        fit: BoxFit.cover,
                        width: widget.height,
                        height: widget.height,
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
                              style: Theme.of(context).textTheme.displayMedium,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              widget.track.trackArtistNames
                                  .take(2)
                                  .join(', ')
                                  .overflow,
                              style: Theme.of(context).textTheme.displaySmall,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: widget.height,
                        width: widget.height - 12.0,
                        child: IconButton(
                          iconSize: 24.0,
                          splashRadius: 20.0,
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () async {
                            int? result;
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) => Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: webTrackPopupMenuItems(context)
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
                            webTrackPopupMenuHandle(
                                context, widget.track, result);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

class WebTrackTile extends StatelessWidget {
  final Track track;
  final List<Track>? group;
  const WebTrackTile({
    Key? key,
    required this.track,
    this.group,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ContextMenuArea(
        onPressed: (e) async {
          final result = await showMenu(
            elevation: 4.0,
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
            items: webTrackPopupMenuItems(
              context,
            ),
          );
          webTrackPopupMenuHandle(context, track, result);
        },
        child: InkWell(
          onTap: () {
            if (group != null) {
              Web.instance.open(
                group,
                index: group!.indexOf(track),
              );
            } else {
              Web.instance.open(track);
            }
          },
          onLongPress: () async {
            int? result;
            await showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) => Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: webTrackPopupMenuItems(context)
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
            webTrackPopupMenuHandle(context, track, result);
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
                    if (track.thumbnails.isNotEmpty && group == null)
                      ExtendedImage(
                        image: NetworkImage(
                          track.thumbnails.values.first,
                        ),
                        height: 56.0,
                        width: 56.0,
                      )
                    else
                      Container(
                        height: 56.0,
                        width: 56.0,
                        child: Text(
                          '${track.trackNumber}',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontSize: 18.0),
                        ),
                        alignment: Alignment.center,
                      ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.trackName.overflow,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            [
                              if (group == null &&
                                  track.duration != Duration.zero)
                                Language.instance.TRACK_SINGLE,
                              if (track.albumArtistName.isNotEmpty)
                                track.albumArtistName.overflow,
                              if (track.albumName.isNotEmpty)
                                track.albumName.overflow,
                              if (track.duration != Duration.zero)
                                track.duration.label
                            ].join(' • '),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Container(
                      width: 64.0,
                      height: 64.0,
                      child: isMobile
                          ? IconButton(
                              splashRadius: 20.0,
                              icon: Icon(
                                Icons.more_vert,
                              ),
                              onPressed: () async {
                                int? result;
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) => Container(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: webTrackPopupMenuItems(context)
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
                                webTrackPopupMenuHandle(
                                  context,
                                  track,
                                  result,
                                );
                              },
                            )
                          : ContextMenuButton<int>(
                              onSelected: (result) {
                                webTrackPopupMenuHandle(context, track, result);
                              },
                              itemBuilder: (context) =>
                                  webTrackPopupMenuItems(context),
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
    );
  }
}
