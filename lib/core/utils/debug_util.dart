import 'package:flutter/material.dart';

extension DebugSnackBar on ScaffoldMessengerState {
  void showDebugSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 30),
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
