import 'dart:async';

import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

class MobileMediaLibraryAppBarOverflowButton extends StatefulWidget {
  const MobileMediaLibraryAppBarOverflowButton({super.key});

  @override
  State<MobileMediaLibraryAppBarOverflowButton> createState() => MobileMediaLibraryAppBarOverflowButtonState();
}

class MobileMediaLibraryAppBarOverflowButtonState extends State<MobileMediaLibraryAppBarOverflowButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () async {
        final mediaLibrary = context.read<MediaLibrary>();
        Completer<int> completer = Completer<int>();
        await showModalBottomSheet(
          context: context,
          showDragHandle: isMaterial3OrGreater,
          useRootNavigator: true,
          isScrollControlled: true,
          elevation: kDefaultHeavyElevation,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  completer.complete(0);
                  Navigator.of(context).maybePop();
                },
                leading: const Icon(Icons.play_arrow),
                title: Text(
                  Localization.instance.PLAY_ALL,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
              ListTile(
                onTap: () {
                  completer.complete(1);
                  Navigator.of(context).maybePop();
                },
                leading: const Icon(Icons.shuffle),
                title: Text(
                  Localization.instance.SHUFFLE,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
              ListTile(
                onTap: () {
                  completer.complete(2);
                  Navigator.of(context).maybePop();
                },
                leading: const Icon(Icons.file_open),
                title: Text(
                  Localization.instance.OPEN_FILE_OR_URL,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
              ListTile(
                onTap: () {
                  completer.complete(3);
                  Navigator.of(context).maybePop();
                },
                leading: const Icon(Icons.label),
                title: Text(
                  Localization.instance.EDIT_TAGS,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
              ListTile(
                onTap: () {
                  completer.complete(4);
                  Navigator.of(context).maybePop();
                },
                leading: const Icon(Icons.settings),
                title: Text(
                  Localization.instance.SETTINGS,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
        completer.future.then((value) async {
          await Future.delayed(const Duration(milliseconds: 300));
          switch (value) {
            case 0:
              {
                await MediaPlayer.instance.open(mediaLibrary.tracks.map((e) => e.toPlayable()));
                break;
              }
            case 1:
              {
                MediaPlayer.instance.open(mediaLibrary.tracks.map((e) => e.toPlayable()), shuffle: true);
                break;
              }
            case 2:
              {
                final result = await pickResource(context, Localization.instance.OPEN_FILE_OR_URL);
                if (result != null) {
                  await Intent.instance.play(result);
                }
                break;
              }
            case 3:
              {
                context.read<SubscriptionNotifier>().accessSubscriptionFeature(context, () async {
                  final result = await pickFile(extensions: kDefaultSupportedFileTypes);
                  if (result != null) {
                    await context.push(Uri(path: '/$kTagEditorPath', queryParameters: {kTagEditorArgResource: result.path}).toString());
                  }
                });
                break;
              }
            case 4:
              {
                await context.push('/$kSettingsPath');
                break;
              }
          }
        });
      },
    );
  }
}
