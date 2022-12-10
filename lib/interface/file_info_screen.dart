/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uri_parser/uri_parser.dart';
import 'package:media_engine/media_engine.dart';
import 'package:media_library/media_library.dart' hide Media;

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/utils/helpers.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/tagger_client.dart';
import 'package:harmonoid/constants/language.dart';

class FileInfoScreen extends StatefulWidget {
  static Future<void> show(
    BuildContext context, {
    Uri? uri,
    Duration timeout: const Duration(days: 1),
  }) async {
    if (uri != null) {
      // Show [Dialog] on desktop & use [showGeneralDialog] on mobile.
      if (isDesktop) {
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            child: FileInfoScreen(
              uri: uri,
              timeout: timeout,
            ),
            clipBehavior: Clip.antiAlias,
            insetPadding: EdgeInsets.all(64.0),
          ),
        );
      } else if (isMobile) {
        await showGeneralDialog(
          useRootNavigator: false,
          context: context,
          pageBuilder: (context, animation, secondaryAnimation) {
            return FileInfoScreen(
              uri: uri,
              timeout: timeout,
            );
          },
        );
      }
    } else {
      await showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(
            Language.instance.READ_METADATA,
          ),
          children: [
            ListTile(
              onTap: () async {
                final file = await pickFile(
                  label: Language.instance.MEDIA_FILES,
                  extensions: kSupportedFileTypes,
                );
                debugPrint(file.toString());
                if (file != null) {
                  await Navigator.of(ctx).maybePop();
                  await show(
                    context,
                    uri: file.uri,
                    timeout: timeout,
                  );
                }
              },
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(ctx).iconTheme.color,
                child: Icon(
                  Icons.folder,
                ),
              ),
              title: Text(
                Language.instance.FILE,
                style: isDesktop
                    ? Theme.of(ctx).textTheme.headlineMedium
                    : Theme.of(ctx).textTheme.displaySmall?.copyWith(
                          fontSize: 16.0,
                        ),
              ),
            ),
            ListTile(
              onTap: () async {
                await Navigator.of(ctx).maybePop();
                final controller = TextEditingController();
                final GlobalKey<FormState> formKey = GlobalKey<FormState>();

                Future<void> showFileInfoScreen(
                  BuildContext ctx,
                  String text,
                  Duration timeout,
                ) async {
                  if (text.isNotEmpty &&
                      (formKey.currentState?.validate() ?? false)) {
                    final parser = URIParser(text);
                    if (parser.validate()) {
                      debugPrint(parser.result.toString());
                      Navigator.of(ctx).maybePop();
                      // Yeah! That's recursion.
                      await show(
                        context,
                        uri: parser.result,
                        timeout: timeout,
                      );
                    }
                  }
                }

                // Show [AlertDialog] on desktop & [showModalBottomSheet] on mobile.
                if (isDesktop) {
                  await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        Language.instance.READ_METADATA,
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                  validator: (value) {
                                    final parser = URIParser(value);
                                    if (!parser.validate()) {
                                      debugPrint(value);
                                      // Empty [String] prevents the message from showing & does not distort the UI.
                                      return '';
                                    }
                                    return null;
                                  },
                                  autofocus: true,
                                  controller: controller,
                                  cursorWidth: 1.0,
                                  onFieldSubmitted: (String value) async {
                                    await showFileInfoScreen(
                                      context,
                                      value,
                                      timeout,
                                    );
                                  },
                                  textAlignVertical: TextAlignVertical.center,
                                  style: Theme.of(ctx).textTheme.headlineMedium,
                                  decoration: inputDecoration(
                                    context,
                                    Language.instance.FILE_PATH_OR_URL,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            Language.instance.READ.toUpperCase(),
                          ),
                          onPressed: () async {
                            await showFileInfoScreen(
                              context,
                              controller.text,
                              timeout,
                            );
                          },
                        ),
                        TextButton(
                          child: Text(
                            Language.instance.CANCEL.toUpperCase(),
                          ),
                          onPressed: Navigator.of(ctx).maybePop,
                        ),
                      ],
                    ),
                  );
                } else {
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    elevation: kDefaultHeavyElevation,
                    useRootNavigator: true,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) {
                        return Container(
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom -
                                MediaQuery.of(context).padding.bottom,
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 4.0),
                              Form(
                                key: formKey,
                                child: TextFormField(
                                  autofocus: true,
                                  autocorrect: false,
                                  validator: (value) {
                                    final parser = URIParser(value);
                                    if (!parser.validate()) {
                                      debugPrint(value);
                                      // Empty [String] prevents the message from showing & does not distort the UI.
                                      return '';
                                    }
                                    return null;
                                  },
                                  controller: controller,
                                  keyboardType: TextInputType.url,
                                  textCapitalization: TextCapitalization.none,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (value) async {
                                    await showFileInfoScreen(
                                      context,
                                      controller.text,
                                      timeout,
                                    );
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(
                                      12,
                                      30,
                                      12,
                                      6,
                                    ),
                                    hintText:
                                        Language.instance.FILE_PATH_OR_URL,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .iconTheme
                                            .color!
                                            .withOpacity(0.4),
                                        width: 1.8,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .iconTheme
                                            .color!
                                            .withOpacity(0.4),
                                        width: 1.8,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 1.8,
                                      ),
                                    ),
                                    errorStyle: TextStyle(height: 0.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              ElevatedButton(
                                onPressed: () async {
                                  await showFileInfoScreen(
                                    context,
                                    controller.text,
                                    timeout,
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                                child: Text(
                                  Language.instance.READ.toUpperCase(),
                                  style: const TextStyle(
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(ctx).iconTheme.color,
                child: Icon(
                  Icons.link,
                ),
              ),
              title: Text(Language.instance.URL,
                  style: isDesktop
                      ? Theme.of(ctx).textTheme.headlineMedium
                      : Theme.of(ctx).textTheme.displaySmall?.copyWith(
                            fontSize: 16.0,
                          )),
            ),
          ],
        ),
      );
    }
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
  Tagger? tagger;
  TaggerClient? client;
  Map<String, dynamic> metadata = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isWindows) {
        tagger = Tagger(verbose: true);
        try {
          metadata.addAll(
            await tagger!.parse(
              Media(
                widget.uri.toString(),
              ),
              coverDirectory: Collection.instance.albumArtDirectory,
              timeout: widget.timeout,
            ),
          );
          track = Helpers.parseTaggerMetadata(metadata);
          cleanup();
          setState(() {});
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      } else if (Platform.isLinux) {
        client = TaggerClient(verbose: true);
        try {
          metadata.addAll(
            await client!.parse(
              widget.uri.toString(),
              coverDirectory: Collection.instance.albumArtDirectory,
              timeout: widget.timeout,
            ),
          );
          track = Helpers.parseTaggerMetadata(metadata);
          cleanup();
          setState(() {});
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      } else if (Platform.isAndroid) {
        try {
          final metadata = await Collection.instance.parse(
            widget.uri,
            Collection.instance.albumArtDirectory,
            timeout: widget.timeout,
            waitUntilAlbumArtIsSaved: true,
          );
          this.metadata.addAll(metadata.toJson());
          track = Track.fromJson(this.metadata);
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
    final durationDivisor = isDesktop ? 1000 : 1;
    final bitrateDivisor = isDesktop ? 1e9 : 1000;
    metadata.removeWhere((key, value) => key.toUpperCase() == key);
    if (metadata.isNotEmpty) {
      if (metadata.containsKey('duration')) {
        try {
          metadata['duration'] = Duration(
            milliseconds: (metadata['duration'] is int
                    ? metadata['duration']
                    : int.parse(metadata['duration'])) ~/
                durationDivisor,
          ).toString();
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
      if (metadata.containsKey('bitrate')) {
        try {
          metadata['bitrate'] =
              '${(metadata['bitrate'] is int ? metadata['bitrate'] : int.parse(metadata['bitrate'])) ~/ bitrateDivisor} kb/s';
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
    }
  }

  @override
  void dispose() {
    tagger?.dispose();
    client?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = DataTable(
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
                      maxWidth: isDesktop ? 420.0 : double.infinity,
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
    );
    return isDesktop
        ? Container(
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            fontSize: 24.0,
                                          ),
                                    ),
                                    Text(
                                      !widget.uri.isScheme('FILE')
                                          ? widget.uri.toString()
                                          : basename(widget.uri.toFilePath()),
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              TextButton(
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
                                data,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: Navigator.of(context).maybePop,
                icon: Icon(Icons.close),
              ),
              title: Text(Language.instance.FILE_INFORMATION),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            floatingActionButton: track == null
                ? FloatingActionButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: const JsonEncoder.withIndent('    ')
                              .convert(metadata),
                        ),
                      );
                    },
                    child: Icon(Icons.copy_all),
                    tooltip: Language.instance.COPY_AS_JSON,
                  )
                : null,
            body: metadata.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : NowPlayingBarScrollHideNotifier(
                    child: CustomListView(
                      children: [
                        SingleChildScrollView(
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  if (track != null)
                                    Image(
                                      image: getAlbumArt(track!),
                                      height: MediaQuery.of(context).size.width,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                    ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: data,
                                  ),
                                ],
                              ),
                              if (track != null)
                                Positioned(
                                  top: MediaQuery.of(context).size.width - 28.0,
                                  right: 28.0,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: const JsonEncoder.withIndent(
                                                  '    ')
                                              .convert(metadata),
                                        ),
                                      );
                                    },
                                    child: Icon(Icons.copy_all),
                                    tooltip: Language.instance.COPY_AS_JSON,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          );
  }
}
