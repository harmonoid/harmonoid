/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///

import 'package:flutter/material.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/interface/collection/artist.dart';

class SearchTab extends StatefulWidget {
  final ValueNotifier<String>? query;
  SearchTab({Key? key, this.query}) : super(key: key);
  SearchTabState createState() => SearchTabState();
}

class SearchTabState extends State<SearchTab> {
  TextEditingController controller = new TextEditingController();
  List<Widget> albums = <Widget>[];
  List<Widget> tracks = <Widget>[];
  List<Widget> artists = <Widget>[];
  int index = 0;
  late Future<void> Function() listener;

  @override
  void initState() {
    super.initState();
    if (widget.query != null) {
      listener = () async {
        albums = <Widget>[];
        tracks = <Widget>[];
        artists = <Widget>[];
        var result = Collection.instance.search(widget.query!.value);
        for (var media in result) {
          if (media is Album) {
            albums.addAll(
              [
                AlbumTile(
                  height: kAlbumTileHeight,
                  width: kAlbumTileWidth,
                  album: media,
                ),
                const SizedBox(
                  width: 16.0,
                ),
              ],
            );
          }
          if (media is Artist) {
            artists.addAll(
              [
                ArtistTile(
                  height: kDesktopArtistTileHeight,
                  width: kDesktopArtistTileWidth,
                  artist: media,
                ),
                const SizedBox(
                  width: 16.0,
                ),
              ],
            );
          } else if (media is Track) {
            tracks.add(
              TrackTile(
                track: media,
                index: Collection.instance.tracks.indexOf(media),
              ),
            );
          }
        }
      };
      widget.query!.addListener(listener);
      listener();
    }
  }

  @override
  void dispose() {
    widget.query!.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) {
        listener();
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              if (widget.query == null)
                Container(
                  margin: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: 8.0,
                        ),
                        child: Container(
                          width: 56.0,
                          child: Icon(
                            FluentIcons.search_24_regular,
                            size: 24.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            if (hasFocus) {
                              HotKeys.instance.disableSpaceHotKey();
                            } else {
                              HotKeys.instance.enableSpaceHotKey();
                            }
                          },
                          child: TextField(
                            controller: controller,
                            onChanged: (String query) async {
                              int _index = index;
                              index++;
                              List<dynamic> result = collection.search(query);
                              List<Widget> _albums = <Widget>[];
                              List<Widget> _tracks = <Widget>[];
                              List<Widget> _artists = <Widget>[];
                              for (final media in result) {
                                if (media is Album) {
                                  _albums.addAll(
                                    [
                                      AlbumTile(
                                        height: kAlbumTileHeight,
                                        width: kAlbumTileWidth,
                                        album: media,
                                      ),
                                      const SizedBox(
                                        width: 16.0,
                                      ),
                                    ],
                                  );
                                }
                                if (media is Artist) {
                                  _artists.addAll(
                                    [
                                      ArtistTile(
                                        height: kDesktopArtistTileHeight,
                                        width: kDesktopArtistTileWidth,
                                        artist: media,
                                      ),
                                      const SizedBox(
                                        width: 16.0,
                                      ),
                                    ],
                                  );
                                } else if (media is Track) {
                                  _tracks.add(
                                    TrackTile(
                                      track: media,
                                      index: collection.tracks.indexOf(media),
                                    ),
                                  );
                                }
                              }
                              if (_index == index - 1) {
                                albums = _albums;
                                artists = _artists;
                                tracks = _tracks;
                                setState(() {});
                              }
                            },
                            style: Theme.of(context).textTheme.headline4,
                            cursorWidth: 1.0,
                            decoration: InputDecoration(
                              hintText:
                                  Language.instance.COLLECTION_SEARCH_LABEL,
                              hintStyle: Theme.of(context).textTheme.headline3,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  width: 1.0,
                                ),
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
                child: albums.isNotEmpty ||
                        artists.isNotEmpty ||
                        tracks.isNotEmpty
                    ? CustomListView(
                        children: <Widget>[
                              if (albums.isNotEmpty)
                                Row(
                                  children: [
                                    SubHeader(Language.instance.ALBUM),
                                    const Spacer(),
                                    ShowAllButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => Scaffold(
                                              body: Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                child: Stack(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: desktopTitleBarHeight +
                                                              kDesktopAppBarHeight),
                                                      child: CustomListView(
                                                        padding:
                                                            EdgeInsets.only(
                                                          top: tileMargin,
                                                        ),
                                                        children:
                                                            tileGridListWidgets(
                                                          context: context,
                                                          tileHeight:
                                                              kAlbumTileHeight,
                                                          tileWidth:
                                                              kAlbumTileWidth,
                                                          elementsPerRow: (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  tileMargin) ~/
                                                              (kAlbumTileWidth +
                                                                  tileMargin),
                                                          subHeader: null,
                                                          leadingSubHeader:
                                                              null,
                                                          widgetCount: this
                                                                  .albums
                                                                  .length ~/
                                                              2,
                                                          leadingWidget:
                                                              Container(),
                                                          builder: (BuildContext
                                                                      context,
                                                                  int index) =>
                                                              albums[2 * index],
                                                        ),
                                                      ),
                                                    ),
                                                    DesktopAppBar(
                                                      title: Language
                                                          .instance.ALBUM,
                                                      elevation: 4.0,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                  ],
                                ),
                              if (albums.isNotEmpty)
                                Container(
                                  height: kAlbumTileHeight + 10.0,
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView(
                                    padding: EdgeInsets.only(
                                      left: 16.0,
                                      top: 2.0,
                                      bottom: 8.0,
                                    ),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: albums,
                                  ),
                                ),
                              if (artists.isNotEmpty)
                                Row(
                                  children: [
                                    SubHeader(Language.instance.ARTIST),
                                    const Spacer(),
                                    ShowAllButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => Scaffold(
                                              body: Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                child: Stack(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: desktopTitleBarHeight +
                                                              kDesktopAppBarHeight),
                                                      child: CustomListView(
                                                        padding:
                                                            EdgeInsets.only(
                                                          top: tileMargin,
                                                        ),
                                                        children:
                                                            tileGridListWidgets(
                                                          context: context,
                                                          tileHeight:
                                                              kDesktopArtistTileHeight,
                                                          tileWidth:
                                                              kDesktopArtistTileWidth,
                                                          elementsPerRow: (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  tileMargin) ~/
                                                              (kDesktopArtistTileWidth +
                                                                  tileMargin),
                                                          subHeader: null,
                                                          leadingSubHeader:
                                                              null,
                                                          widgetCount: this
                                                                  .artists
                                                                  .length ~/
                                                              2,
                                                          leadingWidget:
                                                              Container(),
                                                          builder: (BuildContext
                                                                      context,
                                                                  int index) =>
                                                              artists[
                                                                  2 * index],
                                                        ),
                                                      ),
                                                    ),
                                                    DesktopAppBar(
                                                      title: Language
                                                          .instance.ARTIST,
                                                      elevation: 4.0,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                  ],
                                ),
                              if (artists.isNotEmpty)
                                Container(
                                  height: kDesktopArtistTileHeight + 10.0,
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView(
                                    padding: EdgeInsets.only(
                                      left: 16.0,
                                      top: 2.0,
                                      bottom: 8.0,
                                    ),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: artists,
                                  ),
                                ),
                              if (tracks.isNotEmpty)
                                Row(
                                  children: [
                                    SubHeader(Language.instance.TRACK),
                                    const Spacer(),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                  ],
                                ),
                            ] +
                            tracks,
                      )
                    : (controller.text.isNotEmpty ||
                            (widget.query?.value.isNotEmpty ?? false)
                        ? Center(
                            child: ExceptionWidget(
                              title: Language
                                  .instance.COLLECTION_SEARCH_NO_RESULTS_TITLE,
                              subtitle: Language.instance
                                  .COLLECTION_SEARCH_NO_RESULTS_SUBTITLE,
                            ),
                          )
                        : Center(
                            child: Icon(
                              FluentIcons.search_20_regular,
                              size: 72.0,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          )),
              ),
            ],
          ),
        );
      },
    );
  }
}
