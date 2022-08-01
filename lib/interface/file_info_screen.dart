/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:libmpv/libmpv.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';

class FileInfoScreen extends StatefulWidget {
  static Future<void> show(
    Uri uri,
    BuildContext context, {
    Duration timeout: const Duration(seconds: 10),
  }) async {
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: FileInfoScreen(
            uri: uri,
            timeout: timeout,
          ),
          clipBehavior: Clip.antiAlias,
          elevation: 32.0,
          insetPadding: EdgeInsets.all(64.0),
        ),
      );
    }
    // TODO: Mobile support.
  }

  final Uri uri;
  final Duration timeout;
  FileInfoScreen({
    Key? key,
    required this.uri,
    required this.timeout,
  }) : super(key: key);

  @override
  State<FileInfoScreen> createState() => _FileInfoScreenState();
}

class _FileInfoScreenState extends State<FileInfoScreen> {
  Map<String, dynamic> metadata = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isDesktop) {
        final tagger = Tagger();
        try {
          metadata.addAll(
            await tagger.parse(
              Media(
                widget.uri.toString(),
              ),
              duration: true,
              bitrate: true,
            ),
          );
          cleanup();
          setState(() {});
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        tagger.dispose();
      } else if (isMobile) {
        try {
          final metadata = await MetadataRetriever.fromUri(
            widget.uri,
            coverDirectory: Collection.instance.albumArtDirectory,
          );
          this.metadata.addAll(metadata.toJson());
          cleanup();
          setState(() {});
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
      debugPrint(metadata.toString());
      metadata.addAll(
        {
          'uri': widget.uri.toString(),
          if (widget.uri.isScheme('FILE') &&
              widget.uri.toFilePath().contains('.')) ...{
            'file_format':
                basename(widget.uri.path).split('.').last.toUpperCase(),
          },
        },
      );
      setState(() {});
    });
  }

  void cleanup() {
    metadata.removeWhere((key, value) => key.toUpperCase() == key);
    if (metadata.isNotEmpty) {
      if (metadata.containsKey('duration')) {
        try {
          metadata['duration'] = Duration(
            milliseconds: (metadata['duration'] is int
                    ? metadata['duration']
                    : int.parse(metadata['duration'])) ~/
                1000,
          ).toString();
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
      if (metadata.containsKey('bitrate')) {
        try {
          metadata['bitrate'] =
              '${(metadata['bitrate'] is int ? metadata['bitrate'] : int.parse(metadata['bitrate'])) ~/ 1e9} kbps';
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 960.0 : double.infinity,
        maxHeight: isDesktop ? 640.0 : double.infinity,
      ),
      child: metadata.isEmpty
          ? Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 640.0 : double.infinity,
                maxHeight: isDesktop ? 480.0 : double.infinity,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            )
          : IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.0),
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Language.instance.FILE_INFORMATION,
                                style: Theme.of(context).textTheme.headline1,
                              ),
                              Text(
                                !widget.uri.isScheme('FILE')
                                    ? widget.uri.toString()
                                    : basename(widget.uri.toFilePath()),
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        MaterialButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: const JsonEncoder.withIndent('    ')
                                    .convert(metadata),
                              ),
                            );
                          },
                          child: Text(
                            Language.instance.COPY_AS_JSON.toUpperCase(),
                          ),
                          textColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Text(Language.instance.PROPERTY),
                          ),
                          DataColumn(
                            label: Text(Language.instance.VALUE),
                          ),
                          DataColumn(
                            label: Text(''),
                          ),
                        ],
                        rows: metadata.entries
                            .map(
                              (e) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      e.key.toString(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            isDesktop ? 420.0 : double.infinity,
                                      ),
                                      child: Tooltip(
                                        message: e.value.toString(),
                                        child: Text(
                                          e.value.toString().overflow,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isDesktop)
                                    DataCell(
                                      IconButton(
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text: e.value.toString(),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.copy),
                                        iconSize: 18.0,
                                        splashRadius: 18.0,
                                      ),
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
