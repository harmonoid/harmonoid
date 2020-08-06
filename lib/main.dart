import 'package:flutter/material.dart';

import 'package:harmonoid/search.dart';
import 'package:harmonoid/searchresult.dart';

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
        '/welcome' : (context) => Scaffold(
          body: Search(),
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == SearchResult.pageRoute) {
          final SearchResultArguments args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => SearchResult(
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