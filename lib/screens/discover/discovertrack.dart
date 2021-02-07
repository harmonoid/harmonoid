import 'dart:async';
import 'dart:io';
import 'package:harmonoid/language/constants.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/discover.dart';
import 'package:harmonoid/scripts/download.dart';
import 'package:harmonoid/scripts/vars.dart';


class DiscoverTrackTile extends StatefulWidget {
  final Track track;
  DiscoverTrackTile({Key key, @required this.track}) : super(key: key);
  _DiscoverTrackTileState createState() => _DiscoverTrackTileState();
}

class _DiscoverTrackTileState extends State<DiscoverTrackTile> {
  bool _isDownloading = false;
  double _progress = 0.0;
  bool _exists = false;
  bool _init = true;
  StreamSubscription<DownloadTask> _taskStream;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (this._init) {
      bool inDownloadQueue = false;
      /* If track is downloaded during this runtime of the app, decide existence based on completion of download. */
      for (DownloadTask task in download.tasks) {
        if (task.extras.trackId == widget.track.trackId) {
          inDownloadQueue = true;
          this._exists = task.isCompleted;
        }
      }
      /* If file wasn't downloaded during this runtime, them check for file's existence. */
      if (!inDownloadQueue) {
        File locationFile = File(
          path.join(
            MUSIC_DIRECTORY,
            '${widget.track.trackArtistNames.join(', ')}_${widget.track.trackName}'.replaceAll(new RegExp(r'[^\s\w]'),'') + '.OGG',
        ));
        if (await locationFile.exists()) {
          this.setState(() => this._exists = true);
        }
      }
      this._taskStream = download.taskStream?.listen((DownloadTask task) {
        if (task.extras.trackId == widget.track.trackId) {
          try {
            this.setState(() {
              /* Update progress from taskStream. */
              this._progress = task.progress;
              this._isDownloading = !task.isCompleted;
              this._exists = task.isCompleted;
            });
          }
          catch(exception) {
            print('ERROR: Memory leak in download.dart');
          }
        }
      });
      this._init = false;
    }
  }

  @override
  void dispose() { 
    this._taskStream.cancel();
    super.dispose();
  }

  String _getDurationString(int durationSeconds) {
    int minutes = durationSeconds ~/ 60;
    String seconds = durationSeconds - (minutes * 60) > 9 ? '${durationSeconds - (minutes * 60)}' : '0${durationSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (this._isDownloading || !this._exists) {
          this.setState(() => this._isDownloading = true);
          discover.trackDownload(
            widget.track,
            onCompleted: () => this.setState(() {
              this._isDownloading = false;
              this._exists = true;
            }),
          );
          this._taskStream = download.taskStream.listen((DownloadTask task) {
            if (task.extras.trackId == widget.track.trackId) {
              try {
                this.setState(() {
                  this._progress = task.progress;
                  this._isDownloading = !task.isCompleted;
                });
              }
              catch(exception) {
                print('ERROR: Memory leak in download.dart');
              }
            }
          });
        }
      },
      title: Text(widget.track.trackName),
      subtitle: Text(widget.track.trackArtistNames.join(', ')),
      leading: this._isDownloading ? CircularProgressIndicator(
        value: this._progress,
        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
      ): CircleAvatar(
        child: this._exists ? Icon(Icons.check) : Text('${widget.track.trackNumber ?? 1}'),
        backgroundColor: Theme.of(context).accentColor,
        foregroundColor: Colors.white,
      ),
      trailing: this._exists ? Chip(
        avatar: Icon(
          Icons.check_circle,
          color: Colors.white,
        ),
        label: Text(
          Constants.STRING_SAVED,
          style: TextStyle(
            color: Colors.white
          ),
        ),
        backgroundColor: Theme.of(context).accentColor,
        ) :Text(this._getDurationString(widget.track.trackDuration)),
    );
  }
}