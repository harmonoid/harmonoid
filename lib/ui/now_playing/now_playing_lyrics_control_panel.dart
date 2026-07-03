import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/models/language.dart';
import 'package:harmonoid/state/lyrics/lyrics_notifier.dart';
import 'package:harmonoid/ui/now_playing/now_playing_bar.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/slide_on_enter.dart';

class NowPlayingLyricsControlPanel extends StatefulWidget {
  const NowPlayingLyricsControlPanel({super.key});

  static const double kDesktopWidth = 300.0;
  static const double kDesktopMargin = 16.0;

  // TODO: Move this back into the lyrics control panel flow once the panel grows beyond translation.
  static Future<void> showTranslationLanguageSelection(BuildContext context, {bool subscription = false}) async {
    Future<void> open() async {
      final notifier = context.read<LyricsNotifier>();
      final languages = notifier.translationLanguages;
      final values = [Language(code: '', name: Localization.instance.OFF), ...languages];
      final selected = notifier.translationLanguage;
      final result = await showSelection(
        context,
        Localization.instance.TRANSLATION,
        values,
        selected,
        (language) => language.name,
      );
      if (result == null) return;
      await notifier.setTranslationLanguage(result);
    }

    if (subscription) {
      await context.read<SubscriptionNotifier>().accessSubscriptionFeature(context, open);
    } else {
      await open();
    }
  }

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
  Widget _buildDesktopLyricsVisibility(BuildContext context) {
    return Consumer<LyricsNotifier>(
      builder: (context, notifier, _) {
        return InkWell(
          onTap: () => notifier.setDesktopNowPlayingLyrics(!notifier.desktopNowPlayingLyrics),
          child: Container(
            height: 48.0,
            padding: const EdgeInsets.only(left: 20.0, right: 16.0),
            child: Row(
              children: [
                Text(
                  Localization.instance.SHOW_LYRICS,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 16.0),
                if (notifier.lyricsLoading) const SizedBox.square(dimension: 12.0, child: CircularProgressIndicator()),
                const Spacer(),
                const SizedBox(width: 8.0),
                Switch(
                  value: notifier.desktopNowPlayingLyrics,
                  onChanged: (value) => notifier.setDesktopNowPlayingLyrics(value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranslationLanguage(BuildContext context) {
    return Consumer<LyricsNotifier>(
      builder: (context, notifier, _) {
        final selected = notifier.translationLanguage;
        final selectedName = context.read<SubscriptionNotifier>().state is! SubscriptionValid || selected.code.isEmpty ? Localization.instance.OFF : selected.name;
        return SubscriptionReveal(
          child: InkWell(
            onTap: () => NowPlayingLyricsControlPanel.showTranslationLanguageSelection(context),
            child: Container(
              height: 48.0,
              padding: const EdgeInsets.only(left: 20.0, right: 16.0),
              child: Row(
                children: [
                  Text(
                    Localization.instance.TRANSLATION,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 16.0),
                  if (notifier.translationLoading) const SizedBox.square(dimension: 12.0, child: CircularProgressIndicator()),
                  const Spacer(),
                  const SizedBox(width: 8.0),
                  ActionChip(
                    elevation: 0.0,
                    pressElevation: 0.0,
                    onPressed: () => NowPlayingLyricsControlPanel.showTranslationLanguageSelection(context),
                    label: Text(selectedName),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return _buildTranslationLanguage(context);
  }

  Widget _buildDesktopLayout(BuildContext context) {
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
            Padding(
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
            ),
            const SizedBox(height: 12.0),
            const Divider(height: 1.0, thickness: 1.0),
            _buildDesktopLyricsVisibility(context),
            const Divider(height: 1.0, thickness: 1.0),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: _buildContent(context),
        ),
        const Divider(height: 1.0, thickness: 1.0),
        SizedBox(height: 16.0 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    throw UnimplementedError();
  }
}
