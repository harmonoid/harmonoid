/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_plus/window_plus.dart';
import 'package:media_engine/media_engine.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/state/now_playing_visuals.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
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
                    if (floatingSearchBarController.isOpen) {
                      floatingSearchBarController.close();
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
                    if (floatingSearchBarController.isOpen) {
                      floatingSearchBarController.close();
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
                    top: WindowPlus.instance.captionHeight +
                        kDesktopAppBarHeight,
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
                                          final file = await pickFile(
                                            label: Language.instance.IMAGES,
                                            extensions: kSupportedImageFormats,
                                          );
                                          if (file != null) {
                                            final path = join(
                                              Collection.instance
                                                  .albumArtDirectory.path,
                                              copy.albumArtFileName,
                                            );
                                            await file.copy_(path);
                                            imageCache.clear();
                                            imageCache.clearLiveImages();
                                            await ExtendedFileImageProvider(
                                                    File(path))
                                                .evict();
                                            setState(() {
                                              provider =
                                                  ExtendedFileImageProvider(
                                                      file);
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
                                                    .displayMedium,
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
                                                    context,
                                                    '',
                                                  ),
                                                  cursorWidth: 1.0,
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
                                                      copy.genre = value ??
                                                          kUnknownGenre;
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
                                                      .headlineMedium,
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
                                            .headlineMedium,
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
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              leading: IconButton(
                onPressed: Navigator.of(context).pop,
                icon: Icon(Icons.arrow_back),
              ),
              title: Text(
                Language.instance.EDIT_DETAILS,
              ),
              actions: loading
                  ? []
                  : [
                      IconButton(
                        splashRadius: 24.0,
                        tooltip: Language.instance.SAVE,
                        onPressed: () async {
                          if (!edited.isNotEmpty || loading) {
                            Navigator.of(context).maybePop();
                            return;
                          }
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            useRootNavigator: false,
                            builder: (_) => Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          );
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
                          if (floatingSearchBarController.isOpen) {
                            floatingSearchBarController.close();
                          }
                        },
                        icon: Icon(Icons.save),
                      ),
                      const SizedBox(height: 16.0),
                      IconButton(
                        splashRadius: 24.0,
                        tooltip: Language.instance.RESTORE,
                        onPressed: () async {
                          if (loading) {
                            return;
                          }
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            useRootNavigator: false,
                            builder: (_) => Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          );
                          setState(() {
                            loading = true;
                          });
                          await Collection.instance.delete(
                            widget.track,
                            delete: false,
                          );
                          // [copy]'s album & artists names could've been changed.
                          await Collection.instance
                              .add(file: File(copy.uri.toFilePath()));
                          imageCache.clear();
                          imageCache.clearLiveImages();
                          await ExtendedFileImageProvider(
                                  File(copy.uri.toFilePath()))
                              .evict();
                          while (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                          if (floatingSearchBarController.isOpen) {
                            floatingSearchBarController.close();
                          }
                        },
                        icon: Icon(Icons.restore_page),
                      ),
                      const SizedBox(width: 8.0),
                    ],
            ),
            body: NowPlayingBarScrollHideNotifier(
              child: CustomListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                shrinkWrap: true,
                children: [
                  Stack(
                    children: [
                      Image(
                        image: provider ?? getAlbumArt(copy),
                        height: 248.0,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Material(
                        color: Colors.black38,
                        child: InkWell(
                          onTap: () async {
                            final file = await pickFile(
                              label: Language.instance.IMAGES,
                              extensions: kSupportedImageFormats,
                            );
                            if (file != null) {
                              final path = join(
                                Collection.instance.albumArtDirectory.path,
                                copy.albumArtFileName,
                              );
                              await file.copy_(path);
                              imageCache.clear();
                              imageCache.clearLiveImages();
                              await ExtendedFileImageProvider(File(path))
                                  .evict();
                              setState(() {
                                provider = ExtendedFileImageProvider(file);
                              });
                            }
                          },
                          child: Container(
                            height: 248.0,
                            width: MediaQuery.of(context).size.width,
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                              const SizedBox(height: 8.0),
                            ] +
                            <String, dynamic>{
                              Language.instance.TRACK_SINGLE: copy.trackName,
                              Language.instance.ALBUM_SINGLE: copy.albumName,
                              Language.instance.ALBUM_ARTIST:
                                  copy.albumArtistName,
                              Language.instance.ARTIST:
                                  copy.trackArtistNames.join('/'),
                              Language.instance.YEAR: copy.year,
                              Language.instance.GENRE: copy.genre,
                              Language.instance.TRACK_NUMBER: copy.trackNumber,
                            }
                                .entries
                                .map(
                                  (e) => Container(
                                    alignment: Alignment.topLeft,
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text(
                                            e.key,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall,
                                          ),
                                          margin: EdgeInsets.only(
                                            left: 4.0,
                                            top: 16.0,
                                            bottom: 16.0,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxHeight: 44.0,
                                          ),
                                          child: TextFormField(
                                            initialValue: e.value == null
                                                ? null
                                                : e.value.toString(),
                                            decoration: inputDecoration(
                                              context,
                                              '',
                                            ),
                                            onChanged: (v) {
                                              final value =
                                                  v.isEmpty ? null : v.trim();
                                              edited[e.key] = value;
                                              if (e.key ==
                                                  Language
                                                      .instance.TRACK_SINGLE) {
                                                copy.trackName = value ??
                                                    basename(widget.track.uri
                                                        .toFilePath());
                                              }
                                              if (e.key ==
                                                  Language
                                                      .instance.ALBUM_SINGLE) {
                                                copy.albumName =
                                                    value ?? kUnknownAlbum;
                                              }
                                              if (e.key ==
                                                  Language
                                                      .instance.ALBUM_ARTIST) {
                                                copy.albumArtistName =
                                                    value ?? kUnknownArtist;
                                              }
                                              if (e.key ==
                                                  Language.instance.ARTIST) {
                                                copy.trackArtistNames =
                                                    Tagger.splitArtists(
                                                            value) ??
                                                        [kUnknownArtist];
                                              }
                                              if (e.key ==
                                                  Language.instance.YEAR) {
                                                copy.year = value == null
                                                    ? kUnknownYear
                                                    : value;
                                              }
                                              if (e.key ==
                                                  Language.instance.GENRE) {
                                                copy.genre =
                                                    value ?? kUnknownGenre;
                                              }
                                              if (e.key ==
                                                  Language
                                                      .instance.TRACK_NUMBER) {
                                                copy.trackNumber =
                                                    int.parse(value ?? '1');
                                              }
                                            },
                                            inputFormatters: [
                                              Language.instance.YEAR,
                                              Language.instance.TRACK_NUMBER
                                            ].contains(e.key)
                                                ? <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .allow(
                                                            RegExp(r'[0-9]')),
                                                  ]
                                                : null,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList() +
                            [
                              const SizedBox(height: 24.0),
                              Text(
                                Language
                                    .instance
                                    .USE_THESE_CHARACTERS_TO_SEPARATE_ARTISTS
                                    .overflow,
                                style: Theme.of(context).textTheme.displaySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 24.0),
                            ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [],
            ),
          );
  }
}
