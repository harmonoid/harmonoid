import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/user/login/state/login_notifier.dart';
import 'package:harmonoid/ui/user/login/login_form.dart';
import 'package:harmonoid/utils/rendering.dart';

class LoginDialog extends StatelessWidget {
  const LoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginNotifier>(
      builder: (context, notifier, child) {
        return AlertDialog(
          icon: isMaterial3OrGreater ? const Icon(Icons.login) : null,
          title: Text(Localization.instance.LOGIN),
          content: const LoginForm(),
          actions: [
            TextButton(
              onPressed: notifier.onPressed,
              child: Text(notifier.otpSent ? label(Localization.instance.OTP_VERIFY) : label(Localization.instance.OTP_SEND)),
            ),
            TextButton(
              onPressed: context.pop,
              child: Text(label(Localization.instance.CANCEL)),
            ),
          ],
        );
      },
    );
  }
}
