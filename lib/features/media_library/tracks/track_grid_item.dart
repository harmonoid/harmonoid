import 'dart:async';

import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/utils/rendering.dart';

class TrackGridItem extends StatelessWidget {
  // --------------------------------------------------

  final Track track;
  final double width;
  final double height;
  final FutureOr<List<PopupMenuItem<int>>> Function() popupMenuBuilder;
  final VoidCallback onItemPressed;
  final ValueChanged<int> onPopupMenuItemSelected;

  // --------------------------------------------------

  final bool Function() isItemSelected;
  final ValueChanged<bool> onItemSelected;
  final ChangeNotifier itemSelectionChangeNotifier;
  final ValueNotifier<bool> itemSelectionInvoked;

  const TrackGridItem({
    super.key,
    required this.track,
    required this.width,
    required this.height,
    required this.popupMenuBuilder,
    required this.onItemPressed,
    required this.onPopupMenuItemSelected,
    required this.isItemSelected,
    required this.onItemSelected,
    required this.itemSelectionChangeNotifier,
    required this.itemSelectionInvoked,
  });

  @override
  Widget build(BuildContext context) {
    final title = track.toTitleTappableText();
    final subtitle = [
      track.toGridSubtitle0TappableText(context),
      track.toGridSubtitle1TappableText(context),
    ];

    Widget buildTile(bool showItemSelection) {
      return SelectableGridTile(
        width: width,
        height: height,
        title: title,
        subtitle: subtitle,
        leading: Image(
          width: height,
          height: height,
          image: cover(
            item: track,
            cacheHeight: (height * MediaQuery.of(context).devicePixelRatio).toInt(),
          ),
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
        popupMenuBuilder: popupMenuBuilder,
        onItemPressed: onItemPressed,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        showItemSelection: showItemSelection,
        isItemSelected: isItemSelected(),
        onItemSelected: (value) {
          itemSelectionInvoked.value = true;
          onItemSelected(value);
        },
      );
    }

    return ListenableBuilder(
      listenable: itemSelectionChangeNotifier,
      builder: (context, _) {
        return ValueListenableBuilder(
          valueListenable: itemSelectionInvoked,
          builder: (context, invoked, _) => buildTile(invoked),
        );
      },
    );
  }
}
