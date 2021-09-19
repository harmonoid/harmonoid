import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:harmonoid/core/youtubemusic.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class YouTubeTile extends StatelessWidget {
  final double? height;
  final double? width;
  final Track track;
  final Future<void> Function() action;

  const YouTubeTile({
    Key? key,
    required this.track,
    required this.height,
    required this.width,
    required this.action,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      height: this.height,
      width: this.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        color: Theme.of(context).cardColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          onTap: this.action,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Hero(
                    tag: 'album_art_${this.track.trackName}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      child: Image.network(
                        this.track.networkAlbumArt!,
                        fit: BoxFit.cover,
                        height: this.width,
                        width: this.width,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ContextMenuButton(
                      elevation: 0.0,
                      onSelected: (index) async {
                        switch (index) {
                          case 0:
                            {
                              await track.attachAudioStream();
                              await Playback.add(
                                [
                                  track,
                                ],
                              );
                              break;
                            }
                          case 1:
                            {
                              await Share.share(
                                'https://youtu.be/${track.trackId}',
                              );
                              break;
                            }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 0,
                          child: Text(
                            language!.STRING_ADD_TO_NOW_PLAYING,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: Text(
                            language!.STRING_SHARE,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                height: this.height! - this.width!,
                width: this.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        this.track.trackName!,
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${this.track.trackArtistNames!.join(', ')}',
                            style: Theme.of(context).textTheme.headline3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            '${this.track.albumName}',
                            style: Theme.of(context).textTheme.headline3,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
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
    );
  }
}
