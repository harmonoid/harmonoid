import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';


class Harmonoid extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Visuals>(
      create: (context) => Visuals(
        accent: configuration.accent,
        themeMode: configuration.themeMode,
        platform: configuration.platform,
      ),
      builder: (context, _) => Consumer<Visuals>(
        builder: (context, visuals, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: visuals.theme,
          darkTheme: visuals.darkTheme,
          themeMode: visuals.themeMode,
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<Server>(
                create: (context) => Server(homeAddress: configuration.homeAddress),
              ),
              ChangeNotifierProvider<NotificationLyrics>(
                create: (context) => NotificationLyrics(enabled: configuration.notificationLyrics!),
              ),
            ],
            builder: (context, _) => Consumer<Server>(
              builder: (context, _, __) => Home(),
            ),
          ),
        ),
      ),
    );
  }
}

