import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/models/language.dart';
import 'package:harmonoid/state/lyrics_notifier.dart';
import 'package:harmonoid/ui/now_playing/now_playing_bar.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/slide_on_enter.dart';

class NowPlayingLyricsControlPanel extends StatefulWidget {
  const NowPlayingLyricsControlPanel({super.key});

  static Future<void> show(BuildContext context) async {
    final path = context.location.split('/').last;
    if (isDesktop) {
      await showDialog(
        context: context,
        useRootNavigator: true,
        barrierColor: Colors.transparent,
        builder: (context) => SlideOnEnter(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16.0,
                16.0,
                16.0,
                16.0 + (path == kNowPlayingPath ? 0.0 : NowPlayingBar.height),
              ),
              child: const NowPlayingLyricsControlPanel(),
            ),
          ),
        ),
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
  Future<void> _openLanguageSelection() async {
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

  Widget _buildTranslationLanguage(BuildContext context) {
    return Consumer<LyricsNotifier>(
      builder: (context, notifier, _) {
        final selected = notifier.translationLanguage;
        final selectedName = context.read<SubscriptionNotifier>().state is! SubscriptionValid || selected.code.isEmpty ? Localization.instance.OFF : selected.name;
        return SubscriptionReveal(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  Localization.instance.TRANSLATION,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(width: 8.0),
              ActionChip(
                elevation: 0.0,
                pressElevation: 0.0,
                onPressed: _openLanguageSelection,
                label: Text(selectedName),
              ),
            ],
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
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localization.instance.LYRICS_CONTROL_PANEL,
                    style: Theme.of(context).textTheme.titleMedium,
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
            const SizedBox(height: 12.0),
            const Divider(height: 1.0, thickness: 1.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: _buildContent(context),
            ),
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
