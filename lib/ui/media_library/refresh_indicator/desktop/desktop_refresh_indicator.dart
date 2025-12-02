import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/localization/localization.dart';

class DesktopRefreshIndicator extends StatefulWidget {
  const DesktopRefreshIndicator({super.key});

  @override
  State<DesktopRefreshIndicator> createState() => _DesktopRefreshIndicatorState();
}

class _DesktopRefreshIndicatorState extends State<DesktopRefreshIndicator> {
  // https://m3.material.io/components/toolbars/specs

  static const double kHeight = 64.0;

  Color get _backgroundColor {
    if (isMaterial3) {
      return Theme.of(context).colorScheme.primaryContainer;
    }
    if (isMaterial2) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
    throw UnimplementedError();
  }

  Color get _progressColor {
    if (isMaterial3) {
      return Theme.of(context).colorScheme.onPrimaryContainer;
    }
    if (isMaterial2) {
      return Theme.of(context).colorScheme.primary;
    }
    throw UnimplementedError();
  }

  Color get _foregroundColor {
    return Theme.of(context).colorScheme.onPrimaryContainer;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: mediaLibrary.refreshing ? 1.0 : 0.0),
          duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return IgnorePointer(
              ignoring: value == 0.0,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            elevation: kDefaultCardElevation,
            color: _backgroundColor,
            shape: const StadiumBorder(),
            child: SizedBox(
              height: kHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: kHeight,
                    height: kHeight,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      value: mediaLibrary.current == null ? null : (mediaLibrary.current ?? 0) / (mediaLibrary.total == 0 ? 1 : mediaLibrary.total),
                      color: _progressColor,
                    ),
                  ),
                  Text(
                    mediaLibrary.current == null
                        ? Localization.instance.DISCOVERING_FILES
                        : Localization.instance.ADDED_M_OF_N_FILES
                              .replaceAll('"M"', (mediaLibrary.current ?? 0).toString())
                              .replaceAll('"N"', (mediaLibrary.total == 0 ? 1 : mediaLibrary.total).toString()),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _foregroundColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 20.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
