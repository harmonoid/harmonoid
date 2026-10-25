import 'package:discord_social_sdk/discord_social_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/discord_rpc_mixin.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/settings/settings_section.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class DiscordSection extends StatefulWidget {
  const DiscordSection({super.key});

  @override
  State<DiscordSection> createState() => _DiscordSectionState();
}

class _DiscordSectionState extends State<DiscordSection> {
  static const String _kDiscordSvg =
      '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>Discord</title><path d="M20.317 4.3698a19.7913 19.7913 0 00-4.8851-1.5152.0741.0741 0 00-.0785.0371c-.211.3753-.4447.8648-.6083 1.2495-1.8447-.2762-3.68-.2762-5.4868 0-.1636-.3933-.4058-.8742-.6177-1.2495a.077.077 0 00-.0785-.037 19.7363 19.7363 0 00-4.8852 1.515.0699.0699 0 00-.0321.0277C.5334 9.0458-.319 13.5799.0992 18.0578a.0824.0824 0 00.0312.0561c2.0528 1.5076 4.0413 2.4228 5.9929 3.0294a.0777.0777 0 00.0842-.0276c.4616-.6304.8731-1.2952 1.226-1.9942a.076.076 0 00-.0416-.1057c-.6528-.2476-1.2743-.5495-1.8722-.8923a.077.077 0 01-.0076-.1277c.1258-.0943.2517-.1923.3718-.2914a.0743.0743 0 01.0776-.0105c3.9278 1.7933 8.18 1.7933 12.0614 0a.0739.0739 0 01.0785.0095c.1202.099.246.1981.3728.2924a.077.077 0 01-.0066.1276 12.2986 12.2986 0 01-1.873.8914.0766.0766 0 00-.0407.1067c.3604.698.7719 1.3628 1.225 1.9932a.076.076 0 00.0842.0286c1.961-.6067 3.9495-1.5219 6.0023-3.0294a.077.077 0 00.0313-.0552c.5004-5.177-.8382-9.6739-3.5485-13.6604a.061.061 0 00-.0312-.0286zM8.02 15.3312c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9555-2.4189 2.157-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.9555 2.4189-2.1569 2.4189zm7.9748 0c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9554-2.4189 2.1569-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.946 2.4189-2.1568 2.4189Z"/></svg>';

  final DiscordSocialClient? _client = MediaPlayer.instance.mixinRegistry.get<DiscordRpcMixin>()?.client;

  bool get _connected => Configuration.instance.discordTokens.accessToken.isNotEmpty;

  Future<void> _connect() async {
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

    final client = _client;

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

  Future<void> _disconnect() async {
    final result = await showConfirmation(
      context,
      Localization.instance.CONNECTED,
      Localization.instance.SETTINGS_SECTION_DISCORD_SUBTITLE,
      positiveAction: Localization.instance.DISCONNECT,
      negativeAction: Localization.instance.CANCEL,
    );
    if (result) {
      _client?.disconnect();
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

  void _onTap() {
    if (_connected) {
      _disconnect();
    } else {
      _connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      return const SizedBox.shrink();
    }
    final username = Configuration.instance.discordUsername;
    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_DISCORD_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_DISCORD_SUBTITLE,
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [
        ListItem(
          leading: CircleAvatar(
            child: SvgPicture.string(
              _kDiscordSvg,
              width: 24.0,
              height: 24.0,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: _connected ? Localization.instance.CONNECTED : Localization.instance.CONNECT,
          subtitle: _connected ? Localization.instance.LINKED_AS_X.replaceAll('"X"', username.isEmpty ? '~' : username) : Localization.instance.LINK_YOUR_ACCOUNT,
          onTap: _onTap,
        ),
      ],
    );
  }
}
