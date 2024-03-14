import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/ui/media_library/search/search_screen.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class MediaLibrarySearchBar extends StatelessWidget {
  const MediaLibrarySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + margin,
        left: margin,
        right: margin,
      ),
      child: SearchAnchor(
        isFullScreen: true,
        viewHintText: Language.instance.SEARCH_HINT,
        builder: (context, controller) {
          return Consumer<MediaLibrary>(
            builder: (context, mediaLibrary, _) {
              return Stack(
                children: [
                  SearchBar(
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(Icons.search),
                    ),
                    onTap: controller.openView,
                    onChanged: (text) {
                      controller.text = text;
                      controller.openView();
                    },
                    onSubmitted: (text) {
                      controller.text = text;
                      controller.openView();
                    },
                    trailing: const [
                      MobileAppBarOverflowButton(),
                    ],
                    hintText: !mediaLibrary.refreshing
                        ? Language.instance.SEARCH_HINT
                        : mediaLibrary.current == null
                            ? Language.instance.DISCOVERING_FILES
                            : Language.instance.ADDED_M_OF_N_FILES
                                .replaceAll('"M"', (mediaLibrary.current ?? 0).toString())
                                .replaceAll('"N"', (mediaLibrary.total == 0 ? 1 : mediaLibrary.total).toString()),
                  ),
                  if (mediaLibrary.refreshing)
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        height: 4.0,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(4.0),
                            bottomRight: Radius.circular(4.0),
                          ),
                        ),
                        child: LinearProgressIndicator(
                          value: mediaLibrary.current == null ? null : (mediaLibrary.current ?? 0) / (mediaLibrary.total == 0 ? 1 : mediaLibrary.total),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
        suggestionsBuilder: (context, controller) {
          return [
            SearchScreen(
              key: ValueKey(controller.text),
              query: controller.text,
            ),
          ];
        },
        viewBuilder: (suggestions) {
          return suggestions.first;
        },
      ),
    );
  }
}
