/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
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

  const WebTrackLargeTile({
    Key? key,
    required this.track,
    required this.height,
    required this.width,
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

  // @override
  // void initState() {
  //   super.initState();
  // PaletteGenerator.fromImageProvider(ExtendedNetworkImageProvider(
  //         widget.track.thumbnails.values.first,
  //         cache: true))
  //     .then((palette) {
  //   setState(() {
  //     color = palette.colors.first;
  //   });
  // });
  // }

  Widget build(BuildContext context) {
    return Card(
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
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16.0),
                        Text(
                          widget.track.trackName.replaceFirst('(', '\n('),
                          style: Theme.of(context).textTheme.headline2,
                          // ?.copyWith(
                          //       color: isDark ? Colors.white : Colors.black,
                          //     ),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '${widget.track.trackArtistNames.take(2).join(', ')}',
                          style: Theme.of(context).textTheme.headline3,
                          // ?.copyWith(
                          //   fontSize: isDesktop ? 12.0 : null,
                          //   color: isDark ? Colors.white54 : Colors.black54,
                          // ),
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          widget.track.duration.label,
                          style: Theme.of(context).textTheme.headline3,
                          // ?.copyWith(
                          //   fontSize: isDesktop ? 12.0 : null,
                          //   color: isDark ? Colors.white54 : Colors.black54,
                          // ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Web.open(widget.track);
                  },
                  onLongPress: () async {
                    int? result;
                    await showModalBottomSheet(
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
                    width: widget.width,
                    height: widget.height,
                  ),
                ),
              ),
              if (isDesktop)
                Positioned(
                  bottom: 4.0,
                  right: 4.0,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.0),
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
                ),
            ],
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
            position: RelativeRect.fromRect(
              Offset(e.position.dx, e.position.dy) & Size(228.0, 320.0),
              Rect.fromLTWH(
                0,
                0,
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              ),
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
              Web.open(
                group,
                index: group!.indexOf(track),
              );
            } else {
              Web.open(track);
            }
          },
          onLongPress: () async {
            int? result;
            await showModalBottomSheet(
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
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
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
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            [
                              if (group == null &&
                                  track.duration != Duration.zero)
                                Language.instance.TRACK_SINGLE,
                              if (track.albumName.isNotEmpty)
                                track.albumName.overflow,
                              if (track.albumArtistName.isNotEmpty)
                                track.albumArtistName.overflow,
                              if (track.duration != Duration.zero)
                                track.duration.label
                            ].join(' • '),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    if (isDesktop)
                      Container(
                        width: 64.0,
                        height: 64.0,
                        child: ContextMenuButton<int>(
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
