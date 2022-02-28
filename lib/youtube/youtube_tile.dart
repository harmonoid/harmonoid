import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/utils/rendering.dart';

import 'package:harmonoid/youtube/state/youtube.dart';

class YoutubeTile extends StatefulWidget {
  final double height;
  final double width;
  final Track track;

  const YoutubeTile({
    Key? key,
    required this.track,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  YoutubeTileState createState() => YoutubeTileState();
}

class YoutubeTileState extends State<YoutubeTile> {
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
                        image: getAlbumArt(widget.track, small: true),
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
                                widget.track,
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
                          '${widget.track.trackArtistNames.take(2).join(', ')}',
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
