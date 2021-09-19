import 'package:flutter/material.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';

// TODO (alexmercerind): Improvise this. This is used to identify prevent automatic calling of `didChangeDependencies`,
// when the parent widgets are updated. Since, this project still isn't using riverpod, it can only access
// [ChangeNotifier]s inside the Widget tree.
bool initialized = false;
GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

class Harmonoid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Visuals>(
      create: (context) => Visuals(
        accent: configuration.accent,
        themeMode: configuration.themeMode,
      ),
      builder: (context, _) => Consumer<Visuals>(
        builder: (context, visuals, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: visuals.theme,
          darkTheme: visuals.darkTheme,
          themeMode: visuals.themeMode,
          navigatorKey: key,
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: child!,
            );
          },
          home: FractionallyScaledWidget(
            child: Home(),
          ),
        ),
      ),
    );
  }
}
