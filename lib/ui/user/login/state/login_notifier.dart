import 'package:flutter/widgets.dart';
import 'package:identity/identity.dart';

import 'package:harmonoid/localization/localization.dart';

class LoginNotifier extends ChangeNotifier {
  LoginNotifier({required this.userNotifier, this.onSuccess});

  final UserNotifier userNotifier;
  final VoidCallback? onSuccess;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool loading = false;
  bool otpSent = false;
  String? message;
  String? error;

  VoidCallback? get onPressed => loading
      ? null
      : () {
          if (otpSent) {
            _verify();
          } else {
            _authenticate();
          }
        };

  Future<void> _authenticate() async {
    if (!formKey.currentState!.validate()) return;

    loading = true;
    message = null;
    error = null;
    notifyListeners();

    try {
      await userNotifier.authenticate(emailController.text.trim());
      otpSent = true;
      loading = false;
      message = Localization.instance.OTP_SEND_SUCCESS;
      notifyListeners();
    } on AuthException catch (exception) {
      loading = false;
      error = exception.message;
      notifyListeners();
    } catch (exception) {
      loading = false;
      error = Localization.instance.OTP_SEND_FAILURE;
      notifyListeners();
    }
  }

  Future<void> _verify() async {
    if (!formKey.currentState!.validate()) return;

    loading = true;
    message = null;
    error = null;
    notifyListeners();

    try {
      await userNotifier.verify(emailController.text.trim(), otpController.text.trim());
      loading = false;
      message = Localization.instance.OTP_VERIFY_SUCCESS;
      notifyListeners();
      onSuccess?.call();
    } on AuthException catch (exception) {
      loading = false;
      error = exception.message;
      notifyListeners();
    } catch (exception) {
      loading = false;
      error = Localization.instance.OTP_VERIFY_FAILURE;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    otpController.dispose();
  }
}
