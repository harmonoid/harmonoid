import 'package:flutter/material.dart';

import 'package:harmonoid/saved/welcome.dart';
import 'package:harmonoid/searchalbumresults.dart';

class Application extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harmonoid',
      theme: ThemeData(
        accentColor: Colors.deepPurpleAccent[700],
        colorScheme: ColorScheme.light(),
        primaryColor: Colors.deepPurpleAccent[400],
        primaryColorDark: Colors.deepPurpleAccent[700],
        splashFactory: InkRipple.splashFactory,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome' : (context) => Welcome(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == SearchAlbumResults.pageRoute) {
          final SearchAlbumResultArguments args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => SearchAlbumResults(
                keyword: args.keyword, 
                searchMode: args.searchMode,
            ),
          );
        }
      },
    );
  }
}

void main() => runApp(Application());