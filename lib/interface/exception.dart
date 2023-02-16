/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_plus/window_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';

class ExceptionApp extends StatelessWidget {
  final Object exception;
  final StackTrace stacktrace;
  ExceptionApp({Key? key, required this.exception, required this.stacktrace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: createM2Theme(
        color: Colors.red.shade800,
        mode: ThemeMode.light,
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

class _ExceptionApp extends StatefulWidget {
  final Object exception;
  final StackTrace stacktrace;
  _ExceptionApp({
    Key? key,
    required this.exception,
    required this.stacktrace,
  }) : super(key: key);

  @override
  _ExceptionAppState createState() => _ExceptionAppState();
}

class _ExceptionAppState extends State<_ExceptionApp> {
  final ScrollController controller = ScrollController();
  EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
    start: 16.0,
    bottom: 48.0,
  );

  static const double kDesktopHorizontalPadding = 24.0;

  void listener() {
    setState(() {
      padding = EdgeInsetsDirectional.only(
        start: 16.0,
        bottom: (48.0 *
                (1 -
                    controller.offset /
                        (196.0 -
                            kToolbarHeight -
                            MediaQuery.of(context).padding.top)))
            .clamp(
          16.0,
          48.0,
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS
        ? Scaffold(
            body: Column(
              children: [
                Stack(
                  children: [
                    Material(
                      color: Theme.of(context).colorScheme.primary,
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: Transform.translate(
                              offset: const Offset(16.0, 48.0),
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
                                    top: WindowPlus.instance.captionHeight +
                                        16.0,
                                    left: kDesktopHorizontalPadding,
                                    right: kDesktopHorizontalPadding,
                                  ),
                                  child: Text(
                                    Label.error,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .extension<TextColors>()
                                              ?.darkPrimary,
                                        ),
                                  ),
                                ),
                                const Divider(color: Colors.white24),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16.0,
                                    left: kDesktopHorizontalPadding,
                                    right: kDesktopHorizontalPadding,
                                  ),
                                  child: Text(
                                    widget.exception.toString().overflow,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .extension<TextColors>()
                                              ?.darkSecondary,
                                        ),
                                    maxLines: 1,
                                  ),
                                ),
                                const Spacer(),
                                Material(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.0,
                                      horizontal:
                                          kDesktopHorizontalPadding - 16.0,
                                    ),
                                    child: ButtonBar(
                                      alignment: MainAxisAlignment.start,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text:
                                                    '${Label.exception}: ${widget.exception.toString()}\n${Label.stack_trace}: ${widget.stacktrace.toString()}',
                                              ),
                                            );
                                          },
                                          child: Text(
                                            Label.copy.toUpperCase(),
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
                                                '/harmonoid/harmonoid/issues/new/choose',
                                              ),
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          },
                                          child: Text(
                                            Label.report.toUpperCase(),
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
                      elevation: Theme.of(context).cardTheme.elevation ??
                          kDefaultCardElevation,
                    ),
                    if (Platform.isWindows)
                      DesktopCaptionBar(
                        color: Theme.of(context).colorScheme.primary,
                        hideMaximizeAndRestoreButton: true,
                      ),
                  ],
                ),
                Expanded(
                  child: CustomListView(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: kDesktopHorizontalPadding,
                    ),
                    children: [
                      const SubHeader(
                        Label.stack_trace,
                        padding: const EdgeInsets.only(left: 0),
                      ),
                      const SizedBox(height: 8.0),
                      Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text(
                          widget.stacktrace.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            body: CustomScrollView(
              controller: controller,
              slivers: [
                SliverAppBar(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarBrightness: Brightness.light,
                    statusBarIconBrightness: Brightness.light,
                  ),
                  expandedHeight: 196.0,
                  pinned: true,
                  snap: false,
                  forceElevated: true,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      Label.error,
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<TextColors>()
                            ?.darkPrimary,
                      ),
                    ),
                    titlePadding: padding,
                    background: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            width: MediaQuery.of(context).size.width,
                            child: Icon(
                              Icons.close_outlined,
                              color: Colors.red.shade900,
                              size: 232.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 16.0,
                          ),
                          child: Text(
                            widget.exception.toString().overflow,
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
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SubHeader(
                              Label.stack_trace,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                widget.stacktrace.toString(),
                              ),
                            ),
                            for (int i = 0; i <= 100; i++)
                              const SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

abstract class Label {
  static const error = 'Error';
  static const exception = 'Exception';
  static const stack_trace = 'Stack trace';
  static const copy = 'Copy';
  static const report = 'Report';
}
