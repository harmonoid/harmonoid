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
import 'package:harmonoid/utils/rendering.dart';
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
        color: Colors.red.shade800,
        themeMode: ThemeMode.light,
      ).copyWith(
        highlightColor: Colors.white10,
        splashColor: Colors.white10,
        hoverColor: Colors.white10,
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
                Stack(
                  children: [
                    Material(
                      color: Theme.of(context).primaryColor,
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: Transform.translate(
                              offset: Offset(16.0, 48.0),
                              child: Icon(
                                Icons.close_outlined,
                                color: Colors.red.shade900,
                                size: 356.0,
                              ),
                            ),
                          ),
                          Container(
                            height: 324.0,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: desktopTitleBarHeight + 16.0,
                                    left: 36.0,
                                    right: 36.0,
                                    bottom: 16.0,
                                  ),
                                  child: Text(
                                    'Error',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 96.0,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: Colors.white24,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 16.0,
                                    left: 36.0,
                                    right: 36.0,
                                  ),
                                  child: Text(
                                    exception.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withOpacity(0.87),
                                      fontSize: 14.0,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                const Spacer(),
                                Material(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: 16.0,
                                      left: 20.0,
                                      right: 20.0,
                                      bottom: 16.0,
                                    ),
                                    child: ButtonBar(
                                      alignment: MainAxisAlignment.start,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text:
                                                    'Exception: ${exception.toString()}\nStacktrace: ${stacktrace.toString()}',
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'COPY',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            launchUrl(
                                              Uri.https(
                                                'github.com',
                                                '/harmonoid/harmonoid/issues/new',
                                                {
                                                  'assignees': 'alexmercerind',
                                                  'labels': 'bug',
                                                  'template': 'bug_report.md',
                                                },
                                              ),
                                            );
                                          },
                                          child: Text(
                                            ' REPORT',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      elevation: 4.0,
                    ),
                    if (Platform.isWindows)
                      DesktopTitleBar(
                        color: Theme.of(context).primaryColor,
                        hideMaximizeAndRestoreButton: true,
                      ),
                  ],
                ),
                Expanded(
                  child: CustomListView(
                    padding: EdgeInsets.only(
                      top: 16.0,
                      left: 36.0,
                      right: 36.0,
                      bottom: 16.0,
                    ),
                    children: [
                      Text(
                        'Stack trace',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        stacktrace.toString(),
                      ),
                    ],
                  ),
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
                    TextButton(
                      onPressed: () => launchUrl(
                        Uri.parse(
                          'https://github.com/harmonoid/harmonoid/issues',
                        ),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(
                        'REPORT',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (Platform.isWindows) {
                          appWindow.close();
                        } else {
                          SystemNavigator.pop();
                        }
                      },
                      child: Text(
                        'EXIT',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
