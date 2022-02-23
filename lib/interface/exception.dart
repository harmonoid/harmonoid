/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
        color: kAccents.first.light,
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
    return Scaffold(
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
                onPressed: () =>
                    launch('https://github.com/harmonoid/harmonoid/issues'),
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
