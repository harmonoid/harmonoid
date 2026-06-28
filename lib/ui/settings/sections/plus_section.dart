import 'package:flutter/material.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/duration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/settings/settings_section.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/debouncer.dart';
import 'package:harmonoid/utils/widgets.dart';

class PlusSection extends StatefulWidget {
  const PlusSection({super.key});

  @override
  State<PlusSection> createState() => _PlusSectionState();
}

class _PlusSectionState extends State<PlusSection> {
  final Debouncer kCrossfadeDurationDebouncer = Debouncer(timeout: const Duration(seconds: 3));

  Duration? _pendingCrossfadeDuration;

  Duration _getCrossfadeDuration(MediaPlayer mediaPlayer) {
    return _pendingCrossfadeDuration ?? mediaPlayer.state.crossfadeDuration;
  }

  void _setCrossfadeDuration(
    MediaPlayer mediaPlayer,
    Duration duration, {
    bool debounce = false,
  }) {
    if (debounce) {
      setState(() => _pendingCrossfadeDuration = duration);
      kCrossfadeDurationDebouncer.run(() async {
        await mediaPlayer.setCrossfadeDuration(duration);
        if (mounted && _pendingCrossfadeDuration == duration) {
          setState(() => _pendingCrossfadeDuration = null);
        }
      });
      return;
    }

    kCrossfadeDurationDebouncer.cancel();
    setState(() => _pendingCrossfadeDuration = null);
    mediaPlayer.setCrossfadeDuration(duration);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) {
        final crossfadeDuration = _getCrossfadeDuration(mediaPlayer);
        return SettingsSection(
          title: 'Plus⁺',
          subtitle: Localization.instance.SETTINGS_SECTION_PLUS_SUBTITLE,
          contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
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
                onChanged: (value) => _setCrossfadeDuration(
                  mediaPlayer,
                  Duration(seconds: value.round()),
                  debounce: true,
                ),
                onScrolledUp: () => _setCrossfadeDuration(
                  mediaPlayer,
                  (crossfadeDuration + const Duration(seconds: 1)).clamp(MediaPlayer.kCrossfadeMinDuration, MediaPlayer.kCrossfadeMaxDuration),
                  debounce: true,
                ),
                onScrolledDown: () => _setCrossfadeDuration(
                  mediaPlayer,
                  (crossfadeDuration - const Duration(seconds: 1)).clamp(MediaPlayer.kCrossfadeMinDuration, MediaPlayer.kCrossfadeMaxDuration),
                  debounce: true,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            ListItem(
              trailing: Switch(
                value: crossfadeDuration != Duration.zero,
                onChanged: (value) => _setCrossfadeDuration(mediaPlayer, value ? const Duration(seconds: 5) : Duration.zero),
              ),
              title: Localization.instance.CROSSFADE_BETWEEN_TRACKS,
              onTap: () => _setCrossfadeDuration(mediaPlayer, crossfadeDuration == Duration.zero ? const Duration(seconds: 5) : Duration.zero),
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
          childrenBuilder: (child) => SubscriptionReveal(child: child),
        );
      },
    );
  }
}
