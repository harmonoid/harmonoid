import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/collection/collectionalbum.dart';
import 'package:harmonoid/interface/collection/collectiontrack.dart';
import 'package:harmonoid/interface/collection/collectionartist.dart';
import 'package:harmonoid/interface/collection/collectionplaylist.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionMusic extends StatefulWidget {
  const CollectionMusic({Key? key}) : super(key: key);
  CollectionMusicState createState() => CollectionMusicState();
}

class CollectionMusicState extends State<CollectionMusic>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;
  int index = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    this._tabController =
        TabController(initialIndex: 0, length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: RefreshCollectionButton(),
      body: Column(
        children: [
          Container(
            height: 72.0,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 72.0,
                      width: 192.0,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                        top: 12.0,
                        bottom: 12.0,
                        left: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 8.0,
                          ),
                          Icon(Icons.refresh),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            'Adding your music...',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => this.setState(() => this.index = 0),
                  child: Container(
                    height: 72.0,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      language!.STRING_ALBUM.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight:
                            this.index == 0 ? FontWeight.w600 : FontWeight.w200,
                        color: Colors.white
                            .withOpacity(this.index == 0 ? 1.0 : 0.67),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => this.setState(() => this.index = 1),
                  child: Container(
                    height: 72.0,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      language!.STRING_TRACK.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight:
                            this.index == 1 ? FontWeight.w600 : FontWeight.w200,
                        color: Colors.white
                            .withOpacity(this.index == 1 ? 1.0 : 0.67),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => this.setState(() => this.index = 2),
                  child: Container(
                    height: 72.0,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      language!.STRING_ARTIST.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight:
                            this.index == 2 ? FontWeight.w600 : FontWeight.w200,
                        color: Colors.white
                            .withOpacity(this.index == 2 ? 1.0 : 0.67),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => this.setState(() => this.index = 3),
                  child: Container(
                    height: 72.0,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      language!.STRING_PLAYLISTS.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight:
                            this.index == 3 ? FontWeight.w600 : FontWeight.w200,
                        color: Colors.white
                            .withOpacity(this.index == 3 ? 1.0 : 0.67),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageTransitionSwitcher(
              child: [
                Builder(
                  key: PageStorageKey(new Album().type),
                  builder: (context) => CollectionAlbumTab(),
                ),
                Builder(
                  key: PageStorageKey(new Track().type),
                  builder: (context) => CollectionTrackTab(),
                ),
                Builder(
                  key: PageStorageKey(new Artist().type),
                  builder: (context) => CollectionArtistTab(),
                ),
                Builder(
                  key: PageStorageKey(new Playlist().type),
                  builder: (context) => CollectionPlaylistTab(),
                ),
              ][this.index],
              transitionBuilder: (child, animation, secondaryAnimation) =>
                  SharedAxisTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.vertical,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
