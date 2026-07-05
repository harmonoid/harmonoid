import 'dart:math';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/extensions/set.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/build_context.dart';
import 'package:harmonoid/mappers/media_library_tab.dart';
import 'package:harmonoid/features/media_library/models/media_library_tab.dart';
import 'package:harmonoid/features/now_playing/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/features/media_library/desktop/desktop_media_library_floating_sort_button.dart';
import 'package:harmonoid/features/media_library/media_library_create_playlist_button.dart';
import 'package:harmonoid/features/media_library/media_library_no_items_banner.dart';
import 'package:harmonoid/features/media_library/media_library_refresh_button.dart';
import 'package:harmonoid/features/media_library/mobile/mobile_media_library_search_bar.dart';
import 'package:harmonoid/features/media_library/refresh_indicator/desktop/desktop_refresh_indicator.dart';
import 'package:harmonoid/features/media_library/state/media_library_scroll_view_builder_data_provider.dart';
import 'package:harmonoid/features/now_playing/utils/dimensions.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/features/update/update_button.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class MediaLibraryScreen extends StatefulWidget {
  final Widget child;

  const MediaLibraryScreen({super.key, required this.child});

  @override
  State<MediaLibraryScreen> createState() => MediaLibraryScreenState();
}

class MediaLibraryScreenState extends State<MediaLibraryScreen> {
  static final FocusNode desktopQueryTextFieldFocusNode = FocusNode();

  late final AnimationDuration? _duration = Theme.of(context).extension<AnimationDuration>();

  final ValueNotifier<bool> _desktopMediaLibrarySortButtonFloatingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _desktopAppBarElevatedNotifier = ValueNotifier<bool>(false);
  final TextEditingController _desktopSearchTextEditingController = TextEditingController();
  final ValueNotifier<double> _mobileMediaLibrarySearchBarOffsetNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _mobileMediaLibraryRefreshButtonOffsetNotifier = ValueNotifier<double>(0.0);

  String? _current;

  String get _path => context.location.split('/').last;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<NowPlayingMobileNotifier>().setMediaLibraryScreenStateRef(this));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_current != _path) {
      _current = _path;
      _desktopMediaLibrarySortButtonFloatingNotifier.value = false;
      _desktopAppBarElevatedNotifier.value = false;
      _mobileMediaLibrarySearchBarOffsetNotifier.value = 0.0;
    }
  }

  @override
  void dispose() {
    _desktopMediaLibrarySortButtonFloatingNotifier.dispose();
    _desktopAppBarElevatedNotifier.dispose();
    _desktopSearchTextEditingController.dispose();
    _mobileMediaLibrarySearchBarOffsetNotifier.dispose();
    _mobileMediaLibraryRefreshButtonOffsetNotifier.dispose();
    super.dispose();
  }

  void mobileShiftMediaLibraryRefreshButton() {
    _mobileMediaLibraryRefreshButtonOffsetNotifier.value = kMobileNowPlayingBarHeight;
  }

  void mobileUnshiftMediaLibraryRefreshButton() {
    _mobileMediaLibraryRefreshButtonOffsetNotifier.value = 0.0;
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
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
                    child: mediaLibrary.tracks.isEmpty
                        ? const Center(
                            child: MediaLibraryNoItemsBanner(),
                          )
                        : NotificationListener<ScrollMetricsNotification>(
                            // https://github.com/flutter/flutter/issues/70504#issuecomment-1170609808
                            onNotification: (notification) {
                              if (notification.metrics.axis == Axis.vertical) {
                                _desktopMediaLibrarySortButtonFloatingNotifier.value = notification.metrics.pixels > 0.0;
                                _desktopAppBarElevatedNotifier.value = notification.metrics.pixels > 0.0;
                              }
                              return false;
                            },
                            child: widget.child,
                          ),
                  ),
                  DesktopMediaLibraryFloatingSortButton(
                    floatingNotifier: _desktopMediaLibrarySortButtonFloatingNotifier,
                  ),
                  const Positioned(
                    left: 16.0,
                    bottom: 16.0,
                    child: DesktopRefreshIndicator(),
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
                            end:
                                (desktopAppBarElevated
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
                            children:
                                Configuration.instance.mediaLibraryVisibleTabs.ifEmpty(MediaLibraryTab.values.toSet()).map<Widget>(
                                  (e) {
                                    const selected = TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600);
                                    const unselected = TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300);
                                    return MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (e.toPath() == _path) return;
                                          context.push('/$kMediaLibraryPath/${e.toPath()}');
                                          Configuration.instance.set(mediaLibraryPath: e.toPath());
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          alignment: Alignment.center,
                                          height: kDesktopAppBarHeight - 20.0,
                                          padding: const EdgeInsets.only(left: 12.0),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Text(
                                                e.toLabel().uppercase(),
                                                style: selected.copyWith(color: Colors.transparent),
                                              ),
                                              Text(
                                                e.toLabel().uppercase(),
                                                style: unselected.copyWith(color: Colors.transparent),
                                              ),
                                              AnimatedSwitcher(
                                                duration: _duration.fast,
                                                switchInCurve: Curves.easeInOut,
                                                switchOutCurve: Curves.easeInOut,
                                                child: e.toPath() == _path
                                                    ? Text(
                                                        e.toLabel().uppercase(),
                                                        key: ValueKey('${e.toPath()}-w600'),
                                                        style: selected.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                                                      )
                                                    : Text(
                                                        e.toLabel().uppercase(),
                                                        key: ValueKey('${e.toPath()}-w300'),
                                                        style: unselected.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
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
                                    child: DefaultTextFormField(
                                      focusNode: desktopQueryTextFieldFocusNode,
                                      controller: _desktopSearchTextEditingController,
                                      onFieldSubmitted: (value) async {
                                        context.push(Uri(path: '/$kMediaLibraryPath/$kSearchPath', queryParameters: {kSearchArgQuery: value}).toString());
                                        await Future.delayed(MaterialRoute.animationDuration?.medium ?? const Duration(milliseconds: 300));
                                        desktopQueryTextFieldFocusNode.requestFocus();
                                      },
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      textAlignVertical: TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        hintText: Localization.instance.SEARCH_BANNER_SUBTITLE,
                                        suffixIcon: GestureDetector(
                                          onTap: () async {
                                            context.push(Uri(path: '/$kMediaLibraryPath/$kSearchPath', queryParameters: {kSearchArgQuery: _desktopSearchTextEditingController.text}).toString());
                                            await Future.delayed(MaterialRoute.animationDuration?.medium ?? const Duration(milliseconds: 300));
                                            desktopQueryTextFieldFocusNode.requestFocus();
                                          },
                                          child: Transform.rotate(
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
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  IconButton(
                                    tooltip: Localization.instance.OPEN_FILE_OR_URL,
                                    icon: const Icon(Icons.file_open),
                                    iconSize: 20.0,
                                    splashRadius: 18.0,
                                    color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
                                    onPressed: () async {
                                      final result = await pickResource(context, Localization.instance.OPEN_FILE_OR_URL);
                                      if (result != null) {
                                        await Intent.instance.play(result);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    tooltip: Localization.instance.EDIT_TAGS,
                                    icon: const Icon(Icons.label),
                                    iconSize: 20.0,
                                    splashRadius: 18.0,
                                    color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
                                    onPressed: () async {
                                      context.read<SubscriptionNotifier>().accessSubscriptionFeature(context, () async {
                                        final result = await pickFile(extensions: kDefaultSupportedFileTypes);
                                        if (result != null) {
                                          await context.push(Uri(path: '/$kTagEditorPath', queryParameters: {kTagEditorArgResource: result.path}).toString());
                                        }
                                      });
                                    },
                                  ),
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
                                  const UpdateButton(),
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
      },
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.toSystemUiOverlayStyle(),
      child: Consumer<MediaLibrary>(
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
                          _mobileMediaLibrarySearchBarOffsetNotifier.value = 0.0;
                        }
                        if (notification.direction == ScrollDirection.reverse) {
                          _mobileMediaLibrarySearchBarOffsetNotifier.value = -1.0 * MediaLibraryScrollViewBuilderDataProvider(context).padding.top;
                        }
                      }
                    } else {
                      if (notification.metrics.axis == Axis.vertical) {
                        if (notification.metrics.pixels == 0.0) {
                          _mobileMediaLibrarySearchBarOffsetNotifier.value = 0.0;
                        }
                      }
                    }
                    return false;
                  },
                  child: mediaLibrary.tracks.isEmpty ? const Center(child: MediaLibraryNoItemsBanner()) : widget.child,
                ),
                ValueListenableBuilder<double>(
                  valueListenable: _mobileMediaLibrarySearchBarOffsetNotifier,
                  builder: (context, offset, _) {
                    return AnimatedPositioned(
                      top: offset,
                      left: 0.0,
                      right: 0.0,
                      curve: Curves.easeInOut,
                      duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
                      child: const MobileMediaLibrarySearchBar(),
                    );
                  },
                ),
                Consumer<MediaPlayer>(
                  builder: (context, mediaPlayer, _) {
                    return ValueListenableBuilder<double>(
                      valueListenable: _mobileMediaLibraryRefreshButtonOffsetNotifier,
                      builder: (context, offset, _) {
                        final bottom = 16.0 + (mediaPlayer.state.isEmpty ? 0.0 : offset);
                        final durationValue = mediaPlayer.state.isEmpty ? Duration.zero : _duration?.medium;
                        return AnimatedPositioned(
                          bottom: bottom,
                          right: 16.0,
                          curve: Curves.easeInOut,
                          duration: durationValue ?? Duration.zero,
                          child: _path == kPlaylistsPath ? const MediaLibraryCreatePlaylistButton() : const MediaLibraryRefreshButton(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
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
