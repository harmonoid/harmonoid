import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/playback.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/constants/constants.dart';


class CollectionTrackTile extends StatelessWidget {
  final Track track;
  final int index;
  CollectionTrackTile({Key key, @required this.track, this.index});

  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () => this.index != null ? Playback.play(
          index: this.index,
          tracks: collection.tracks,
        ) : Playback.play(
          index: this.index,
          tracks: <Track>[this.track],
        ),
        dense: false,
        isThreeLine: true,
        leading: CircleAvatar(
          child: Text(this.track.trackNumber),
          backgroundImage: FileImage(collection.getAlbumArt(this.track.albumArtId)),
        ),
        title: Text(this.track.trackName),
        subtitle: Text(
          this.track.albumName + '\n' + 
          (this.track.trackArtistNames.length < 2 ? 
          this.track.trackArtistNames.join(', ') : 
          this.track.trackArtistNames.sublist(0, 2).join(', ')),
        ),
        trailing: PopupMenuButton(
          elevation: 2,
          color: Theme.of(context).appBarTheme.color,
          onSelected: (index) {
            switch(index) {
              case 0: {
                showDialog(
                  context: context,
                  builder: (subContext) => AlertDialog(
                    title: Text(
                      Constants.STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER,
                      style: Theme.of(subContext).textTheme.headline1,
                    ),
                    content: Text(
                      Constants.STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY,
                      style: Theme.of(subContext).textTheme.headline4,
                    ),
                    actions: [
                      MaterialButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () async {
                          await collection.delete(this.track);
                          States.refreshMusicCollection(States.musicCollectionCurrentTab);
                          States.refreshMusicSearch();
                          Navigator.of(subContext).pop();
                        },
                        child: Text(Constants.STRING_YES),
                      ),
                      MaterialButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: Navigator.of(subContext).pop,
                        child: Text(Constants.STRING_NO),
                      ),
                    ],
                  ),
                );
              }
              break;
              case 1: {
                Share.shareFiles(
                  [track.filePath],
                  subject: '${track.trackName} - ${track.albumName}. Shared using Harmonoid!',
                );
              }
              break;
              case 2: {
                showDialog(
                  context: context,
                  builder: (subContext) => AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    actionsPadding: EdgeInsets.zero,
                    title: Text(
                      Constants.STRING_PLAYLIST_ADD_DIALOG_TITLE,
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
                            padding: EdgeInsets.only(left: 24, top: 8, bottom: 16),
                            child: Text(
                              Constants.STRING_PLAYLIST_ADD_DIALOG_BODY,
                              style: Theme.of(subContext).textTheme.headline4,
                            ),
                          ),
                          Container(
                            height: 236,
                            width: 280,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                                bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                              )
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: collection.playlists.length,
                              itemBuilder: (BuildContext context, int playlistIndex) => ListTile(
                                title: Text(collection.playlists[playlistIndex].playlistName, style: Theme.of(context).textTheme.headline2),
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      MaterialButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: Navigator.of(subContext).pop,
                        child: Text(Constants.STRING_CANCEL),
                      ),
                    ],
                  ),
                );
              }
              break;
            }
          },
          icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color, size: Theme.of(context).iconTheme.size),
          tooltip: Constants.STRING_OPTIONS,
          itemBuilder: (_) => <PopupMenuEntry>[
            PopupMenuItem(
              value: 0,
              child: Text(Constants.STRING_DELETE),
            ),
            PopupMenuItem(
              value: 1,
              child: Text(Constants.STRING_SHARE),
            ),
            PopupMenuItem(
              value: 2,
              child: Text(Constants.STRING_ADD_TO_PLAYLIST),
            ),
            PopupMenuItem(
              value: 3,
              child: Text(Constants.STRING_SAVE_TO_DOWNLOADS),
            ),
          ],
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
      margin: EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 0),
      child: Container(
        height: 256,
        width: MediaQuery.of(context).size.width - 32 + 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.file(
              collection.getAlbumArt(collection.tracks.first.albumArtId),
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.low,
              alignment: Alignment.topCenter,
              height: 156,
              width: MediaQuery.of(context).size.width - 32,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    child: Text(collection.tracks.first.trackNumber,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  width: MediaQuery.of(context).size.width - 32 - 64 - 16 - 72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Divider(
                        color: Colors.transparent,
                        height: 12,
                      ),
                      Container(
                        height: 20,
                        child: Text(
                          collection.tracks.first.trackName,
                          style: Theme.of(context).textTheme.headline1,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                      ),
                      Divider(
                        color: Colors.transparent,
                        height: 2,
                      ),
                      Text(
                        collection.tracks.first.albumName,
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                      Divider(
                        color: Colors.transparent,
                        height: 4,
                      ),
                      Text(
                        collection.tracks.first.trackArtistNames.length < 2 ? 
                        collection.tracks.first.trackArtistNames.join(', ') : 
                        collection.tracks.first.trackArtistNames.sublist(0, 2).join(', '),
                        style: Theme.of(context).textTheme.headline4,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '(${collection.tracks.first.year})',
                        style: Theme.of(context).textTheme.headline4,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      Divider(
                        color: Colors.transparent,
                        height: 4,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 72,
                  alignment: Alignment.center,
                  child: FloatingActionButton(
                    onPressed: () async => await Playback.play(
                      index: 0,
                      tracks: collection.tracks
                    ),
                    mini: true,
                    child: Icon(Icons.play_arrow, color: Colors.white),
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}