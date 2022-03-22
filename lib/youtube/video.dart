/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_music/youtube_music.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';

class VideoTile extends StatelessWidget {
  final Video video;
  const VideoTile({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Handle [Video].
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
