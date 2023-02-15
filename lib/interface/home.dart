/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/interface/now_playing_bar.dart';
import 'package:harmonoid/interface/now_playing_screen.dart';
import 'package:harmonoid/interface/mini_now_playing_bar.dart';
import 'package:harmonoid/interface/collection/collection.dart';
import 'package:harmonoid/interface/modern_now_playing_screen.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/constants/language.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FloatingSearchBarController floatingSearchBarController =
    FloatingSearchBarController();

class _NavigatorObserver extends NavigatorObserver {
  final VoidCallback onPushRoute;

  _NavigatorObserver(this.onPushRoute);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPushRoute.call();
  }
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ValueNotifier<TabRoute> tabControllerNotifier = ValueNotifier<TabRoute>(
    TabRoute(
      Configuration.instance.libraryTab,
      TabRouteSender.systemNavigationBackButton,
    ),
  );
  final List<TabRoute> tabControllerRouteStack = <TabRoute>[
    TabRoute(
      Configuration.instance.libraryTab,
      TabRouteSender.systemNavigationBackButton,
    ),
  ];

  /// [WidgetsBindingObserver.didPushRoute] does not work.
  late final _NavigatorObserver observer;
  bool isSystemNavigationBackButtonUsed = false;
  int routePushCountAfterFloatingSearchBarOpened = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    observer = _NavigatorObserver(() {
      // If some route is pushed after [floatingSearchBarController.isOpen],
      // then we shouldn't close the [FloatingSearchBar], but rather just
      // pop the pushed route.
      if (floatingSearchBarController.isOpen) {
        routePushCountAfterFloatingSearchBarOpened++;
      }
    });
    tabControllerNotifier.addListener(onTabChange);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint(state.toString());
    // This section attempts to initialize the playback of the opened file
    // through Android intents, if the app was already alive in the background.
    // Otherwise, the [Intent.play] call from [CollectionScreen] is responsible.
    if (state == AppLifecycleState.resumed) {
      Intent.instance.play();
    }
    // https://stackoverflow.com/a/65101428/12825435
    // Save the application state & remove any existing lyrics notifications present.
    if (state == AppLifecycleState.paused) {
      await Playback.instance.saveAppState();
      await Lyrics.instance.dismissNotification();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    tabControllerNotifier.removeListener(onTabChange);
    super.dispose();
  }

  void onTabChange() {
    debugPrint(tabControllerNotifier.value.sender.toString());
    if (tabControllerRouteStack.last.index ==
        tabControllerNotifier.value.index) {
      return;
    }
    // Remove any pushed [Route]s from the navigator stack upon tab
    // change.
    if (tabControllerNotifier.value.sender ==
        TabRouteSender.bottomNavigationBar) {
      if (floatingSearchBarController.isOpen) {
        floatingSearchBarController.close();
      }
      if (navigatorKey.currentState!.canPop()) {
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      }
    }
    // Avoid adding to the history stack because subsequent
    // call from [TabRouteSender.pageView] is sent additionally
    // & we don't want to add page-change history caused by
    // back-button to the navigator stack.
    if (isSystemNavigationBackButtonUsed) {
      isSystemNavigationBackButtonUsed = false;
    }
    // Since [PageView] reacts to the route change caused by
    // [TabRouteSender.bottomNavigationBar] as well & ends up
    // adding it to the stack, the subsequent listener call is
    // avoided.
    else if (this.tabControllerNotifier.value.sender ==
        TabRouteSender.systemNavigationBackButton) {
      isSystemNavigationBackButtonUsed = true;
    }
    // Do nothing. Additional [TabRouteSender.pageView] sender
    // call will be sent later on.
    // else if (tabControllerNotifier.value.sender ==
    //     TabRouteSender.bottomNavigationBar) {
    // }
    else {
      tabControllerRouteStack.add(tabControllerNotifier.value);
    }
    debugPrint(tabControllerRouteStack.map((e) => e.index).toString());
  }

  @override
  Future<bool> didPopRoute() {
    // Intercept [didPopRoute] to close the [FloatingSearchBar]
    // with system navigation back button.
    if (floatingSearchBarController.isOpen) {
      if (routePushCountAfterFloatingSearchBarOpened > 0) {
        if (navigatorKey.currentState!.canPop()) {
          navigatorKey.currentState!.pop();
        }
        routePushCountAfterFloatingSearchBarOpened--;
      }
      // No more route left to pop. Close the [FloatingSearchBar].
      else {
        floatingSearchBarController.close();
        routePushCountAfterFloatingSearchBarOpened = 0;
      }
    } else if (navigatorKey.currentState!.canPop()) {
      // Any route was pushed to nested [Navigator].
      navigatorKey.currentState!.pop();
    }
    // No route was left in nested [Navigator]'s stack.
    else {
      // Check for previously opened tabs & switch.
      if (tabControllerRouteStack.length > 1) {
        tabControllerRouteStack.removeLast();
        tabControllerNotifier.value = TabRoute(
          tabControllerRouteStack.last.index,
          TabRouteSender.systemNavigationBackButton,
        );
        debugPrint(
            '${TabRouteSender.systemNavigationBackButton}: ${tabControllerRouteStack.last.index}');
      } else {
        SystemNavigator.pop();
      }
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => DesktopNowPlayingController(
            launch: () {
              if (Configuration.instance.modernNowPlayingScreen) {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: Theme.of(context)
                            .extension<AnimationDuration>()
                            ?.slow ??
                        Duration.zero,
                    reverseTransitionDuration: Theme.of(context)
                            .extension<AnimationDuration>()
                            ?.medium ??
                        Duration.zero,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SharedAxisTransition(
                      transitionType: SharedAxisTransitionType.vertical,
                      fillColor: Colors.transparent,
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: ModernNowPlayingScreen(),
                    ),
                  ),
                );
              } else {
                navigatorKey.currentState?.pushNamed('/now_playing');
              }
            },
            exit: () {
              if (Configuration.instance.modernNowPlayingScreen) {
                Navigator.of(context).maybePop();
              } else {
                navigatorKey.currentState!.maybePop();
              }
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
                            key: navigatorKey,
                            initialRoute: '/collection_screen',
                            onGenerateRoute: (RouteSettings routeSettings) {
                              Route<dynamic>? route;
                              if (routeSettings.name == '/collection_screen') {
                                route = MaterialRoute(
                                  builder: (BuildContext context) =>
                                      CollectionScreen(
                                    tabControllerNotifier:
                                        tabControllerNotifier,
                                    floatingSearchBarController:
                                        floatingSearchBarController,
                                  ),
                                );
                              }
                              if (routeSettings.name == '/now_playing') {
                                route = PageRouteBuilder(
                                  transitionDuration: Theme.of(context)
                                          .extension<AnimationDuration>()
                                          ?.slow ??
                                      Duration.zero,
                                  reverseTransitionDuration: Theme.of(context)
                                          .extension<AnimationDuration>()
                                          ?.medium ??
                                      Duration.zero,
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
                  body: Stack(
                    children: [
                      HeroControllerScope(
                        controller: MaterialApp.createMaterialHeroController(),
                        child: Navigator(
                          key: navigatorKey,
                          initialRoute: '/collection_screen',
                          observers: [observer],
                          onGenerateRoute: (RouteSettings routeSettings) {
                            Route<dynamic>? route;
                            if (routeSettings.name == '/collection_screen') {
                              route = MaterialRoute(
                                builder: (BuildContext context) =>
                                    NowPlayingBarScrollHideNotifier(
                                  child: CollectionScreen(
                                    tabControllerNotifier:
                                        tabControllerNotifier,
                                    floatingSearchBarController:
                                        floatingSearchBarController,
                                  ),
                                ),
                              );
                            }
                            return route;
                          },
                        ),
                      ),
                      MiniNowPlayingBar(
                        key: MobileNowPlayingController.instance.barKey,
                      ),
                    ],
                  ),
                  bottomNavigationBar: ValueListenableBuilder<double>(
                    valueListenable:
                        MobileNowPlayingController.instance.bottomNavigationBar,
                    child: M2MobileBottomNavigationBar(
                      tabControllerNotifier: tabControllerNotifier,
                    ),
                    builder: (context, height, child) => Container(
                      height: (
                              // [MobileBottomNavigationBar] only visible on mobile.
                              isMobile &&
                                  // On-screen keyboard is hidden (not visible).
                                  MediaQuery.of(context).viewInsets.bottom <
                                      180.0)
                          ? height * navigationBarHeight(context)
                          : 0.0,
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: child!,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
