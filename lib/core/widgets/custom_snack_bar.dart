import 'package:flutter/material.dart';

enum SnackBarType {
  error,
  success,
}

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 3),
    String actionLabel = 'OK',
  }) {
    // Color for SnackBar based on type
    final backgroundColor =
        type == SnackBarType.error ? Colors.red : Colors.green;

    // SnackBar widget
    final snackBar = SnackBar(
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ) ??
            const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating, // Ensures SnackBar floats above FAB
      action: SnackBarAction(
        label: actionLabel,
        textColor: Colors.white,
        onPressed: onActionPressed ?? () {},
      ),
    );

    // Show the SnackBar
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
