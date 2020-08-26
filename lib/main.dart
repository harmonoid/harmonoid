import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/saved/welcome.dart';
import 'package:harmonoid/scripts/globalspersistent.dart';
import 'package:harmonoid/scripts/globalsupdater.dart';
import 'package:harmonoid/searchalbumresults.dart';
import 'package:harmonoid/scripts/backgroundtask.dart';

class Application extends StatelessWidget {

  Future<void> _setupGlobals() async {
    String languageRegion = await GlobalsPersistent.getConfiguration('language');
    String homeURL = await GlobalsPersistent.getConfiguration('server');
    updateGlobals(languageRegion);
    updateHomeURL(homeURL);
  }

  @override 
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Harmonoid',
      theme: ThemeData(
        accentColor: Colors.deepPurpleAccent[700],
        colorScheme: ColorScheme.light(),
        primaryColor: Colors.deepPurpleAccent[400],
        primaryColorLight: Colors.deepPurpleAccent[100],
        primaryColorDark: Colors.deepPurpleAccent[700],
        splashFactory: InkRipple.splashFactory,
        textSelectionHandleColor: Colors.deepPurpleAccent[400],
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome' : (context) => 
        AudioServiceWidget(
          child: FutureBuilder(
            future:  this._setupGlobals(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Welcome();
              }
              else {
                return Scaffold();
              }
            },
          ),
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == SearchAlbumResults.pageRoute) {
          final SearchAlbumResultArguments args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => SearchAlbumResults(
                keyword: args.keyword, 
                searchMode: args.searchMode,
                searchTitle: args.searchTitle,
            ),
          );
        }
      },
    );
  }
}

void main() => runApp(Application());

void backgroundTaskEntryPoint() => AudioServiceBackground.run(() => BackgroundTask());