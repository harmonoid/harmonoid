import 'package:flutter/material.dart';
import 'package:harmonoid/interface/collection/collectionalbum.dart';
import 'package:harmonoid/interface/collection/collectiontrack.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:share/share.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';


class CollectionArtistTab extends StatelessWidget {
  Widget build(BuildContext context) {
    int elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
    double tileWidth = (MediaQuery.of(context).size.width - 16 - (elementsPerRow - 1) * 8) / elementsPerRow;
    double tileHeight = tileWidth + 36.0;

    return Consumer<Collection>(
      builder: (context, collection, _) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              collection.tracks.isNotEmpty ? tileGridListWidgets(
                context: context,
                tileHeight: tileHeight,
                tileWidth: tileWidth,
                elementsPerRow: elementsPerRow,
                subHeader: language!.STRING_LOCAL_OTHER_SUBHEADER_ARTIST,
                leadingSubHeader: language!.STRING_LOCAL_TOP_SUBHEADER_ARTIST,
                widgetCount: collection.artists.length,
                leadingWidget: LeadingCollectionArtistTile(
                  height: tileWidth,
                ),
                builder: (BuildContext context, int index) => CollectionArtistTile(
                  height: tileHeight,
                  width: tileWidth,
                  artist: collection.artists[index],
                ),
              ): <Widget>[
                ExceptionWidget(
                  margin: EdgeInsets.only(top: 96.0, left: 8.0, right: 8.0),
                  height: tileWidth,
                  assetImage: 'assets/images/collection-album.jpg',
                  title: language!.STRING_NO_COLLECTION_TITLE,
                  subtitle: language!.STRING_NO_COLLECTION_SUBTITLE,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class LeadingCollectionArtistTile extends StatelessWidget {
  final double height;
  const LeadingCollectionArtistTile({Key? key, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 4.0),
        child: OpenContainer(
          closedElevation: 2,
          closedColor: Theme.of(context).cardColor,
          openColor: Theme.of(context).scaffoldBackgroundColor,
          closedBuilder: (_, open) => Container(
            height: this.height,
            width: MediaQuery.of(context).size.width - 16,
            child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Ink.image(
                    image: FileImage(collection.lastArtist!.tracks.last.albumArt),
                    fit: BoxFit.fill,
                    height: this.height,
                    width: this.height,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 8, right: 8),
                    width: MediaQuery.of(context).size.width - 32 - this.height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          collection.lastArtist!.artistName!,
                          style: Theme.of(context).textTheme.headline1,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          openBuilder: (_, __) => CollectionArtist(artist: collection.lastArtist),
        ),
      ),
    );
  }
}


class CollectionArtistTile extends StatelessWidget {
  final double height;
  final double width;
  final Artist artist;
  const CollectionArtistTile({Key? key, required this.height, required this.width, required this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedElevation: 2.0,
      closedColor: Theme.of(context).cardColor,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedBuilder: (_, open) => Container(
        height: this.height,
        width: this.width,
        child: InkWell(
          onTap: open,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Ink.image(
                image: FileImage(this.artist.tracks.last.albumArt),
                fit: BoxFit.fill,
                height: this.width,
                width: this.width,
              ),
              Container(
                height: 36.0,
                width: this.width,
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(8.0),
                child: Text(
                  this.artist.artistName!,
                  style: Theme.of(context).textTheme.headline2,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
      openBuilder: (_, __) => CollectionArtist(artist: artist),
    );
  }
}


class CollectionArtist extends StatelessWidget {
  final Artist? artist;
  const CollectionArtist({Key? key, required this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
    double tileWidth = (MediaQuery.of(context).size.width - 16 - (elementsPerRow - 1) * 8) / elementsPerRow;
    double tileHeight = tileWidth * 242 / 156;

    return Consumer<Collection>(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.file(
            this.artist!.tracks.last.albumArt,
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            filterQuality: FilterQuality.low,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [
                  0.4,
                  1.0
                ],
                colors: [
                  Colors.transparent,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
        ],
      ),
      builder: (context, collection, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
          body: Stack(
            children: [
              child!,
              ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 192.0 + 128.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [
                              0.4,
                              1.0,
                            ],
                            colors: [
                              Colors.transparent,
                              Theme.of(context).scaffoldBackgroundColor,
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.only(
                          left: (MediaQuery.of(context).size.width - 192.0) / 2,
                          right: (MediaQuery.of(context).size.width - 192.0) / 2,
                          bottom: 32.0,
                        ),
                        elevation: 2.0,
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          height: 192.0 + 36.0,
                          width: 192.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.file(
                                this.artist!.tracks.last.albumArt,
                                fit: BoxFit.fill,
                                height: 192.0,
                                width: 192.0,
                              ),
                              Container(
                                height: 36.0,
                                width: 192.0,
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  this.artist!.artistName!,
                                  style: Theme.of(context).textTheme.headline2,
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: tileHeight + 8.0,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      scrollDirection: Axis.horizontal,
                      children: this.artist!.albums.map(
                        (Album album) => Container(
                          margin: EdgeInsets.all(4.0),
                          child: CollectionAlbumTile(
                            album: album,
                            height: tileHeight,
                            width: tileWidth,
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                  Container(
                    height: 16.0,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ] + this.artist!.tracks.map(
                  (Track track) => Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: CollectionTrackTile(
                    track: track,
                    popupMenuButton: PopupMenuButton(
                      elevation: 2,
                      onSelected: (index) {
                        switch (index) {
                          case 0:
                            showDialog(
                              context: context,
                              builder: (subContext) => AlertDialog(
                                title: Text(
                                  language!.STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER,
                                  style: Theme.of(subContext).textTheme.headline1,
                                ),
                                content: Text(
                                  language!.STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY,
                                  style: Theme.of(subContext).textTheme.headline5,
                                ),
                                actions: [
                                  MaterialButton(
                                    textColor: Theme.of(context).primaryColor,
                                    onPressed: () async {
                                      await collection.delete(track);
                                      Navigator.of(subContext).pop();
                                      if (this.artist!.tracks.isEmpty) Navigator.of(context).pop();
                                    },
                                    child: Text(language!.STRING_YES),
                                  ),
                                  MaterialButton(
                                    textColor: Theme.of(context).primaryColor,
                                    onPressed: Navigator.of(subContext).pop,
                                    child: Text(language!.STRING_NO),
                                  ),
                                ],
                              ),
                            );
                            break;
                          case 1:
                            Share.shareFiles(
                              [track.filePath!],
                              subject:
                                  '${track.trackName} - ${track.albumName}. Shared using Harmonoid!',
                            );
                            break;
                          case 2:
                            showDialog(
                              context: context,
                              builder: (subContext) => AlertDialog(
                                contentPadding: EdgeInsets.zero,
                                actionsPadding: EdgeInsets.zero,
                                title: Text(
                                  language!.STRING_PLAYLIST_ADD_DIALOG_TITLE,
                                  style: Theme.of(subContext).textTheme.headline1,
                                ),
                                content: Container(
                                  height: 280,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(24, 8, 0, 16),
                                        child: Text(
                                          language!.STRING_PLAYLIST_ADD_DIALOG_BODY,
                                          style: Theme.of(subContext).textTheme.headline5,
                                        ),
                                      ),
                                      Container(
                                        height: 236,
                                        width: 280,
                                        decoration: BoxDecoration(
                                          border: Border.symmetric(
                                            vertical: BorderSide(
                                              color: Theme.of(context).dividerColor,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: collection.playlists.length,
                                          itemBuilder: (context, playlistIndex) {
                                            return ListTile(
                                              title: Text(
                                                collection
                                                    .playlists[playlistIndex].playlistName!,
                                                style:
                                                    Theme.of(context).textTheme.headline2,
                                              ),
                                              leading: Icon(
                                                Icons.queue_music,
                                                size: Theme.of(context).iconTheme.size,
                                                color: Theme.of(context).iconTheme.color,
                                              ),
                                              onTap: () async {
                                                await collection.playlistAddTrack(
                                                  collection.playlists[playlistIndex],
                                                  track,
                                                );
                                                Navigator.of(subContext).pop();
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  MaterialButton(
                                    textColor: Theme.of(context).primaryColor,
                                    onPressed: Navigator.of(subContext).pop,
                                    child: Text(language!.STRING_CANCEL),
                                  ),
                                ],
                              ),
                            );
                            break;
                        }
                      },
                      icon: Icon(Icons.more_vert,
                          color: Theme.of(context).iconTheme.color,
                          size: Theme.of(context).iconTheme.size),
                      tooltip: language!.STRING_OPTIONS,
                      itemBuilder: (_) => <PopupMenuEntry>[
                        PopupMenuItem(
                          value: 0,
                          child: Text(language!.STRING_DELETE),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: Text(language!.STRING_SHARE),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Text(language!.STRING_ADD_TO_PLAYLIST),
                        ),
                      ],
                    ),
                  ),
                  ),
                ).toList().reversed.toList(),
              ),
            ],
          )
        ),
      ),
    );
  }
}

