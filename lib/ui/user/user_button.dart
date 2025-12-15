import 'package:flutter/material.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/user/login/login.dart';
import 'package:harmonoid/ui/user/logout/logout.dart';

class UserButton extends StatelessWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
      builder: (context, userNotifier, _) {
        final email = userNotifier.session?.user.email;

        return ActionChip(
          padding: const EdgeInsets.all(4.0),
          label: email == null ? Text(Localization.instance.LOGIN) : Text(Localization.instance.LOGOUT),
          onPressed: () => email == null ? showLogin(context) : showLogout(context),
        );
      },
    );
  }
}
