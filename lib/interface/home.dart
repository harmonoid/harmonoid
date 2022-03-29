/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/state/now_playing_launcher.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/interface/now_playing.dart';
import 'package:harmonoid/interface/now_playing_bar.dart';
import 'package:harmonoid/interface/collection/collection.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final ValueNotifier<TabRoute> tabControllerNotifier = ValueNotifier<TabRoute>(
    TabRoute(isMobile ? 2 : 0, TabRouteSender.systemNavigationBackButton),
  );
  final List<TabRoute> tabControllerRouteStack = <TabRoute>[
    TabRoute(isMobile ? 2 : 0, TabRouteSender.systemNavigationBackButton),
  ];
  bool isSystemNavigationBackButtonPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    this.tabControllerNotifier.addListener(onTabChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    tabControllerNotifier.removeListener(onTabChange);
    super.dispose();
  }

  void onTabChange() {
    if (this.tabControllerNotifier.value.sender ==
        TabRouteSender.systemNavigationBackButton) {
      this.isSystemNavigationBackButtonPressed = true;
    }
    // Since [PageView] reacts to the route change caused by `TabRouteSender.systemNavigationBackButton` as well & ends up adding it to the stack, we avoid it like this.
    else if (this.isSystemNavigationBackButtonPressed) {
      this.isSystemNavigationBackButtonPressed = false;
    } else if (this.tabControllerNotifier.value.sender ==
        TabRouteSender.pageView) {
      this.tabControllerRouteStack.add(this.tabControllerNotifier.value);
    }
  }

  @override
  Future<bool> didPopRoute() async {
    if (this.navigatorKey.currentState!.canPop()) {
      // Any route was pushed to nested [Navigator].
      this.navigatorKey.currentState!.pop();
    }
    // No route was left in nested [Navigator]'s stack.
    else {
      // Check for previously opened tabs & switch.
      if (this.tabControllerRouteStack.length > 1) {
        tabControllerRouteStack.removeLast();
        this.tabControllerNotifier.value = TabRoute(
          tabControllerRouteStack.last.index,
          TabRouteSender.systemNavigationBackButton,
        );
      } else {
        // Show exist confirmation dialog.
        showDialog(
          context: context,
          builder: (subContext) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              Language.instance.EXIT_TITLE,
              style: Theme.of(subContext).textTheme.headline1,
            ),
            content: Text(
              Language.instance.EXIT_SUBTITLE,
              style: Theme.of(subContext).textTheme.headline3,
            ),
            actions: [
              MaterialButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: SystemNavigator.pop,
                child: Text(Language.instance.YES),
              ),
              MaterialButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: Navigator.of(subContext).pop,
                child: Text(Language.instance.NO),
              ),
            ],
          ),
        );
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Collection.instance,
          ),
          ChangeNotifierProvider(
            create: (context) => CollectionRefresh.instance,
          ),
          ChangeNotifierProvider(
            create: (context) => Playback.instance,
          ),
          ChangeNotifierProvider(
            create: (context) => Lyrics.instance,
          ),
          ChangeNotifierProvider(
            create: (context) => Language.instance,
          ),
          ChangeNotifierProvider(
            create: (context) => NowPlayingLauncher(
              launch: () {
                navigatorKey.currentState?.pushNamed('/now_playing');
              },
              exit: () {
                navigatorKey.currentState?.maybePop();
              },
            ),
          ),
        ],
        builder: (context, _) => LayoutBuilder(
          builder: (context, _) => isDesktop
              ? Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        bottom: kDesktopNowPlayingBarHeight,
                      ),
                      child: Consumer<Language>(
                        builder: (context, _, __) => Scaffold(
                          resizeToAvoidBottomInset: false,
                          body: HeroControllerScope(
                            controller:
                                MaterialApp.createMaterialHeroController(),
                            child: Navigator(
                              key: this.navigatorKey,
                              initialRoute: '/collection_screen',
                              onGenerateRoute: (RouteSettings routeSettings) {
                                Route<dynamic>? route;
                                if (routeSettings.name ==
                                    '/collection_screen') {
                                  route = MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        CollectionScreen(
                                      tabControllerNotifier:
                                          tabControllerNotifier,
                                    ),
                                  );
                                }
                                if (routeSettings.name == '/now_playing') {
                                  route = PageRouteBuilder(
                                    transitionDuration:
                                        Duration(milliseconds: 600),
                                    reverseTransitionDuration:
                                        Duration(milliseconds: 300),
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        SharedAxisTransition(
                                      transitionType:
                                          SharedAxisTransitionType.vertical,
                                      fillColor: Colors.transparent,
                                      animation: animation,
                                      secondaryAnimation: secondaryAnimation,
                                      child: NowPlayingScreen(),
                                    ),
                                  );
                                }
                                return route;
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    NowPlayingBar(),
                  ],
                )
              : Consumer<Language>(
                  builder: (context, _, __) => Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: HeroControllerScope(
                      controller: MaterialApp.createMaterialHeroController(),
                      child: Navigator(
                        key: this.navigatorKey,
                        initialRoute: '/collection_screen',
                        onGenerateRoute: (RouteSettings routeSettings) {
                          Route<dynamic>? route;
                          if (routeSettings.name == '/collection_screen') {
                            route = MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  CollectionScreen(
                                tabControllerNotifier: tabControllerNotifier,
                              ),
                            );
                          }
                          return route;
                        },
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
