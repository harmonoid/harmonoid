import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class TrackItem extends StatelessWidget {
  final Track track;
  final double width;
  final double height;
  final VoidCallback? onTap;
  const TrackItem({
    super.key,
    required this.track,
    required this.width,
    required this.height,
    this.onTap,
  });

  Widget _buildDesktopLayout(BuildContext context) {
    return SizedBox(
      height: kDesktopTrackTileHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              onTap: onTap ??
                  () {
                    MediaPlayer.instance.open([track.toPlayable()]);
                  },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 1.0),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: kDesktopTrackTileHeight + 8.0,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        track.trackNumber == 0 ? '1' : track.trackNumber.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const VerticalDivider(width: 1.0),
                    Expanded(
                      flex: 5,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: kDesktopTrackTileHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1.0),
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: kDesktopTrackTileHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: HyperLink(
                          text: TextSpan(
                            children: [
                              for (final artist in (track.artists.isEmpty ? {kDefaultArtist} : track.artists)) ...[
                                TextSpan(
                                  text: artist,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO:
                                    },
                                ),
                                const TextSpan(
                                  text: ', ',
                                ),
                              ]
                            ]..removeLast(),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1.0),
                    Expanded(
                      flex: 4,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: kDesktopTrackTileHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: HyperLink(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: track.album.isEmpty ? kDefaultAlbum : track.album,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO:
                                  },
                              ),
                            ],
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1.0),
                    Expanded(
                      flex: 4,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: kDesktopTrackTileHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: HyperLink(
                          text: TextSpan(
                            children: [
                              for (final genre in (track.genres.isEmpty ? {kDefaultGenre} : track.genres)) ...[
                                TextSpan(
                                  text: genre,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO:
                                    },
                                ),
                                const TextSpan(
                                  text: ', ',
                                ),
                              ]
                            ]..removeLast(),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1.0),
                    Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: kDesktopTrackTileHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          track.year == 0 ? kDefaultYear : track.year.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    throw UnimplementedError();
  }
}
