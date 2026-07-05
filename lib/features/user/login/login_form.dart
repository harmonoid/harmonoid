import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/user/login/state/login_notifier.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginNotifier>(
      builder: (context, notifier, child) {
        return SizedBox(
          width: kDesktopCenteredLayoutWidth / 2,
          child: Form(
            key: notifier.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextFormField(
                  controller: notifier.emailController,
                  focusNode: notifier.emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  enabled: !notifier.otpSent,
                  autofocus: true,
                  autocorrect: false,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(hintText: Localization.instance.EMAIL),
                  onFieldSubmitted: (_) => notifier.onPressed?.call(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return '';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                DefaultTextFormField(
                  controller: notifier.otpController,
                  focusNode: notifier.otpFocusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  enabled: notifier.otpSent,
                  autofocus: false,
                  autocorrect: false,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(hintText: Localization.instance.OTP),
                  onFieldSubmitted: (_) => notifier.onPressed?.call(),
                  validator: (value) {
                    if (!notifier.otpSent) return null;
                    if (value == null || value.trim().isEmpty) {
                      return '';
                    }
                    if (value.length != 6) {
                      return '';
                    }
                    return null;
                  },
                ),
                if (notifier.message != null)
                  IntrinsicWidth(
                    child: Card.outlined(
                      elevation: 0.0,
                      margin: const EdgeInsets.only(top: 16.0),
                      shape: isMaterial3OrGreater
                          ? null
                          : RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              side: BorderSide(color: Theme.of(context).dividerColor),
                            ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 16.0),
                            const SizedBox(width: 8.0),
                            Expanded(child: Text(notifier.message!, style: Theme.of(context).textTheme.bodyMedium)),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (notifier.error != null)
                  IntrinsicWidth(
                    child: Card.outlined(
                      elevation: 0.0,
                      margin: const EdgeInsets.only(top: 16.0),
                      shape: isMaterial3OrGreater
                          ? null
                          : RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              side: BorderSide(color: Theme.of(context).dividerColor),
                            ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error, size: 16.0),
                            const SizedBox(width: 8.0),
                            Expanded(child: Text(notifier.error!, style: Theme.of(context).textTheme.bodyMedium)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
