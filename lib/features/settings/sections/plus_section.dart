import 'dart:async';
import 'package:flutter/material.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/settings/settings_section.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class PlusSection extends StatefulWidget {
  const PlusSection({super.key});

  @override
  State<PlusSection> createState() => _PlusSectionState();
}

class _PlusSectionState extends State<PlusSection> {
  Future<void> _onDeleteAccount() async {
    final subscriptionNotifier = context.read<SubscriptionNotifier>();
    final userNotifier = context.read<UserNotifier>();

    final email = userNotifier.session?.user.email;

    if (email == null) return;

    final result = await showConfirmation(
      context,
      Localization.instance.DELETE_YOUR_ACCOUNT,
      Localization.instance.DELETE_ACCOUNT_CONFIRMATION_DIALOG_SUBTITLE,
      positiveAction: Localization.instance.DELETE,
      negativeAction: Localization.instance.CANCEL,
    );

    if (!result) return;

    await subscriptionNotifier.deleteAccount();
    await userNotifier.logout();

    if (!mounted) return;

    await showMessage(
      context,
      Localization.instance.DELETE_YOUR_ACCOUNT,
      Localization.instance.DELETE_ACCOUNT_SUCCESS_DIALOG_SUBTITLE,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) {
        final crossfadeDuration = mediaPlayer.state.crossfadeDuration;
        return SettingsSection(
          title: 'Plus⁺',
          subtitle: Localization.instance.SETTINGS_SECTION_PLUS_SUBTITLE,
          contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
          children: [
            SubscriptionReveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Consumer<SubscriptionNotifier>(
                    builder: (context, notifier, child) {
                      final subscription = notifier.subscription;
                      if (subscription == null) {
                        return const SizedBox.shrink();
                      }
                      return ListItem(
                        leading: const CircleAvatar(
                          child: Icon(Icons.star),
                        ),
                        title: Localization.instance.LINKED_AS_X.replaceAll('"X"', notifier.subscription?.email ?? '~'),
                        subtitle: subscription.toLabel(context),
                      );
                    },
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '${Localization.instance.CROSSFADE_DURATION} ${crossfadeDuration.inSeconds}s',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    height: 64.0,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ScrollableSlider(
                      min: 2.0,
                      max: 30.0,
                      interval: 1.0,
                      stepSize: 1.0,
                      showLabels: true,
                      labelFormatterCallback: (value, _) {
                        if (value == MediaPlayer.kCrossfadeDefaultDuration.inSeconds) {
                          return '${MediaPlayer.kCrossfadeDefaultDuration.inSeconds}s';
                        } else if (value == MediaPlayer.kCrossfadeMinDuration.inSeconds) {
                          return '${MediaPlayer.kCrossfadeMinDuration.inSeconds}s';
                        } else if (value == MediaPlayer.kCrossfadeMaxDuration.inSeconds) {
                          return '${MediaPlayer.kCrossfadeMaxDuration.inSeconds}s';
                        }
                        return '';
                      },
                      value: crossfadeDuration.inSeconds.clamp(2.0, 30.0).toDouble(),
                      onChangeEnd: (value) => mediaPlayer.setCrossfadeDuration(Duration(seconds: value.round())),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ListItem(
                    trailing: Switch(
                      value: crossfadeDuration != Duration.zero,
                      onChanged: (value) => mediaPlayer.setCrossfadeDuration(value ? const Duration(seconds: 5) : Duration.zero),
                    ),
                    title: Localization.instance.CROSSFADE_BETWEEN_TRACKS,
                    onTap: () => mediaPlayer.setCrossfadeDuration(crossfadeDuration == Duration.zero ? const Duration(seconds: 5) : Duration.zero),
                  ),
                  ListItem(
                    trailing: Switch(
                      value: Configuration.instance.mediaLibraryArtistImages,
                      onChanged: (value) async {
                        await Configuration.instance.set(mediaLibraryArtistImages: value);
                        AsyncFileImage.clear();
                        setState(() {});
                      },
                    ),
                    title: Localization.instance.DISPLAY_ARTIST_IMAGES,
                    onTap: () async {
                      await Configuration.instance.set(mediaLibraryArtistImages: !Configuration.instance.mediaLibraryArtistImages);
                      AsyncFileImage.clear();
                      setState(() {});
                    },
                  ),
                  ListItem(
                    trailing: Consumer<SubscriptionNotifier>(
                      builder: (context, notifier, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Checkbox(
                            value: notifier.state is SubscriptionValid,
                            onChanged: (_) {},
                          ),
                        );
                      },
                    ),
                    title: Localization.instance.TAG_EDITOR,
                  ),
                  ListItem(
                    trailing: Consumer<SubscriptionNotifier>(
                      builder: (context, notifier, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Checkbox(
                            value: notifier.state is SubscriptionValid,
                            onChanged: (_) {},
                          ),
                        );
                      },
                    ),
                    title: Localization.instance.LYRICS_TRANSLATION,
                  ),
                ],
              ),
            ),
            Consumer<UserNotifier>(
              builder: (context, notifier, child) {
                if (notifier.session?.user.email == null) {
                  return const SizedBox.shrink();
                }
                return ListItem(
                  title: Localization.instance.DELETE_YOUR_ACCOUNT,
                  onTap: _onDeleteAccount,
                  titleStyle: const TextStyle(color: Colors.red),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
