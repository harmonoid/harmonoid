import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/interface/collection/collectionalbum.dart';
import 'package:harmonoid/interface/collection/collectiontrack.dart';
import 'package:harmonoid/interface/collection/collectionartist.dart';
import 'package:harmonoid/interface/collection/collectionplaylist.dart';
import 'package:harmonoid/interface/youtube/youtubemusic.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/interface/collection/collectionsearch.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/utils/widgets.dart';

class CollectionMusic extends StatefulWidget {
  const CollectionMusic({Key? key}) : super(key: key);
  CollectionMusicState createState() => CollectionMusicState();
}

class CollectionMusicState extends State<CollectionMusic>
    with AutomaticKeepAliveClientMixin {
  int index = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    intent.play();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: index != 5 ? RefreshCollectionButton() : null,
      body: Column(
        children: [
          Container(
            height: 64.0,
            padding: Platform.isWindows || Platform.isLinux || Platform.isMacOS
                ? EdgeInsets.symmetric(horizontal: 8.0)
                : EdgeInsets.zero,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.10)
                : Colors.black.withOpacity(0.10),
            child: Platform.isWindows || Platform.isLinux || Platform.isMacOS
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 44.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 0),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    language!.STRING_ALBUM.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 0
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 0 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 1),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    language!.STRING_TRACK.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 1
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 1 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 2),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    language!.STRING_ARTIST.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 2
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 2 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 4),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    language!.STRING_SEARCH.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 4
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 4 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 3),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    language!.STRING_PLAYLISTS.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 3
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 3 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 5),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'YouTube'.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 5
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 5 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      ContextMenuButton<CollectionSort>(
                        offset: Offset.fromDirection(pi / 2, 64.0),
                        icon: Icon(
                          FluentIcons.more_vertical_20_regular,
                          size: 20.0,
                        ),
                        elevation: 0.0,
                        onSelected: (value) async {
                          Provider.of<Collection>(context, listen: false)
                              .sort(type: value);
                          await configuration.save(
                            collectionSortType: value,
                          );
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: CollectionSort.dateAdded,
                            child: Text(
                              language!.STRING_DATE_ADDED,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                          PopupMenuItem(
                            value: CollectionSort.aToZ,
                            child: Text(
                              language!.STRING_A_TO_Z,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        FadeThroughTransition(
                                  fillColor: Colors.transparent,
                                  animation: animation,
                                  secondaryAnimation: secondaryAnimation,
                                  child: Settings(),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          child: Container(
                            height: 40.0,
                            width: 40.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(0.10)
                                  : Colors.black.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              FluentIcons.settings_20_regular,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 44.0,
                          child: ListView(
                            padding: Platform.isWindows ||
                                    Platform.isLinux ||
                                    Platform.isMacOS
                                ? EdgeInsets.zero
                                : EdgeInsets.symmetric(horizontal: 8.0),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 0),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    language!.STRING_ALBUM.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 0
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 0 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 1),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    language!.STRING_TRACK.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 1
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 1 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 2),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    language!.STRING_ARTIST.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 2
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 2 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 4),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    language!.STRING_SEARCH.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 4
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 4 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 3),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    language!.STRING_PLAYLISTS.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 3
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 3 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () =>
                                    this.setState(() => this.index = 5),
                                child: Container(
                                  height: 40.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'YouTube'.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: this.index == 5
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                              this.index == 5 ? 1.0 : 0.67),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                                child: ContextMenuButton<CollectionSort>(
                                  offset: Offset.fromDirection(pi / 2, 64.0),
                                  icon: Icon(
                                    FluentIcons.more_vertical_20_regular,
                                    size: 20.0,
                                  ),
                                  elevation: 0.0,
                                  onSelected: (value) async {
                                    Provider.of<Collection>(context,
                                            listen: false)
                                        .sort(type: value);
                                    await configuration.save(
                                      collectionSortType: value,
                                    );
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: CollectionSort.dateAdded,
                                      child: Text(
                                        language!.STRING_DATE_ADDED,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: CollectionSort.aToZ,
                                      child: Text(
                                        language!.STRING_A_TO_Z,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            FadeThroughTransition(
                                          fillColor: Colors.transparent,
                                          animation: animation,
                                          secondaryAnimation:
                                              secondaryAnimation,
                                          child: Settings(),
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  child: Container(
                                    height: 40.0,
                                    width: 40.0,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withOpacity(0.08)
                                          : Colors.black.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Icon(
                                      FluentIcons.settings_20_regular,
                                      size: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Expanded(
            child: Consumer<CollectionRefreshController>(
              builder: (context, refresh, __) => Stack(
                alignment: Alignment.bottomLeft,
                children: <Widget>[
                      (refresh.progress != refresh.total &&
                              collection.collectionRefreshType ==
                                  CollectionRefreshType.soft)
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).colorScheme.secondary),
                              ),
                            )
                          : PageTransitionSwitcher(
                              child: [
                                CollectionAlbumTab(),
                                CollectionTrackTab(),
                                CollectionArtistTab(),
                                CollectionPlaylistTab(),
                                CollectionSearch(),
                                YouTubeMusic(),
                              ][this.index],
                              transitionBuilder:
                                  (child, animation, secondaryAnimation) =>
                                      SharedAxisTransition(
                                fillColor: Colors.transparent,
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType:
                                    SharedAxisTransitionType.vertical,
                                child: child,
                              ),
                            ),
                    ] +
                    (refresh.progress == refresh.total
                        ? <Widget>[]
                        : <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF242424),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0),
                                ),
                                border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                    width: 1.0),
                              ),
                              margin: EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: refresh.progress / refresh.total,
                                    valueColor: AlwaysStoppedAnimation(
                                      Theme.of(context).primaryColor,
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.4),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16.0,
                                        ),
                                        Text(
                                          '${refresh.progress}/${refresh.total}',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                        SizedBox(
                                          width: 16.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                            language!
                                                .STRING_COLLECTION_INDEXING_LABEL,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
