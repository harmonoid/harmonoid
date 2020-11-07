import 'package:flutter/material.dart';

import 'package:harmonoid/screens/albumscollection.dart';
import 'package:harmonoid/screens/search.dart';


class MusicCollection extends StatefulWidget {
  MusicCollection({Key key}) : super(key: key);
  MusicCollectionState createState() => MusicCollectionState();
}

class MusicCollectionState extends State<MusicCollection> {

  GlobalKey<SearchBarState> _searchBarKey = new GlobalKey<SearchBarState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AlbumsCollection(
          showSearchBar: () => _searchBarKey.currentState.show(),
          hideSearchBar: () => _searchBarKey.currentState.hide(),
        ),
        SearchBar(key: this._searchBarKey),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).padding.top,
          color: Theme.of(context).scaffoldBackgroundColor,
        )
      ],
    );
  }
}