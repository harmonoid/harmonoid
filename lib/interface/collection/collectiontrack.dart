import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';


class CollectionTrackTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
    double tileWidth = (MediaQuery.of(context).size.width - 16 - (elementsPerRow - 1) * 8) / elementsPerRow;
    return Consumer<Collection>(
      builder: (context, collection, _) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              collection.tracks.isNotEmpty ? () {
                List<Widget> children = <Widget>[];
                children.addAll([
                  SubHeader(language.STRING_LOCAL_TOP_SUBHEADER_TRACK),
                  LeadingCollectionTrackTile(),
                  SubHeader(language.STRING_LOCAL_OTHER_SUBHEADER_TRACK)
                ]);
                collection.tracks.asMap().forEach((int index, _) {
                  children.add(
                    CollectionTrackTile(
                      track: collection.tracks[index],
                      index: index,
                      popupMenuButton: PopupMenuButton(
                        elevation: 2,
                        onSelected: (index) {
                          switch (index) {
                            case 0:
                              showDialog(
                                context: context,
                                builder: (subContext) => AlertDialog(
                                  title: Text(
                                    language
                                        .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER,
                                    style: Theme.of(subContext).textTheme.headline1,
                                  ),
                                  content: Text(
                                    language
                                        .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY,
                                    style: Theme.of(subContext).textTheme.headline5,
                                  ),
                                  actions: [
                                    MaterialButton(
                                      textColor: Theme.of(context).primaryColor,
                                      onPressed: () async {
                                        await collection.delete(collection.tracks[index]);
                                        Navigator.of(subContext).pop();
                                      },
                                      child: Text(language.STRING_YES),
                                    ),
                                    MaterialButton(
                                      textColor: Theme.of(context).primaryColor,
                                      onPressed: Navigator.of(subContext).pop,
                                      child: Text(language.STRING_NO),
                                    ),
                                  ],
                                ),
                              );
                              break;
                            case 1:
                              Share.shareFiles(
                                [collection.tracks[index].filePath],
                                subject:
                                    '${collection.tracks[index].trackName} - ${collection.tracks[index].albumName}. Shared using Harmonoid!',
                              );
                              break;
                            case 2:
                              showDialog(
                                context: context,
                                builder: (subContext) => AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  actionsPadding: EdgeInsets.zero,
                                  title: Text(
                                    language.STRING_PLAYLIST_ADD_DIALOG_TITLE,
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
                                            language.STRING_PLAYLIST_ADD_DIALOG_BODY,
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
                                                      .playlists[playlistIndex].playlistName,
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
                                                    collection.tracks[index],
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
                                      child: Text(language.STRING_CANCEL),
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
                        tooltip: language.STRING_OPTIONS,
                        itemBuilder: (_) => <PopupMenuEntry>[
                          PopupMenuItem(
                            value: 0,
                            child: Text(language.STRING_DELETE),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: Text(language.STRING_SHARE),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Text(language.STRING_ADD_TO_PLAYLIST),
                          ),
                        ],
                      ),
                    ),
                  );
                });
                return children;
              }(): <Widget>[
                ExceptionWidget(
                  margin: EdgeInsets.only(top: 96.0, left: 8.0, right: 8.0),
                  height: tileWidth,
                  assetImage: 'assets/images/collection-album.jpg',
                  title: language.STRING_NO_COLLECTION_TITLE,
                  subtitle: language.STRING_NO_COLLECTION_SUBTITLE,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class CollectionTrackTile extends StatelessWidget {
  final Track track;
  final int index;
  final PopupMenuButton popupMenuButton;
  const CollectionTrackTile({Key key, @required this.track, this.index, @required this.popupMenuButton});

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () => this.index != null
              ? Playback.play(
                  index: this.index,
                  tracks: collection.tracks,
                )
              : Playback.play(
                  index: 0,
                  tracks: <Track>[this.track],
                ),
          dense: false,
          isThreeLine: true,
          leading: CircleAvatar(
            child: Text('${this.track.trackNumber ?? 1}'),
            backgroundImage: FileImage(this.track.albumArt),
          ),
          title: Text(this.track.trackName),
          subtitle: Text(
            this.track.albumName +
                '\n' +
                (this.track.trackArtistNames.length < 2
                    ? this.track.trackArtistNames.join(', ')
                    : this.track.trackArtistNames.sublist(0, 2).join(', ')),
          ),
          trailing: popupMenuButton,
        ),
      ),
    );
  }
}


class LeadingCollectionTrackTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
      child:  Consumer<Collection>(
        builder: (context, collection, _) => InkWell(
          onTap: () async => await Playback.play(
            index: collection.tracks.length - 1,
            tracks: collection.tracks,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Ink.image(
                image: FileImage(collection.lastTrack.albumArt),
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                height: 156.0,
                width: MediaQuery.of(context).size.width - 16.0,
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 16.0, right: 16.0),
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        child: Text(
                          '${collection.lastTrack.trackNumber ?? 1}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundImage: FileImage(
                          collection.lastTrack.albumArt,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Divider(
                            color: Colors.transparent,
                            height: 8.0,
                          ),
                          Text(
                            collection.lastTrack.trackName,
                            style: Theme.of(context).textTheme.headline1,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                          ),
                          Text(
                            collection.lastTrack.albumName,
                            style: Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                          ),
                          Text(
                            collection.lastTrack.trackArtistNames.length < 2
                                ? collection.lastTrack.trackArtistNames.join(', ')
                                : collection.lastTrack.trackArtistNames
                                    .sublist(0, 2)
                                    .join(', '),
                            style: Theme.of(context).textTheme.headline5,
                            maxLines: 1,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.play_arrow_outlined,
                          color: Theme.of(context).accentColor,
                          size: 28.0,
                        ),
                        onPressed: null,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
