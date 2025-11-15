import 'package:flutter/material.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/user/login/login.dart';
import 'package:harmonoid/ui/user/logout/logout.dart';
import 'package:harmonoid/utils/rendering.dart';

class UserButton extends StatelessWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
      builder: (context, userNotifier, _) {
        final email = userNotifier.session?.user.email;
        final maxWidth = isDesktop ? double.infinity : 200.0;
        final label = isDesktop ? email : email?.split('@').firstOrNull ?? email;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ActionChip(
            padding: const EdgeInsets.all(4.0),
            label: email == null
                ? Text(Localization.instance.LOGIN)
                : Text(
                    label ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface, overflow: TextOverflow.ellipsis),
                  ),
            onPressed: () => email == null ? showLogin(context) : showLogout(context),
          ),
        );
      },
    );
  }
}
