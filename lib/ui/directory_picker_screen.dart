import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmonoid/utils/rendering.dart';
// ignore: implementation_imports
import 'package:media_library/src/utils/constants.dart';
import 'package:path/path.dart' as path;
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';

typedef DirectoryEntity = ({String directoryName, List<FileSystemEntity>? children});

class DirectoryPickerScreen extends StatefulWidget {
  const DirectoryPickerScreen({super.key});

  @override
  State<DirectoryPickerScreen> createState() => _DirectoryPickerScreenState();
}

class _DirectoryPickerScreenState extends State<DirectoryPickerScreen> {
  static const double _kAddressBarHeight = 48.0;

  List<Directory>? _storageDirectories;
  final HashMap<String, PageStorageKey> _pageStorageKeys = HashMap<String, PageStorageKey>();
  final ScrollController _controller = ScrollController();
  final ValueNotifier<List<DirectoryEntity>> _directoryPath = ValueNotifier([]);

  Directory get _directory => Directory(_directoryPath.value.map((e) => e.directoryName).join('/'));

  @override
  void initState() {
    super.initState();
    AndroidStorageController.instance.getStorageDirectories().then((value) {
      setState(() {
        _storageDirectories = value;
        if (value.length == 1) {
          _navigateTo(value.first.path);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _directoryPath.dispose();
    super.dispose();
  }

  Future<void> _navigateTo(String directoryName) async {
    _directoryPath.value = [..._directoryPath.value, (directoryName: directoryName, children: null)];
    _createPageStorageKey();

    final directoryChildren = await _directory.children_();

    _directoryPath.value = [
      ..._directoryPath.value.sublist(0, _directoryPath.value.length - 1),
      (
        directoryName: _directoryPath.value.last.directoryName,
        children: directoryChildren.where((e) => e is Directory || e is File).sorted((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;
          if (aIsDir != bIsDir) {
            return aIsDir ? -1 : 1;
          }
          return path.basename(a.path).toLowerCase().compareTo(path.basename(b.path).toLowerCase());
        }),
      ),
    ];

    _scrollAddressBarToEnd();
  }

  Future<void> _navigateUp() async {
    _directoryPath.value = _directoryPath.value.sublist(0, _directoryPath.value.length - 1);
    _scrollAddressBarToEnd();
  }

  void _scrollAddressBarToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        curve: Curves.easeInOut,
        duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
      );
    });
  }

  void _createPageStorageKey() {
    _pageStorageKeys[_directoryPath.value.map((e) => e.directoryName).join('/')] = PageStorageKey(Random().nextDouble());
  }

  PageStorageKey? _getPageStorageKey() {
    return _pageStorageKeys[_directoryPath.value.map((e) => e.directoryName).join('/')];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Directory?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (result != null) {
          context.pop(result);
        } else if (_directoryPath.value.length > 1) {
          _navigateUp();
        } else {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(Localization.instance.ADD_NEW_FOLDER),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_kAddressBarHeight),
        child: Container(
          height: _kAddressBarHeight,
          margin: const EdgeInsets.only(bottom: 4.0),
          child: ValueListenableBuilder(
            valueListenable: _directoryPath,
            builder: (context, directoryPath, _) {
              if (_storageDirectories == null) {
                return const SizedBox.shrink();
              }
              if (directoryPath.isEmpty) {
                return Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    Localization.instance.AVAILABLE_STORAGES,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
              return ListView.separated(
                key: PageStorageKey(directoryPath),
                controller: _controller,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, i) {
                  final directoryName = directoryPath[i].directoryName;
                  return Center(
                    child: Text(
                      i == 0
                          ? directoryName.replaceAll(_storageDirectories!.first.path, Localization.instance.PHONE).replaceAll(_storageDirectories!.last.path, Localization.instance.SD_CARD)
                          : directoryName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
                separatorBuilder: (context, i) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.chevron_right, size: 20.0),
                    ),
                  );
                },
                itemCount: directoryPath.length,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder(
      valueListenable: _directoryPath,
      builder: (context, directoryPath, _) {
        return Stack(
          children: [
            if (_storageDirectories == null || (directoryPath.isNotEmpty && directoryPath.lastOrNull?.children == null))
              const Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: SizedBox(height: 4.0, child: LinearProgressIndicator()),
              ),
            Column(
              children: [
                Expanded(
                  child: directoryPath.isEmpty ? _buildStorageDirectories() : _buildDirectoryChildren(directoryPath),
                ),
                Material(
                  elevation: kDefaultHeavyElevation,
                  color: Theme.of(context).bottomAppBarTheme.color,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      16.0,
                      16.0,
                      16.0,
                      16.0 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: FilledButton(
                      onPressed: directoryPath.isEmpty ? null : () => context.pop(_directory),
                      child: Text(label(Localization.instance.ADD_THIS_FOLDER)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStorageDirectories() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _storageDirectories?.length ?? 0,
      itemBuilder: (context, i) {
        if (i % 2 != 0) {
          return const Divider(height: 1.0, thickness: 1.0);
        } else {
          return ListTile(
            leading: Icon(
              switch (i) {
                0 => Icons.phone_android,
                1 => Icons.sd_storage,
                _ => Icons.folder,
              },
            ),
            title: Text(
              switch (i) {
                0 => Localization.instance.PHONE,
                1 => Localization.instance.SD_CARD,
                _ => '',
              },
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _navigateTo(_storageDirectories![i].path),
          );
        }
      },
    );
  }

  Widget _buildDirectoryChildren(List<DirectoryEntity> directoryPath) {
    final directoryChildren = directoryPath.last.children ?? [];
    return ListView.builder(
      key: _getPageStorageKey(),
      padding: EdgeInsets.zero,
      itemCount: (directoryChildren.length * 2 - 1).clamp(0, 1 << 32),
      itemBuilder: (context, i) {
        if (i % 2 != 0) {
          return const Divider(height: 1.0, thickness: 1.0);
        } else {
          final fileSystemEntity = directoryChildren[i ~/ 2];
          final fileSystemEntityName = path.basename(fileSystemEntity.path);
          return ListTile(
            leading: Icon(
              switch (fileSystemEntity) {
                Directory() => Icons.folder,
                File() when kDefaultSupportedFileTypes.contains(fileSystemEntity.extension) => Icons.audiotrack,
                _ => Icons.insert_drive_file,
              },
            ),
            title: Text(
              fileSystemEntityName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: fileSystemEntity is! Directory ? null : () => _navigateTo(fileSystemEntityName),
          );
        }
      },
      itemExtentBuilder: (i, _) => i % 2 != 0 ? 1.0 : 56.0,
    );
  }
}
