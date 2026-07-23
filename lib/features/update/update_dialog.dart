import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/update/state/update_notifier.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> with ScrollControllerMixin {
  late final ScrollController _controller = getScrollController('update-dialog');

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateNotifier>(
      builder: (context, updateNotifier, _) {
        final release = updateNotifier.latestRelease;

        if (release == null) {
          return const SizedBox.shrink();
        }

        final desktopContentWidth = kDesktopCenteredLayoutWidth + 2 * 24.0;
        final mobileContentWidth = MediaQuery.sizeOf(context).width - 2 * 24.0;
        final contentWidth = isDesktop ? desktopContentWidth : mobileContentWidth;
        final contentHeight = MediaQuery.sizeOf(context).height * 0.5;

        final styleSheet = MarkdownStyleSheet(
          h1Padding: const EdgeInsets.symmetric(vertical: 4.0),
          h2Padding: const EdgeInsets.symmetric(vertical: 4.0),
          h3Padding: const EdgeInsets.symmetric(vertical: 4.0),
          h4Padding: const EdgeInsets.symmetric(vertical: 4.0),
          h5Padding: const EdgeInsets.symmetric(vertical: 4.0),
          h6Padding: const EdgeInsets.symmetric(vertical: 4.0),
        );

        return AlertDialog(
          clipBehavior: Clip.antiAlias,
          titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0),
          contentPadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Localization.instance.UPDATE_AVAILABLE,
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
              const SizedBox(height: 4.0),
              Text(
                release.name,
                style: Theme.of(context).dialogTheme.contentTextStyle,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1.0, thickness: 1.0),
              SizedBox(
                width: contentWidth,
                height: contentHeight,
                child: Markdown(
                  controller: _controller,
                  data: release.body,
                  padding: const EdgeInsets.all(24.0),
                  styleSheet: styleSheet,
                  onTapLink: (text, href, title) {
                    if (href != null) {
                      launchUrlString(href, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
              const Divider(height: 1.0, thickness: 1.0),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateNotifier.download();
                context.pop(true);
              },
              child: Text(Localization.instance.OK),
            ),
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(Localization.instance.CANCEL),
            ),
          ],
        );
      },
    );
  }
}
