import 'package:flutter/material.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/appstate.dart';
import 'package:harmonoid/constants/constants.dart';


class CollectionTrackTile extends StatelessWidget {
  final Track track;
  CollectionTrackTile({Key key, @required this.track});

  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      dense: false,
      isThreeLine: true,
      leading: CircleAvatar(
        child: Text(this.track.trackNumber),
        backgroundImage: FileImage(collection.getAlbumArt(this.track.albumArtId)),
      ),
      title: Text(this.track.trackName),
      subtitle: Text(
        this.track.albumName + '\n' + 
        (this.track.artistNames.length < 2 ? 
        this.track.artistNames.join(', ') : 
        this.track.artistNames.sublist(0, 2).join(', ')),
      ),
      trailing: PopupMenuButton(
        elevation: 2,
        color: Theme.of(context).cardColor,
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
                        if (AppState.musicCollectionSearchRefresh != null) AppState.musicCollectionSearchRefresh();
                        if (AppState.musicCollectionRefresh != null) AppState.musicCollectionRefresh(AppState.musicCollectionCurrentTab);
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
                              top: BorderSide(color: Theme.of(context).iconTheme.color, width: 0.5),
                              bottom: BorderSide(color: Theme.of(context).iconTheme.color, width: 0.5),
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
    );
  }
}