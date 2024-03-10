import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class TrackItem extends StatefulWidget {
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

  @override
  State<TrackItem> createState() => TrackItemState();
}

class TrackItemState extends State<TrackItem> {
  bool _reactToSecondaryPress = false;

  Widget _buildDesktopLayout(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        _reactToSecondaryPress = e.kind == PointerDeviceKind.mouse && e.buttons == kSecondaryMouseButton;
      },
      onPointerUp: (e) async {
        if (!_reactToSecondaryPress) {
          return;
        }
        final path = GoRouterState.of(context).uri.pathSegments.last;
        final result = await showMaterialMenu(
          context: context,
          constraints: const BoxConstraints(
            maxWidth: double.infinity,
          ),
          position: RelativeRect.fromLTRB(
            e.position.dx,
            e.position.dy - (path != kSearchPath ? 0.0 : captionHeight + kDesktopAppBarHeight),
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
          items: trackPopupMenuItems(context, widget.track),
        );
        await trackPopupMenuHandle(context, widget.track, result);
      },
      child: SizedBox(
        height: kDesktopTrackTileHeight,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: widget.onTap ??
                    () {
                      MediaPlayer.instance.open([widget.track.toPlayable()]);
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
                          widget.track.trackNumber == 0 ? '1' : widget.track.trackNumber.toString(),
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
                            widget.track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                                for (final artist in (widget.track.artists.isEmpty ? {kDefaultArtist} : widget.track.artists)) ...[
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
                                  text: widget.track.album.isEmpty ? kDefaultAlbum : widget.track.album,
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
                                for (final genre in (widget.track.genres.isEmpty ? {kDefaultGenre} : widget.track.genres)) ...[
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
                            widget.track.year == 0 ? kDefaultYear : widget.track.year.toString(),
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
