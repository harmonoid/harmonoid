import 'package:discord_social_sdk/discord_social_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lastfm/lastfm.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/discord_rpc_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/lastfm_mixin.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/settings/settings_section.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class ConnectionsSection extends StatefulWidget {
  const ConnectionsSection({super.key});

  @override
  State<ConnectionsSection> createState() => _ConnectionsSectionState();
}

class _ConnectionsSectionState extends State<ConnectionsSection> {
  static const String _kLastFmSvg =
      '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>Last.fm</title><path d="M10.584 17.21l-.88-2.392s-1.43 1.594-3.573 1.594c-1.897 0-3.244-1.649-3.244-4.288 0-3.382 1.704-4.591 3.381-4.591 2.42 0 3.189 1.567 3.849 3.574l.88 2.749c.88 2.666 2.529 4.81 7.285 4.81 3.409 0 5.718-1.044 5.718-3.793 0-2.227-1.265-3.381-3.63-3.931l-1.758-.385c-1.21-.275-1.567-.77-1.567-1.595 0-.934.742-1.484 1.952-1.484 1.32 0 2.034.495 2.144 1.677l2.749-.33c-.22-2.474-1.924-3.492-4.729-3.492-2.474 0-4.893.935-4.893 3.932 0 1.87.907 3.051 3.189 3.601l1.87.44c1.402.33 1.869.907 1.869 1.704 0 1.017-.99 1.43-2.86 1.43-2.776 0-3.93-1.457-4.59-3.464l-.907-2.75c-1.155-3.573-2.997-4.893-6.653-4.893C2.144 5.333 0 7.89 0 12.233c0 4.18 2.144 6.434 5.993 6.434 3.106 0 4.591-1.457 4.591-1.457z"/></svg>';
  static const String _kDiscordSvg =
      '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>Discord</title><path d="M20.317 4.3698a19.7913 19.7913 0 00-4.8851-1.5152.0741.0741 0 00-.0785.0371c-.211.3753-.4447.8648-.6083 1.2495-1.8447-.2762-3.68-.2762-5.4868 0-.1636-.3933-.4058-.8742-.6177-1.2495a.077.077 0 00-.0785-.037 19.7363 19.7363 0 00-4.8852 1.515.0699.0699 0 00-.0321.0277C.5334 9.0458-.319 13.5799.0992 18.0578a.0824.0824 0 00.0312.0561c2.0528 1.5076 4.0413 2.4228 5.9929 3.0294a.0777.0777 0 00.0842-.0276c.4616-.6304.8731-1.2952 1.226-1.9942a.076.076 0 00-.0416-.1057c-.6528-.2476-1.2743-.5495-1.8722-.8923a.077.077 0 01-.0076-.1277c.1258-.0943.2517-.1923.3718-.2914a.0743.0743 0 01.0776-.0105c3.9278 1.7933 8.18 1.7933 12.0614 0a.0739.0739 0 01.0785.0095c.1202.099.246.1981.3728.2924a.077.077 0 01-.0066.1276 12.2986 12.2986 0 01-1.873.8914.0766.0766 0 00-.0407.1067c.3604.698.7719 1.3628 1.225 1.9932a.076.076 0 00.0842.0286c1.961-.6067 3.9495-1.5219 6.0023-3.0294a.077.077 0 00.0313-.0552c.5004-5.177-.8382-9.6739-3.5485-13.6604a.061.061 0 00-.0312-.0286zM8.02 15.3312c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9555-2.4189 2.157-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.9555 2.4189-2.1569 2.4189zm7.9748 0c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9554-2.4189 2.1569-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.946 2.4189-2.1568 2.4189Z"/></svg>';

  final LastFm? _lastFm = MediaPlayer.instance.mixinRegistry.get<LastFmMixin>()?.lastFm;
  final DiscordSocialClient? _discordClient = MediaPlayer.instance.mixinRegistry.get<DiscordRpcMixin>()?.client;

  bool get _lastFmConnected => _lastFm?.session?.key.isNotEmpty ?? false;
  bool get _discordConnected => Configuration.instance.discordTokens.accessToken.isNotEmpty;

  void Function() _showProgressDialog() {
    BuildContext? ctx;

    void pop() {
      if (ctx?.mounted == true) {
        ctx?.pop();
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        ctx = context;
        return Scaffold(
          backgroundColor: Colors.black12,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 32.0),
                TextButton(
                  onPressed: pop,
                  child: Text(
                    Localization.instance.CANCEL,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return pop;
  }

  Future<void> _connectLastFm() async {
    final pop = _showProgressDialog();

    await _lastFm?.authenticate(launchUrl);
    await Configuration.instance.set(lastfmSession: _lastFm?.session);

    setState(() {});
    pop();
  }

  Future<void> _disconnectLastFm() async {
    final result = await showConfirmation(
      context,
      Localization.instance.CONNECTED,
      Localization.instance.LINKED_AS_X.replaceAll('"X"', _lastFm?.session?.name ?? '~'),
      positiveAction: Localization.instance.DISCONNECT,
      negativeAction: Localization.instance.CANCEL,
    );
    if (result) {
      await _lastFm?.clearSession();
      await Configuration.instance.set(
        lastfmSession: const Session(name: '', key: ''),
      );
      setState(() {});
    }
  }

  Future<void> _connectDiscord() async {
    final pop = _showProgressDialog();

    final client = _discordClient;

    if (client == null) return;

    try {
      final code = await client.authorize();
      final tokens = await client.fetchToken(code: code.code, codeVerifier: code.codeVerifier, redirectUri: code.redirectUri);

      await client.updateToken(tokenType: tokens.tokenType, token: tokens.accessToken);
      await client.connect();

      final user = await client.fetchCurrentUser(tokenType: tokens.tokenType, token: tokens.accessToken);

      await Configuration.instance.set(discordTokens: tokens, discordUsername: user.name);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      client.disconnect();
    }

    setState(() {});
    pop();
  }

  Future<void> _disconnectDiscord() async {
    final result = await showConfirmation(
      context,
      Localization.instance.CONNECTED,
      Localization.instance.LINKED_AS_X.replaceAll('"X"', Configuration.instance.discordUsername.isEmpty ? '~' : Configuration.instance.discordUsername),
      positiveAction: Localization.instance.DISCONNECT,
      negativeAction: Localization.instance.CANCEL,
    );
    if (result) {
      _discordClient?.disconnect();
      await Configuration.instance.set(
        discordTokens: const DiscordTokens(
          accessToken: '',
          refreshToken: '',
          tokenType: DiscordTokenType.bearer,
          expiresIn: Duration.zero,
          scopes: [],
        ),
        discordUsername: '',
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final discordUsername = Configuration.instance.discordUsername;
    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_CONNECTIONS_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_CONNECTIONS_SUBTITLE,
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [
        ListItem(
          leading: CircleAvatar(
            child: SvgPicture.string(
              _kLastFmSvg,
              width: 24.0,
              height: 24.0,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: 'Last.fm',
          subtitle: _lastFmConnected ? Localization.instance.LINKED_AS_X.replaceAll('"X"', _lastFm?.session?.name ?? '~') : Localization.instance.LINK_YOUR_ACCOUNT,
          onTap: _lastFmConnected ? _disconnectLastFm : _connectLastFm,
        ),
        if (_discordClient != null)
          ListItem(
            leading: CircleAvatar(
              child: SvgPicture.string(
                _kDiscordSvg,
                width: 24.0,
                height: 24.0,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: 'Discord',
            subtitle: _discordConnected ? Localization.instance.LINKED_AS_X.replaceAll('"X"', discordUsername.isEmpty ? '~' : discordUsername) : Localization.instance.LINK_YOUR_ACCOUNT,
            onTap: _discordConnected ? _disconnectDiscord : _connectDiscord,
          ),
      ],
    );
  }
}
