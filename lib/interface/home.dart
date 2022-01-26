/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/discord_rpc.dart';
import 'package:harmonoid/interface/change_notifiers.dart';
import 'package:harmonoid/interface/nowplaying.dart';
import 'package:harmonoid/interface/nowplayingbar.dart';
import 'package:harmonoid/core/lyrics.dart';
import 'package:harmonoid/interface/collection/collection.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/dimensions.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final ValueNotifier<TabRoute> tabControllerNotifier =
      ValueNotifier<TabRoute>(TabRoute(0, TabRouteSender.systemNavigation));
  final List<TabRoute> tabControllerRouteStack = <TabRoute>[
    TabRoute(0, TabRouteSender.systemNavigation)
  ];

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
    print(this.tabControllerNotifier.value.index);
    if (this.tabControllerNotifier.value.sender !=
        TabRouteSender.systemNavigation) {
      this.tabControllerRouteStack.add(this.tabControllerNotifier.value);
    }
  }

  @override
  Future<bool> didPopRoute() async {
    if (this.navigatorKey.currentState!.canPop()) {
      // Any route was pushed to nested [Navigator].
      this.navigatorKey.currentState!.pop();
    } // No route was left in nested [Navigator]'s stack.
    else {
      // Check for previously opened tabs & switch.
      if (this.tabControllerRouteStack.length > 1) {
        tabControllerRouteStack.removeLast();
        this.tabControllerNotifier.value = TabRoute(
          tabControllerRouteStack.removeLast().index,
          TabRouteSender.systemNavigation,
        );
      } else {
        // Show exist confirmation dialog.
        showDialog(
          context: context,
          builder: (subContext) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              language.EXIT_TITLE,
              style: Theme.of(subContext).textTheme.headline1,
            ),
            content: Text(
              language.EXIT_SUBTITLE,
              style: Theme.of(subContext).textTheme.headline3,
            ),
            actions: [
              MaterialButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: SystemNavigator.pop,
                child: Text(language.YES),
              ),
              MaterialButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: Navigator.of(subContext).pop,
                child: Text(language.NO),
              ),
            ],
          ),
        );
      }
    }

    /// Desktop specific.
    if (nowPlayingBar.maximized) nowPlayingBar.maximized = false;
    return true;
  }

  /// Desktop specific.
  void launch() {
    nowPlayingBar.maximized = true;
    navigatorKey.currentState?.push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SharedAxisTransition(
          transitionType: SharedAxisTransitionType.vertical,
          fillColor: Colors.transparent,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: NowPlayingScreen(),
        ),
      ),
    );
  }

  void exit() {
    nowPlayingBar.maximized = false;
    navigatorKey.currentState?.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider<Collection>(
            create: (context) => collection,
          ),
          ChangeNotifierProvider(
            create: (context) => collectionRefresh,
          ),
          ChangeNotifierProvider<NowPlayingController>(
            create: (context) => nowPlaying,
          ),
          ChangeNotifierProvider<NowPlayingBarController>(
            create: (context) => nowPlayingBar,
          ),
          Provider<DiscordRPC>(
            create: (context) => discordRPC,
          ),
          ChangeNotifierProvider<YouTubeStateController>(
            create: (context) => YouTubeStateController(),
          ),
          ChangeNotifierProvider<Language>(
            create: (context) => Language.get()!,
          ),
          ChangeNotifierProvider<Lyrics>(
            create: (context) => Lyrics.get(),
          ),
        ],
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
                            initialRoute: 'collection',
                            onGenerateRoute: (RouteSettings routeSettings) {
                              Route<dynamic>? route;
                              if (routeSettings.name == 'collection') {
                                route = MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      CollectionScreen(
                                    tabControllerNotifier:
                                        tabControllerNotifier,
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
                  NowPlayingBar(
                    launch: this.launch,
                    exit: this.exit,
                  ),
                ],
              )
            : Consumer<Language>(
                builder: (context, _, __) => Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: HeroControllerScope(
                    controller: MaterialApp.createMaterialHeroController(),
                    child: Navigator(
                      key: this.navigatorKey,
                      initialRoute: 'collection',
                      onGenerateRoute: (RouteSettings routeSettings) {
                        Route<dynamic>? route;
                        if (routeSettings.name == 'collection') {
                          route = MaterialPageRoute(
                            builder: (BuildContext context) => CollectionScreen(
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
    );
  }
}
