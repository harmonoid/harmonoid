import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';

import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';


class CollectionTabs extends StatefulWidget {
  CollectionTabs({Key key}) : super(key: key);
  _CollectionTabsState createState() => _CollectionTabsState();
}


class _CollectionTabsState extends State<CollectionTabs> {
  List<String> names = [language.STRING_ALBUM, language.STRING_TRACK, language.STRING_PLAYLISTS];

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: 'Collection Tabs',
      subtitle: 'Choose your favorite order',
      child: ImplicitlyAnimatedReorderableList<String>(
        onReorderFinished: (item, from, to, values) {
          setState(() => this.names = values);
        },
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        items: this.names,
        areItemsTheSame: (a, b) => a == b,
        itemBuilder: (context, animation, item, index) {
          return Reorderable(
            key: ValueKey<String>(item),
            child: SizeTransition(
              sizeFactor: animation,
              child: Handle(
                child: ListTile(
                  title: Text(item),
                  trailing: Icon(
                    isMaterial ? Icons.drag_handle : Icons.list,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}

bool get isMaterial => [TargetPlatform.android, TargetPlatform.fuchsia].contains(defaultTargetPlatform);
