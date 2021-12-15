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
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/youtubemusic.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class YouTubeTile extends StatelessWidget {
  final double? height;
  final double? width;
  final Track track;

  const YouTubeTile({
    Key? key,
    required this.track,
    required this.height,
    required this.width,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      height: this.height,
      width: this.width,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ScaleOnHover(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: -10.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        this.track.networkAlbumArt!,
                        height: this.width! - 44.0,
                        width: this.width! - 44.0,
                      ),
                      Container(
                        color: Colors.black.withOpacity(
                            Theme.of(context).brightness == Brightness.light
                                ? 0.1
                                : 0.6),
                        height: this.width! - 44.0,
                        width: this.width! - 44.0,
                      ),
                      ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 8.0,
                            sigmaY: 8.0,
                          ),
                          child: Container(
                            height: this.width!,
                            width: this.width!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4.0),
                  ),
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FadeThroughTransition(
                          fillColor: Colors.transparent,
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          child: YouTube(
                            track: this.track,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'track_art_${this.track.trackName}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                      child: Image.network(
                        this.track.networkAlbumArt!,
                        fit: BoxFit.cover,
                        height: this.width! - 48.0,
                        width: this.width! - 48.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20.0,
            child: Container(
              width: this.width,
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${this.track.trackName}',
                    style: Theme.of(context).textTheme.headline2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 2.0,
                  ),
                  Text(
                    '${this.track.trackArtistNames!.join(', ')}',
                    style: Theme.of(context).textTheme.headline3,
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class YouTube extends StatefulWidget {
  final Track track;
  const YouTube({Key? key, required this.track}) : super(key: key);
  YouTubeState createState() => YouTubeState();
}

class YouTubeState extends State<YouTube> {
  String? description;

  @override
  void initState() {
    super.initState();
    this.description = widget.track.extras;
    widget.track.attachAudioStream(
      onDone: () {
        this.setState(
          () => this.description = widget.track.extras,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        height: MediaQuery.of(context).size.width.normalized >
                kDesktopHorizontalBreakPoint
            ? MediaQuery.of(context).size.height.normalized
            : 324.0 + 128.0,
        width: MediaQuery.of(context).size.width.normalized / 3,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 324.0,
                      maxHeight: 324.0,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned.fill(
                          bottom: -20.0,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(44.0),
                                    child: Image.network(
                                      widget.track.networkAlbumArt!,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(44.0),
                                    child: Container(
                                      color: Colors.black.withOpacity(
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? 0.1
                                              : 0.4),
                                    ),
                                  ),
                                ],
                              ),
                              ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 8.0,
                                    sigmaY: 8.0,
                                  ),
                                  child: Container(
                                    height: 284.0,
                                    width: 284.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Hero(
                            tag: 'track_art_${widget.track.trackName}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              child: Image.network(
                                widget.track.networkAlbumArt!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 0.0),
              Container(
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
                // decoration: BoxDecoration(
                //   color: Theme.of(context).brightness == Brightness.dark
                //       ? Colors.white.withOpacity(0.08)
                //       : Colors.black.withOpacity(0.08),
                //   borderRadius: BorderRadius.circular(8.0),
                // ),
                child: Column(
                  children: [
                    Text(
                      widget.track.trackName!,
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          ?.copyWith(fontSize: 24.0),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      widget.track.albumName!,
                      style: Theme.of(context).textTheme.headline3,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.track.albumArtistName}\n(${widget.track.year ?? 'Unknown Year'})',
                      style: Theme.of(context).textTheme.headline3,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.0),
              widget.track.filePath == null
                  ? Container(
                      height: 28.0,
                      margin: EdgeInsets.symmetric(horizontal: 48.0),
                      child: Center(
                        child: LinearProgressIndicator(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () {
                            Playback.play(
                              index: 0,
                              tracks: [
                                widget.track,
                              ],
                            );
                            Provider.of<YouTubeStateController>(
                              context,
                              listen: false,
                            ).updateRecommendations(
                              widget.track,
                            );
                          },
                          child: Text(
                            language.PLAY_NOW,
                          ),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () {
                            Playback.add(
                              [
                                widget.track,
                              ],
                            );
                          },
                          child: Text(
                            language.ADD_TO_NOW_PLAYING,
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 18.0),
            ],
          ),
        ),
      ),
      builder: (context, collection, child) => Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) => Container(
            height: MediaQuery.of(context).size.height.normalized,
            width: MediaQuery.of(context).size.width.normalized,
            child: Column(
              children: [
                Container(
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    border: Border(
                      bottom: BorderSide(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.12)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      NavigatorPopButton(),
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        'YouTube',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Color(0xFF202020),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        constraints.maxWidth > kDesktopHorizontalBreakPoint
                            ? child!
                            : Container(),
                        Expanded(
                          child: constraints.maxWidth >
                                  kDesktopHorizontalBreakPoint
                              ? (this.description == null
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    )
                                  : CustomListView(
                                      children: <Widget>[
                                        constraints.maxWidth >
                                                kDesktopHorizontalBreakPoint
                                            ? Container()
                                            : child!,
                                        SubHeader(
                                          language.ABOUT_TITLE,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(18.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                this.description == null
                                                    ? CrossAxisAlignment.center
                                                    : CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                this.description!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ))
                              : CustomListView(
                                  children: <Widget>[
                                    constraints.maxWidth >
                                            kDesktopHorizontalBreakPoint
                                        ? Container()
                                        : child!,
                                    SubHeader(
                                      language.ABOUT_TITLE,
                                    ),
                                    this.description == null
                                        ? Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                            ),
                                          )
                                        : Padding(
                                            padding: EdgeInsets.all(18.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment: this
                                                          .description ==
                                                      null
                                                  ? CrossAxisAlignment.center
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  this.description!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline4,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
