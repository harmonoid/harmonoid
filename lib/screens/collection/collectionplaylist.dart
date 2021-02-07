import 'package:flutter/material.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/playback.dart';
import 'package:harmonoid/widgets.dart';
import 'package:harmonoid/language/constants.dart';


class CollectionPlaylist extends StatefulWidget {
  final Playlist playlist;
  CollectionPlaylist({Key key, @required this.playlist}) : super(key: key);
  CollectionPlaylistState createState() => CollectionPlaylistState();
}


class CollectionPlaylistState extends State<CollectionPlaylist> {
  Playlist playlist;
  List<Widget> _tracks;
  bool _init = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      this.playlist = widget.playlist;
      this._refresh();
    }
    this._init = false;
  }

  void _refresh() {
    this._tracks = <Widget>[];
    for (Track track in this.playlist.tracks) {
      this._tracks.add(
        new ListTile(
          onTap: () => Playback.play(
            index: this.playlist.tracks.indexOf(track),
            tracks: this.playlist.tracks,
          ),
          isThreeLine: true,
          leading: CircleAvatar(
            child: Text('${track.trackNumber ?? 1}'),
            backgroundImage: FileImage(collection.getAlbumArt(track)),
          ),
          title: Text(track.trackName),
          subtitle: Text(
            track.albumName + '\n' + 
            (track.trackArtistNames.length < 2 ? 
            track.trackArtistNames.join(', ') : 
            track.trackArtistNames.sublist(0, 2).join(', ')),
          ),
          trailing: IconButton(
            onPressed: () {
              collection.playlistRemoveTrack(widget.playlist, track);
              this._refresh();
            },
            icon: Icon(
              Icons.remove,
              color: Theme.of(context).iconTheme.color,
            ),
            iconSize: Theme.of(context).iconTheme.size,
            splashRadius: Theme.of(context).iconTheme.size - 8,
          ),
        )
      );
    }
    this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          iconSize: Theme.of(context).iconTheme.size,
          splashRadius: Theme.of(context).iconTheme.size - 8,
          onPressed: Navigator.of(context).pop,
        ),
        title: Text(widget.playlist.playlistName),
      ),
      body: ListView(
        children: <Widget>[SubHeader(Constants.STRING_PLAYLIST_TRACKS_SUBHEADER)] + this._tracks,
      ),
    );
  }
}
