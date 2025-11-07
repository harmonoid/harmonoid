import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/ui/user/login/state/login_notifier.dart';
import 'package:harmonoid/ui/user/login/login_form.dart';

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
        title: const Text('Login'),
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
                child: Text(notifier.otpSent ? 'Verify OTP' : 'Send OTP'),
              ),
            ],
          );
        },
      ),
    );
  }
}
