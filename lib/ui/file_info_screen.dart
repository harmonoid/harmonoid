// ignore_for_file: implementation_imports

import 'dart:convert';
import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:tag_reader/tag_reader.dart';
import 'package:media_kit/src/player/native/utils/temp_file.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

class FileInfoScreen extends StatefulWidget {
  final String resource;
  const FileInfoScreen({super.key, required this.resource});

  @override
  State<FileInfoScreen> createState() => _FileInfoScreenState();
}

class _FileInfoScreenState extends State<FileInfoScreen> {
  static const kTimeout = Duration(seconds: 60);

  File? _cover;
  Map<String, String>? _metadata;

  final TagReader _tagReader = TagReader();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _cover = await TempFile.create();
      _metadata = await _tagReader.metadata(
        widget.resource,
        cover: _cover,
        timeout: kTimeout,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tagReader.dispose();
  }

  Widget align(Widget child) {
    if (isDesktop) {
      return SizedBox(
        width: kDesktopCenteredLayoutWidth,
        child: Center(
          child: child,
        ),
      );
    }
    if (isTablet) {
      throw UnimplementedError();
    }
    if (isMobile) {
      return child;
    }
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return SliverContentScreen(
      caption: kCaption,
      title: Localization.instance.FILE_INFORMATION,
      floatingActionButton: _metadata == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: json.encode(_metadata)));
              },
              tooltip: Localization.instance.COPY_AS_JSON,
              child: const Icon(Icons.code),
            ),
      slivers: _metadata == null
          ? const [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))]
          : [
              SliverList.list(
                children: [
                  if (_cover != null && _cover!.lengthSync_() > 0.0)
                    if (isDesktop)
                      align(
                        Card(
                          margin: const EdgeInsets.all(24.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius.subtract(BorderRadius.circular(8.0)),
                              child: Image.file(
                                _cover!,
                                fit: BoxFit.cover,
                                width: 360.0,
                                height: 360.0,
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (isTablet)
                      throw UnimplementedError()
                    else if (isMobile)
                      align(
                        Image.file(
                          _cover!,
                          fit: BoxFit.cover,
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).width,
                        ),
                      ),
                  align(
                    SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 48.0,
                        dataRowMinHeight: 48.0,
                        dataRowMaxHeight: double.infinity,
                        columnSpacing: 32.0,
                        horizontalMargin: 32.0,
                        dividerThickness: 1.0,
                        columns: [
                          DataColumn(label: Text(Localization.instance.PROPERTY)),
                          DataColumn(label: Text(Localization.instance.VALUE)),
                          const DataColumn(label: SizedBox(width: 64.0)),
                        ],
                        rows: _metadata!.entries.map((entry) {
                          return DataRow(
                            cells: [
                              DataCell(Padding(padding: const EdgeInsets.symmetric(vertical: 12.0), child: Text(entry.key))),
                              DataCell(Padding(padding: const EdgeInsets.symmetric(vertical: 12.0), child: Text(entry.value))),
                              DataCell(
                                Container(
                                  width: 64.0,
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    iconSize: 18.0,
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: entry.value));
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
    );
  }
}
