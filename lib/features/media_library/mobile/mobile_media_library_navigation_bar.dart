import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/extensions/set.dart';
import 'package:harmonoid/mappers/media_library_tab.dart';
import 'package:harmonoid/features/media_library/models/media_library_tab.dart';
import 'package:harmonoid/features/now_playing/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

class MobileMediaLibraryNavigationBar extends StatelessWidget {
  const MobileMediaLibraryNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final path = context.location.split('/').last;
    final tabs = Configuration.instance.mediaLibraryVisibleTabs.ifEmpty(MediaLibraryTab.values.toSet());
    final paths = tabs.map((tab) => tab.toPath()).toList();
    final labels = tabs.map((tab) => tab.toLabel()).toList();
    final index = paths.indexOf(path);
    final displayLabels = labels.max.length <= 10;

    void onDestinationSelected(int i) {
      if (index == i) return;
      context.push('/$kMediaLibraryPath/${paths[i]}');
      Configuration.instance.set(mediaLibraryPath: paths[i]);
      NowPlayingMobileNotifier.instance.showNowPlayingBar();
    }

    return isMaterial3
        ? NavigationBar(
            selectedIndex: index,
            onDestinationSelected: onDestinationSelected,
            labelBehavior: displayLabels ? NavigationDestinationLabelBehavior.alwaysShow : NavigationDestinationLabelBehavior.alwaysHide,
            destinations: tabs.map((tab) => NavigationDestination(icon: Icon(tab.toIcon()), label: tab.toLabel())).toList(),
          )
        : Container(
            decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8.0)]),
            child: BottomNavigationBar(
              currentIndex: index,
              type: BottomNavigationBarType.shifting,
              onTap: onDestinationSelected,
              items: tabs.map((tab) => BottomNavigationBarItem(icon: Icon(tab.toIcon()), label: displayLabels ? tab.toLabel() : null, backgroundColor: Theme.of(context).colorScheme.primary)).toList(),
            ),
          );
  }
}
