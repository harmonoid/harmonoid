import 'package:flutter/material.dart';

class AlbumViewer extends StatefulWidget {
  final String albumId;
  final String albumName;
  final String albumArt;

  AlbumViewer({Key key, @required this.albumId, @required this.albumName, @required this.albumArt}): super(key: key);
  _AlbumViewer createState() => _AlbumViewer();
}

class _AlbumViewer extends State<AlbumViewer> {
  
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: Container(
            height: 56,
            width: 56,
            alignment: Alignment.center,
            child: IconButton(
              iconSize: 24,
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              splashRadius: 20,
              onPressed: () => Navigator.of(context).pop(),
            )
          ),
          pinned: true,
          expandedHeight: MediaQuery.of(context).size.width - MediaQuery.of(context).padding.top,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(widget.albumName.split('(')[0].trim()),
            background: Image.network(
              widget.albumArt,
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        SliverFillRemaining(),
      ],
    );
  }
}