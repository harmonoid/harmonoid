/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_music/youtube_music.dart';

import 'package:harmonoid/models/media.dart' as media;
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/youtube/state/youtube.dart';

class VideoTile extends StatelessWidget {
  final Video video;
  const VideoTile({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          YouTube.instance.open(video);
        },
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
                      video.thumbnails.values.first,
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
                          video.videoName.overflow,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),
                        Text(
                          [
                            Language.instance.VIDEO_SINGLE,
                            video.channelName,
                            (video.duration?.label ?? '')
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
                              launch(video.uri.toString());
                              break;
                            }
                          case 1:
                            {
                              showAddToPlaylistDialog(
                                context,
                                media.Track.fromYouTubeMusicVideo(
                                    video.toJson()),
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
