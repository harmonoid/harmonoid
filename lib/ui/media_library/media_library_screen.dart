import 'dart:math';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/extensions/go_router.dart';
import 'package:harmonoid/extensions/media_library.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/media_library/media_library_inaccessible_directories_screen.dart';
import 'package:harmonoid/ui/media_library/media_library_no_items_banner.dart';
import 'package:harmonoid/ui/media_library/media_library_search_bar.dart';
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
  late final AnimationDuration? _duration = Theme.of(context).extension<AnimationDuration>();

  final ValueNotifier<bool> _floatingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _desktopAppBarElevatedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> _mediaLibrarySearchBarOffsetNotifier = ValueNotifier<double>(0.0);
  final FocusNode _queryTextFieldFocusNode = FocusNode();
  final TextEditingController _queryTextFieldEditingController = TextEditingController();

  String? _current;

  String get _path => router.location.split('/').last;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MediaLibraryInaccessibleDirectoriesScreen.showIfRequired(context);
      Intent.instance.notify(playbackState: Configuration.instance.mediaPlayerPlaybackState);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_current != _path) {
      _current = _path;
      _floatingNotifier.value = false;
      _desktopAppBarElevatedNotifier.value = false;
      _mediaLibrarySearchBarOffsetNotifier.value = 0.0;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _floatingNotifier.dispose();
    _desktopAppBarElevatedNotifier.dispose();
    _mediaLibrarySearchBarOffsetNotifier.dispose();
    _queryTextFieldFocusNode.dispose();
    _queryTextFieldEditingController.dispose();
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
                child: mediaLibrary.isEmpty
                    ? const Center(
                        child: MediaLibraryNoItemsBanner(),
                      )
                    : NotificationListener<ScrollMetricsNotification>(
                        // https://github.com/flutter/flutter/issues/70504#issuecomment-1170609808
                        onNotification: (notification) {
                          if (notification.metrics.axis == Axis.vertical) {
                            _floatingNotifier.value = notification.metrics.pixels > 0.0;
                            _desktopAppBarElevatedNotifier.value = notification.metrics.pixels > 0.0;
                          }
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
              Positioned(
                right: 16.0,
                bottom: 16.0,
                child: _path == kPlaylistsPath ? const MediaLibraryCreatePlaylistButton() : const MediaLibraryRefreshButton(),
              ),
              ClipRect(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  height: captionHeight + kDesktopAppBarHeight + 8.0,
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _desktopAppBarElevatedNotifier,
                    builder: (context, desktopAppBarElevated, _) => TweenAnimationBuilder<Color?>(
                      tween: ColorTween(
                        begin: Theme.of(context).appBarTheme.backgroundColor ?? Colors.transparent,
                        end: (desktopAppBarElevated
                                ? Color.lerp(
                                    Theme.of(context).appBarTheme.backgroundColor,
                                    Theme.of(context).appBarTheme.surfaceTintColor,
                                    0.08,
                                  )
                                : Theme.of(context).appBarTheme.backgroundColor) ??
                            Colors.transparent,
                      ),
                      duration: _duration!.fast,
                      builder: (context, value, child) {
                        return Material(
                          elevation: Theme.of(context).appBarTheme.elevation ?? kDefaultAppBarElevation,
                          color: value,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DesktopCaptionBar(
                                caption: kCaption,
                                color: value,
                              ),
                              Expanded(
                                child: Container(
                                  height: kDesktopAppBarHeight - 20.0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: child!,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: {
                              kAlbumsPath: Localization.instance.ALBUMS,
                              kTracksPath: Localization.instance.TRACKS,
                              kArtistsPath: Localization.instance.ARTISTS,
                              kGenresPath: Localization.instance.GENRES,
                              kPlaylistsPath: Localization.instance.PLAYLISTS,
                            }.entries.map<Widget>(
                              (e) {
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      context.go('/$kMediaLibraryPath/${e.key}');
                                      Configuration.instance.set(mediaLibraryPath: e.key);
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
                                  focusNode: _queryTextFieldFocusNode,
                                  controller: _queryTextFieldEditingController,
                                  cursorWidth: 1.0,
                                  onSubmitted: (value) async {
                                    context.go(Uri(path: '/$kMediaLibraryPath/$kSearchPath', queryParameters: {kSearchArgQuery: value}).toString());
                                    await Future.delayed(MaterialRoute.animationDuration?.medium ?? const Duration(milliseconds: 300));
                                    _queryTextFieldFocusNode.requestFocus();
                                  },
                                  textAlignVertical: TextAlignVertical.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  decoration: inputDecoration(
                                    context,
                                    Localization.instance.SEARCH_BANNER_SUBTITLE,
                                    suffixIcon: Transform.rotate(
                                      angle: pi / 2,
                                      child: Tooltip(
                                        message: Localization.instance.SEARCH,
                                        child: Icon(
                                          Icons.search,
                                          size: 20.0,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    onSuffixIconPressed: () async {
                                      context.go(Uri(path: '/$kMediaLibraryPath/$kSearchPath', queryParameters: {kSearchArgQuery: _queryTextFieldEditingController.text}).toString());
                                      await Future.delayed(MaterialRoute.animationDuration?.medium ?? const Duration(milliseconds: 300));
                                      _queryTextFieldFocusNode.requestFocus();
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              const PlayFileOrURLButton(),
                              const ReadFileOrURLMetadataButton(),
                              IconButton(
                                onPressed: () {
                                  context.push('/$kSettingsPath');
                                },
                                tooltip: Localization.instance.SETTINGS,
                                icon: const Icon(Icons.settings),
                                iconSize: 20.0,
                                splashRadius: 18.0,
                                color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
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
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is UserScrollNotification) {
                    if (notification.metrics.axis == Axis.vertical) {
                      if (notification.direction == ScrollDirection.forward) {
                        _mediaLibrarySearchBarOffsetNotifier.value = 0.0;
                      }
                      if (notification.direction == ScrollDirection.reverse) {
                        _mediaLibrarySearchBarOffsetNotifier.value = -1.0 * mediaLibraryScrollViewBuilderPadding.top;
                      }
                    }
                  } else {
                    if (notification.metrics.axis == Axis.vertical) {
                      if (notification.metrics.pixels == 0.0) {
                        _mediaLibrarySearchBarOffsetNotifier.value = 0.0;
                      }
                    }
                  }
                  return false;
                },
                child: mediaLibrary.isEmpty
                    ? const Center(
                        child: MediaLibraryNoItemsBanner(),
                      )
                    : widget.child,
              ),
              ValueListenableBuilder<double>(
                valueListenable: _mediaLibrarySearchBarOffsetNotifier,
                builder: (context, offset, _) {
                  return AnimatedPositioned(
                    top: offset,
                    left: 0.0,
                    right: 0.0,
                    curve: Curves.easeInOut,
                    duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
                    child: const MediaLibrarySearchBar(),
                  );
                },
              ),
              Positioned(
                right: 16.0,
                bottom: 16.0,
                child: _path == kPlaylistsPath ? const MediaLibraryCreatePlaylistButton() : const MediaLibraryRefreshButton(),
              ),
            ],
          ),
          bottomNavigationBar: const MobileNavigationBar(),
        );
      },
    );
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
