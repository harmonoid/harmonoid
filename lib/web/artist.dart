/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:extended_image/extended_image.dart';

import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';

class ArtistTile extends StatelessWidget {
  final Artist artist;

  const ArtistTile({
    Key? key,
    required this.artist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Handle [Artist].
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
                  Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(2.0),
                      child: artist.thumbnails.isNotEmpty
                          ? ClipOval(
                              child: ExtendedImage(
                                image: NetworkImage(
                                  artist.thumbnails.values.first,
                                ),
                                height: 52.0,
                                width: 52.0,
                              ),
                            )
                          : SizedBox.square(
                              dimension: 52.0,
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
                          artist.artistName.overflow,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),
                        Text(
                          [artist.subscribersCount].join(' • '),
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
