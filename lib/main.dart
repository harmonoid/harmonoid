import 'package:flutter/material.dart';

import 'package:harmonoid/search.dart';

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
      home: Scaffold(
        body: Search(),
      ),
    );
  }
}

void main() => runApp(Application());