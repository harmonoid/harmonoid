import 'dart:async';
import 'package:flutter/material.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/core/lyrics.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/fileintent.dart';
import 'package:harmonoid/interface/collection/collectionmusic.dart';
import 'package:harmonoid/constants/language.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int? index = fileIntent.tabIndex;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    if (fileIntent.tabIndex == 0) fileIntent.play();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (this.navigatorKey.currentState!.canPop()) {
      this.navigatorKey.currentState!.pop();
    } else {
      showDialog(
        context: context,
        builder: (subContext) => AlertDialog(
          title: Text(
            language!.STRING_EXIT_TITLE,
            style: Theme.of(subContext).textTheme.headline1,
          ),
          content: Text(
            language!.STRING_EXIT_SUBTITLE,
            style: Theme.of(subContext).textTheme.headline5,
          ),
          actions: [
            MaterialButton(
              textColor: Theme.of(context).primaryColor,
              onPressed: SystemNavigator.pop,
              child: Text(language!.STRING_YES),
            ),
            MaterialButton(
              textColor: Theme.of(context).primaryColor,
              onPressed: Navigator.of(subContext).pop,
              child: Text(language!.STRING_NO),
            ),
          ],
        ),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Collection>(
            create: (context) => Collection.get()!),
        ChangeNotifierProvider<Language>(create: (context) => Language.get()!),
        ChangeNotifierProvider<Lyrics>(create: (context) => Lyrics.get())
      ],
      builder: (context, _) => Consumer<Language>(
        builder: (context, _, __) => Scaffold(
          body: HeroControllerScope(
            controller: MaterialApp.createMaterialHeroController(),
            child: Navigator(
              key: this.navigatorKey,
              initialRoute: 'collection',
              onGenerateRoute: (RouteSettings routeSettings) {
                Route<dynamic>? route;
                if (routeSettings.name == 'collection') {
                  route = MaterialPageRoute(
                    builder: (BuildContext context) => ChangeNotifierProvider(
                      child: CollectionMusic(),
                      create: (context) => CollectionRefresh(),
                      builder: (context, child) => child!,
                    ),
                  );
                }
                return route;
              },
            ),
          ),
          // bottomNavigationBar: BottomNavigationBar(
          //   type: BottomNavigationBarType.shifting,
          //   currentIndex: this.index!,
          //   onTap: (int index) => this.setState(() => this.index = index),
          //   items: <BottomNavigationBarItem>[
          //         BottomNavigationBarItem(
          //           icon: Icon(Icons.play_arrow),
          //           label: language!.STRING_NOW_PLAYING,
          //           backgroundColor: Theme.of(context)
          //               .bottomNavigationBarTheme
          //               .backgroundColor,
          //         ),
          //         BottomNavigationBarItem(
          //           icon: Icon(Icons.library_music),
          //           label: language!.STRING_COLLECTION,
          //           backgroundColor: Theme.of(context)
          //               .bottomNavigationBarTheme
          //               .backgroundColor,
          //         ),
          //       ] +
          //       (configuration.homeAddress != ''
          //           ? <BottomNavigationBarItem>[
          //               BottomNavigationBarItem(
          //                 icon: Icon(Icons.search),
          //                 label: language!.STRING_DISCOVER,
          //                 backgroundColor: Theme.of(context)
          //                     .bottomNavigationBarTheme
          //                     .backgroundColor,
          //               ),
          //             ]
          //           : <BottomNavigationBarItem>[]) +
          //       <BottomNavigationBarItem>[
          //         BottomNavigationBarItem(
          //           icon: Icon(Icons.settings),
          //           label: language!.STRING_SETTING,
          //           backgroundColor: Theme.of(context)
          //               .bottomNavigationBarTheme
          //               .backgroundColor,
          //         ),
          //       ],
          // ),
        ),
      ),
    );
  }
}
