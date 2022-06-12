/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:path/path.dart';
import 'package:libmpv/libmpv.dart';
import 'package:extended_image/extended_image.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/file_system.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/constants/language.dart';

class EditDetailsScreen extends StatefulWidget {
  final Track track;
  EditDetailsScreen({
    Key? key,
    required this.track,
  }) : super(key: key);

  @override
  State<EditDetailsScreen> createState() => _EditDetailsScreenState();
}

class _EditDetailsScreenState extends State<EditDetailsScreen> {
  bool hover = false;
  bool loading = false;
  late Track copy;
  ImageProvider? provider;
  Map<String, String?> edited = {};

  @override
  void initState() {
    super.initState();
    copy = widget.track.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? Scaffold(
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: -1,
                  onPressed: () async {
                    if (!edited.isNotEmpty || loading) {
                      Navigator.of(context).maybePop();
                      return;
                    }
                    setState(() {
                      loading = true;
                    });
                    debugPrint(edited.toString());
                    debugPrint(copy.toJson().toString());
                    await Collection.instance
                        .delete(widget.track, delete: false);
                    // [copy]'s album & artists names could've been changed.
                    await Collection.instance.arrange(copy);
                    String from = (getAlbumArt(widget.track)
                                as ExtendedFileImageProvider)
                            .file
                            .uri
                            .toFilePath(),
                        to = join(
                          Collection.instance.albumArtDirectory.path,
                          copy.albumArtFileName,
                        );
                    debugPrint(from);
                    debugPrint(to);
                    imageCache.clear();
                    imageCache.clearLiveImages();
                    await ExtendedFileImageProvider(File(to)).evict();
                    if (from != to) {
                      await File(from).copy_(to);
                    }
                    while (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  label: Text(Language.instance.SAVE.toUpperCase()),
                  icon: loading
                      ? Container(
                          height: 24.0,
                          width: 24.0,
                          padding: EdgeInsets.all(4.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                            strokeWidth: 4.4,
                          ),
                        )
                      : Icon(Icons.save),
                ),
                const SizedBox(height: 16.0),
                FloatingActionButton.extended(
                  heroTag: -2,
                  onPressed: () async {
                    if (loading) {
                      return;
                    }
                    setState(() {
                      loading = true;
                    });
                    await Collection.instance
                        .delete(widget.track, delete: false);
                    // [copy]'s album & artists names could've been changed.
                    await Collection.instance
                        .add(file: File(copy.uri.toFilePath()));
                    imageCache.clear();
                    imageCache.clearLiveImages();
                    await ExtendedFileImageProvider(File(copy.uri.toFilePath()))
                        .evict();
                    while (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  label: Text(Language.instance.RESTORE.toUpperCase()),
                  icon: loading
                      ? Container(
                          height: 24.0,
                          width: 24.0,
                          padding: EdgeInsets.all(4.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                            strokeWidth: 4.4,
                          ),
                        )
                      : Icon(Icons.replay),
                ),
              ],
            ),
            body: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: desktopTitleBarHeight + kDesktopAppBarHeight,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: EdgeInsets.all(16.0),
                        height: 234.0,
                        width: 234.0,
                        alignment: Alignment.centerLeft,
                        child: MouseRegion(
                          onEnter: (e) {
                            setState(() {
                              hover = true;
                            });
                          },
                          onExit: (e) {
                            setState(() {
                              hover = false;
                            });
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Image(
                                    image: provider ?? getAlbumArt(copy),
                                    height: 234.0,
                                    width: 234.0,
                                  ),
                                  if (hover)
                                    Material(
                                      color: Colors.black38,
                                      child: InkWell(
                                        onTap: () async {
                                          // TODO: Using un-safe FileSystem APIs.
                                          Uint8List? file;
                                          if (Platform.isWindows) {
                                            OpenFilePicker picker =
                                                OpenFilePicker()
                                                  ..filterSpecification = {
                                                    'Images':
                                                        '*.jpg;*.jpeg;*.png;*.webp;*.bmp',
                                                  }
                                                  ..defaultFilterIndex = 0
                                                  ..defaultExtension = 'jpg'
                                                  ..title = 'Select an image';
                                            file = await picker
                                                .getFile()!
                                                .readAsBytes();
                                          }
                                          if (Platform.isLinux) {
                                            final xFile = await openFile(
                                              acceptedTypeGroups: [
                                                XTypeGroup(
                                                  label: 'images',
                                                  extensions:
                                                      '*.jpg;*.jpeg;*.png;*.webp;*.bmp'
                                                          .split(',')
                                                          .map((e) =>
                                                              e.replaceAll(
                                                                  '*.', ''))
                                                          .toList()
                                                          .cast<String>(),
                                                ),
                                              ],
                                            );
                                            if (xFile != null) {
                                              file = await File(xFile.path)
                                                  .readAsBytes();
                                            }
                                          }
                                          if (Platform.isAndroid ||
                                              Platform.isIOS ||
                                              Platform.isMacOS) {
                                            final result = await FilePicker
                                                .platform
                                                .pickFiles(
                                              type: FileType.image,
                                            );
                                            if (result!.count > 0) {
                                              file = result.files.first.bytes;
                                            }
                                          }
                                          if (file != null) {
                                            final path = join(
                                              Collection.instance
                                                  .albumArtDirectory.path,
                                              copy.albumArtFileName,
                                            );
                                            await File(path).writeAsBytes(file);
                                            imageCache.clear();
                                            imageCache.clearLiveImages();
                                            await ExtendedFileImageProvider(
                                                    File(path))
                                                .evict();
                                            setState(() {
                                              provider =
                                                  ExtendedMemoryImageProvider(
                                                      file!);
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 234.0,
                                          width: 234.0,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.edit,
                                            size: 36.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                            ],
                          ),
                        ),
                      ),
                      VerticalDivider(
                        thickness: 2.0,
                        width: 2.0,
                      ),
                      Expanded(
                        child: Form(
                          child: CustomListView(
                            cacheExtent: MediaQuery.of(context).size.height * 4,
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            children: <Widget>[
                                  const SizedBox(height: 24.0),
                                ] +
                                <String, dynamic>{
                                  Language.instance.TRACK_SINGLE:
                                      copy.trackName,
                                  Language.instance.ALBUM_SINGLE:
                                      copy.albumName,
                                  Language.instance.ALBUM_ARTIST:
                                      copy.albumArtistName,
                                  Language.instance.ARTIST:
                                      copy.trackArtistNames.join('/'),
                                  Language.instance.YEAR: copy.year,
                                  Language.instance.GENRE: copy.genre,
                                  Language.instance.TRACK_NUMBER:
                                      copy.trackNumber,
                                }
                                    .entries
                                    .map(
                                      (e) => Container(
                                        alignment: Alignment.topLeft,
                                        height: 56.0,
                                        width: double.infinity,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 156.0,
                                              child: Text(
                                                e.key + ' : ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline2,
                                              ),
                                            ),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 360.0,
                                                maxHeight: 36.0,
                                              ),
                                              child: Focus(
                                                onFocusChange: (hasFocus) {
                                                  if (hasFocus) {
                                                    HotKeys.instance
                                                        .disableSpaceHotKey();
                                                  } else {
                                                    HotKeys.instance
                                                        .enableSpaceHotKey();
                                                  }
                                                },
                                                child: TextFormField(
                                                  initialValue: e.value == null
                                                      ? null
                                                      : e.value.toString(),
                                                  decoration: inputDecoration(
                                                          context, '')
                                                      .copyWith(
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                      left: 10.0,
                                                      bottom: 14.0,
                                                    ),
                                                  ),
                                                  onChanged: (v) {
                                                    final value = v.isEmpty
                                                        ? null
                                                        : v.trim();
                                                    edited[e.key] = value;
                                                    if (e.key ==
                                                        Language.instance
                                                            .TRACK_SINGLE) {
                                                      copy.trackName = value ??
                                                          basename(widget
                                                              .track.uri
                                                              .toFilePath());
                                                    }
                                                    if (e.key ==
                                                        Language.instance
                                                            .ALBUM_SINGLE) {
                                                      copy.albumName = value ??
                                                          kUnknownAlbum;
                                                    }
                                                    if (e.key ==
                                                        Language.instance
                                                            .ALBUM_ARTIST) {
                                                      copy.albumArtistName =
                                                          value ??
                                                              kUnknownArtist;
                                                    }
                                                    if (e.key ==
                                                        Language
                                                            .instance.ARTIST) {
                                                      copy.trackArtistNames =
                                                          Tagger.splitArtists(
                                                                  value) ??
                                                              [kUnknownArtist];
                                                    }
                                                    if (e.key ==
                                                        Language
                                                            .instance.YEAR) {
                                                      copy.year = value == null
                                                          ? kUnknownYear
                                                          : value;
                                                    }
                                                    if (e.key ==
                                                        Language
                                                            .instance.GENRE) {
                                                      copy.genre = value;
                                                    }
                                                    if (e.key ==
                                                        Language.instance
                                                            .TRACK_NUMBER) {
                                                      copy.trackNumber =
                                                          int.parse(
                                                              value ?? '1');
                                                    }
                                                  },
                                                  inputFormatters: [
                                                    Language.instance.YEAR,
                                                    Language
                                                        .instance.TRACK_NUMBER
                                                  ].contains(e.key)
                                                      ? <TextInputFormatter>[
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  r'[0-9]')),
                                                        ]
                                                      : null,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList() +
                                [
                                  Row(
                                    children: [
                                      Icon(Icons.info),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        Language.instance
                                            .USE_THESE_CHARACTERS_TO_SEPARATE_ARTISTS,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24.0),
                                ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DesktopAppBar(
                  title: Language.instance.EDIT_DETAILS,
                ),
              ],
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(
                Language.instance.EDIT_DETAILS,
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            body: NowPlayingBarScrollHideNotifier(
              child: CustomListView(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          );
  }
}
