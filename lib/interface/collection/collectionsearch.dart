import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/interface/collection/collectionartist.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/collection/collectionalbum.dart';
import 'package:harmonoid/interface/collection/collectiontrack.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionSearch extends StatefulWidget {
  CollectionSearch({Key? key}) : super(key: key);
  CollectionSearchState createState() => CollectionSearchState();
}

class CollectionSearchState extends State<CollectionSearch> {
  int elementsPerRow = 2;
  TextEditingController controller = new TextEditingController();
  bool get search =>
      _albums.length == 0 && _tracks.length == 0 && _artists.length == 0;
  bool get albums => _albums.length == 0;
  bool get tracks => _tracks.length == 0;
  bool get artists => _artists.length == 0;
  List<Widget> _albums = <Widget>[];
  List<Widget> _tracks = <Widget>[];
  List<Widget> _artists = <Widget>[];
  int globalIndex = 0;

  @override
  Widget build(BuildContext context) {
    /// TODO: These elements get added to a [List] for rendering.
    /// But their dimensions do not get recalculated because they are now part of mutable list.
    /// Thus, overflow happens if someone resizes the window. Unlike other tabs.
    int elementsPerRow =
        (MediaQuery.of(context).size.width * (Platform.isLinux ? 0.75 : 1.0)) ~/
            (156 + 8);
    double tileWidthAlbum =
        ((MediaQuery.of(context).size.width * (Platform.isLinux ? 0.75 : 1.0)) -
                16 -
                (elementsPerRow - 1) * 8) /
            elementsPerRow;
    double tileHeightAlbum = tileWidthAlbum * 260.0 / 156;
    double tileWidthArtist = tileWidthAlbum;
    double tileHeightArtist = tileWidthArtist + 36.0;
    return Consumer<Collection>(
      builder: (context, collection, _) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 56.0,
                      child: Icon(
                        FluentIcons.search_24_regular,
                        size: 24.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: Platform.isWindows ||
                          Platform.isLinux ||
                          Platform.isMacOS,
                      controller: controller,
                      onChanged: (String query) async {
                        int localIndex = globalIndex;
                        globalIndex++;
                        List<dynamic> resultCollection =
                            await collection.search(query);
                        List<Widget> albums = <Widget>[];
                        List<Widget> tracks = <Widget>[];
                        List<Widget> artists = <Widget>[];
                        for (dynamic item in resultCollection) {
                          if (item is Album) {
                            albums.add(
                              Container(
                                margin: EdgeInsets.only(
                                    top: 8.0, bottom: 8.0, right: 8.0),
                                child: CollectionAlbumTile(
                                  height: tileHeightAlbum,
                                  width: tileWidthAlbum,
                                  album: item,
                                ),
                              ),
                            );
                          }
                          if (item is Artist) {
                            artists.add(
                              Container(
                                margin: EdgeInsets.only(
                                    top: 8.0, bottom: 8.0, right: 8.0),
                                child: CollectionArtistTile(
                                  height: tileHeightArtist,
                                  width: tileWidthArtist,
                                  artist: item,
                                ),
                              ),
                            );
                          } else if (item is Track) {
                            tracks.add(
                              CollectionTrackTile(
                                track: item,
                                index: collection.tracks.indexOf(item),
                              ),
                            );
                          }
                        }
                        if (localIndex == globalIndex - 1) {
                          _albums = albums;
                          _artists = artists;
                          _tracks = tracks;
                          setState(() {});
                        }
                      },
                      style: Theme.of(context).textTheme.headline4,
                      cursorWidth: 1.0,
                      decoration: InputDecoration(
                        hintText: language!.STRING_COLLECTION_SEARCH_LABEL,
                        hintStyle: Theme.of(context).textTheme.headline3,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 24.0,
                  ),
                ],
              ),
            ),
            Expanded(
              child: search
                  ? (controller.text.isEmpty
                      ? Center(
                          child: Icon(
                            FluentIcons.search_20_regular,
                            size: 72.0,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FluentIcons.emoji_sad_24_regular,
                                  size: 72.0,
                                  color: Theme.of(context).iconTheme.color),
                              Divider(
                                color: Colors.transparent,
                                height: 12.0,
                              ),
                              Text(
                                language!.STRING_LOCAL_SEARCH_NO_RESULTS,
                                style: Theme.of(context).textTheme.headline3,
                              )
                            ],
                          ),
                        ))
                  : CustomListView(
                      children: <Widget>[
                            albums
                                ? Container()
                                : SubHeader(language!.STRING_ALBUM),
                            albums
                                ? Container()
                                : Container(
                                    margin: EdgeInsets.only(left: 8.0),
                                    height: tileHeightAlbum + 16.0,
                                    width: (MediaQuery.of(context).size.width *
                                        (Platform.isLinux ? 0.75 : 1.0)),
                                    child: CustomListView(
                                      scrollDirection: Axis.horizontal,
                                      children: _albums,
                                    ),
                                  ),
                            artists
                                ? Container()
                                : SubHeader(language!.STRING_ARTIST),
                            artists
                                ? Container()
                                : Container(
                                    margin: EdgeInsets.only(left: 8.0),
                                    height: tileHeightArtist + 16.0,
                                    width: (MediaQuery.of(context).size.width *
                                        (Platform.isLinux ? 0.75 : 1.0)),
                                    child: CustomListView(
                                      scrollDirection: Axis.horizontal,
                                      children: _artists,
                                    ),
                                  ),
                            tracks
                                ? Container()
                                : SubHeader(language!.STRING_TRACK),
                          ] +
                          (tracks
                              ? [
                                  Container(),
                                ]
                              : _tracks),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
