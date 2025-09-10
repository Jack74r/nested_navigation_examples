import 'package:flutter/material.dart';

/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatelessWidget {
  /// Creates a RootScreen
  const RootScreen({
    required this.label,
    required this.onDetailsPressed,
    Key? key,
  }) : super(key: key);

  /// The label
  final String label;

  /// Callback when details button is pressed
  final VoidCallback onDetailsPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tab root - $label"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Screen $label",
                style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              onPressed: onDetailsPressed,
              child: const Text("View details"),
            ),
          ],
        ),
      ),
    );
  }
}
