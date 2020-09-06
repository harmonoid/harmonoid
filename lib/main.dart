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
        accentColor: Globals.colors[Globals.globalColor][Globals.globalTheme],
        colorScheme: ColorScheme.light(),
        primaryColor: Globals.colors[Globals.globalColor][Globals.globalTheme],
        primaryColorLight: Colors.black12,
        primaryColorDark: Globals.colors[Globals.globalColor][Globals.globalTheme],
        splashFactory: InkRipple.splashFactory,
        textSelectionHandleColor: Globals.colors[Globals.globalColor][Globals.globalTheme],
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