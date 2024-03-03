import 'dart:math';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class MediaLibraryScreen extends StatefulWidget {
  final Widget child;
  const MediaLibraryScreen({super.key, required this.child});

  @override
  State<MediaLibraryScreen> createState() => MediaLibraryScreenState();
}

class MediaLibraryScreenState extends State<MediaLibraryScreen> {
  final FocusNode _node = FocusNode();
  final ValueNotifier<bool> _floatingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _desktopAppBarElevatedNotifier = ValueNotifier<bool>(false);

  String? _current;

  String get _path => GoRouterState.of(context).uri.pathSegments.last;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_current != _path) {
      _current = _path;
      _floatingNotifier.value = false;
      _desktopAppBarElevatedNotifier.value = false;
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: captionHeight + kDesktopAppBarHeight,
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    _floatingNotifier.value = notification.metrics.pixels > 0.0;
                    _desktopAppBarElevatedNotifier.value = notification.metrics.pixels > 0.0;
                    return false;
                  },
                  child: widget.child,
                ),
              ),
              DesktopMediaLibraryFloatingSortButton(
                floatingNotifier: _floatingNotifier,
              ),
              const Positioned(
                left: 16.0,
                bottom: 16.0,
                child: DesktopMediaLibraryRefreshIndicator(),
              ),
              const Positioned(
                right: 16.0,
                bottom: 16.0,
                child: MediaLibraryRefreshButton(),
              ),
              ClipRect(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  height: captionHeight + kDesktopAppBarHeight + 8.0,
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _desktopAppBarElevatedNotifier,
                    builder: (context, desktopAppBarElevated, _) => Material(
                      elevation: Theme.of(context).appBarTheme.elevation ?? kDefaultAppBarElevation,
                      color: desktopAppBarElevated
                          ? Color.lerp(
                              Theme.of(context).appBarTheme.backgroundColor,
                              Theme.of(context).appBarTheme.surfaceTintColor,
                              0.08,
                            )
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DesktopCaptionBar(
                            caption: kCaption,
                            color: desktopAppBarElevated
                                ? Color.lerp(
                                    Theme.of(context).appBarTheme.backgroundColor,
                                    Theme.of(context).appBarTheme.surfaceTintColor,
                                    0.08,
                                  )
                                : null,
                          ),
                          Expanded(
                            child: Container(
                              height: kDesktopAppBarHeight - 20.0,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: {
                                      kAlbumsPath: Language.instance.ALBUMS,
                                      kTracksPath: Language.instance.TRACKS,
                                      kArtistsPath: Language.instance.ARTISTS,
                                      kGenresPath: Language.instance.GENRES,
                                      kPlaylistsPath: Language.instance.PLAYLISTS,
                                    }.entries.map<Widget>(
                                      (e) {
                                        return InkWell(
                                          borderRadius: BorderRadius.circular(4.0),
                                          onTap: () {
                                            context.go('/$kMediaLibraryPath/${e.key}');
                                          },
                                          child: Container(
                                            height: kDesktopAppBarHeight - 20.0,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Text(
                                                  e.value.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: e.key == _path ? Theme.of(context).textTheme.bodyLarge?.color : Colors.transparent,
                                                  ),
                                                ),
                                                Text(
                                                  e.value.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w300,
                                                    color: e.key != _path ? Theme.of(context).textTheme.bodyMedium?.color : Colors.transparent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList() +
                                    [
                                      const Spacer(),
                                      const SizedBox(width: 8.0),
                                      SizedBox(
                                        height: 40.0,
                                        width: 280.0,
                                        child: DefaultTextField(
                                          focusNode: _node,
                                          cursorWidth: 1.0,
                                          onSubmitted: (value) {
                                            _node.requestFocus();
                                            // TODO:
                                          },
                                          textAlignVertical: TextAlignVertical.center,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          decoration: inputDecoration(
                                            context,
                                            Language.instance.SEARCH_SUBTITLE,
                                            suffixIcon: Transform.rotate(
                                              angle: pi / 2,
                                              child: Tooltip(
                                                message: Language.instance.SEARCH,
                                                child: Icon(
                                                  Icons.search,
                                                  size: 20.0,
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                            onSuffixIconPressed: () {
                                              _node.requestFocus();
                                              // TODO:
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      const PlayFileOrURLButton(),
                                      const ReadFileOrURLMetadataButton(),
                                      IconButton(
                                        onPressed: () {
                                          // TODO:
                                        },
                                        tooltip: Language.instance.SETTINGS,
                                        icon: const Icon(Icons.settings),
                                        iconSize: 20.0,
                                        splashRadius: 18.0,
                                        color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
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
              ),
            ],
          ),
        );
      },
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