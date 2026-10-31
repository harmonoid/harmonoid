import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/features/now_playing/now_playing_bar.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/localization/models/language.dart';
import 'package:harmonoid/routing/router.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/state/lyrics/lyrics_notifier.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class NowPlayingLyricsControlPanel extends StatefulWidget {
  const NowPlayingLyricsControlPanel({super.key});

  static const double kDesktopWidth = 300.0;
  static const double kDesktopMargin = 16.0;

  static Future<void> show(BuildContext context, {Rect? anchorBounds}) async {
    final path = context.location.split('/').last;
    if (isDesktop) {
      await showDialog(
        context: context,
        useRootNavigator: true,
        barrierColor: Colors.transparent,
        builder: (context) {
          final size = MediaQuery.sizeOf(context);
          final bounds = path == kNowPlayingPath ? anchorBounds : null;
          final maxLeft = size.width > kDesktopWidth + kDesktopMargin * 2 ? size.width - kDesktopWidth - kDesktopMargin : kDesktopMargin;
          final left = bounds == null ? maxLeft : (bounds.center.dx - kDesktopWidth / 2).clamp(kDesktopMargin, maxLeft).toDouble();
          final bottom = bounds == null ? kDesktopMargin + (path == kNowPlayingPath ? 0.0 : NowPlayingBar.height) : size.height - bounds.top + 8.0;
          return SlideOnEnter(
            child: Stack(
              children: [
                Positioned(
                  left: left,
                  bottom: bottom,
                  child: const NowPlayingLyricsControlPanel(),
                ),
              ],
            ),
          );
        },
      );
    }
    if (isTablet) {
      throw UnimplementedError();
    }
    if (isMobile) {
      await showModalBottomSheet(
        context: context,
        showDragHandle: isMaterial3OrGreater,
        elevation: kDefaultHeavyElevation,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => const Padding(
          padding: EdgeInsets.all(16.0),
          child: NowPlayingLyricsControlPanel(),
        ),
      );
    }
  }

  @override
  State<NowPlayingLyricsControlPanel> createState() => NowPlayingLyricsControlPanelState();
}

class NowPlayingLyricsControlPanelState extends State<NowPlayingLyricsControlPanel> {
  Future<void> _cycleTrackLyricsVisibility() async {
    final notifier = context.read<LyricsNotifier>();
    final values = [(null,), (true,), (false,)];
    final selected = (notifier.desktopNowPlayingLyricsTrack,);
    final result = await showSelection<(bool?,)>(
      context,
      Localization.instance.LYRICS,
      values,
      selected,
      (language) => switch (language) {
        (null,) => Localization.instance.GLOBAL,
        (true,) => Localization.instance.ON,
        (false,) => Localization.instance.OFF,
      },
    );
    if (result == null) return;
    notifier.setDesktopNowPlayingLyricsTrack(result.$1);
  }

  Future<void> _showTrackTranslationLanguageSelection() async {
    final notifier = context.read<LyricsNotifier>();
    final global = Language(code: '__global__', name: Localization.instance.GLOBAL);
    final off = Language(code: '', name: Localization.instance.OFF);
    final values = [global, off, ...notifier.translationLanguages];
    final selected = notifier.translationLanguageTrack ?? global;
    final result = await showSelection<Language>(
      context,
      Localization.instance.TRANSLATION,
      values,
      selected,
      (language) => language.name,
    );
    if (result == null) return;
    await notifier.setTranslationLanguageTrack(result == global ? null : result);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    Localization.instance.LYRICS_CONTROL_PANEL,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Text(
                    Localization.instance.BETA.uppercase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
          Consumer<LyricsNotifier>(
            builder: (context, notifier, _) {
              final loading = notifier.lyricsLoading || notifier.translationLoading;
              return IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 28.0, height: 28.0),
                iconSize: 18.0,
                tooltip: Localization.instance.REFRESH,
                onPressed: loading ? null : () => notifier.refresh(),
                icon: const Icon(Icons.refresh),
              );
            },
          ),
          const SizedBox(width: 8.0),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28.0, height: 28.0),
            iconSize: 18.0,
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackLyricsVisibility() {
    return Consumer<LyricsNotifier>(
      builder: (context, notifier, _) {
        final selected = notifier.desktopNowPlayingLyrics;
        final value = notifier.desktopNowPlayingLyricsTrack == null
            ? '${Localization.instance.GLOBAL} (${selected ? Localization.instance.ON : Localization.instance.OFF})'
            : selected
            ? Localization.instance.ON
            : Localization.instance.OFF;
        return InkWell(
          onTap: () => _cycleTrackLyricsVisibility(),
          child: Container(
            height: 48.0,
            padding: isDesktop ? const EdgeInsets.only(left: 20.0, right: 16.0) : EdgeInsets.zero,
            child: Row(
              children: [
                Text(
                  Localization.instance.LYRICS,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 16.0),
                if (notifier.lyricsLoading) const SizedBox.square(dimension: 12.0, child: CircularProgressIndicator()),
                const Spacer(),
                const SizedBox(width: 8.0),
                ActionChip(
                  elevation: 0.0,
                  pressElevation: 0.0,
                  onPressed: () => _cycleTrackLyricsVisibility(),
                  label: Text(value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackTranslationLanguage() {
    return Consumer2<LyricsNotifier, SubscriptionNotifier>(
      builder: (context, lyricsNotifier, subscriptionNotifier, _) {
        final selected = lyricsNotifier.translationLanguage;
        final selectedName = subscriptionNotifier.state is! SubscriptionValid || selected.code.isEmpty ? Localization.instance.OFF : selected.name;
        final value = lyricsNotifier.translationLanguageTrack == null ? '${Localization.instance.GLOBAL} ($selectedName)' : selectedName;
        return SubscriptionReveal(
          blur: false,
          child: InkWell(
            onTap: () => _showTrackTranslationLanguageSelection(),
            child: Container(
              height: 48.0,
              padding: isDesktop ? const EdgeInsets.only(left: 20.0, right: 16.0) : EdgeInsets.zero,
              child: Row(
                children: [
                  Text(
                    Localization.instance.TRANSLATION,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 16.0),
                  if (lyricsNotifier.translationLoading) const SizedBox.square(dimension: 12.0, child: CircularProgressIndicator()),
                  const Spacer(),
                  const SizedBox(width: 8.0),
                  ActionChip(
                    elevation: 0.0,
                    pressElevation: 0.0,
                    onPressed: () => _showTrackTranslationLanguageSelection(),
                    label: Text(value),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackOffset() {
    return Consumer<LyricsNotifier>(
      builder: (context, notifier, _) {
        final offset = (notifier.offset?.inMilliseconds ?? 0) / 1000.0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 36.0,
              padding: isDesktop ? const EdgeInsets.only(left: 20.0, right: 16.0) : EdgeInsets.zero,
              child: Row(
                children: [
                  Text(
                    Localization.instance.OFFSET,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  Text(
                    offset == 0.0 ? '0s' : '${offset > 0.0 ? '+' : '-'}${offset.abs().toStringAsFixed(1)}s',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: isDesktop ? const EdgeInsets.symmetric(horizontal: 12.0) : EdgeInsets.zero,
              child: ScrollableSlider(
                min: -10.0,
                max: 10.0,
                value: offset.clamp(-10.0, 10.0),
                interval: 0.5,
                stepSize: 0.5,
                showLabels: false,
                onChanged: notifier.lyrics.isEmpty
                    ? null
                    : (value) async {
                        await notifier.setOffset(Duration(milliseconds: ((value as double) * 1000.0).round()));
                      },
              ),
            ),
            const SizedBox(height: 4.0),
          ],
        );
      },
    );
  }

  Widget _buildHint() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localization.instance.LYRICS_TRACK_SETTINGS_HINT,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TappableText(
          text: [
            TappableTextData(text: Localization.instance.LYRICS_TRACK_SETTINGS_PREFIX),
            TappableTextData(
              onTap: () {
                context.pop();
                router.pushReplacement('/$kSettingsPath');
              },
              text: Localization.instance.LYRICS_TRACK_SETTINGS_TARGET,
            ),
          ],
          separator: ' ',
          style: Theme.of(context).textTheme.bodySmall,
          ignoring: false,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: kDefaultHeavyElevation,
      child: Container(
        width: 300.0,
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12.0),
            const Divider(height: 1.0, thickness: 1.0),
            _buildTrackLyricsVisibility(),
            const Divider(height: 1.0, thickness: 1.0),
            _buildTrackTranslationLanguage(),
            const Divider(height: 1.0, thickness: 1.0),
            _buildTrackOffset(),
            const Divider(height: 1.0, thickness: 1.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
              child: _buildHint(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTrackTranslationLanguage(),
        _buildTrackOffset(),
        const SizedBox(height: 8.0),
        const Divider(height: 1.0, thickness: 1.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: _buildHint(),
        ),
        SizedBox(height: 16.0 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout();
    }
    if (isTablet) {
      return _buildTabletLayout();
    }
    if (isMobile) {
      return _buildMobileLayout();
    }
    throw UnimplementedError();
  }
}
