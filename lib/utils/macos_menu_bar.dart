import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';

class MacOSMenuBar extends StatelessWidget {
  final Widget child;

  const MacOSMenuBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isMacOS) return child;
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: kTitle,
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: Localization.instance.ABOUT_HARMONOID,
                  onSelected: () {
                    while (router.canPop()) {
                      router.pop();
                    }
                    router.push('/$kAboutPath');
                  },
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: Localization.instance.SETTINGS,
                  shortcut: const CharacterActivator(',', meta: true),
                  onSelected: () {
                    while (router.canPop()) {
                      router.pop();
                    }
                    router.push('/$kSettingsPath');
                  },
                ),
                PlatformMenuItem(
                  label: Localization.instance.REFRESH,
                  onSelected: () {
                    MediaLibrary.instance.refresh();
                  },
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: Localization.instance.QUIT_HARMONOID,
                  shortcut: const CharacterActivator('Q', meta: true),
                  onSelected: () {
                    SystemNavigator.pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      child: child,
    );
  }
}
