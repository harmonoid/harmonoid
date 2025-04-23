import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/media_library/search/search_screen.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

final SearchController mediaLibrarySearchController = SearchController();

class MediaLibrarySearchBar extends StatelessWidget {
  const MediaLibrarySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final shape = Theme.of(context).searchBarTheme.shape?.resolve({});
    final borderRadius = shape is! RoundedRectangleBorder ? null : shape.borderRadius as BorderRadius;

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + margin,
        left: margin,
        right: margin,
      ),
      child: SearchAnchor(
        searchController: mediaLibrarySearchController,
        viewHintText: Localization.instance.SEARCH_HINT,
        builder: (context, controller) {
          return Consumer<MediaLibrary>(
            builder: (context, mediaLibrary, _) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ExcludeFocus(
                    child: SearchBar(
                      autoFocus: false,
                      leading: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Icon(Icons.search),
                      ),
                      onTap: controller.openView,
                      trailing: const [
                        UpdateButton(),
                        MobileGridSpanButton(),
                        MobileAppBarOverflowButton(),
                      ],
                      hintText: !mediaLibrary.refreshing
                          ? Localization.instance.SEARCH_HINT
                          : mediaLibrary.current == null
                              ? Localization.instance.DISCOVERING_FILES
                              : Localization.instance.ADDED_M_OF_N_FILES
                                  .replaceAll('"M"', (mediaLibrary.current ?? 0).toString())
                                  .replaceAll('"N"', (mediaLibrary.total == 0 ? 1 : mediaLibrary.total).toString()),
                    ),
                  ),
                  if (mediaLibrary.refreshing)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(borderRadius: borderRadius),
                          child: LinearProgressIndicator(
                            value: mediaLibrary.current == null ? null : (mediaLibrary.current ?? 0) / (mediaLibrary.total == 0 ? 1 : mediaLibrary.total),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
        suggestionsBuilder: (context, controller) => [SearchScreen(query: controller.text)],
        viewBuilder: (suggestions) => suggestions.elementAtOrNull(0) ?? const SizedBox.shrink(),
      ),
    );
  }
}
