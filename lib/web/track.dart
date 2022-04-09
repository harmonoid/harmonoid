/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:extended_image/extended_image.dart';

import 'package:harmonoid/models/media.dart' as media;
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

  @override
  void initState() {
    super.initState();
    PaletteGenerator.fromImageProvider(
            ExtendedNetworkImageProvider(widget.track.thumbnails.values.first))
        .then((palette) {
      setState(() {
        color = palette.colors.first;
      });
    });
  }

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
                                widget.track.thumbnails[120] ??
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
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16.0),
                        Text(
                          widget.track.trackName.replaceAll('(', '\n('),
                          style:
                              Theme.of(context).textTheme.headline2?.copyWith(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            '${widget.track.trackArtistNames.take(2).join(', ')}',
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                ?.copyWith(
                                  fontSize: 12.0,
                                  color:
                                      isDark ? Colors.white54 : Colors.black54,
                                ),
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          widget.track.duration.label,
                          style: Theme.of(context)
                              .textTheme
                              .headline3
                              ?.copyWith(
                                fontSize: 12.0,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                        ),
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
                    Web.instance.open(widget.track);
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
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16.0),
                  child: ContextMenuButton(
                    itemBuilder: (BuildContext context) =>
                        webTrackPopupMenuItems(
                      context,
                    ),
                    onSelected: (result) async {
                      switch (result) {
                        case 0:
                          {
                            await launch(widget.track.uri.toString());
                            break;
                          }
                        case 1:
                          {
                            await showAddToPlaylistDialog(
                              context,
                              media.Track.fromWebTrack(
                                widget.track.toJson(),
                              ),
                            );
                            break;
                          }
                      }
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
          switch (result) {
            case 0:
              {
                await launch(track.uri.toString());
                break;
              }
            case 1:
              {
                await showAddToPlaylistDialog(
                  context,
                  media.Track.fromWebTrack(track.toJson()),
                );
                break;
              }
          }
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
                              if (group == null) Language.instance.TRACK_SINGLE,
                              if (track.albumName.isNotEmpty)
                                track.albumName.overflow,
                              track.albumArtistName.overflow,
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
                    Container(
                      width: 64.0,
                      height: 64.0,
                      child: ContextMenuButton<int>(
                        onSelected: (result) {
                          switch (result) {
                            case 0:
                              {
                                launch(track.uri.toString());
                                break;
                              }
                            case 1:
                              {
                                showAddToPlaylistDialog(
                                  context,
                                  media.Track.fromWebTrack(track.toJson()),
                                );
                                break;
                              }
                          }
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
