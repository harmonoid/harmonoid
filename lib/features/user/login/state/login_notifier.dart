import 'package:flutter/widgets.dart';
import 'package:identity/identity.dart';

import 'package:harmonoid/localization/localization.dart';

class LoginNotifier extends ChangeNotifier {
  final UserNotifier userNotifier;
  final VoidCallback? onSuccess;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode otpFocusNode = FocusNode();
  bool otpSent = false;
  bool loading = false;
  String? message;
  String? error;

  LoginNotifier({required this.userNotifier, this.onSuccess}) {
    emailController.addListener(_emailControllerListener);
  }

  VoidCallback? get onPressed => loading ? null : submit;

  void submit() {
    if (otpSent) {
      _verify();
    } else {
      _authenticate();
    }
  }

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        otpFocusNode.requestFocus();
      });
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

  void _emailControllerListener() {
    if (otpSent) {
      otpSent = false;
      message = null;
      error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    otpController.dispose();
    emailFocusNode.dispose();
    otpFocusNode.dispose();
    emailController.removeListener(_emailControllerListener);
  }
}
