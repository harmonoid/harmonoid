import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlbumViewer extends StatefulWidget {
  final String albumId;
  final String headerName;
  final String albumArt;

  AlbumViewer({Key key, @required this.albumId, @required this.headerName, @required this.albumArt}): super(key: key);
  _AlbumViewer createState() => _AlbumViewer();
}

class _AlbumViewer extends State<AlbumViewer> {
  
  @override
  void initState() {
    super.initState();
    
  }

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
            title: Text(widget.headerName.split('(')[0].trim()),
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