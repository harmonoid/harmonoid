import 'dart:io';
import 'package:harmonoid/saved/savedartistviewer.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:harmonoid/globals.dart' as Globals;

class SavedArtistResults extends StatefulWidget {
  final ScrollController scrollController;
  SavedArtistResults({Key key, @required this.scrollController}) : super(key: key);
  SavedArtistResultsState createState() => SavedArtistResultsState();
}

class SavedArtistResultsState extends State<SavedArtistResults> {

  Widget _artists = Container();
  List<Widget> _artistsGrid = [Container()];

  @override
  void initState() {
    super.initState();
    (() async {
      String musicDirectory = Directory(path.join(
        (await path.getExternalStorageDirectory()).path, '.harmonoid', 'musicLibrary')
      ).path;

      this._artistsGrid.clear();
      for (int index = 0; index < Globals.artists.length; index++) {
        print('Length Of Current Album: ' + Globals.artistTracksList[index][0].length.toString());
        this._artistsGrid.add(
          OpenContainer(
            closedElevation: 1,
            openElevation: 1,
            closedBuilder: (BuildContext context, _) => Container(
              color: Globals.globalTheme == 0 ? Colors.white : Colors.white.withOpacity(0.10),
              width: 156,
              height: 216,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 156,
                    width: 156,
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.file(
                        File(path.join(musicDirectory, Globals.artists[index]['albums'][0]['album_id'], 'albumArt.png')),
                        height: 138,
                        width: 138,
                      ),
                    ),
                  ),
                  Container(
                    height: 36,
                    margin: EdgeInsets.only(left: 2, right: 2),
                    alignment: Alignment.center,
                    child: Text(
                      Globals.artists[index]['artist'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Globals.globalTheme == 0 ? Colors.black87 : Colors.white.withOpacity(0.87),
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ), 
            openBuilder: (_, __) => SavedArtistViewer( 
              albumArtPath: musicDirectory,
              index: index,
            ),
          )
        );
      }
      this.setState(() {
        this._artists = GridView.count(
          padding: EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 2),
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: MediaQuery.of(context).size.width - 2 * (16 + 156),
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          children: this._artistsGrid,
          childAspectRatio: 156/216,
          clipBehavior: Clip.antiAlias,
        );
      });
    })();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.globalTheme == 0 ? Colors.grey[50] : Color(0xFF121212),
      body: ListView(
        controller: widget.scrollController,
        children: [
          Container(
            height: 48,
            width: MediaQuery.of(Globals.globalContext).size.width,
          ),
          Container(
            margin: EdgeInsets.only(left: 16, top: 24, bottom: 24),
            child: Text(
              Globals.STRING_LOCAL_OTHER_SUBHEADER_ARTIST,
              style: TextStyle(
                fontSize: 12,
                color: Globals.globalTheme == 0 ? Colors.black54 : Colors.white.withOpacity(0.60),
              ),
            ),
          ),
          this._artists,
        ],
      ),
    );
  }
}