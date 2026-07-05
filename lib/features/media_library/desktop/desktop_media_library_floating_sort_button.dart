import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/features/media_library/desktop/desktop_media_library_sort_button.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/utils/dimensions.dart';

class DesktopMediaLibraryFloatingSortButton extends StatefulWidget {
  final ValueNotifier<bool> floatingNotifier;

  const DesktopMediaLibraryFloatingSortButton({
    super.key,
    required this.floatingNotifier,
  });

  @override
  State<DesktopMediaLibraryFloatingSortButton> createState() => DesktopMediaLibraryFloatingSortButtonState();
}

class DesktopMediaLibraryFloatingSortButtonState extends State<DesktopMediaLibraryFloatingSortButton> {
  @override
  Widget build(BuildContext context) {
    final path = context.location.split('/').last;

    if (![kAlbumsPath, /* kTracksPath, */ kArtistsPath, kGenresPath].contains(path)) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: widget.floatingNotifier,
      child: const DesktopMediaLibrarySortButton(floating: true),
      builder: (context, floating, child) => AnimatedPositioned(
        curve: Curves.easeInOut,
        duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
        top: margin + captionHeight + kDesktopAppBarHeight + (floating ? 0.0 : -72.0),
        right: margin,
        child: Card(
          elevation: 4.0,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          child: child,
        ),
      ),
    );
  }
}
