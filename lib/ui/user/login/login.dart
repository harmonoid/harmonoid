import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/ui/user/login/login_dialog.dart';
import 'package:harmonoid/ui/user/login/state/login_notifier.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:provider/provider.dart';

Future<void> showLogin(BuildContext context) {
  if (isDesktop) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => LoginNotifier(
          userNotifier: context.read(),
          onSuccess: context.pop,
        ),
        child: const LoginDialog(),
      ),
    );
  } else {
    return context.push<void>('/$kLoginPath');
  }
}
