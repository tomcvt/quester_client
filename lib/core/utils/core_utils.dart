import 'package:flutter/material.dart';

extension DismissibleSnackBar on ScaffoldMessengerState {
  void showDismissibleSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: hideCurrentSnackBar,
        ),
      ),
    );
  }
}
