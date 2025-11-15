import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/user/login/login_form.dart';
import 'package:harmonoid/ui/user/login/state/login_notifier.dart';
import 'package:harmonoid/utils/rendering.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(Localization.instance.LOGIN),
      ),
      body: Consumer<LoginNotifier>(
        builder: (context, notifier, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const LoginForm(),
              const SizedBox(height: 16.0),
              FilledButton(
                onPressed: notifier.onPressed,
                child: Text(label(notifier.otpSent ? Localization.instance.OTP_VERIFY : Localization.instance.OTP_SEND)),
              ),
            ],
          );
        },
      ),
    );
  }
}
