import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/update/state/update_notifier.dart';

class UpdateButton extends StatelessWidget {
  const UpdateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateNotifier>(
      builder: (context, updateNotifier, _) {
        if (!updateNotifier.updateAvailable) {
          return const SizedBox.shrink();
        }
        return IconButton(
          onPressed: updateNotifier.check,
          tooltip: Localization.instance.UPDATE_AVAILABLE,
          icon: const Icon(Icons.download),
          iconSize: 20.0,
          splashRadius: 18.0,
          color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
        );
      },
    );
  }
}
