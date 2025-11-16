import 'package:flutter/material.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/duration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/media_library/artists/state/artist_image_notifier.dart';
import 'package:harmonoid/ui/settings/settings_section.dart';
import 'package:harmonoid/utils/widgets.dart';

class PlusSection extends StatefulWidget {
  const PlusSection({super.key});

  @override
  State<PlusSection> createState() => _PlusSectionState();
}

class _PlusSectionState extends State<PlusSection> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) {
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
                  subtitle: '${subscription.type.toLabel()} (${subscription.source.toLabel()})',
                );
              },
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${Localization.instance.CROSSFADE_DURATION} ${mediaPlayer.state.crossfadeDuration.inSeconds}s',
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
                  if (value == MediaPlayer.kDefaultCrossfadeDuration.inSeconds) {
                    return '${MediaPlayer.kDefaultCrossfadeDuration.inSeconds}s';
                  } else if (value == MediaPlayer.kMinCrossfadeDuration.inSeconds) {
                    return '${MediaPlayer.kMinCrossfadeDuration.inSeconds}s';
                  } else if (value == MediaPlayer.kMaxCrossfadeDuration.inSeconds) {
                    return '${MediaPlayer.kMaxCrossfadeDuration.inSeconds}s';
                  }
                  return '';
                },
                value: mediaPlayer.state.crossfadeDuration.inSeconds.clamp(2.0, 30.0).toDouble(),
                onChanged: mediaPlayer.state.crossfadeDuration != Duration.zero ? (value) => mediaPlayer.setCrossfadeDuration(Duration(seconds: value.round())) : null,
                onScrolledUp: () => mediaPlayer.setCrossfadeDuration(
                  (mediaPlayer.state.crossfadeDuration + const Duration(seconds: 1)).clamp(MediaPlayer.kMinCrossfadeDuration, MediaPlayer.kMaxCrossfadeDuration),
                ),
                onScrolledDown: () => mediaPlayer.setCrossfadeDuration(
                  (mediaPlayer.state.crossfadeDuration - const Duration(seconds: 1)).clamp(MediaPlayer.kMinCrossfadeDuration, MediaPlayer.kMaxCrossfadeDuration),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            ListItem(
              trailing: Switch(
                value: mediaPlayer.state.crossfadeDuration != Duration.zero,
                onChanged: (value) => mediaPlayer.setCrossfadeDuration(value ? const Duration(seconds: 5) : Duration.zero),
              ),
              title: Localization.instance.CROSSFADE_BETWEEN_TRACKS,
              onTap: () => mediaPlayer.setCrossfadeDuration(mediaPlayer.state.crossfadeDuration == Duration.zero ? const Duration(seconds: 5) : Duration.zero),
            ),
            ListItem(
              trailing: Switch(
                value: Configuration.instance.mediaLibraryArtistImages,
                onChanged: (value) async {
                  await Configuration.instance.set(mediaLibraryArtistImages: value);
                  context.read<ArtistImageNotifier>().clearCache();
                  setState(() {});
                },
              ),
              title: Localization.instance.DISPLAY_ARTIST_IMAGES,
              onTap: () async {
                await Configuration.instance.set(mediaLibraryArtistImages: !Configuration.instance.mediaLibraryArtistImages);
                context.read<ArtistImageNotifier>().clearCache();
                setState(() {});
              },
            ),
          ],
          childrenBuilder: (child) => SubscriptionReveal(child: child),
        );
      },
    );
  }
}
