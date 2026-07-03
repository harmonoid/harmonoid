import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/media_library/media_library_flags.dart';
import 'package:harmonoid/ui/media_library/media_library_menus.dart';
import 'package:harmonoid/ui/now_playing/now_playing_bar.dart';
import 'package:harmonoid/utils/rendering.dart';

class SelectionToolbar extends StatefulWidget {
  final Widget child;
  const SelectionToolbar({super.key, required this.child});

  @override
  State<SelectionToolbar> createState() => _SelectionToolbarState();
}

class _SelectionToolbarState extends State<SelectionToolbar> {
  // https://m3.material.io/components/toolbars/specs

  static const double kHeight = 56.0;

  double get _bottomPadding => NowPlayingBar.height + 16.0;

  Color get _backgroundColor {
    if (isMaterial3) {
      return Theme.of(context).colorScheme.primaryContainer;
    }
    if (isMaterial2) {
      return Theme.of(context).colorScheme.primary;
    }
    throw UnimplementedError();
  }

  Color get _foregroundColor {
    if (isMaterial3) {
      return Theme.of(context).colorScheme.onPrimaryContainer;
    }
    if (isMaterial2) {
      return Theme.of(context).colorScheme.onPrimary;
    }
    throw UnimplementedError();
  }

  Color get _fabBackgroundColor {
    if (isMaterial3) {
      return Theme.of(context).colorScheme.tertiaryContainer;
    }
    if (isMaterial2) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
    throw UnimplementedError();
  }

  Color get _fabForegroundColor {
    if (isMaterial3) {
      return Theme.of(context).colorScheme.onTertiaryContainer;
    }
    if (isMaterial2) {
      return Theme.of(context).colorScheme.onSurface;
    }
    throw UnimplementedError();
  }

  Widget _buildToolbar(
    BuildContext context, {
    int? limit,
    bool animate = true,
  }) {
    return ValueListenableBuilder<Set<Track>>(
      valueListenable: mediaLibrarySelectedTracks,
      builder: (context, value, _) {
        final tracksMenuProvider = TracksMenuProvider(context, value.toList());
        return Consumer<MediaLibrary>(
          builder: (context, mediaLibrary, _) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0,
                end: mediaLibrary.refreshing || value.isEmpty ? 0.0 : 1.0,
              ),
              duration: animate ? Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero : Duration.zero,
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return IgnorePointer(
                  ignoring: value == 0.0,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    elevation: kDefaultCardElevation,
                    color: _backgroundColor,
                    shape: const StadiumBorder(),
                    child: Container(
                      height: kHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        spacing: 4.0,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ...[
                            for (final action in limit != null ? TracksMenuAction.values.take(limit) : TracksMenuAction.values)
                              FutureBuilder<String>(
                                future: tracksMenuProvider.getLabel(action),
                                builder: (context, snapshot) {
                                  return IconButton(
                                    icon: Icon(tracksMenuProvider.getIcon(action), color: _foregroundColor),
                                    onPressed: () => tracksMenuProvider.handlePopupMenuAction(action.index),
                                    tooltip: snapshot.data,
                                  );
                                },
                              ),
                          ],
                          if (limit != null && TracksMenuAction.values.length > limit)
                            IconButton(
                              icon: Icon(Icons.more_horiz, color: _foregroundColor),
                              onPressed: () async {
                                final items = await tracksMenuProvider.getPopupMenuItems();
                                final value = await showMenuItems(context, items.skip(limit).toList());
                                await tracksMenuProvider.handlePopupMenuAction(value);
                              },
                              tooltip: Localization.instance.MORE,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FloatingActionButton.small(
                    heroTag: 'media-library-selection-toolbar-clear-selection',
                    onPressed: () => mediaLibrarySelectedTracks.value = {},
                    backgroundColor: _fabBackgroundColor,
                    foregroundColor: _fabForegroundColor,
                    tooltip: Localization.instance.CLEAR_SELECTION,
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        Positioned(
          left: 16.0,
          bottom: _bottomPadding,
          child: _buildToolbar(context),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    final limit = 3;
    final floatingWidgetWidth =
        /* Horizontal padding */ 2 * 8.0 +
        /* Icons width */ (limit + 1) * 48.0 +
        /* Icons spacing */ limit * 4.0 +
        /* Spacing */ 8.0 +
        /* Close button width */ 48.0 +
        /* Spacing */ 16.0;
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        DraggableFloatWidget(
          config: DraggableFloatWidgetBaseConfig(
            borderTop: MediaQuery.paddingOf(context).top + 8.0,
            borderBottom: MediaQuery.paddingOf(context).bottom + 8.0,
          ),
          width: floatingWidgetWidth,
          height: kHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildToolbar(context, limit: limit, animate: false),
          ),
        ),
      ],
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
