import 'package:flutter/material.dart';

/// For entry points whose screen or backend is not built yet: say so instead of
/// opening a mock screen or doing nothing.
void showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('Coming soon')));
}
