import 'package:flutter/material.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/user/login/login.dart';
import 'package:harmonoid/features/user/logout/logout.dart';

class UserButton extends StatelessWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
      builder: (context, userNotifier, _) {
        final email = userNotifier.session?.user.email;

        return ActionChip(
          onPressed: () => email == null ? showLogin(context) : showLogout(context),
          padding: const EdgeInsets.all(4.0),
          label: email == null ? Text(Localization.instance.LOGIN) : Text(Localization.instance.LOGOUT),
          labelStyle: Theme.of(context).textTheme.bodySmall,
        );
      },
    );
  }
}
