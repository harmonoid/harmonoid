/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:animations/animations.dart';
import 'package:media_library/media_library.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/constants/language.dart';

class DirectoryPickerScreen extends StatefulWidget {
  DirectoryPickerScreen({Key? key}) : super(key: key);

  @override
  State<DirectoryPickerScreen> createState() => _DirectoryPickerScreenState();
}

class _DirectoryPickerScreenState extends State<DirectoryPickerScreen> {
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  final ValueNotifier<List<String>> stack = ValueNotifier(<String>['.']);
  final ScrollController controller = ScrollController();
  List<Directory>? volumes;
  bool exit = false;

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
    if (stack.value.length == 1) {
      stack.value.add(directory.path);
    } else {
      stack.value.add(basename(directory.path));
    }
    stack.notifyListeners();
    try {
      if (this.controller.hasClients) {
        Future.delayed(const Duration(milliseconds: 400), () {
          this.controller.animateTo(
                this.controller.position.maxScrollExtent,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
        });
      }
    } catch (exception) {
      //
    }
    debugPrint(stack.value.toString());
    final root = await compute(dir, directory);
    final controller = ScrollController();
    final shouldShowMoveUpButton = volumes!.length > 1
        ? (stack.value.length > 1)
        : (stack.value.length > 2);
    await Navigator.of(key.currentContext!).pushNamed(
      '/',
      arguments: DraggableScrollbar.semicircle(
        heightScrollThumb: 56.0,
        backgroundColor: Theme.of(key.currentContext!).cardTheme.color ??
            Theme.of(key.currentContext!).cardColor,
        controller: controller,
        child: ListView.separated(
          controller: controller,
          itemCount: root.length + (shouldShowMoveUpButton ? 1 : 0),
          itemBuilder: (context, i) {
            if (i == 0 && shouldShowMoveUpButton) {
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  dense: false,
                  enabled: shouldShowMoveUpButton,
                  onTap: () async {
                    stack.value.removeLast();
                    stack.notifyListeners();
                    await Navigator.of(key.currentContext!).maybePop();
                    try {
                      if (this.controller.hasClients) {
                        Future.delayed(const Duration(milliseconds: 400), () {
                          this.controller.animateTo(
                                this.controller.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              );
                        });
                      }
                    } catch (exception) {
                      //
                    }
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
              if (shouldShowMoveUpButton) i--;
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
                                Icons.music_note,
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
          // Only internal storage is available.
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (exit) {
          return true;
        }
        try {
          stack.value.removeLast();
        } catch (exception) {
          //
        }
        await Navigator.of(key.currentContext!).maybePop();
        final value = (volumes?.length ?? 1) > 1
            ? (stack.value.length < 1)
            : (stack.value.length < 2);
        if (!value) {
          stack.notifyListeners();
        }
        return value;
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
        body: Column(
          children: [
            Container(
              height: 64.0,
              width: MediaQuery.of(context).size.width,
              child: ValueListenableBuilder<List<String>>(
                valueListenable: stack,
                builder: (context, stack, _) => volumes == null
                    ? const SizedBox(height: 64.0)
                    : stack.length <= 1
                        ? Container(
                            height: 64.0,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Language.instance.AVAILABLE_STORAGES,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          )
                        : Theme(
                            data: Theme.of(context).copyWith(
                              // ignore: deprecated_member_use
                              androidOverscrollIndicator:
                                  AndroidOverscrollIndicator.glow,
                            ),
                            child: ScrollConfiguration(
                              behavior: NoOverscrollGlowBehavior(),
                              child: ListView.separated(
                                physics: ClampingScrollPhysics(),
                                key: ValueKey(
                                    'directory_screen_picker/address_bar'),
                                controller: controller,
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, i) => Container(
                                  alignment: Alignment.center,
                                  child: volumes == null
                                      ? Text(stack[i])
                                      : Text(
                                          stack[i]
                                              .replaceAll(
                                                volumes!.first.path,
                                                Language.instance.PHONE,
                                              )
                                              .replaceAll(
                                                volumes!.last.path,
                                                Language.instance.SD_CARD,
                                              ),
                                        ),
                                ),
                                separatorBuilder: (context, i) => Container(
                                  height: 64.0,
                                  width: 48.0,
                                  child: Icon(Icons.chevron_right),
                                ),
                                itemCount: stack.length,
                              ),
                            ),
                          ),
              ),
            ),
            Expanded(
              child: Navigator(
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
            ValueListenableBuilder<List<String>>(
              valueListenable: stack,
              builder: (context, stack, _) => Container(
                padding: EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: stack.length <= 1
                      ? null
                      : () async {
                          exit = true;
                          final path = joinAll(stack.sublist(1));
                          debugPrint(path);
                          final result = Directory(path);
                          Navigator.of(context).maybePop(
                            await result.exists_() ? result : null,
                          );
                        },
                  child: Text(
                    Language.instance.ADD_THIS_FOLDER.toUpperCase(),
                    style: const TextStyle(
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
