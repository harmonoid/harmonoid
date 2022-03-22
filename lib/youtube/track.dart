/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_music/youtube_music.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/models/media.dart' as media;
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/youtube/state/youtube.dart';
import 'package:harmonoid/constants/language.dart';

class TrackSquareTile extends StatefulWidget {
  final double height;
  final double width;
  final Track track;

  const TrackSquareTile({
    Key? key,
    required this.track,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  TrackSquareTileState createState() => TrackSquareTileState();
}

class TrackSquareTileState extends State<TrackSquareTile> {
  double scale = 0.0;

  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      margin: EdgeInsets.zero,
      child: MouseRegion(
        onEnter: (e) => setState(() {
          scale = 1.0;
        }),
        onExit: (e) => setState(() {
          scale = 0.0;
        }),
        child: Container(
          height: widget.height,
          width: widget.width,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRect(
                    child: Hero(
                      tag: widget.track.hashCode,
                      child: ExtendedImage(
                        image: NetworkImage(
                          widget.track.thumbnails.length > 1
                              ? widget.track.thumbnails.values.skip(1).first
                              : widget.track.thumbnails.values.first,
                        ),
                        fit: BoxFit.cover,
                        height: widget.width,
                        width: widget.width,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: scale,
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20.0),
                          elevation: 4.0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20.0),
                            onTap: () {
                              YouTube.instance.open(widget.track);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.black54,
                              ),
                              height: 40.0,
                              width: 40.0,
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.0),
                      AnimatedScale(
                        scale: scale,
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20.0),
                          elevation: 4.0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20.0),
                            onTap: () {
                              trackPopupMenuHandle(
                                context,
                                media.Track.fromYouTubeMusicTrack(
                                    widget.track.toJson()),
                                2,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.black54,
                              ),
                              height: 40.0,
                              width: 40.0,
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  width: widget.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.track.trackName.overflow,
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          '${widget.track.trackArtistNames?.take(2).join(', ')}',
                          style:
                              Theme.of(context).textTheme.headline3?.copyWith(
                                    fontSize: 12.0,
                                  ),
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}

class TrackTile extends StatelessWidget {
  final Track track;
  const TrackTile({
    Key? key,
    required this.track,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => YouTube.instance.open(track),
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
                  ExtendedImage(
                    image: NetworkImage(
                      track.thumbnails.values.first,
                    ),
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
                            Language.instance.TRACK_SINGLE,
                            track.albumName?.overflow ?? '',
                            track.albumArtistName?.overflow,
                            track.duration?.label ?? ''
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
                      onSelected: (value) {
                        switch (value) {
                          case 0:
                            {
                              launch(track.uri.toString());
                              break;
                            }
                          case 1:
                            {
                              showAddToPlaylistDialog(
                                context,
                                media.Track.fromYouTubeMusicTrack(
                                    track.toJson()),
                              );
                              break;
                            }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          value: 0,
                          child: ListTile(
                            leading: Icon(Platform.isWindows
                                ? FluentIcons.earth_20_regular
                                : Icons.delete),
                            title: Text(
                              Language.instance.OPEN_IN_BROWSER,
                              style: isDesktop
                                  ? Theme.of(context).textTheme.headline4
                                  : null,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          value: 1,
                          child: ListTile(
                            leading: Icon(Platform.isWindows
                                ? FluentIcons.list_16_regular
                                : Icons.queue_music),
                            title: Text(
                              Language.instance.ADD_TO_PLAYLIST,
                              style: isDesktop
                                  ? Theme.of(context).textTheme.headline4
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
