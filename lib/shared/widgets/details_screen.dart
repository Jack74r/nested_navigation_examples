import 'package:flutter/material.dart';

/// The details screen for either the A or B screen.
class DetailsScreen extends StatefulWidget {
  /// Constructs a [DetailsScreen].
  const DetailsScreen({
    required this.label,
    this.onResetPressed,
    Key? key,
  }) : super(key: key);

  /// The label to display in the center of the screen.
  final String label;

  /// Optional callback for reset button (only shown for section B)
  final VoidCallback? onResetPressed;

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

/// The state for DetailsScreen
class DetailsScreenState extends State<DetailsScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details Screen - ${widget.label}"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Details for ${widget.label} - Counter: $_counter",
                style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
              child: const Text("Increment counter"),
            ),
            if (widget.onResetPressed != null) ...[
              const Padding(padding: EdgeInsets.all(8)),
              TextButton(
                onPressed: widget.onResetPressed,
                child: const Text("Reset to Section A"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
