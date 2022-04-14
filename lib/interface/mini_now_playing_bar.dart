/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:extended_image/extended_image.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';

class MiniNowPlayingBar extends StatefulWidget {
  MiniNowPlayingBar({Key? key}) : super(key: key);

  @override
  State<MiniNowPlayingBar> createState() => MiniNowPlayingBarState();
}

class MiniNowPlayingBarState extends State<MiniNowPlayingBar> {
  double _yOffset = 0.0;

  bool get isHidden => _yOffset != 0.0;

  void show() {
    if (_yOffset != 0.0) {
      setState(() => _yOffset = 0.0);
    }
  }

  void hide() {
    if (_yOffset != 1.0) {
      setState(
        () => _yOffset = kMobileNowPlayingBarHeight /
            (MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.vertical),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(0, _yOffset),
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Miniplayer(
        elevation: 8.0,
        minHeight: kMobileNowPlayingBarHeight,
        maxHeight: 370,
        tapToCollapse: false,
        builder: (height, percentage) {
          return Column(
            children: [
              LinearProgressIndicator(
                value: 0.4,
                minHeight: 2.0,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
              ),
              Expanded(
                child: Stack(
                  children: [
                    LinearProgressIndicator(
                      value: 0.4,
                      minHeight: height - 2.0,
                      valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor.withOpacity(0.1)),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    Positioned.fill(
                      child: Row(
                        children: [
                          ExtendedImage(
                              image: getAlbumArt(
                                  Collection.instance.tracks.skip(10).first)),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Collection.instance.tracks
                                      .skip(10)
                                      .first
                                      .trackName
                                      .overflow,
                                  style: Theme.of(context).textTheme.headline2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  Collection.instance.tracks
                                      .skip(10)
                                      .first
                                      .trackArtistNames
                                      .take(2)
                                      .join(', ')
                                      .overflow,
                                  style: Theme.of(context).textTheme.headline3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 64.0,
                            width: 64.0,
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.play_arrow),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
