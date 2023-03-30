/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/constants/language.dart';

class MissingDirectoriesScreen extends StatefulWidget {
  MissingDirectoriesScreen({Key? key}) : super(key: key);

  @override
  State<MissingDirectoriesScreen> createState() =>
      _MissingDirectoriesScreenState();
}

class _MissingDirectoriesScreenState extends State<MissingDirectoriesScreen>
    with SingleTickerProviderStateMixin {
  bool loaded = false;
  List<Directory> missing = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => refresh());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> refresh() async {
    List<Directory>? volumes;
    if (Platform.isAndroid) {
      volumes = await StorageRetriever.instance.volumes;
    }
    final result = <Directory>[];
    for (final directory in Collection.instance.collectionDirectories) {
      if (!await directory.exists_()) {
        if (volumes == null) {
          result.add(directory);
        }
        // Replace underlying path with more human understand-able [String]s on Android.
        else {
          result.add(
            Directory(
              directory.path
                  .replaceAll(
                    volumes.first.path,
                    Language.instance.PHONE,
                  )
                  .replaceAll(
                    volumes.last.path,
                    Language.instance.SD_CARD,
                  ),
            ),
          );
        }
      }
    }
    debugPrint(result.toString());
    // If all issues are resolved, remove current screen from the route.
    if (result.isEmpty) {
      // Resolve [WillPopScope].
      loaded = true;
      missing = [];
      Navigator.of(context).maybePop();
    }
    // Display.
    else {
      setState(() {
        loaded = true;
        missing = result;
      });
    }
  }

  Iterable<Row> get iterable => missing.map(
        (e) => Row(
          children: [
            Container(
              width: 72.0,
              height: 48.0,
              padding: EdgeInsets.only(right: 8.0),
              alignment: Alignment.center,
              child: const Icon(
                FluentIcons.folder_32_regular,
                size: 32.0,
              ),
            ),
            Expanded(
              child: Container(
                height: 48.0,
                padding: EdgeInsets.only(right: 8.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  e.path.overflow,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            TextButton(
              child: Text(
                label(
                  context,
                  Language.instance.REMOVE,
                ),
              ),
              onPressed: () async {
                try {
                  debugPrint(e.toString());
                  final c = Collection.instance;
                  final conf = Configuration.instance;
                  final cr = CollectionRefresh.instance;
                  if (!cr.completed) {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).cardTheme.color,
                        title: Text(
                          Language.instance.INDEXING_ALREADY_GOING_ON_TITLE,
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(
                          24.0,
                          20.0,
                          24.0,
                          8.0,
                        ),
                        content: Text(
                          Language.instance.INDEXING_ALREADY_GOING_ON_SUBTITLE,
                        ),
                        actions: [
                          TextButton(
                            onPressed: Navigator.of(context).pop,
                            child: Text(
                              label(
                                context,
                                Language.instance.OK,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  if (conf.collectionDirectories.length == 1) {
                    await showDialog(
                      context: context,
                      builder: (subContext) => AlertDialog(
                        title: Text(
                          Language.instance.WARNING,
                        ),
                        content: Text(
                          Language.instance.LAST_COLLECTION_DIRECTORY_REMOVED,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.of(subContext).pop();
                            },
                            child: Text(
                              label(
                                context,
                                Language.instance.OK,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  await c.removeDirectories(
                    refresh: false,
                    directories: {e},
                    onProgress: (progress, total, _) {
                      cr.set(progress, total);
                    },
                  );
                  await conf.save(
                    collectionDirectories: c.collectionDirectories.difference(
                      {
                        e,
                      },
                    ),
                  );
                } catch (exception, stacktrace) {
                  debugPrint(exception.toString());
                  debugPrint(stacktrace.toString());
                }
                await refresh();
              },
            ),
            const SizedBox(width: 16.0),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  DesktopAppBar(
                    leading: NavigatorPopButton(
                      color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .computeLuminance() >
                              0.5
                          ? Theme.of(context)
                              .extension<IconColors>()
                              ?.appBarLight
                          : Theme.of(context)
                              .extension<IconColors>()
                              ?.appBarDark,
                      onTap: refresh,
                    ),
                    color: Theme.of(context).colorScheme.error,
                    height: MediaQuery.of(context).size.height / 3,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height -
                        kDesktopNowPlayingBarHeight,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      alignment: Alignment.center,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        margin: EdgeInsets.only(top: 96.0, bottom: 4.0),
                        elevation: Theme.of(context).cardTheme.elevation ??
                            kDefaultCardElevation,
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 12 / 6 * 720.0,
                            maxHeight: 720.0,
                          ),
                          width: MediaQuery.of(context).size.width - 136.0,
                          height: MediaQuery.of(context).size.height - 192.0,
                          child: CustomListView(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    height: 156.0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Language.instance.FOLDERS_NOT_FOUND,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          Language.instance
                                              .FOLDERS_NOT_FOUND_SUBTITLE,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        FloatingActionButton(
                                          heroTag: 'refresh',
                                          onPressed: refresh,
                                          mini: true,
                                          child: const Icon(Icons.refresh),
                                          tooltip: Language.instance.REFRESH,
                                        ),
                                        const SizedBox(width: 8.0),
                                        FloatingActionButton(
                                          heroTag: 'settings',
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialRoute(
                                                builder: (context) =>
                                                    Settings(),
                                              ),
                                            );
                                          },
                                          mini: true,
                                          child: const Icon(Icons.settings),
                                          tooltip:
                                              Language.instance.GO_TO_SETTINGS,
                                        ),
                                        const SizedBox(width: 8.0),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 1.0,
                                thickness: 1.0,
                              ),
                              const SizedBox(height: 8.0),
                              ...iterable,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : WillPopScope(
            onWillPop: () => Future.value(missing.isEmpty),
            child: Scaffold(
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'settings',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialRoute(
                          builder: (context) => Settings(),
                        ),
                      );
                    },
                    child: const Icon(Icons.settings),
                    tooltip: Language.instance.GO_TO_SETTINGS,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  const SizedBox(height: 16.0),
                  FloatingActionButton(
                    heroTag: 'refresh',
                    onPressed: refresh,
                    child: const Icon(Icons.refresh),
                    tooltip: Language.instance.REFRESH,
                  ),
                ],
              ),
              resizeToAvoidBottomInset: true,
              body: NowPlayingBarScrollHideNotifier(
                child: CustomScrollView(
                  slivers: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        // Change [_LargeScrollUnderFlexibleConfig.expandedTextStyle].
                        textTheme: Theme.of(context).textTheme.copyWith(
                              headlineMedium:
                                  Theme.of(context).textTheme.headlineSmall,
                            ),
                      ),
                      // TODO(@alexmercerind): https://github.com/flutter/flutter/issues/120516
                      child: SliverAppBar(
                        leading: IconButton(
                          onPressed: refresh,
                          icon: const Icon(Icons.arrow_back),
                          color: Theme.of(context).appBarTheme.iconTheme?.color,
                          splashRadius: 24.0,
                        ),
                        floating: false,
                        pinned: true,
                        snap: false,
                        stretch: false,
                        stretchTriggerOffset: 100.0,
                        toolbarHeight:
                            LargeScrollUnderFlexibleConfig.collapsedHeight,
                        collapsedHeight:
                            LargeScrollUnderFlexibleConfig.collapsedHeight,
                        expandedHeight:
                            LargeScrollUnderFlexibleConfig.expandedHeight,
                        flexibleSpace: ScrollUnderFlexibleSpace(
                          title: Text(Language.instance.FOLDERS_NOT_FOUND),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate.fixed(
                        [
                          const SizedBox(height: 16.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              Language.instance.FOLDERS_NOT_FOUND_SUBTITLE
                                  .replaceAll('\n', ' '),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ...iterable,
                          const SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
