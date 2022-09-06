/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:media_library/media_library.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:safe_session_storage/isolates.dart';
import 'package:safe_session_storage/safe_session_storage.dart';

import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/constants/language.dart';

class DirectoryPickerScreen extends StatefulWidget {
  DirectoryPickerScreen({Key? key}) : super(key: key);

  @override
  State<DirectoryPickerScreen> createState() => _DirectoryPickerScreenState();
}

class _DirectoryPickerScreenState extends State<DirectoryPickerScreen> {
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  List<Directory>? volumes;
  List<String> stack = [];

  static Future<List<FileSystemEntity>> dir(Directory directory) async {
    final root = await directory.children_();
    // Sort the list of files and directories based on based name & make sure directories appear before files.
    root.sort((a, b) {
      if (a is Directory && b is File) return -1;
      if (a is File && b is Directory) return 1;
      return a.path.compareTo(b.path);
    });
    return root;
  }

  Future<void> pushDirectoryIntoStack(Directory directory) async {
    if (stack.isEmpty) {
      stack.add(directory.path);
    } else {
      stack.add(basename(directory.path));
    }
    debugPrint(stack.toString());
    final root = await compute(dir, directory);
    final controller = ScrollController();
    await Navigator.of(key.currentContext!).pushNamed(
      '/',
      arguments: DraggableScrollbar.semicircle(
        heightScrollThumb: 56.0,
        backgroundColor: Theme.of(key.currentContext!).cardColor,
        controller: controller,
        child: ListView.separated(
          controller: controller,
          itemCount: root.length + (stack.length > 1 ? 1 : 0),
          itemBuilder: (context, i) {
            if (i == 0 && stack.length > 1) {
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  dense: false,
                  enabled: stack.length > 1,
                  onTap: () async {
                    stack.removeLast();
                    await Navigator.of(key.currentContext!).maybePop();
                  },
                  leading: CircleAvatar(
                    child: const Icon(
                      Icons.arrow_upward,
                      size: 24.0,
                    ),
                    foregroundColor: Theme.of(context).iconTheme.color,
                    backgroundColor: Colors.transparent,
                  ),
                  title: Text(
                    '...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            } else {
              if (stack.length > 1) i--;
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  dense: false,
                  enabled: root[i] is Directory,
                  onTap: root[i] is Directory
                      ? () => pushDirectoryIntoStack(root[i] as Directory)
                      : null,
                  leading: CircleAvatar(
                    child: root[i] is Directory
                        ? const Icon(
                            Icons.folder_outlined,
                            size: 24.0,
                          )
                        : kSupportedFileTypes.contains(root[i].extension)
                            ? const Icon(
                                Icons.audio_file_outlined,
                                size: 24.0,
                              )
                            : const Icon(
                                Icons.description_outlined,
                                size: 24.0,
                              ),
                    foregroundColor: Theme.of(context).iconTheme.color,
                    backgroundColor: Colors.transparent,
                  ),
                  title: Text(
                    basename(root[i].path),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }
          },
          separatorBuilder: (context, i) => const Divider(
            indent: 72.0,
            height: 1.0,
            thickness: 1.0,
          ),
        ),
      ),
    );
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (volumes == null) {
        volumes = await StorageRetriever.instance.volumes;
        setState(() {});
        if (volumes!.length == 1) {
          await pushDirectoryIntoStack(volumes![0]);
        } else {
          await Navigator.of(key.currentContext!).pushNamed(
            '/',
            arguments: ListView.separated(
              itemBuilder: (context, i) => Material(
                color: Colors.transparent,
                child: ListTile(
                  dense: false,
                  onTap: () => pushDirectoryIntoStack(volumes![i]),
                  leading: CircleAvatar(
                    child: i == 0
                        ? const Icon(
                            Icons.smartphone,
                            size: 24.0,
                          )
                        : const Icon(
                            Icons.sd_card,
                            size: 24.0,
                          ),
                    foregroundColor: Theme.of(context).iconTheme.color,
                    backgroundColor: Colors.transparent,
                  ),
                  title: i == 0
                      ? Text(Language.instance.PHONE)
                      : Text(Language.instance.SD_CARD),
                ),
              ),
              separatorBuilder: (context, i) => const Divider(
                indent: 72.0,
                height: 1.0,
                thickness: 1.0,
              ),
              itemCount: volumes!.length,
            ),
          );
        }
      }
    });
  }

  bool exit = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (exit) {
          return true;
        }
        stack.removeLast();
        await Navigator.of(key.currentContext!).maybePop();
        return stack.isEmpty;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              exit = true;
              Navigator.of(context).maybePop();
            },
            icon: Icon(Icons.close),
            splashRadius: 20.0,
          ),
          title: Text(
            Language.instance.ADD_NEW_FOLDER,
          ),
        ),
        body: Navigator(
          key: key,
          onGenerateRoute: (settings) => PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, animation, secondaryAnimation) =>
                SharedAxisTransition(
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              transitionType: SharedAxisTransitionType.vertical,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: settings.arguments as Widget?,
            ),
          ),
        ),
      ),
    );
  }
}
