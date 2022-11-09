/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:extended_image/extended_image.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/web/state/web.dart';
import 'package:harmonoid/web/utils/rendering.dart';

class WebVideoLargeTile extends StatefulWidget {
  final double height;
  final double width;
  final Track track;

  const WebVideoLargeTile({
    Key? key,
    required this.track,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  WebVideoLargeTileState createState() => WebVideoLargeTileState();
}

class WebVideoLargeTileState extends State<WebVideoLargeTile> {
  double scale = 1.0;

  Widget build(BuildContext context) {
    return Card(
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
              Hero(
                tag: widget.track.hashCode,
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 100),
                  tween: Tween<double>(begin: 1.0, end: scale),
                  builder: (BuildContext context, double value, _) {
                    return Transform.scale(
                      scale: value,
                      child: ExtendedImage(
                        image: ExtendedNetworkImageProvider(
                          widget.track.thumbnails[120] ??
                              widget.track.thumbnails.values.first,
                          cache: true,
                        ),
                        fit: BoxFit.cover,
                        width: widget.width,
                        height: widget.height,
                      ),
                    );
                  },
                ),
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
                    webTrackPopupMenuHandle(context, widget.track, result);
                  },
                  child: Container(
                    width: widget.width,
                    height: widget.height,
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                        stops: [
                          0.2,
                          1.0,
                        ],
                      ),
                    ),
                    child: Container(
                      height: 64.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.track.trackName.overflow,
                                  style: isDesktop
                                      ? Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          )
                                      : Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Text(
                                    '${widget.track.trackArtistNames.take(2).join(', ')}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          color: Colors.white54,
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
                          const SizedBox(width: 12.0),
                          if (widget.track.duration != Duration.zero)
                            Text(
                              widget.track.duration.label,
                              style: TextStyle(
                                color: Colors.white54,
                              ),
                            ),
                          const SizedBox(width: 4.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4.0,
                right: 4.0,
                child: isMobile
                    ? IconButton(
                        splashRadius: 20.0,
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.white54,
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
                      )
                    : ContextMenuButton(
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
                          color: Colors.white54,
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

class VideoTile extends StatelessWidget {
  final Video video;
  const VideoTile({Key? key, required this.video}) : super(key: key);

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
          webTrackPopupMenuHandle(context, video, result);
        },
        child: InkWell(
          onTap: () {
            Web.instance.open(video);
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
            webTrackPopupMenuHandle(context, video, result);
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
                      image: ExtendedNetworkImageProvider(
                        video.thumbnails.values.first,
                        cache: true,
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
                            style: Theme.of(context).textTheme.displayMedium,
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
                                  video,
                                  result,
                                );
                              },
                            )
                          : ContextMenuButton<int>(
                              onSelected: (result) {
                                webTrackPopupMenuHandle(context, video, result);
                              },
                              itemBuilder: (context) =>
                                  webTrackPopupMenuItems(context),
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
