import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:nested_navigation_gorouter_example/beamer/beamer_scaffold_with_bottom_nav_bar.dart';

/// Entry point for the Beamer navigation example
/// Demonstrates complex nested navigation with bottom tabs
void main() {
  runApp(MyApp());
}

/// Main application widget using Beamer for navigation
/// Sets up the root router delegate with catch-all routing
class MyApp extends StatelessWidget {
  MyApp({super.key});

  /// Root router delegate that handles all navigation
  /// Uses a catch-all pattern '*' to route everything to the main scaffold
  final routerDelegate = BeamerDelegate(
    initialPath: '/a', // Start with tab A
    locationBuilder: RoutesLocationBuilder(
      routes: {
        // Catch-all route - all paths go to the main scaffold
        // The actual tab routing is handled by nested BeamerDelegates
        '*': (context, state, data) => const BeamerScaffoldWithBottomNavBar(),
      },
    ).call,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      // Main router delegate for the entire app
      routerDelegate: routerDelegate,
      // Beamer's route information parser for URL handling
      routeInformationParser: BeamerParser(),
      // Custom back button dispatcher for proper navigation history
      backButtonDispatcher: BeamerBackButtonDispatcher(
        delegate: routerDelegate,
      ),
    );
  }
}
