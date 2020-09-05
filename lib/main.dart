import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/globals.dart' as Globals;
import 'package:harmonoid/saved/welcome.dart';
import 'package:harmonoid/scripts/globalsupdater.dart';
import 'package:harmonoid/searchalbumresults.dart';
import 'package:harmonoid/scripts/backgroundtask.dart';


class Application extends StatelessWidget {

  @override 
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Harmonoid',
      theme: ThemeData(
        accentColor: Globals.globalColor,
        colorScheme: ColorScheme.light(),
        primaryColor: Globals.globalColor,
        primaryColorLight: Colors.black12,
        primaryColorDark: Globals.globalColor,
        splashFactory: InkRipple.splashFactory,
        textSelectionHandleColor: Globals.globalColor,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome' : (context) => 
        AudioServiceWidget(
          child: Welcome(),
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupStartupGlobals();
  runApp(Application());
}

void backgroundTaskEntryPoint() => AudioServiceBackground.run(() => BackgroundTask());