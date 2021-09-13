import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/utils/utils.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'package:harmonoid/interface/settings/settings.dart';

class ExceptionApp extends StatelessWidget {
  final Object exception;
  final StackTrace stacktrace;
  ExceptionApp({Key? key, required this.exception, required this.stacktrace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: Utils.getTheme(
        accentColor: Colors.deepPurpleAccent.shade200,
        themeMode: ThemeMode.dark,
      ),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: Column(
          children: [
            WindowTitleBar(),
            Expanded(
              child: ListView(
                children: [
                  SizedBox(
                    height: 8.0,
                  ),
                  SettingsTile(
                    title: 'Exception occured',
                    subtitle: 'Something wrong has happened.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exception.toString(),
                        ),
                        Text(
                          stacktrace.toString(),
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 16.0,
                        ),
                      ],
                    ),
                    margin: EdgeInsets.all(16.0),
                  ),
                ],
              ),
            ),
            ButtonBar(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.deepPurpleAccent.shade200,
                    ),
                  ),
                  onPressed: () => UrlLauncher.launch(
                      'https://github.com/alexmercerind/harmonoid/issues'),
                  child: Text(
                    'REPORT ISSUE',
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.deepPurpleAccent.shade200,
                    ),
                  ),
                  onPressed: SystemNavigator.pop,
                  child: Text(
                    'EXIT APP',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
