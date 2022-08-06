/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:libmpv/libmpv.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/file_system.dart';
import 'package:media_library/media_library.dart' hide Media;
import 'package:harmonoid/constants/language.dart';

class FileInfoScreen extends StatefulWidget {
  static Future<void> show(
    BuildContext context, {
    Uri? uri,
    Duration timeout: const Duration(seconds: 10),
  }) async {
    if (isDesktop) {
      if (uri != null) {
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            child: FileInfoScreen(
              uri: uri!,
              timeout: timeout,
            ),
            clipBehavior: Clip.antiAlias,
            elevation: 32.0,
            insetPadding: EdgeInsets.all(64.0),
          ),
        );
      } else {
        const kTimeout = 1000;
        final controller = TextEditingController();
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
        Uri? validate(String text) {
          // Get rid of quotes.
          if (text.startsWith('"') && text.endsWith('"')) {
            text = text.substring(1, text.length - 1);
          }
          debugPrint(text);
          Uri? uri;
          if (uri == null) {
            try {
              if (FS.typeSync_(text) == FileSystemEntityType.file) {
                if (Platform.isWindows) {
                  text = text.replaceAll('\\', '/');
                }
                uri = File(text).uri;
              }
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
          }
          if (uri == null) {
            try {
              uri = Uri.parse(text);
              if (!(uri.isScheme('HTTP') ||
                  uri.isScheme('HTTPS') ||
                  uri.isScheme('FTP') ||
                  uri.isScheme('RSTP') ||
                  uri.isScheme('FILE'))) {
                uri = null;
              }
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
          }
          return uri;
        }

        Future<void> showFileInfoScreen(
          BuildContext ctx,
          String text,
          int timeout,
        ) async {
          if (text.isNotEmpty && (formKey.currentState?.validate() ?? false)) {
            uri = validate(text);
            if (uri != null) {
              debugPrint(uri.toString());
              Navigator.of(ctx).maybePop();
              // Yeah! That's recursion.
              await show(
                context,
                uri: uri,
                timeout: Duration(seconds: timeout),
              );
            }
          }
        }

        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  child: Text(
                    Language.instance.READ_METADATA,
                    style: Theme.of(ctx).textTheme.headline1,
                    textAlign: TextAlign.start,
                  ),
                  padding: EdgeInsets.only(
                    bottom: 16.0,
                    left: 4.0,
                  ),
                ),
                Container(
                  height: 40.0,
                  width: 420.0,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
                  padding: EdgeInsets.only(top: 2.0),
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        HotKeys.instance.disableSpaceHotKey();
                      } else {
                        HotKeys.instance.enableSpaceHotKey();
                      }
                    },
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        autofocus: true,
                        controller: controller,
                        cursorWidth: 1.0,
                        onFieldSubmitted: (String value) async {
                          await showFileInfoScreen(ctx, value, kTimeout);
                        },
                        validator: (value) {
                          final error = value == null
                              ? null
                              : validate(value) == null
                                  ? ''
                                  : null;
                          debugPrint(error.toString());
                          return error;
                        },
                        cursorColor:
                            Theme.of(ctx).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                        textAlignVertical: TextAlignVertical.bottom,
                        style: Theme.of(ctx).textTheme.headline4,
                        decoration: inputDecoration(
                          ctx,
                          Language.instance.FILE_PATH_OR_URL,
                          trailingIcon: Icon(
                            Icons.check,
                            size: 20.0,
                            color: Theme.of(ctx).iconTheme.color,
                          ),
                          trailingIconOnPressed: () async {
                            await showFileInfoScreen(
                                ctx, controller.text, kTimeout);
                          },
                        ).copyWith(
                          errorMaxLines: 1,
                          errorStyle: TextStyle(height: 0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              MaterialButton(
                child: Text(
                  Language.instance.READ.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(ctx).primaryColor,
                  ),
                ),
                onPressed: () async {
                  await showFileInfoScreen(
                    ctx,
                    controller.text,
                    kTimeout,
                  );
                },
              ),
              MaterialButton(
                child: Text(
                  Language.instance.CANCEL.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(ctx).primaryColor,
                  ),
                ),
                onPressed: Navigator.of(ctx).maybePop,
              ),
            ],
          ),
        );
      }
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
  Track? track;
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
              coverDirectory: Collection.instance.albumArtDirectory,
              timeout: widget.timeout,
            ),
          );
          track = Track.fromTagger(metadata);
          cleanup();
          setState(() {});
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        tagger.dispose();
      } else if (isMobile) {
        try {
          final metadata =
              await Collection.instance.retrievePlatformSpecificMetadataFromUri(
            widget.uri,
            Collection.instance.albumArtDirectory,
          );
          this.metadata.addAll(metadata.toJson());
          track = Track.fromTagger(this.metadata);
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
                      child: Column(
                        children: [
                          if (track != null)
                            Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Image(
                                image: getAlbumArt(track!),
                                height: 200.0,
                              ),
                            ),
                          DataTable(
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
                                            maxWidth: isDesktop
                                                ? 420.0
                                                : double.infinity,
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
