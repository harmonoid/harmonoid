/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';

class ExceptionApp extends StatelessWidget {
  final Object exception;
  final StackTrace stacktrace;
  ExceptionApp({Key? key, required this.exception, required this.stacktrace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: createTheme(
        color: Color(0xFF6200EA),
        themeMode: ThemeMode.light,
      ),
      themeMode: ThemeMode.light,
      home: _ExceptionApp(
        exception: exception,
        stacktrace: stacktrace,
      ),
    );
  }
}

class _ExceptionApp extends StatelessWidget {
  final Object exception;
  final StackTrace stacktrace;
  _ExceptionApp({
    Key? key,
    required this.exception,
    required this.stacktrace,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS
        ? Scaffold(
            body: Column(
              children: [
                DesktopAppBar(
                  leading: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      height: 40.0,
                      width: 40.0,
                      child: Icon(Icons.error),
                    ),
                  ),
                  title: 'Exception',
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exception.toString(),
                              style: Theme.of(context).textTheme.headline2,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              stacktrace.toString(),
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ],
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ],
                  ),
                ),
                ButtonBar(
                  children: [
                    MaterialButton(
                      onPressed: () => launchUrl(
                        Uri.parse(
                            'https://github.com/harmonoid/harmonoid/issues'),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(
                        'REPORT',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        if (Platform.isWindows) {
                          appWindow.close();
                        } else {
                          SystemNavigator.pop();
                        }
                      },
                      child: Text(
                        'EXIT',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                'Exception',
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exception.toString(),
                              style: Theme.of(context).textTheme.headline2,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              stacktrace.toString(),
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ],
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ],
                  ),
                ),
                ButtonBar(
                  children: [
                    MaterialButton(
                      onPressed: () => launchUrl(
                        Uri.parse(
                            'https://github.com/harmonoid/harmonoid/issues'),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(
                        'REPORT',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        if (Platform.isWindows) {
                          appWindow.close();
                        } else {
                          SystemNavigator.pop();
                        }
                      },
                      child: Text(
                        'EXIT',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
