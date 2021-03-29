import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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


class CollectionMusicState extends State<CollectionMusic> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late double _refreshTurns;
  late Tween<double> _refreshTween;
  TabController? _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    this._refreshTurns = 2 * math.pi;
    this._tabController = TabController(initialIndex: 0, length: 4, vsync: this);
    this._refreshTween = Tween<double>(begin: 0, end: this._refreshTurns);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: TweenAnimationBuilder(
          child: Icon(Icons.refresh),
          tween: this._refreshTween,
          duration: Duration(milliseconds: 800),
          builder: (_, dynamic value, child) => Transform.rotate(
            alignment: Alignment.center,
            angle: value,
            child: child,
          ),
        ),
        onPressed: () async {
          this._refreshTurns += 2 * math.pi;
          this._refreshTween = Tween<double>(begin: 0, end: this._refreshTurns);
          this.setState(() {});
          await Provider.of<Collection>(context, listen: false).refresh();
        },
      ),
      body: DefaultTabController(
        length: 4,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  elevation: innerBoxIsScrolled ? 4.0 : 1.0,
                  forceElevated: true,
                  pinned: true,
                  floating: true,
                  snap: true,
                  leading: IconButton(
                    icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
                    iconSize: Theme.of(context).iconTheme.size!,
                    splashRadius: Theme.of(context).iconTheme.size! - 8,
                    onPressed: () {},
                    tooltip: language!.STRING_MENU,
                  ),
                  title: Text('Harmonoid'),
                  centerTitle: Provider.of<Visuals>(context, listen: false).platform == TargetPlatform.iOS,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                      iconSize: Theme.of(context).iconTheme.size!,
                      splashRadius: Theme.of(context).iconTheme.size! - 8,
                      tooltip: language!.STRING_SEARCH_COLLECTION,
                      onPressed: () {
                        Navigator.of(context).pushNamed('collectionSearch');
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
                      iconSize: Theme.of(context).iconTheme.size!,
                      splashRadius: Theme.of(context).iconTheme.size! - 8,
                      tooltip: language!.STRING_OPTIONS,
                      onPressed: () async {
                        CollectionSort? collectionSortType = await showMenu<CollectionSort>(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).padding.top + 48.0,
                            0.0,
                            0.0,
                          ),
                          items: <PopupMenuEntry<CollectionSort>>[
                            CheckedPopupMenuItem<CollectionSort>(
                              checked: CollectionSort.aToZ == configuration.collectionSortType,
                              value: CollectionSort.aToZ,
                              child: Text(language!.STRING_A_TO_Z),
                            ),
                            CheckedPopupMenuItem<CollectionSort>(
                              checked: CollectionSort.dateAdded == configuration.collectionSortType,
                              value: CollectionSort.dateAdded,
                              child: Text(language!.STRING_DATE_ADDED),
                            ),
                          ],
                          elevation: 2.0,
                        );
                        await Provider.of<Collection>(context, listen: false).sort(
                          type: collectionSortType,
                        );
                        await configuration.save(
                          collectionSortType: collectionSortType,
                        );
                      }
                    ),
                  ],
                  bottom: TabBar(
                    controller: this._tabController,
                    indicatorColor: Theme.of(context).accentColor,
                    isScrollable: true,
                    tabs: [
                      Tab(
                        child: Text(
                          language!.STRING_ALBUM!.toUpperCase(),
                        ),
                      ),
                      Tab(
                        child: Text(
                          language!.STRING_TRACK!.toUpperCase(),
                        ),
                      ),
                      Tab(
                        child: Text(
                          language!.STRING_ARTIST!.toUpperCase(),
                        ),
                      ),
                      Tab(
                        child: Text(
                          language!.STRING_PLAYLISTS!.toUpperCase(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Consumer<Collection>(
            builder: (context, collection, _) => TabBarView(
              controller: this._tabController,
              children: <Widget>[
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
