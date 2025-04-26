import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lastfm/lastfm.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/settings/settings_section.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class LastfmSection extends StatefulWidget {
  const LastfmSection({super.key});

  @override
  State<LastfmSection> createState() => _LastfmSectionState();
}

class _LastfmSectionState extends State<LastfmSection> {
  static const String _kLastFmSvg =
      '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>Last.fm</title><path d="M10.584 17.21l-.88-2.392s-1.43 1.594-3.573 1.594c-1.897 0-3.244-1.649-3.244-4.288 0-3.382 1.704-4.591 3.381-4.591 2.42 0 3.189 1.567 3.849 3.574l.88 2.749c.88 2.666 2.529 4.81 7.285 4.81 3.409 0 5.718-1.044 5.718-3.793 0-2.227-1.265-3.381-3.63-3.931l-1.758-.385c-1.21-.275-1.567-.77-1.567-1.595 0-.934.742-1.484 1.952-1.484 1.32 0 2.034.495 2.144 1.677l2.749-.33c-.22-2.474-1.924-3.492-4.729-3.492-2.474 0-4.893.935-4.893 3.932 0 1.87.907 3.051 3.189 3.601l1.87.44c1.402.33 1.869.907 1.869 1.704 0 1.017-.99 1.43-2.86 1.43-2.776 0-3.93-1.457-4.59-3.464l-.907-2.75c-1.155-3.573-2.997-4.893-6.653-4.893C2.144 5.333 0 7.89 0 12.233c0 4.18 2.144 6.434 5.993 6.434 3.106 0 4.591-1.457 4.591-1.457z"/></svg>';

  final LastFm _instance = MediaPlayer.instance.lastFm;

  bool get _connected => _instance.session?.key.isNotEmpty ?? false;

  Future<void> _connect() async {
    BuildContext? ctx;
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        ctx = context;
        return const Center(child: CircularProgressIndicator());
      },
    );

    await _instance.authenticate(launchUrl);
    await Configuration.instance.set(lastfmSession: _instance.session);

    setState(() {});
    ctx?.pop();
  }

  Future<void> _disconnect() async {
    final result = await showConfirmation(
      context,
      Localization.instance.CONNECTED,
      Localization.instance.LINKED_AS_X.replaceAll('"X"', _instance.session?.name ?? '~'),
      positiveAction: Localization.instance.DISCONNECT,
      negativeAction: Localization.instance.CANCEL,
    );
    if (result) {
      await _instance.clearSession();
      await Configuration.instance.set(lastfmSession: const Session(name: '', key: ''));
      setState(() {});
    }
  }

  void _onTap() {
    if (_connected) {
      _disconnect();
    } else {
      _connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_LASTFM_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_LASTFM_SUBTITLE,
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [
        ListItem(
          leading: CircleAvatar(
            child: SvgPicture.string(
              _kLastFmSvg,
              width: 24.0,
              height: 24.0,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: _connected ? Localization.instance.CONNECTED : Localization.instance.CONNECT,
          subtitle: _connected ? Localization.instance.LINKED_AS_X.replaceAll('"X"', _instance.session?.name ?? '~') : Localization.instance.LINK_YOUR_ACCOUNT,
          onTap: _onTap,
        ),
      ],
    );
  }
}
