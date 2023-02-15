/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.

import 'dart:convert';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uri_parser/uri_parser.dart';
import 'package:media_library/media_library.dart';
import 'package:media_kit_tag_reader/media_kit_tag_reader.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/constants/language.dart';

class FileInfoScreen extends StatefulWidget {
  static Future<void> show(
    BuildContext context, {
    Uri? uri,
    Duration timeout = const Duration(days: 1),
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
                style: isDesktop ? Theme.of(ctx).textTheme.bodyLarge : null,
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
                            child: Form(
                              key: formKey,
                              child: CustomTextFormField(
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
                                style: Theme.of(context).textTheme.bodyLarge,
                                decoration: inputDecoration(
                                  context,
                                  Language.instance.FILE_PATH_OR_URL,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            label(
                              context,
                              Language.instance.READ,
                            ),
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
                            label(
                              context,
                              Language.instance.CANCEL,
                            ),
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
                                child: CustomTextFormField(
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontSize: 16.0,
                                      ),
                                  decoration: mobileUnderlinedInputDecoration(
                                    context,
                                    Language.instance.FILE_PATH_OR_URL,
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
                                child: Text(
                                  label(
                                    context,
                                    Language.instance.READ,
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
              title: Text(
                Language.instance.URL,
                style: isDesktop ? Theme.of(ctx).textTheme.bodyLarge : null,
              ),
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
  Map<String, dynamic> metadata = {};
  TagReader reader = TagReader(
    configuration: TagReaderConfiguration(verbose: true),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final result = await reader.metadata(
          widget.uri.toString(),
          albumArtDirectory: Collection.instance.albumArtDirectory,
          waitUntilAlbumArtIsSaved: true,
          timeout: widget.timeout,
        );
        metadata.addAll(result.map((k, v) => MapEntry(k.toUpperCase(), v)));
        try {
          // Convert `package:media_kit_tag_reader` model to `package:media_library` model.
          track = Track.fromJson(reader.platform?.serialize(result).toJson());
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    reader.dispose();
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
            child: metadata.isEmpty
                ? Container(
                    constraints: BoxConstraints(
                      maxWidth: 360.0,
                      maxHeight: 360.0,
                    ),
                    child: Center(
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      Language.instance.FILE_INFORMATION,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    Text(
                                      !widget.uri.isScheme('FILE')
                                          ? widget.uri.toString()
                                          : basename(widget.uri.toFilePath()),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                  label(
                                    context,
                                    Language.instance.COPY_AS_JSON,
                                  ),
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
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: const CircularProgressIndicator(),
                  )
                : NowPlayingBarScrollHideNotifier(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (track != null)
                            Stack(
                              children: [
                                Image(
                                  image: getAlbumArt(track!),
                                  height: MediaQuery.of(context).size.width,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                ),
                                if (track != null)
                                  Positioned(
                                    right: 16.0,
                                    bottom: 16.0,
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
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: data,
                          ),
                        ],
                      ),
                    ),
                  ),
          );
  }
}
