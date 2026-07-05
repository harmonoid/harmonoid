import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/utils/rendering.dart';

Future<void> showLogout(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: isMaterial3OrGreater ? const Icon(Icons.logout) : null,
      title: Text(Localization.instance.LOGOUT),
      actions: [
        TextButton(
          onPressed: () {
            context.read<UserNotifier>().logout();
            context.pop();
          },
          child: Text(label(Localization.instance.LOGOUT)),
        ),
        TextButton(
          onPressed: context.pop,
          child: Text(label(Localization.instance.CANCEL)),
        ),
      ],
    ),
  );
}
