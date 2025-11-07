import 'package:flutter/widgets.dart';
import 'package:identity/identity.dart';

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
      message = 'OTP Sent. Please check your email.';
      notifyListeners();
    } on AuthException catch (exception) {
      loading = false;
      error = exception.message;
      notifyListeners();
    } catch (exception) {
      loading = false;
      error = 'Couldn\'t send OTP.';
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
      message = 'OTP Verified.';
      notifyListeners();
      onSuccess?.call();
    } on AuthException catch (exception) {
      loading = false;
      error = exception.message;
      notifyListeners();
    } catch (exception) {
      loading = false;
      error = 'Couldn\'t verify OTP.';
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
