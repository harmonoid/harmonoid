import 'package:flutter/material.dart';

import 'package:harmonoid/ui/update/update_dialog.dart';

Future<bool> showUpdate(BuildContext context) async {
  final result = await showDialog<bool?>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const UpdateDialog(),
  );
  return result ?? false;
}
